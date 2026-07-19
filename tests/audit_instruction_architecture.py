#!/usr/bin/env python3
"""Deterministic, dependency-free audit of Pegasus lazy-loaded instructions."""

from __future__ import annotations

import argparse
import difflib
import hashlib
import json
import os
import re
import shutil
import statistics
import subprocess
import sys
import tempfile
import zipfile
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path


FORBIDDEN = "install_and_usage.txt"
REF_RE = re.compile(r"(?<![\w/])\.github/references/[A-Za-z0-9_./<>-]+\.md")
WORD_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9_'/-]*")
RESULT_RE = re.compile(r"PEGASUS_[A-Z0-9_]+_RESULT_V\d+")
PRECEDENCE_RE = re.compile(r"(?:precedence (?:is|order:)|current macro >)[^\n.]*", re.I)
SIMILARITY_THRESHOLD = 0.92

# These are the shipped, user-discoverable instruction entry points. Prompts
# are explicit so a stray backup file cannot silently gain graph authority.
CANONICAL_ROOTS = {
    ".github/agents/pegasus-orchestrator.agent.md": "primary user-facing coordinator",
    ".github/prompts/handoff.prompt.md": "shipped Handoff command",
    ".github/prompts/memory-update.prompt.md": "shipped Memory command",
    ".github/prompts/sdd-phases.prompt.md": "shipped SDD command",
}

# Budgets protect the eagerly loaded boundary. Exceptions must name a reason.
ROLE_BUDGETS = {
    "orchestrator": (50, 500),
    "specialist": (24, 390),
    "router": (18, 190),
    "global-fallback": (16, 180),
    "eager": (42, 480),
}
LENGTH_ALLOWLIST: dict[str, tuple[int, int, str]] = {
    # Empty by design. Add exact paths only after review, with a durable rationale.
}
ORPHAN_ALLOWLIST: dict[str, str] = {
    # Empty by design. Every detailed contract currently has a macro consumer.
}
DUPLICATE_ALLOWLIST = {
    "missing-reference": (
        re.compile(r"every exact path.*required.*missing or unreadable", re.I),
        "Fail-closed wording must remain literal across independently invoked specialists.",
    ),
    "precedence": (
        re.compile(r"(?:instruction )?precedence is:?.*current macro", re.I),
        "The authority order is an exact safety invariant at every execution boundary.",
    ),
    "no-false-success": (
        re.compile(r"never report .* that did not occur", re.I),
        "Each result boundary repeats the exact truthful-reporting warning intentionally.",
    ),
    "ordered-load-skeleton": (
        re.compile(r"load these workspace-root-relative references manually in exact order", re.I),
        "Independent specialist entry points must carry the same mandatory load skeleton.",
    ),
    "specialist-direct-execution": (
        re.compile(r"you own and execute the .* phase only, directly in this fresh context", re.I),
        "Specialists repeat the non-delegation boundary because each can be invoked directly.",
    ),
    "phase-scope-boundary": (
        re.compile(r"this manually loaded phase reference owns only the detailed", re.I),
        "Each phase contract repeats the same authority delimiter with its own phase name.",
    ),
    "result-scope-boundary": (
        re.compile(r"this manually loaded result reference owns only the .* phase-specific fields", re.I),
        "Each wire schema repeats the same authority delimiter with its own schema name.",
    ),
    "blocked-result-warning": (
        re.compile(r"for blocked, identify the first unmet gate and do not imply", re.I),
        "Every independently consumed result schema must preserve the blocked-result warning.",
    ),
    "managed-artifact-marker": (
        re.compile(r"preserve existing pegasus managed markers exactly", re.I),
        "Artifact editors require the same exact generated-marker safety rule.",
    ),
    "cross-change-isolation": (
        re.compile(r"consult another change only when the current prd", re.I),
        "Proposal and Spec intentionally share the exact cross-change isolation gate.",
    ),
}
EAGER_FORBIDDEN = re.compile(
    r"PEGASUS_[A-Z0-9_]+_RESULT|blocked-missing-reference|"
    r"exactly one (?:active |authorized )?(?:change|task-slice|evidence-scope)", re.I
)


@dataclass
class Report:
    errors: list[str] = field(default_factory=list)
    counts: Counter = field(default_factory=Counter)
    macros: list[int] = field(default_factory=list)

    def fail(self, category: str, message: str) -> None:
        self.errors.append(f"[{category}] {message}")
        self.counts[f"{category}_violations"] += 1


def text(path: Path) -> str:
    if path.name == FORBIDDEN:
        raise RuntimeError(f"restricted path read refused: {path}")
    return path.read_text(encoding="utf-8")


def instruction_files(root: Path) -> list[Path]:
    bases = [root / "templates/harness", root / "templates/copilot-global", root / "templates/cursor-global"]
    return sorted(
        path for base in bases if base.is_dir()
        for path in base.rglob("*")
        if path.is_file() and path.name != FORBIDDEN and path.suffix in {".md", ".mdc"}
        and "/docs/pegasus/" not in path.as_posix()
    )


def rel(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def frontmatter(content: str) -> tuple[dict[str, object], str]:
    lines = content.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, content
    try:
        end = lines.index("---", 1)
    except ValueError:
        return {}, content
    data: dict[str, object] = {}
    current = ""
    for line in lines[1:end]:
        match = re.match(r"^([\w-]+):\s*(.*)$", line)
        if match:
            current, value = match.groups()
            data[current] = value.strip(" '[]") if value else []
        elif current and re.match(r"^\s+-\s+", line):
            value = re.sub(r"^\s+-\s+", "", line).strip(" '\"")
            if not isinstance(data[current], list):
                data[current] = []
            data[current].append(value)
    raw_tools = data.get("tools", [])
    if isinstance(raw_tools, str):
        data["tools"] = [item.strip(" '\"") for item in raw_tools.split(",") if item.strip()]
    return data, "\n".join(lines[end + 1:]).strip()


def prose_without_fences(content: str) -> str:
    """Remove CommonMark-style fenced examples while preserving line breaks."""
    output: list[str] = []
    fence: tuple[str, int] | None = None
    for line in content.splitlines():
        marker = re.match(r"^ {0,3}(`{3,}|~{3,})(?:[^`]*)$", line)
        if fence is None and marker:
            token = marker.group(1)
            fence = token[0], len(token)
            output.append("")
        elif fence and re.match(rf"^ {{0,3}}{re.escape(fence[0])}{{{fence[1]},}}\s*$", line):
            fence = None
            output.append("")
        elif fence is None:
            output.append(line)
        else:
            output.append("")
    return "\n".join(output)


def role(path: Path, meta: dict[str, object], body: str) -> str | None:
    posix = path.as_posix()
    name = str(meta.get("name", path.name))
    tools = set(meta.get("tools", []))
    if "copilot-global" in posix or "cursor-global" in posix:
        return "global-fallback"
    if "/agents/" in posix:
        return "orchestrator" if "orchestrator" in name else "specialist"
    if "/prompts/" in posix:
        return "router"
    if "instructions" in path.name or path.name == "copilot-instructions.md" or path.name == "AGENTS.md":
        return "eager"
    if "agent" in tools and "execute" not in tools and "edit" not in tools:
        return "router"
    return None


def normalize_paragraphs(content: str) -> list[tuple[str, str]]:
    _, body = frontmatter(content)
    body = prose_without_fences(body)
    sections: list[tuple[str, str]] = []
    heading = "<body>"
    body = re.sub(r"(?m)^(#{1,6}\s+[^\n]+)\n(?=\S)", r"\1\n\n", body)
    for block in re.split(r"\n\s*\n", body):
        block = block.strip()
        if block.startswith("#"):
            heading = block.lstrip("# ")
            continue
        plain = re.sub(r"[`*_>#]", "", block)
        plain = re.sub(r"^\s*(?:[-*]|\d+\.)\s+", "", plain, flags=re.M)
        plain = re.sub(r"\s+", " ", plain).strip().lower()
        normative = re.search(r"\b(must(?: not)?|never|do not|required|shall|always|blocks?|stop|only)\b", plain)
        if normative and len(plain.split()) >= 8 and not block.lstrip().startswith("|"):
            sections.append((heading, plain))
    return sections


def duplicate_allowed(a: str, b: str) -> bool:
    return any(pattern.search(a) and pattern.search(b) for pattern, _ in DUPLICATE_ALLOWLIST.values())


def check_lengths_and_eager(root: Path, files: list[Path], report: Report) -> None:
    for path in files:
        content = text(path)
        meta, body = frontmatter(content)
        current_role = role(path, meta, body)
        if current_role is None or "/references/" in path.as_posix():
            continue
        key = rel(root, path)
        lines, words = len(content.splitlines()), len(WORD_RE.findall(content))
        report.counts[f"role_{current_role}"] += 1
        if current_role in {"orchestrator", "specialist", "router", "global-fallback"}:
            report.macros.append(words)
        line_limit, word_limit = ROLE_BUDGETS[current_role]
        if key in LENGTH_ALLOWLIST:
            line_limit, word_limit, reason = LENGTH_ALLOWLIST[key]
            if not reason.strip():
                report.fail("length", f"{key}: exception lacks rationale")
        if lines > line_limit:
            report.fail("length", f"{key}: lines actual={lines} limit={line_limit}")
        if words > word_limit:
            report.fail("length", f"{key}: words actual={words} limit={word_limit}")
        if current_role == "eager":
            report.counts["eager_words"] += words
            report.counts["eager_tokens_estimate"] += (len(content) + 3) // 4
            match = EAGER_FORBIDDEN.search(body)
            if match:
                report.fail("eager", f"{key}: embeds phase/result/transport detail {match.group(0)!r}")
    for path in files:
        if "/references/" not in path.as_posix():
            continue
        meta, _ = frontmatter(text(path))
        if "applyTo" in meta or "alwaysApply" in meta:
            report.fail("eager", f"{rel(root, path)}: reference declares a global apply surface")


def reference_key(root: Path, path: Path) -> str:
    marker = "templates/harness/"
    value = rel(root, path)
    return value.split(marker, 1)[1] if marker in value else value


def check_reference_graph(root: Path, files: list[Path], report: Report) -> None:
    refs = {reference_key(root, path): path for path in files if "/references/" in path.as_posix()}
    graph: dict[str, set[str]] = defaultdict(set)
    roots: set[str] = set()
    agents: dict[str, str] = {}
    consumers: Counter = Counter()
    prompt_inventory = {
        reference_key(root, path) for path in files
        if path.as_posix().startswith((root / "templates/harness/.github/prompts").as_posix() + "/")
    }
    declared_prompts = {path for path in CANONICAL_ROOTS if "/prompts/" in path}
    if prompt_inventory != declared_prompts:
        report.fail(
            "root-policy",
            f"prompt inventory drift added={sorted(prompt_inventory - declared_prompts)} "
            f"missing={sorted(declared_prompts - prompt_inventory)}",
        )
    for path in files:
        source = reference_key(root, path)
        meta, _ = frontmatter(text(path))
        if source in CANONICAL_ROOTS:
            if not meta.get("name") or str(meta.get("user-invocable", "true")).lower() == "false":
                report.fail("root-policy", f"{rel(root, path)}: canonical root is not discoverable")
            roots.add(source)
        if "/agents/" in path.as_posix() and meta.get("name"):
            agents[str(meta["name"])] = source
        for target in REF_RE.findall(text(path)):
            if "<" in target:
                continue
            graph[source].add(target)
            consumers[target] += 1
            if target not in refs:
                report.fail("reference", f"{rel(root, path)} -> {target}: missing")
    for path in files:
        source, content = reference_key(root, path), text(path)
        for name, target in agents.items():
            if source != target and re.search(rf"`{re.escape(name)}`|\b{re.escape(name)}\b", content):
                graph[source].add(target)
    reachable: set[str] = set()
    stack = sorted(roots, reverse=True)
    while stack:
        node = stack.pop()
        if node in reachable:
            continue
        reachable.add(node)
        stack.extend(sorted(graph[node] - reachable, reverse=True))
    for target, path in refs.items():
        if target not in reachable and target not in ORPHAN_ALLOWLIST:
            report.fail("orphan", f"{rel(root, path)}: no canonical root path reaches it")
        if consumers[target] == 0 and target not in ORPHAN_ALLOWLIST:
            report.fail("reference", f"{rel(root, path)}: no canonical consumer")
    report.counts["references_total"] = len(refs)
    report.counts["references_reachable"] = len(set(refs) & reachable)
    report.counts["references_orphan"] = len(set(refs) - reachable)
    report.counts["references_broken"] = report.counts["reference_violations"]

    mandatory = {source: targets & set(refs) for source, targets in graph.items() if source in refs}
    visiting: list[str] = []
    visited: set[str] = set()

    def visit(node: str) -> None:
        if node in visiting:
            cycle = visiting[visiting.index(node):] + [node]
            report.fail("cycle", " -> ".join(cycle))
            return
        if node in visited:
            return
        visiting.append(node)
        for child in sorted(mandatory.get(node, ())):
            visit(child)
        visiting.pop()
        visited.add(node)

    for node in sorted(mandatory):
        visit(node)
    report.counts["cycles"] = report.counts["cycle_violations"]


def check_duplicates(root: Path, files: list[Path], report: Report) -> None:
    items: list[tuple[Path, str, str]] = []
    for path in files:
        for section, paragraph in normalize_paragraphs(text(path)):
            items.append((path, section, paragraph))
    for index, (path_a, section_a, a) in enumerate(items):
        for path_b, section_b, b in items[index + 1:]:
            # The index slice prevents self-comparison; same-file entries are
            # distinct occurrences and must be checked like cross-file copies.
            if duplicate_allowed(a, b):
                continue
            if abs(len(a) - len(b)) > max(len(a), len(b)) * (1 - SIMILARITY_THRESHOLD):
                continue
            ratio = difflib.SequenceMatcher(None, a, b, autojunk=False).ratio()
            if ratio >= SIMILARITY_THRESHOLD:
                evidence = a[:100] + ("..." if len(a) > 100 else "")
                report.counts["duplicate_candidates"] += 1
                report.fail(
                    "duplicate",
                    f"{rel(root, path_a)}#{section_a} <-> {rel(root, path_b)}#{section_b}: "
                    f"similarity={ratio:.3f} threshold={SIMILARITY_THRESHOLD:.2f}; {evidence!r}",
                )


def precedence(content: str) -> tuple[str, ...] | None:
    match = PRECEDENCE_RE.search(content)
    if not match or ">" not in match.group(0):
        return None
    parts = []
    for part in match.group(0).split(">"):
        value = part.strip(" `:;.").lower()
        value = re.sub(r"^(?:instruction )?precedence is:?\s*", "", value)
        value = value.strip(" `:;.")
        value = re.split(r"[`;]", value, 1)[0].strip()
        parts.append(value)
    return tuple(parts)


def check_capabilities_and_contradictions(root: Path, files: list[Path], report: Report) -> None:
    owner_claims: dict[str, list[str]] = defaultdict(list)
    canonical_precedence: tuple[str, ...] | None = None
    for path in files:
        content = text(path)
        meta, body = frontmatter(content)
        prose = prose_without_fences(body)
        key = rel(root, path)
        tools = set(meta.get("tools", []))
        current_role = role(path, meta, body)
        if current_role in {"orchestrator", "router", "global-fallback"} and "agent" in tools:
            forbidden = tools & {"edit", "execute"}
            if forbidden:
                report.fail("capability", f"{key}: delegator has forbidden tools {sorted(forbidden)}")
        if current_role == "specialist":
            if "agent" in tools or re.search(r"\bdelegate|launch another agent\b", prose, re.I) and not re.search(r"do not (?:delegate|launch)", prose, re.I):
                report.fail("capability", f"{key}: specialist can recursively delegate")
        if current_role in {"orchestrator", "router"}:
            for sentence in re.split(r"(?<=[.!?])\s+|\n+", prose):
                if re.search(r"\b(?:must|shall|always)\s+(?:implement|edit|execute)\b|\b(?:implement|edit|execute) (?:the|phase|code)\b", sentence, re.I) and not re.search(r"\b(?:must not|never|do not)\b[^.!?]*(?:implement|edit|execute)", sentence, re.I):
                    report.fail("contradiction", f"{key}: local execute/edit imperative {sentence.strip()[:120]!r}")
                    break
        current = precedence(prose)
        if current:
            reduced = tuple(
                "phase reference" if item == "orchestration reference" else item
                for item in current if item not in {"result schema reference", "transport reference"}
            )
            canonical_precedence = canonical_precedence or reduced
            if reduced != canonical_precedence:
                report.fail("contradiction", f"{key}: precedence {current} conflicts with {canonical_precedence}")
        for sentence in re.split(r"(?<=[.!?])\s+", prose):
            if re.search(r"missing (?:exact |required |local )*reference", sentence, re.I) and re.search(r"\b(?:fallback|search)\b", sentence, re.I):
                if not re.search(r"do not search|no .*fallback|must block|return blocked|stop|never", sentence, re.I):
                    report.fail("contradiction", f"{key}: missing-reference rule permits search/fallback")
        if "global" in key and re.search(r"global (?:fallback )?(?:overrides?|weakens?) (?:the )?(?:workspace-)?local|local (?:authority )?is (?:optional|advisory)", prose, re.I):
            report.fail("contradiction", f"{key}: global fallback weakens local authority")
        identifiers = set(RESULT_RE.findall(prose))
        if len(identifiers) > 1:
            report.fail("contradiction", f"{key}: conflicting result identifiers {sorted(identifiers)}")
        for concern in ("routing", "persistence", "status", "result", "phase execution"):
            if re.search(rf"(?:own|owner of|owns)\s+(?:the\s+)?{re.escape(concern)}", prose, re.I):
                owner_claims[concern].append(key)
    for concern, owners in sorted(owner_claims.items()):
        if len(set(owners)) > 1:
            report.fail("contradiction", f"canonical concern {concern!r} has owners {sorted(set(owners))}")
    report.counts["capability_violations"] = report.counts["capability_violations"]


def managed_templates(root: Path) -> list[Path]:
    return sorted(
        path for base in (root / "templates/harness", root / "templates/copilot-global", root / "templates/cursor-global")
        for path in base.rglob("*") if path.is_file() and path.name != FORBIDDEN
    )


def compare_bytes(expected: bytes, actual: bytes, label: str, report: Report) -> None:
    if expected != actual:
        report.fail("equivalence", f"{label}: byte mismatch expected_sha256={hashlib.sha256(expected).hexdigest()[:12]} actual_sha256={hashlib.sha256(actual).hexdigest()[:12]}")


def check_generated_tree(root: Path, target: Path, report: Report) -> None:
    sys.path.insert(0, str(root))
    from pegasus_harness_bootstrap.cli import render_copilot_global_template, render_global_template, render_template
    from pegasus_harness_bootstrap.manifest import render_workspace_content

    harness = root / "templates/harness"
    memory_root = target.parent / "memory"
    memory_script, memory_cwd = (memory_root / "dist/bin/pegasus-memory-mcp.js").resolve(), memory_root.resolve()
    for source in sorted(path for path in harness.rglob("*") if path.is_file()):
            relative = source.relative_to(harness)
            if relative.as_posix() == ".pegasus-bootstrap-ia/manifest.json":
                continue
            rendered = render_workspace_content(render_template(text(source), "audit-project", target, memory_script, memory_cwd), relative) + "\n"
            actual = target / relative
            if not actual.is_file():
                report.fail("equivalence", f"generated:{relative}: missing")
            else:
                compare_bytes(rendered.encode(), actual.read_bytes(), f"generated:{relative}", report)


def check_generated_and_globals(root: Path, report: Report) -> None:
    sys.path.insert(0, str(root))
    from pegasus_harness_bootstrap.cli import render_copilot_global_template, render_global_template

    with tempfile.TemporaryDirectory(prefix="pegasus-instruction-audit-") as temp_name:
        temp = Path(temp_name)
        target, home, xdg = temp / "workspace", temp / "home", temp / "xdg"
        home.mkdir(); xdg.mkdir()
        env = os.environ | {"HOME": str(home), "XDG_CONFIG_HOME": str(xdg), "PEGASUS_MEMORY_MCP_SKIP_INSTALL": "1", "PEGASUS_MEMORY_MCP_ROOT": str(temp / "memory")}
        command = [sys.executable, str(root / "bin/pegasus-harness-bootstrap"), "--project-name", "audit-project", "--target-path", str(target), "--install-copilot-global", "--install-cursor-global"]
        result = subprocess.run(command, input="yes\n", text=True, capture_output=True, env=env, cwd=root)
        if result.returncode:
            report.fail("equivalence", f"normal bootstrap failed exit={result.returncode}: {result.stderr.strip()}")
            return
        check_generated_tree(root, target, report)
        for template, installed, renderer, label in (
            (root / "templates/copilot-global", xdg / "pegasus-ia/copilot", render_copilot_global_template, "copilot-global"),
            (root / "templates/cursor-global", xdg / "Cursor/User/rules", render_global_template, "cursor-global"),
        ):
            for source in sorted(template.rglob("*")):
                if source.is_file():
                    relative = source.relative_to(template)
                    compare_bytes((renderer(text(source)) + "\n").encode(), (installed / relative).read_bytes(), f"{label}:{relative}", report)


def check_wheel_archive(root: Path, wheel: Path, report: Report) -> None:
    expected = {source.relative_to(root / "templates").as_posix(): source.read_bytes() for source in managed_templates(root)}
    with zipfile.ZipFile(wheel) as archive:
        suffix_map = {name.split("/templates/", 1)[1]: name for name in archive.namelist() if "/templates/" in name and not name.endswith("/")}
        for relative in sorted(set(expected) | set(suffix_map)):
            if relative not in expected or relative not in suffix_map:
                report.fail("package", f"{wheel}: nested path mismatch: {relative}")
            elif archive.read(suffix_map[relative]) != expected[relative]:
                report.fail("package", f"{wheel}: byte mismatch: {relative}")


def check_wheel(root: Path, report: Report) -> None:
    with tempfile.TemporaryDirectory(prefix="pegasus-wheel-audit-") as temp_name:
        dist = Path(temp_name)
        result = subprocess.run([sys.executable, "-m", "pip", "wheel", "--no-deps", "--wheel-dir", str(dist), str(root)], capture_output=True, text=True)
        if result.returncode:
            report.fail("package", f"wheel build failed exit={result.returncode}: {result.stderr.strip()}")
            return
        wheel = next(dist.glob("*.whl"), None)
        if wheel is None:
            report.fail("package", "wheel build produced no wheel")
            return
        check_wheel_archive(root, wheel, report)
        shutil.rmtree(root / "build", ignore_errors=True)
        shutil.rmtree(root / "pegasus_ia_bootstrap.egg-info", ignore_errors=True)


def static_audit(root: Path) -> Report:
    report = Report()
    files = instruction_files(root)
    check_lengths_and_eager(root, files, report)
    check_reference_graph(root, files, report)
    check_duplicates(root, files, report)
    check_capabilities_and_contradictions(root, files, report)
    report.counts["instruction_files"] = len(files)
    return report


def negative_self_tests(root: Path) -> list[str]:
    cases = {
        "length": ("templates/harness/.github/prompts/sdd-phases.prompt.md", "\n" + "MUST stop.\n" * 20),
        "broken-reference": ("templates/harness/.github/agents/sdd-apply.agent.md", "\nLoad `.github/references/phases/not-there.md`.\n"),
        "orphan-reference": ("templates/harness/.github/references/phases/orphan.md", "# Orphan\n\nMUST remain unreachable.\n"),
        "duplicate": ("templates/harness/.github/references/phases/duplicate.md", "# Duplicate\n\nThe coordinator MUST frobnicate the exact canonical target before any irreversible operation and stop when evidence is absent.\n\nThe coordinator MUST frobnicate the exact canonical target before any irreversible operation and stop when evidence is absent.\n"),
        "contradiction": ("templates/harness/.github/agents/sdd-apply.agent.md", "\nInstruction precedence is: global fallback > current macro > shared reference.\n"),
        "cycle": ("templates/harness/.github/references/shared/authority.md", "\nLoad `.github/references/shared/phase-common.md`.\n"),
        "eager": ("templates/harness/.github/copilot-instructions.md", "\nOutput `PEGASUS_APPLY_RESULT_V1`.\n"),
        "capability": ("templates/harness/.github/prompts/sdd-phases.prompt.md", None),
        "imperative-contradiction": ("templates/harness/.github/prompts/sdd-phases.prompt.md", "\nAlways execute the code before routing.\n"),
    }
    expected = {"length": "[length]", "broken-reference": "[reference]", "orphan-reference": "[orphan]", "duplicate": "[duplicate]", "contradiction": "[contradiction]", "cycle": "[cycle]", "eager": "[eager]", "capability": "[capability]", "imperative-contradiction": "[contradiction]"}
    passed: list[str] = []
    script = Path(__file__).resolve()
    with tempfile.TemporaryDirectory(prefix="pegasus-audit-negative-") as temp_name:
        temp = Path(temp_name)
        for name, (relative, addition) in cases.items():
            fixture = temp / name
            shutil.copytree(root / "templates", fixture / "templates")
            target = fixture / relative
            if name == "capability":
                target.write_text(text(target).replace("  - agent", "  - agent\n  - execute"), encoding="utf-8")
            elif name == "duplicate":
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(addition or "", encoding="utf-8")
            elif name == "orphan-reference":
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(addition or "", encoding="utf-8")
                backup = fixture / "templates/harness/.github/prompts/unused-backup.prompt.md"
                backup.write_text("---\nname: unused-backup\n---\n\nLoad `.github/references/phases/orphan.md`.\n", encoding="utf-8")
            elif name == "contradiction":
                target.write_text(text(target).replace("current macro > phase reference", "global fallback > current macro"), encoding="utf-8")
            elif name == "cycle":
                target.write_text(text(target) + addition, encoding="utf-8")
                other = fixture / "templates/harness/.github/references/shared/phase-common.md"
                other.write_text(text(other) + "\nLoad `.github/references/shared/authority.md`.\n", encoding="utf-8")
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text((text(target) if target.exists() else "") + (addition or ""), encoding="utf-8")
            result = subprocess.run([sys.executable, str(script), "--root", str(fixture), "--static-only"], text=True, capture_output=True)
            diagnostics = result.stdout + result.stderr
            if result.returncode == 0 or expected[name] not in diagnostics or Path(relative).name not in diagnostics:
                raise AssertionError(f"negative CLI test {name} failed proof: exit={result.returncode}\n{diagnostics}")
            passed.append(name)
        fenced = temp / "fenced-control"
        shutil.copytree(root / "templates", fenced / "templates")
        target = fenced / "templates/harness/.github/prompts/sdd-phases.prompt.md"
        meta = text(target).split("---", 2)[1]
        target.write_text(f"---{meta}---\n\n# SDD router\nLaunch `pegasus-orchestrator`.\n```text\nAlways execute the code before routing.\n```\n~~~shell\nAlways edit the phase locally.\n~~~\n", encoding="utf-8")
        result = subprocess.run([sys.executable, str(script), "--root", str(fenced), "--static-only"], text=True, capture_output=True)
        if result.returncode or "[contradiction]" in result.stdout + result.stderr:
            raise AssertionError(f"fenced imperative control failed: exit={result.returncode}\n{result.stdout}{result.stderr}")
        passed.append("fenced-imperative-control")
        generated, home, xdg = temp / "generated", temp / "home", temp / "xdg"
        home.mkdir(); xdg.mkdir()
        env = os.environ | {"HOME": str(home), "XDG_CONFIG_HOME": str(xdg), "PEGASUS_MEMORY_MCP_SKIP_INSTALL": "1", "PEGASUS_MEMORY_MCP_ROOT": str(temp / "memory")}
        setup = subprocess.run([sys.executable, str(root / "bin/pegasus-harness-bootstrap"), "--project-name", "audit-project", "--target-path", str(generated)], input="yes\n", text=True, capture_output=True, env=env)
        if setup.returncode:
            raise AssertionError(f"generated negative setup failed: {setup.stderr}")
        victim = generated / ".github/references/phases/apply.md"
        victim.write_text(text(victim) + "\nMUTATED GENERATED OUTPUT\n", encoding="utf-8")
        result = subprocess.run([sys.executable, str(script), "--root", str(root), "--generated-root", str(generated)], text=True, capture_output=True)
        if result.returncode == 0 or "[equivalence]" not in result.stderr or str(victim.relative_to(generated)) not in result.stderr:
            raise AssertionError(f"generated CLI mutation escaped: {result.stderr}")
        passed.append("generated-equivalence")

        dist = temp / "dist"; dist.mkdir()
        build = subprocess.run([sys.executable, "-m", "pip", "wheel", "--no-deps", "--wheel-dir", str(dist), str(root)], text=True, capture_output=True)
        if build.returncode:
            raise AssertionError(f"package negative setup failed: {build.stderr}")
        wheel, mutated = next(dist.glob("*.whl")), temp / "mutated.whl"
        with zipfile.ZipFile(wheel) as source, zipfile.ZipFile(mutated, "w") as target_zip:
            for info in source.infolist():
                data = source.read(info.filename)
                if info.filename.endswith("/templates/harness/.github/references/phases/apply.md"):
                    data += b"\nMUTATED PACKAGE CONTENT\n"
                target_zip.writestr(info, data)
        result = subprocess.run([sys.executable, str(script), "--root", str(root), "--wheel-file", str(mutated)], text=True, capture_output=True)
        if result.returncode == 0 or "[package]" not in result.stderr or "phases/apply.md" not in result.stderr:
            raise AssertionError(f"package CLI mutation escaped: {result.stderr}")
        passed.append("package")
        shutil.rmtree(root / "build", ignore_errors=True)
        shutil.rmtree(root / "pegasus_ia_bootstrap.egg-info", ignore_errors=True)
    return passed


def print_report(report: Report) -> None:
    roles = ", ".join(f"{name.removeprefix('role_')}={count}" for name, count in sorted(report.counts.items()) if name.startswith("role_"))
    median = int(statistics.median(report.macros)) if report.macros else 0
    maximum = max(report.macros, default=0)
    print(f"Files by role: {roles}; instruction_files={report.counts['instruction_files']}")
    print(f"Eager: words={report.counts['eager_words']} tokens_estimate={report.counts['eager_tokens_estimate']}; macros words max={maximum} median={median}")
    print(f"References: total={report.counts['references_total']} reachable={report.counts['references_reachable']} orphan={report.counts['references_orphan']} broken={report.counts['references_broken']}")
    print(f"Candidates: duplicates={report.counts['duplicate_candidates']} cycles={report.counts['cycles']} capability_violations={report.counts['capability_violations']}")
    print(f"Mismatches: package={report.counts['package_violations']} generated/global={report.counts['equivalence_violations']}")
    for error in sorted(report.errors):
        print(error, file=sys.stderr)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--self-test", action="store_true", help="Run isolated negative fixtures for every blocking category.")
    parser.add_argument("--static-only", action="store_true", help="Run only source instruction checks.")
    parser.add_argument("--generated-root", type=Path, help="Audit an existing generated workspace against canonical source.")
    parser.add_argument("--wheel-file", type=Path, help="Audit an existing wheel against canonical source.")
    args = parser.parse_args()
    root = args.root.resolve()
    report = static_audit(root)
    if not report.errors and args.generated_root:
        check_generated_tree(root, args.generated_root.resolve(), report)
    elif not report.errors and args.wheel_file:
        check_wheel_archive(root, args.wheel_file.resolve(), report)
    elif not report.errors and not args.static_only:
        check_generated_and_globals(root, report)
        check_wheel(root, report)
    if args.self_test:
        passed = negative_self_tests(root)
        print(f"Negative self-tests: {len(passed)} passed ({', '.join(passed)})")
    print_report(report)
    if report.errors:
        return 1
    print("Instruction architecture audit passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
