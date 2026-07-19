#!/usr/bin/env python3
"""Deterministic contract probes for the pre-change root PRD runtime boundary."""

from __future__ import annotations

import json
import os
import secrets
import subprocess
import sys
import tempfile
from pathlib import Path


def require(content: str, *needles: str) -> None:
    for needle in needles:
        assert needle in content, needle


def dispatch_allowed(project: str | None, launch: str | None, duplicate: str | None) -> bool:
    return bool(project and launch == f"{project}:prd:root" and duplicate == "not-started")


def specialist_actions(
    manifest_project: str,
    payload_project: str | None,
    payload_launch: str | None,
    material_gaps: list[str],
) -> tuple[str, list[str], list[str]]:
    identity_matches = (
        payload_project == manifest_project
        and payload_launch == f"{manifest_project}:prd:root"
    )
    if not identity_matches:
        return "blocked-identity", [], []
    if material_gaps:
        return "awaiting-input", [], material_gaps
    return "drafted", ["edit:docs/pegasus/prd.md", f"ensure_project:{manifest_project}",
                       f"record_artifact:{manifest_project}", f"record_observation:{manifest_project}"], []


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    token = secrets.token_hex(8)
    project = f"fixture-{token}"
    product = f"Atlas-{secrets.token_hex(7)}"
    assert project not in product and product not in project

    with tempfile.TemporaryDirectory(prefix="pegasus-prd-contract-") as temp_name:
        target = Path(temp_name) / "workspace-unrelated-to-identities"
        env = os.environ | {
            "PEGASUS_MEMORY_MCP_SKIP_INSTALL": "1",
            "PEGASUS_MEMORY_MCP_ROOT": str(Path(temp_name) / "memory"),
        }
        result = subprocess.run(
            [sys.executable, str(root / "bin/pegasus-harness-bootstrap"),
             "--project-name", project, "--target-path", str(target)],
            input="yes\n", text=True, capture_output=True, env=env, cwd=root,
        )
        assert result.returncode == 0, result.stderr

        manifest = json.loads((target / ".pegasus-bootstrap-ia/manifest.json").read_text())
        canonical = manifest["workspace"]["project_name"]
        assert canonical == project
        launch = f"{canonical}:prd:root"

        routing = (target / ".github/references/orchestration/routing.md").read_text()
        specialist = (target / ".github/agents/doc-designer.agent.md").read_text()
        phase = (target / ".github/references/phases/prd.md").read_text()
        prd_result = (target / ".github/references/results/prd-result-v1.md").read_text()
        orchestrator_result = (target / ".github/references/results/orchestrator-result-v1.md").read_text()

        require(routing, "`workspace.project_name` as the canonical project key",
                "`<canonical-project-key>:prd:root`",
                "exact canonical project key and launch identity as explicit payload fields",
                "do not authorize Proposal")
        require(specialist, "dispatch payload's exact canonical project key and launch identity",
                "never derive project identity from product prose, title, or path")
        require(phase, "Before any artifact edit or persistence",
                "return a blocked awaiting-input result",
                "root PRD persistence does not require `ensure_change`",
                "do not invent questions and proceed")
        require(prd_result, "compatible blocked-state specialization",
                "artifact edit not run: awaiting product input")
        require(orchestrator_result, "Launch identity: <project:prd:root|change:phase[:slice]|not established>",
                "valid PRD awaiting-input result is surfaced as `blocked`")
        assert "git diff" not in phase.lower()

        assert not dispatch_allowed(None, None, None)
        assert not dispatch_allowed(canonical, None, "not-started")
        assert not dispatch_allowed(canonical, launch, None)
        assert not dispatch_allowed(canonical, launch, "in-progress")
        assert dispatch_allowed(canonical, launch, "not-started")

        invented = product.lower()
        state, writes, questions = specialist_actions(canonical, invented, f"{invented}:prd:root", [])
        assert (state, writes, questions) == ("blocked-identity", [], [])

        gaps = ["Which moons are included?", "Guided or free default?", "What reading level?"]
        state, writes, questions = specialist_actions(canonical, canonical, launch, gaps)
        assert state == "awaiting-input" and writes == [] and questions == gaps

        state, writes, questions = specialist_actions(canonical, canonical, launch, [])
        assert state == "drafted" and not questions
        assert writes == ["edit:docs/pegasus/prd.md", f"ensure_project:{canonical}",
                          f"record_artifact:{canonical}", f"record_observation:{canonical}"]
        assert all(product.lower() not in write for write in writes)
        assert not any("ensure_change" in write for write in writes)

    print("PRD runtime contract probes passed.")


if __name__ == "__main__":
    main()
