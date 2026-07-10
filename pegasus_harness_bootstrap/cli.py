"""Bootstrap a Pegasus VS Code/Copilot harness into a target workspace."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

from pegasus_harness_bootstrap.manifest import (
    MANIFEST_RELATIVE_PATH,
    OWNERSHIP_MARKER,
    build_manifest,
    classify_manifest_path,
    file_record,
    is_safe_sync_managed_path,
    manifest_file_records,
    render_workspace_content,
    update_manifest_for_sync,
    write_manifest,
)


DEFAULT_ROOT = Path("/var/www/html/personal")
PROJECT_NAME_RE = re.compile(r"^[A-Za-z0-9._-]+$")
GLOBAL_MARKER = "PEGASUS-CURSOR-GLOBAL"
COPILOT_GLOBAL_MARKER = "PEGASUS-COPILOT-GLOBAL"
GLOBAL_TEMPLATE_VERSION = "1"
COPILOT_SETTINGS_KEYS = (
    ("chat.agentFilesLocations", "agents"),
    ("chat.instructionsFilesLocations", "instructions"),
    ("chat.promptFilesLocations", "prompts"),
)
COPILOT_SURFACES = (
    ".vscode/",
    ".github/",
    ".github/copilot-instructions.md",
    ".github/instructions/",
    ".github/prompts/",
    ".github/agents/",
)
WORKSPACE_SURFACES = COPILOT_SURFACES + (
    "AGENTS.md",
    "docs/pegasus/",
    ".cursor/",
)
PLANNED_WORKSPACE_FILES = (
    Path(".github/copilot-instructions.md"),
)
MEMORY_MCP_PACKAGE = "pegasus-memory-mcp"
MEMORY_MCP_REPOSITORY = "https://github.com/balerdis/pegasus-memory-mcp.git"
MEMORY_MCP_BRANCH = "stable/0.1.1"
MEMORY_MCP_DEFAULT_ROOT = Path("/home/serg/ia-scripts/pegasus-memory-mcp")
MEMORY_MCP_SCRIPT_RELATIVE_PATH = Path("dist/bin/pegasus-memory-mcp.js")
MEMORY_MCP_UNAVAILABLE_WARNING = (
    "El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, "
    "no se guardara nada de lo que hagamos en memoria persistente"
)


@dataclass(frozen=True)
class MemoryMcpResolution:
    script_path: Path
    cwd: Path
    source: str
    warning: str | None = None


@dataclass(frozen=True)
class WorkspaceTarget:
    project_name: str
    root: Path


SyncState = Literal["create", "updateable", "conflict", "untouched", "obsolete"]


@dataclass(frozen=True)
class SyncPlanItem:
    rel_path: Path
    state: SyncState
    reason: str = ""


@dataclass(frozen=True)
class MemoryCleanupPlan:
    label: str
    command: list[str]
    cwd: Path | None = None


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="pegasus-harness-bootstrap",
        description="Configure a local Pegasus VS Code/Copilot harness in a target workspace.",
    )
    parser.add_argument(
        "--project-name",
        help="Project name used for defaults and template tokens.",
    )
    parser.add_argument(
        "--target-path",
        help="Target workspace path. Defaults to /var/www/html/personal/<project-name>.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned writes and conflicts without changing files.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Replace existing known harness files.",
    )
    parser.add_argument(
        "--install-copilot-global",
        action="store_true",
        help="Install or update opt-in global VS Code/Copilot user assets and settings with backups.",
    )
    parser.add_argument(
        "--vscode-target",
        choices=("stable", "insiders"),
        default="stable",
        help="VS Code target for Copilot global configuration planning: stable or insiders.",
    )
    parser.add_argument(
        "--install-cursor-global",
        action="store_true",
        help="Legacy: install or update opt-in global Cursor user rules with backups.",
    )
    parser.add_argument(
        "--install-memory-mcp",
        action="store_true",
        help="Plan the default Pegasus Memory MCP workspace stdio setup explicitly.",
    )
    parser.add_argument(
        "--uninstall",
        action="store_true",
        help="Alias for --uninstall-workspace; remove Pegasus-managed workspace files recorded in the manifest.",
    )
    parser.add_argument(
        "--uninstall-workspace",
        action="store_true",
        help="Remove Pegasus-managed workspace files recorded in the manifest.",
    )
    parser.add_argument(
        "--reset-memory-project",
        action="store_true",
        help="With workspace uninstall, delegate project memory reset to pegasus-memory-mcp.",
    )
    parser.add_argument(
        "--purge-memory",
        action="store_true",
        help="With workspace uninstall, delegate total Pegasus Memory purge to pegasus-memory-mcp.",
    )
    parser.add_argument(
        "--memory-cli-command",
        help=(
            "Override memory cleanup delegation command. Pass an executable path/name or a .js entrypoint; "
            ".js paths are invoked with node."
        ),
    )
    parser.add_argument(
        "--sync-workspace",
        action="store_true",
        help="Update safe Pegasus-managed files in the current workspace using manifest checksum evidence.",
    )
    parser.add_argument(
        "--overwrite-conflicts",
        action="store_true",
        help="During --sync-workspace, back up and replace user-modified Pegasus-managed conflicts.",
    )
    parser.add_argument(
        "--uninstall-copilot-global",
        action="store_true",
        help="Remove Pegasus-managed global VS Code/Copilot assets and settings entries with backups.",
    )
    parser.add_argument(
        "--new-change",
        metavar="CHANGE_ID",
        help="Create a new Pegasus change with only docs/pegasus/changes/<change-id>/prd.md.",
    )
    return parser.parse_args(argv)


def fail(message: str, exit_code: int = 1) -> None:
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(exit_code)


def validate_project_name(project_name: str) -> None:
    if project_name in {"", ".", ".."} or "/" in project_name or " " in project_name:
        fail("project name must be non-empty and contain no spaces or slashes")
    if not PROJECT_NAME_RE.fullmatch(project_name):
        fail("project name may contain only letters, numbers, dot, underscore, and hyphen")


def validate_change_id(change_id: str) -> None:
    if change_id in {"", ".", ".."} or "/" in change_id or " " in change_id:
        fail("change id must be non-empty and contain no spaces or slashes")
    if not PROJECT_NAME_RE.fullmatch(change_id):
        fail("change id may contain only letters, numbers, dot, underscore, and hyphen")


def target_path_for(project_name: str | None, target_path: str | None) -> Path:
    if project_name is None and target_path is None:
        fail("--project-name is required unless --target-path is provided")
    target = Path(target_path).expanduser() if target_path else DEFAULT_ROOT / project_name
    if str(target) == "/":
        fail("target path cannot be /")
    return target


def confirm_missing_explicit_target(target: Path) -> None:
    print(f"Explicit target path does not exist: {target}")
    try:
        answer = input("Create this target path and write Pegasus harness files? Type yes to continue: ")
    except EOFError:
        fail(f"target path creation requires confirmation: {target}")
    if answer.strip().lower() not in {"y", "yes"}:
        fail(f"target path creation cancelled: {target}")


def change_target_path_for(target_path: str | None) -> Path:
    target = Path(target_path).expanduser() if target_path else Path.cwd()
    if str(target) == "/":
        fail("target path cannot be /")
    return target


def template_base() -> Path:
    project_root = Path(__file__).resolve().parents[1]
    source_templates = project_root / "templates"
    if source_templates.is_dir():
        return source_templates

    installed_templates = Path(sys.prefix) / "share" / "pegasus-ia-bootstrap" / "templates"
    if installed_templates.is_dir():
        return installed_templates

    fail(f"template root not found: {source_templates} or {installed_templates}")


def template_root() -> Path:
    root = template_base() / "harness"
    if not root.is_dir():
        fail(f"template root not found: {root}")
    return root


def cursor_global_template_root() -> Path:
    root = template_base() / "cursor-global"
    if not root.is_dir():
        fail(f"global Cursor template root not found: {root}")
    return root


def copilot_global_template_root() -> Path:
    root = template_base() / "copilot-global"
    if not root.is_dir():
        fail(f"global Copilot template root not found: {root}")
    return root


def template_files(root: Path) -> list[Path]:
    files = sorted(path.relative_to(root) for path in root.rglob("*") if path.is_file())
    if not files:
        fail(f"no template files found in {root}")
    return files


def workspace_inventory_files(files: list[Path]) -> list[Path]:
    return sorted(set(files).union(PLANNED_WORKSPACE_FILES))


def detect_cursor_rules_dir() -> tuple[Path, str | None]:
    home = Path.home()
    legacy_rules = home / ".cursor" / "rules"
    if legacy_rules.exists():
        return legacy_rules, f"Existing legacy Cursor rules path detected and preferred: {legacy_rules}"

    xdg_config_home = None
    if "XDG_CONFIG_HOME" in os.environ:
        xdg_config_home = Path(os.environ["XDG_CONFIG_HOME"]).expanduser()

    if xdg_config_home is not None:
        return xdg_config_home / "Cursor" / "User" / "rules", None

    return home / ".config" / "Cursor" / "User" / "rules", None


def xdg_config_root() -> Path:
    if "XDG_CONFIG_HOME" in os.environ:
        return Path(os.environ["XDG_CONFIG_HOME"]).expanduser()
    return Path.home() / ".config"


def copilot_managed_root() -> Path:
    return xdg_config_root() / "pegasus-ia" / "copilot"


def vscode_settings_path(vscode_target: str) -> Path:
    app_dir = "Code - Insiders" if vscode_target == "insiders" else "Code"
    return xdg_config_root() / app_dir / "User" / "settings.json"


def memory_mcp_default_root() -> Path:
    override = os.environ.get("PEGASUS_MEMORY_MCP_ROOT")
    return Path(override).expanduser() if override else MEMORY_MCP_DEFAULT_ROOT


def memory_mcp_default_script_path() -> Path:
    return (memory_mcp_default_root() / MEMORY_MCP_SCRIPT_RELATIVE_PATH).resolve()


def memory_mcp_root_from_script(script_path: Path) -> Path:
    if tuple(script_path.parts[-len(MEMORY_MCP_SCRIPT_RELATIVE_PATH.parts) :]) == MEMORY_MCP_SCRIPT_RELATIVE_PATH.parts:
        return script_path.parents[len(MEMORY_MCP_SCRIPT_RELATIVE_PATH.parts) - 1]
    return script_path.parent


def memory_mcp_path_script() -> Path | None:
    for binary in (MEMORY_MCP_PACKAGE, "pegasus-memory-mcp.js"):
        found = shutil.which(binary)
        if found is None:
            continue
        resolved = Path(found).resolve()
        if resolved.name == MEMORY_MCP_SCRIPT_RELATIVE_PATH.name and resolved.is_file():
            return resolved
    return None


def run_memory_mcp_command(command: list[str], cwd: Path) -> bool:
    try:
        subprocess.run(command, cwd=cwd, check=True)
    except (OSError, subprocess.CalledProcessError):
        return False
    return True


def memory_cleanup_suffix(project_name: str, *, reset_project: bool, purge: bool, dry_run: bool) -> tuple[str, list[str]] | None:
    if reset_project:
        command = ["reset", "--project", project_name]
        command.append("--dry-run" if dry_run else "--yes")
        return "Pegasus Memory project reset", command
    if purge:
        command = ["purge", "--all"]
        command.append("--dry-run" if dry_run else "--yes-i-understand-this-deletes-data")
        return "Pegasus Memory total purge", command
    return None


def command_from_memory_cli_override(memory_cli_command: str) -> list[str]:
    candidate = Path(memory_cli_command).expanduser()
    command_text = str(candidate) if candidate != Path(memory_cli_command) else memory_cli_command
    if command_text.endswith(".js"):
        return ["node", command_text]
    return [command_text]


def command_from_workspace_mcp_config(target: Path) -> tuple[list[str], Path | None] | None:
    config_path = target / ".vscode" / "mcp.json"
    if not config_path.exists():
        return None
    try:
        config = json.loads(config_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return None
    if not isinstance(config, dict):
        return None
    servers = config.get("servers")
    if not isinstance(servers, dict):
        return None
    server = servers.get(MEMORY_MCP_PACKAGE)
    if not isinstance(server, dict):
        return None
    raw_command = server.get("command")
    raw_args = server.get("args", [])
    raw_cwd = server.get("cwd")
    if not isinstance(raw_command, str):
        return None
    if not isinstance(raw_args, list) or not all(isinstance(arg, str) for arg in raw_args):
        return None
    cwd = Path(raw_cwd).expanduser() if isinstance(raw_cwd, str) and raw_cwd else None

    command_name = Path(raw_command).name
    if command_name == "node" and raw_args and raw_args[0].endswith(".js"):
        return [raw_command, raw_args[0]], cwd
    if MEMORY_MCP_PACKAGE in command_name and not any(arg in {"stdio", "--stdio", "serve", "server"} for arg in raw_args):
        return [raw_command, *raw_args], cwd
    return None


def resolve_memory_cleanup_base_command(target: Path, memory_cli_command: str | None) -> tuple[list[str], Path | None] | None:
    if memory_cli_command:
        return command_from_memory_cli_override(memory_cli_command), None
    if shutil.which(MEMORY_MCP_PACKAGE) is not None:
        return [MEMORY_MCP_PACKAGE], None
    return command_from_workspace_mcp_config(target)


def memory_cleanup_plan(
    project_name: str,
    *,
    reset_project: bool,
    purge: bool,
    dry_run: bool,
    target: Path,
    memory_cli_command: str | None,
) -> MemoryCleanupPlan | None:
    cleanup = memory_cleanup_suffix(project_name, reset_project=reset_project, purge=purge, dry_run=dry_run)
    if cleanup is None:
        return None
    label, suffix = cleanup
    resolved = resolve_memory_cleanup_base_command(target, memory_cli_command)
    if resolved is None:
        fail(
            f"could not resolve {MEMORY_MCP_PACKAGE} for requested memory cleanup; install it on PATH, "
            "pass --memory-cli-command, or keep a compatible target .vscode/mcp.json. "
            "Pegasus IA will not delete memory data directly."
        )
    command, cwd = resolved
    return MemoryCleanupPlan(label, [*command, *suffix], cwd)


def format_command(command: list[str]) -> str:
    return " ".join(shlex.quote(part) for part in command)


def ensure_memory_cleanup_cli_available(plan: MemoryCleanupPlan) -> None:
    if shutil.which(plan.command[0]) is None:
        fail(
            f"{MEMORY_MCP_PACKAGE} is required for requested memory cleanup; install it on PATH, "
            "configure a compatible workspace .vscode/mcp.json, pass --memory-cli-command, or remove the "
            "memory cleanup flag. Pegasus IA will not delete memory data directly."
        )


def run_memory_cleanup(plan: MemoryCleanupPlan) -> None:
    ensure_memory_cleanup_cli_available(plan)
    try:
        subprocess.run(plan.command, cwd=plan.cwd, check=True)
    except subprocess.CalledProcessError as exc:
        fail(f"memory cleanup command failed with exit code {exc.returncode}: {format_command(plan.command)}")
    except OSError as exc:
        fail(f"memory cleanup command could not be executed: {exc}")


def install_memory_mcp(default_root: Path) -> bool:
    if os.environ.get("PEGASUS_MEMORY_MCP_SKIP_INSTALL") == "1":
        return False
    if not default_root.exists():
        default_root.parent.mkdir(parents=True, exist_ok=True)
        clone_command = ["git", "clone", "--branch", MEMORY_MCP_BRANCH, MEMORY_MCP_REPOSITORY, str(default_root)]
        if not run_memory_mcp_command(clone_command, default_root.parent):
            return False
    if not run_memory_mcp_command(["npm", "ci"], default_root):
        return False
    if not run_memory_mcp_command(["npm", "run", "build"], default_root):
        return False
    return (default_root / MEMORY_MCP_SCRIPT_RELATIVE_PATH).is_file()


def resolve_memory_mcp(allow_install: bool) -> MemoryMcpResolution:
    path_script = memory_mcp_path_script()
    if path_script is not None:
        return MemoryMcpResolution(path_script, memory_mcp_root_from_script(path_script), "path")

    default_script = memory_mcp_default_script_path()
    default_root = memory_mcp_default_root().resolve()
    if default_script.is_file():
        return MemoryMcpResolution(default_script, default_root, "default-local")

    if allow_install and install_memory_mcp(default_root):
        return MemoryMcpResolution(default_script, default_root, "installed")

    return MemoryMcpResolution(default_script, default_root, "unavailable", MEMORY_MCP_UNAVAILABLE_WARNING)


def build_plan(target: Path, files: list[Path], force: bool) -> tuple[list[Path], list[Path], list[Path]]:
    creates: list[Path] = []
    overwrites: list[Path] = []
    conflicts: list[Path] = []

    for rel_path in files:
        destination = target / rel_path
        if destination.exists():
            if force:
                overwrites.append(destination)
            else:
                conflicts.append(destination)
        else:
            creates.append(destination)

    return creates, overwrites, conflicts


def build_global_plan(rules_dir: Path, files: list[Path]) -> tuple[list[Path], list[Path], list[Path]]:
    creates: list[Path] = []
    updates: list[Path] = []
    backups: list[Path] = []

    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d%H%M%S")
    for rel_path in files:
        destination = rules_dir / rel_path
        if destination.exists():
            updates.append(destination)
            backups.append(destination.with_name(f"{destination.name}.{timestamp}.bak"))
        else:
            creates.append(destination)

    return creates, updates, backups


def build_copilot_asset_plan(managed_root: Path, files: list[Path]) -> tuple[list[Path], list[Path]]:
    creates: list[Path] = []
    updates: list[Path] = []

    for rel_path in files:
        destination = managed_root / rel_path
        if destination.exists():
            updates.append(destination)
        else:
            creates.append(destination)

    return creates, updates


def settings_backup_path(settings_path: Path) -> Path:
    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d%H%M%S")
    return settings_path.with_name(f"{settings_path.name}.{timestamp}.bak")


def print_plan(
    project_name: str,
    target: Path,
    root: Path,
    creates: list[Path],
    overwrites: list[Path],
    conflicts: list[Path],
    global_rules_dir: Path | None = None,
    global_note: str | None = None,
    global_creates: list[Path] | None = None,
    global_updates: list[Path] | None = None,
    global_backups: list[Path] | None = None,
    copilot_root: Path | None = None,
    copilot_settings_path: Path | None = None,
    copilot_creates: list[Path] | None = None,
    copilot_updates: list[Path] | None = None,
    copilot_settings_backup: Path | None = None,
    install_copilot_global: bool = False,
    vscode_target: str = "stable",
    memory_mcp: MemoryMcpResolution | None = None,
    install_memory_mcp_requested: bool = False,
) -> None:
    print("Pegasus VS Code/Copilot harness bootstrap plan")
    print(f"Project: {project_name}")
    print(f"Target: {target}")
    print(f"Template root: {root}")
    print("Primary IDE: VS Code with GitHub Copilot")
    print(f"Manifest: {target / MANIFEST_RELATIVE_PATH}")

    if memory_mcp is not None:
        label = "explicit" if install_memory_mcp_requested else "default-on"
        print(f"\nPegasus Memory MCP workspace stdio setup ({label}):")
        print("  Command: node")
        print(f"  Script: {memory_mcp.script_path}")
        print(f"  Cwd: {memory_mcp.cwd}")
        print(f"  Source: {memory_mcp.source}")
        if memory_mcp.warning is not None:
            print(f"  Warning: {memory_mcp.warning}")

    print("\nManaged workspace surfaces:")
    for surface in WORKSPACE_SURFACES:
        label = " (legacy compatibility)" if surface == ".cursor/" else ""
        print(f"  {target / surface.rstrip('/')}{label}")

    if creates:
        print("\nCreates:")
        for path in creates:
            print(f"  {path}")

    if overwrites:
        print("\nOverwrites (--force):")
        for path in overwrites:
            print(f"  {path}")

    if conflicts:
        print("\nConflicts (skipped unless --force):")
        for path in conflicts:
            print(f"  {path}")

    if global_rules_dir is not None:
        print("\nLegacy global Cursor rules (--install-cursor-global):")
        print(f"  Rules path: {global_rules_dir}")
        if global_note:
            print(f"  Note: {global_note}")

        if global_creates:
            print("  Creates:")
            for path in global_creates:
                print(f"    {path}")

        if global_updates:
            print("  Updates:")
            for path in global_updates:
                print(f"    {path}")

        if global_backups:
            print("  Backups:")
            for path in global_backups:
                print(f"    {path}")

    if install_copilot_global:
        print("\nGlobal VS Code/Copilot configuration (--install-copilot-global):")
        print(f"  VS Code target: {vscode_target}")
        if copilot_root is not None:
            print(f"  Pegasus-managed root: {copilot_root}")
        if copilot_settings_path is not None:
            print(f"  Settings path: {copilot_settings_path}")
        if copilot_creates:
            print("  Asset creates:")
            for path in copilot_creates:
                print(f"    {path}")
        if copilot_updates:
            print("  Asset updates:")
            for path in copilot_updates:
                print(f"    {path}")
        if copilot_settings_backup is not None:
            print(f"  Settings backup: {copilot_settings_backup}")
        else:
            print("  Settings backup: none; settings file does not exist yet")
        print("  Settings merge:")
        if copilot_root is not None:
            for key, subdir in COPILOT_SETTINGS_KEYS:
                print(f"    {key} += {copilot_root / subdir}")


def render_template(
    content: str,
    project_name: str,
    target: Path,
    memory_mcp_script_path: Path,
    memory_mcp_cwd: Path,
) -> str:
    today = dt.date.today().isoformat()
    return (
        content.replace("{{PROJECT_NAME}}", project_name)
        .replace("{{TARGET_PATH}}", str(target))
        .replace("{{DATE}}", today)
        .replace("{{MEMORY_MCP_SCRIPT_PATH}}", str(memory_mcp_script_path))
        .replace("{{MEMORY_MCP_CWD}}", str(memory_mcp_cwd))
    )


def render_global_template(content: str) -> str:
    body = content.replace("{{GLOBAL_TEMPLATE_VERSION}}", GLOBAL_TEMPLATE_VERSION)
    checksum = hashlib.sha256(body.encode("utf-8")).hexdigest()[:16]
    marker = f"<!-- {GLOBAL_MARKER}: version={GLOBAL_TEMPLATE_VERSION} checksum={checksum} -->"
    return f"{marker}\n{body}"


def render_copilot_global_template(content: str) -> str:
    body = content.replace("{{GLOBAL_TEMPLATE_VERSION}}", GLOBAL_TEMPLATE_VERSION)
    checksum = hashlib.sha256(body.encode("utf-8")).hexdigest()[:16]
    marker = f"<!-- {COPILOT_GLOBAL_MARKER}: version={GLOBAL_TEMPLATE_VERSION} checksum={checksum} -->"
    return f"{marker}\n{body}"


def write_files(
    root: Path,
    target: Path,
    files: list[Path],
    project_name: str,
    memory_mcp_script_path: Path,
    memory_mcp_cwd: Path,
) -> list[dict]:
    written: list[dict] = []
    for rel_path in files:
        source = root / rel_path
        destination = target / rel_path
        destination.parent.mkdir(parents=True, exist_ok=True)
        content = source.read_text(encoding="utf-8")
        rendered = render_workspace_content(
            render_template(content, project_name, target, memory_mcp_script_path, memory_mcp_cwd), rel_path
        )
        action = "updated" if destination.exists() else "created"
        destination.write_text(rendered + "\n", encoding="utf-8")
        written.append(file_record(rel_path, rendered, action))
    return written


def write_global_files(root: Path, rules_dir: Path, files: list[Path], backups: list[Path]) -> None:
    existing_destinations = [rules_dir / rel_path for rel_path in files if (rules_dir / rel_path).exists()]
    backup_by_destination = dict(zip(existing_destinations, backups))

    for rel_path in files:
        source = root / rel_path
        destination = rules_dir / rel_path
        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            backup_path = backup_by_destination[destination]
            backup_path.write_text(destination.read_text(encoding="utf-8"), encoding="utf-8")
        content = source.read_text(encoding="utf-8")
        destination.write_text(render_global_template(content) + "\n", encoding="utf-8")


def write_copilot_global_files(root: Path, managed_root: Path, files: list[Path]) -> None:
    for rel_path in files:
        source = root / rel_path
        destination = managed_root / rel_path
        destination.parent.mkdir(parents=True, exist_ok=True)
        content = source.read_text(encoding="utf-8")
        destination.write_text(render_copilot_global_template(content) + "\n", encoding="utf-8")


def load_settings(settings_path: Path) -> dict:
    if not settings_path.exists():
        return {}
    try:
        settings = json.loads(settings_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"invalid VS Code settings JSON at {settings_path}: {exc.msg}")
    if not isinstance(settings, dict):
        fail(f"VS Code settings JSON must be an object: {settings_path}")
    return settings


def append_location(existing: object, location: str, key: str) -> object:
    if existing is None:
        return {location: True}
    if isinstance(existing, dict):
        merged = dict(existing)
        merged[location] = True
        return merged
    if isinstance(existing, list):
        merged = list(existing)
        if location not in merged:
            merged.append(location)
        return merged
    fail(f"VS Code setting {key} must be an object or array to merge safely")


def merge_copilot_settings(settings: dict, managed_root: Path) -> dict:
    merged = dict(settings)
    for key, subdir in COPILOT_SETTINGS_KEYS:
        location = str(managed_root / subdir)
        merged[key] = append_location(merged.get(key), location, key)
    return merged


def prepare_copilot_settings(settings_path: Path, managed_root: Path) -> tuple[dict, Path | None]:
    settings = load_settings(settings_path)
    backup_path = settings_backup_path(settings_path) if settings_path.exists() else None
    merged = merge_copilot_settings(settings, managed_root)
    return merged, backup_path


def write_copilot_settings(settings_path: Path, merged: dict, backup_path: Path | None) -> Path | None:
    settings_path.parent.mkdir(parents=True, exist_ok=True)
    if backup_path is not None:
        shutil.copy2(settings_path, backup_path)
    settings_path.write_text(json.dumps(merged, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return backup_path


def load_workspace_manifest(target: Path) -> dict:
    manifest_path = target / MANIFEST_RELATIVE_PATH
    if not manifest_path.exists():
        fail(f"workspace manifest not found: {manifest_path}")
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"invalid workspace manifest JSON at {manifest_path}: {exc.msg}")
    if not isinstance(manifest, dict):
        fail(f"workspace manifest JSON must be an object: {manifest_path}")
    if manifest.get("managed_by") != "pegasus-harness-bootstrap":
        fail(f"workspace manifest is not Pegasus-managed: {manifest_path}")
    return manifest


def workspace_manifest_path(target: Path) -> Path:
    return target / MANIFEST_RELATIVE_PATH


def workspace_target_for(project_name: str, target: Path) -> WorkspaceTarget:
    return WorkspaceTarget(project_name=project_name, root=target)


def workspace_target_from_manifest(target: Path, manifest: dict) -> WorkspaceTarget:
    workspace = manifest.get("workspace")
    if not isinstance(workspace, dict):
        fail(f"workspace manifest is missing workspace metadata: {target / MANIFEST_RELATIVE_PATH}")
    project_name = workspace.get("project_name")
    if not isinstance(project_name, str):
        fail(f"workspace manifest is missing workspace.project_name: {target / MANIFEST_RELATIVE_PATH}")
    validate_project_name(project_name)
    return WorkspaceTarget(project_name=project_name, root=target)


def sync_inventory_files(files: list[Path]) -> list[Path]:
    return sorted(path for path in workspace_inventory_files(files) if is_safe_sync_managed_path(path))


def rendered_workspace_file(
    root: Path,
    rel_path: Path,
    target: WorkspaceTarget,
    memory_mcp: MemoryMcpResolution,
) -> str:
    content = (root / rel_path).read_text(encoding="utf-8")
    return render_workspace_content(
        render_template(content, target.project_name, target.root, memory_mcp.script_path, memory_mcp.cwd), rel_path
    )


def plan_workspace_sync(target: WorkspaceTarget, manifest: dict, current_files: list[Path]) -> list[SyncPlanItem]:
    records = manifest_file_records(manifest)
    current = set(current_files)
    plan: list[SyncPlanItem] = []

    for rel_path in sorted(current):
        state = classify_manifest_path(target.root, rel_path, records.get(rel_path))
        reason = "current generated file missing" if state == "create" else "manifest checksum matched"
        if state == "conflict":
            reason = "current file differs from manifest checksum"
        elif state == "untouched":
            reason = "existing file is not manifest-owned"
        plan.append(SyncPlanItem(rel_path, state, reason))

    for rel_path in sorted(path for path in records if is_safe_sync_managed_path(path) and path not in current):
        plan.append(SyncPlanItem(rel_path, "obsolete", "manifest-owned file is not in the current template inventory"))
    return plan


def sync_backup_root(target: WorkspaceTarget) -> Path:
    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%d%H%M%S")
    return target.root / ".pegasus-bootstrap-ia" / "backups" / timestamp


def backup_workspace_file(target: WorkspaceTarget, rel_path: Path, backup_root: Path) -> Path:
    source = target.root / rel_path
    backup = backup_root / rel_path
    backup.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, backup)
    return backup


def print_sync_plan(
    target: WorkspaceTarget,
    root: Path,
    plan: list[SyncPlanItem],
    backup_root: Path,
    overwrite_conflicts: bool,
) -> None:
    print("Pegasus workspace sync plan")
    print(f"Project: {target.project_name}")
    print(f"Target: {target.root}")
    print(f"Template root: {root}")
    print(f"Manifest: {target.root / MANIFEST_RELATIVE_PATH}")
    print("Scope: current workspace only")

    sections = (
        ("Creates:", "create"),
        ("Updates:", "updateable"),
        ("Conflicts (skipped unless --overwrite-conflicts):", "conflict"),
        ("User-created files preserved:", "untouched"),
        ("Obsolete managed files (report-only):", "obsolete"),
    )
    for title, state in sections:
        items = [item for item in plan if item.state == state]
        if not items:
            continue
        print(f"\n{title}")
        for item in items:
            print(f"  {target.root / item.rel_path} ({item.reason})")

    backup_items = [item for item in plan if item.state == "updateable" or (item.state == "conflict" and overwrite_conflicts)]
    if backup_items:
        print("\nBackups before replacement:")
        for item in backup_items:
            if (target.root / item.rel_path).exists():
                print(f"  {target.root / item.rel_path} -> {backup_root / item.rel_path}")

    print("\nPreserved user artifacts:")
    for artifact in (
        "docs/pegasus/prd.md",
        "docs/pegasus/proposal.md",
        "docs/pegasus/spec.md",
        "docs/pegasus/design.md",
        "docs/pegasus/tasks.md",
        "docs/pegasus/apply-progress.md",
        "docs/pegasus/verify.md",
        "docs/pegasus/changes/**",
    ):
        print(f"  {target.root / artifact}")


def apply_workspace_sync(
    target: WorkspaceTarget,
    root: Path,
    plan: list[SyncPlanItem],
    manifest: dict,
    memory_mcp: MemoryMcpResolution,
    overwrite_conflicts: bool,
    backup_root: Path,
) -> tuple[list[Path], list[Path], Path | None]:
    writable = [item for item in plan if item.state in {"create", "updateable"} or (item.state == "conflict" and overwrite_conflicts)]
    active_backup_root = backup_root if any((target.root / item.rel_path).exists() for item in writable) else None
    written_records: list[dict] = []
    written_paths: list[Path] = []
    backups: list[Path] = []
    overwritten_conflicts: list[Path] = []

    for item in writable:
        destination = target.root / item.rel_path
        if destination.exists():
            assert active_backup_root is not None
            backups.append(backup_workspace_file(target, item.rel_path, active_backup_root))
            if item.state == "conflict":
                overwritten_conflicts.append(item.rel_path)
        destination.parent.mkdir(parents=True, exist_ok=True)
        rendered = rendered_workspace_file(root, item.rel_path, target, memory_mcp)
        destination.write_text(rendered + "\n", encoding="utf-8")
        action = "created" if item.state == "create" else "updated"
        written_records.append(file_record(item.rel_path, rendered, action))
        written_paths.append(destination)

    if written_records:
        write_manifest(
            target.root,
            update_manifest_for_sync(manifest, updated_records=written_records, overwritten_conflicts=overwritten_conflicts),
        )
    return written_paths, backups, active_backup_root


def new_change_prd_path(target: Path, change_id: str) -> Path:
    return target / "docs" / "pegasus" / "changes" / change_id / "prd.md"


def render_change_prd(change_id: str, manifest: dict) -> str:
    workspace = manifest.get("workspace", {})
    project_name = workspace.get("project_name") if isinstance(workspace, dict) else None
    project_label = project_name if isinstance(project_name, str) else "TBD"
    return f"""# PRD: {change_id}

## Summary

Define the product problem, user value, and success criteria for this change before proposal, spec, design, or task planning starts.

## Context

- Project: `{project_label}`
- Change ID: `{change_id}`

## Problem

TBD

## Goals

- TBD

## Non-Goals

- TBD

## Users / Stakeholders

- TBD

## Requirements

- TBD

## Success Criteria

- TBD

## Approval

- Owner: TBD
- Status: Draft
"""


def create_new_change(target: Path, change_id: str) -> Path:
    manifest = load_workspace_manifest(target)
    destination = new_change_prd_path(target, change_id)
    if destination.exists():
        fail(f"change PRD already exists: {destination}")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(render_change_prd(change_id, manifest), encoding="utf-8")
    return destination


def workspace_uninstall_files(manifest: dict) -> list[tuple[Path, str]]:
    install = manifest.get("install", {})
    records = install.get("files", []) if isinstance(install, dict) else []
    files: list[tuple[Path, str]] = []
    for record in records:
        if not isinstance(record, dict):
            continue
        rel_path = record.get("path")
        if not isinstance(rel_path, str) or rel_path.startswith("/") or ".." in Path(rel_path).parts:
            continue
        ownership = record.get("ownership")
        files.append((Path(rel_path), ownership if isinstance(ownership, str) else "full-file"))
    return sorted(set(files), key=lambda item: item[0].as_posix())


def is_workspace_user_artifact(rel_path: Path) -> bool:
    clean = Path(rel_path.as_posix())
    docs_root = Path("docs/pegasus")
    return clean == docs_root or docs_root in clean.parents


def marker_block_bounds(text: str, rel_path: Path) -> tuple[int, int] | None:
    start = f"<!-- {OWNERSHIP_MARKER}:start path={rel_path.as_posix()}"
    end = f"<!-- {OWNERSHIP_MARKER}:end path={rel_path.as_posix()} -->"
    start_index = text.find(start)
    if start_index == -1:
        return None
    end_index = text.find(end, start_index)
    if end_index == -1:
        return None
    return start_index, end_index + len(end)


def remove_marker_block(text: str, rel_path: Path) -> str | None:
    bounds = marker_block_bounds(text, rel_path)
    if bounds is None:
        return None
    start, end = bounds
    before = text[:start].rstrip("\n")
    after = text[end:].lstrip("\n")
    if before and after:
        return f"{before}\n{after}"
    return before or after


def plan_workspace_uninstall(target: Path, manifest: dict) -> tuple[list[Path], list[Path], list[Path], list[Path]]:
    remove_files: list[Path] = []
    update_files: list[Path] = []
    preserve_files: list[Path] = []
    cleanup_dirs: set[Path] = set()

    for rel_path, ownership in workspace_uninstall_files(manifest):
        path = target / rel_path
        if not path.exists() or not path.is_file():
            continue
        if is_workspace_user_artifact(rel_path):
            preserve_files.append(path)
            continue
        text = path.read_text(encoding="utf-8")
        stripped = remove_marker_block(text, rel_path)
        if stripped is None:
            if ownership == "full-file":
                remove_files.append(path)
                cleanup_dirs.update(path.parents)
                continue
            preserve_files.append(path)
            continue
        if ownership == "marker-managed" and stripped.strip():
            update_files.append(path)
        else:
            remove_files.append(path)
        cleanup_dirs.update(path.parents)

    manifest_path = target / MANIFEST_RELATIVE_PATH
    if manifest_path.exists():
        remove_files.append(manifest_path)
        cleanup_dirs.update(manifest_path.parents)

    cleanup = [path for path in cleanup_dirs if target in path.parents]
    cleanup = sorted(set(cleanup), key=lambda path: len(path.parts), reverse=True)
    return sorted(set(remove_files)), sorted(set(update_files)), sorted(set(preserve_files)), cleanup


def print_uninstall_plan(
    target: Path,
    workspace_removes: list[Path],
    workspace_updates: list[Path],
    workspace_preserves: list[Path],
    workspace_dirs: list[Path],
    missing_workspace_manifest: Path | None = None,
    memory_cleanup: MemoryCleanupPlan | None = None,
    copilot_root: Path | None = None,
    copilot_settings_path: Path | None = None,
    copilot_asset_removes: list[Path] | None = None,
    copilot_dirs: list[Path] | None = None,
    copilot_settings_backup: Path | None = None,
) -> None:
    print("Pegasus uninstall plan")
    print(f"Target: {target}")
    if missing_workspace_manifest is not None:
        print("\nWorkspace uninstall skipped:")
        print(f"  No workspace manifest was found: {missing_workspace_manifest}")
        print("  Pegasus IA managed workspace assets cannot be planned or removed safely without the manifest.")
    if workspace_removes:
        print("\nWorkspace file removals:")
        for path in workspace_removes:
            print(f"  {path}")
    if workspace_updates:
        print("\nWorkspace marker removals:")
        for path in workspace_updates:
            print(f"  {path}")
    if workspace_preserves:
        print("\nWorkspace files preserved (user artifacts or no Pegasus marker found):")
        for path in workspace_preserves:
            print(f"  {path}")
    if workspace_dirs:
        print("\nEmpty workspace directories to remove when possible:")
        for path in workspace_dirs:
            print(f"  {path}")
    if memory_cleanup is not None:
        print(f"\n{memory_cleanup.label} (delegated):")
        print(f"  Command: {format_command(memory_cleanup.command)}")
        if memory_cleanup.cwd is not None:
            print(f"  Cwd: {memory_cleanup.cwd}")
        print("  Note: Pegasus IA does not delete Pegasus Memory database, config, or cache paths directly.")
    if copilot_root is not None:
        print("\nGlobal VS Code/Copilot uninstall (--uninstall-copilot-global):")
        print(f"  Pegasus-managed root: {copilot_root}")
        if copilot_settings_path is not None:
            print(f"  Settings path: {copilot_settings_path}")
        if copilot_settings_backup is not None:
            print(f"  Settings backup: {copilot_settings_backup}")
        elif copilot_settings_path is not None:
            print("  Settings backup: none; settings file does not exist or has no Pegasus entries")
        if copilot_asset_removes:
            print("  Asset removals:")
            for path in copilot_asset_removes:
                print(f"    {path}")
        if copilot_dirs:
            print("  Empty global directories to remove when possible:")
            for path in copilot_dirs:
                print(f"    {path}")


def apply_workspace_uninstall(
    target: Path,
    remove_files: list[Path],
    update_files: list[Path],
    cleanup_dirs: list[Path],
) -> tuple[list[Path], list[Path]]:
    removed_dirs: list[Path] = []
    preserved_dirs: list[Path] = []
    for path in update_files:
        rel_path = path.relative_to(target)
        text = path.read_text(encoding="utf-8")
        stripped = remove_marker_block(text, rel_path)
        if stripped is not None:
            path.write_text(stripped.rstrip("\n") + "\n", encoding="utf-8")
    for path in remove_files:
        if path.exists() and path.is_file():
            path.unlink()
    for directory in cleanup_dirs:
        if directory == target.parent:
            continue
        if directory.exists() and directory.is_dir():
            try:
                directory.rmdir()
                removed_dirs.append(directory)
            except OSError:
                preserved_dirs.append(directory)
    return removed_dirs, preserved_dirs


def remove_location(existing: object, location: str) -> tuple[object | None, bool]:
    if isinstance(existing, dict):
        if location not in existing:
            return existing, False
        updated = dict(existing)
        updated.pop(location, None)
        return (updated if updated else None), True
    if isinstance(existing, list):
        updated = [item for item in existing if item != location]
        changed = len(updated) != len(existing)
        return (updated if updated else None), changed
    return existing, False


def remove_copilot_settings(settings: dict, managed_root: Path) -> tuple[dict, bool]:
    updated = dict(settings)
    changed = False
    for key, subdir in COPILOT_SETTINGS_KEYS:
        if key not in updated:
            continue
        next_value, key_changed = remove_location(updated[key], str(managed_root / subdir))
        if key_changed:
            changed = True
            if next_value is None:
                updated.pop(key, None)
            else:
                updated[key] = next_value
    return updated, changed


def plan_copilot_global_uninstall(managed_root: Path, settings_path: Path) -> tuple[list[Path], list[Path], dict, Path | None, bool]:
    settings = load_settings(settings_path)
    updated_settings, settings_changed = remove_copilot_settings(settings, managed_root)
    asset_removes = sorted(path for path in managed_root.rglob("*") if path.is_file() and is_copilot_managed_asset(path)) if managed_root.exists() else []
    cleanup_dirs = sorted(
        {path.parent for path in asset_removes}.union({managed_root}),
        key=lambda path: len(path.parts),
        reverse=True,
    )
    backup_path = settings_backup_path(settings_path) if settings_path.exists() and settings_changed else None
    return asset_removes, cleanup_dirs, updated_settings, backup_path, settings_changed


def is_copilot_managed_asset(path: Path) -> bool:
    try:
        return COPILOT_GLOBAL_MARKER in path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return False


def apply_copilot_global_uninstall(
    asset_removes: list[Path],
    cleanup_dirs: list[Path],
    settings_path: Path,
    updated_settings: dict,
    backup_path: Path | None,
    settings_changed: bool,
) -> tuple[list[Path], list[Path]]:
    if settings_changed:
        write_copilot_settings(settings_path, updated_settings, backup_path)
    for path in asset_removes:
        if path.exists() and path.is_file():
            path.unlink()
    removed_dirs: list[Path] = []
    preserved_dirs: list[Path] = []
    for directory in cleanup_dirs:
        if directory.exists() and directory.is_dir():
            try:
                directory.rmdir()
                removed_dirs.append(directory)
            except OSError:
                preserved_dirs.append(directory)
    return removed_dirs, preserved_dirs


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    if args.project_name is not None:
        validate_project_name(args.project_name)

    if args.new_change:
        validate_change_id(args.new_change)
        target = change_target_path_for(args.target_path)
        prd_path = create_new_change(target, args.new_change)
        print("Created Pegasus change PRD.")
        print(f"Target: {target}")
        print(f"Change: {args.new_change}")
        print(f"PRD: {prd_path}")
        print("Later SDD phase progression creates proposal, spec, design, tasks, apply-progress, and verify artifacts.")
        return 0

    if args.overwrite_conflicts and not args.sync_workspace:
        fail("--overwrite-conflicts can only be used with --sync-workspace")

    uninstall_workspace_requested = args.uninstall or args.uninstall_workspace

    if args.reset_memory_project and args.purge_memory:
        fail("--reset-memory-project and --purge-memory are mutually exclusive")
    if args.memory_cli_command and not (args.reset_memory_project or args.purge_memory):
        fail("--memory-cli-command can only be used with --reset-memory-project or --purge-memory")
    if (args.reset_memory_project or args.purge_memory) and not uninstall_workspace_requested:
        fail("memory cleanup flags can only be used with --uninstall or --uninstall-workspace")

    if args.project_name is None and not (args.sync_workspace or uninstall_workspace_requested or args.uninstall_copilot_global):
        fail("--project-name is required unless --sync-workspace, --new-change, or an uninstall flag is used")

    if args.sync_workspace:
        target = change_target_path_for(args.target_path)
        manifest = load_workspace_manifest(target)
        workspace_target = workspace_target_from_manifest(target, manifest)
        root = template_root()
        current_files = sync_inventory_files(template_files(root))
        memory_mcp = resolve_memory_mcp(allow_install=not args.dry_run)
        sync_plan = plan_workspace_sync(workspace_target, manifest, current_files)
        plan_backup_root = sync_backup_root(workspace_target)
        print_sync_plan(workspace_target, root, sync_plan, plan_backup_root, args.overwrite_conflicts)

        if args.dry_run:
            print("\nDry run only; no files were written.")
            return 0

        if memory_mcp.warning is not None:
            print(memory_mcp.warning)
        written_paths, backup_paths, _ = apply_workspace_sync(
            workspace_target,
            root,
            sync_plan,
            manifest,
            memory_mcp,
            args.overwrite_conflicts,
            plan_backup_root,
        )
        print("\nCompleted Pegasus workspace sync.")
        for path in written_paths:
            print(f"Updated: {path}")
        for backup in backup_paths:
            print(f"Backup created: {backup}")
        conflicts = [item for item in sync_plan if item.state == "conflict"]
        if conflicts and not args.overwrite_conflicts:
            print("Conflicting Pegasus-managed files were preserved; rerun with --overwrite-conflicts to back up and replace them.")
        obsolete = [item for item in sync_plan if item.state == "obsolete"]
        if obsolete:
            print("Obsolete Pegasus-managed files were reported only; none were deleted.")
        return 0

    target = target_path_for(args.project_name, args.target_path)

    if uninstall_workspace_requested or args.uninstall_copilot_global:
        workspace_removes: list[Path] = []
        workspace_updates: list[Path] = []
        workspace_preserves: list[Path] = []
        workspace_dirs: list[Path] = []
        missing_workspace_manifest: Path | None = None
        memory_cleanup = None
        if uninstall_workspace_requested:
            manifest_path = workspace_manifest_path(target)
            if args.purge_memory and not manifest_path.exists():
                missing_workspace_manifest = manifest_path
                memory_cleanup = memory_cleanup_plan(
                    args.project_name or "",
                    reset_project=False,
                    purge=True,
                    dry_run=args.dry_run,
                    target=target,
                    memory_cli_command=args.memory_cli_command,
                )
            else:
                manifest = load_workspace_manifest(target)
                workspace_target = workspace_target_from_manifest(target, manifest)
                workspace_removes, workspace_updates, workspace_preserves, workspace_dirs = plan_workspace_uninstall(target, manifest)
                memory_cleanup = memory_cleanup_plan(
                    workspace_target.project_name,
                    reset_project=args.reset_memory_project,
                    purge=args.purge_memory,
                    dry_run=args.dry_run,
                    target=target,
                    memory_cli_command=args.memory_cli_command,
                )

        copilot_root = None
        copilot_settings = None
        copilot_asset_removes: list[Path] = []
        copilot_dirs: list[Path] = []
        copilot_updated_settings: dict = {}
        copilot_settings_backup = None
        copilot_settings_changed = False
        if args.uninstall_copilot_global:
            copilot_root = copilot_managed_root()
            copilot_settings = vscode_settings_path(args.vscode_target)
            (
                copilot_asset_removes,
                copilot_dirs,
                copilot_updated_settings,
                copilot_settings_backup,
                copilot_settings_changed,
            ) = plan_copilot_global_uninstall(copilot_root, copilot_settings)

        print_uninstall_plan(
            target,
            workspace_removes,
            workspace_updates,
            workspace_preserves,
            workspace_dirs,
            missing_workspace_manifest,
            memory_cleanup,
            copilot_root,
            copilot_settings,
            copilot_asset_removes,
            copilot_dirs,
            copilot_settings_backup,
        )

        if args.dry_run:
            print("\nDry run only; no files were removed.")
            return 0

        if memory_cleanup is not None:
            ensure_memory_cleanup_cli_available(memory_cleanup)

        if uninstall_workspace_requested:
            if missing_workspace_manifest is not None:
                print("\nSkipped Pegasus workspace uninstall because the workspace manifest was not found.")
                print("No workspace files were removed by Pegasus IA.")
            else:
                removed_dirs, preserved_dirs = apply_workspace_uninstall(
                    target,
                    workspace_removes,
                    workspace_updates,
                    workspace_dirs,
                )
                print("\nCompleted Pegasus workspace uninstall.")
                for directory in removed_dirs:
                    print(f"Removed empty directory: {directory}")
                for directory in preserved_dirs:
                    print(f"Preserved non-empty directory: {directory}")

        if memory_cleanup is not None:
            run_memory_cleanup(memory_cleanup)
            print(f"Completed delegated memory cleanup: {format_command(memory_cleanup.command)}")

        if args.uninstall_copilot_global:
            assert copilot_settings is not None
            removed_dirs, preserved_dirs = apply_copilot_global_uninstall(
                copilot_asset_removes,
                copilot_dirs,
                copilot_settings,
                copilot_updated_settings,
                copilot_settings_backup,
                copilot_settings_changed,
            )
            print("\nCompleted Pegasus global VS Code/Copilot uninstall.")
            if copilot_settings_backup is not None:
                print(f"Backup created: {copilot_settings_backup}")
            for directory in removed_dirs:
                print(f"Removed empty global directory: {directory}")
            for directory in preserved_dirs:
                print(f"Preserved non-empty global directory: {directory}")
        return 0

    root = template_root()
    files = template_files(root)
    workspace_files = workspace_inventory_files(files)
    creates, overwrites, conflicts = build_plan(target, workspace_files, args.force)
    memory_mcp = resolve_memory_mcp(allow_install=not args.dry_run)

    global_root = None
    global_files: list[Path] = []
    global_rules_dir = None
    global_note = None
    global_creates: list[Path] = []
    global_updates: list[Path] = []
    global_backups: list[Path] = []
    copilot_root = None
    copilot_settings = None
    copilot_files: list[Path] = []
    copilot_creates: list[Path] = []
    copilot_updates: list[Path] = []
    copilot_settings_backup = None
    copilot_merged_settings = None

    if args.install_copilot_global:
        copilot_root_template = copilot_global_template_root()
        copilot_files = template_files(copilot_root_template)
        copilot_root = copilot_managed_root()
        copilot_settings = vscode_settings_path(args.vscode_target)
        copilot_creates, copilot_updates = build_copilot_asset_plan(copilot_root, copilot_files)
        if args.dry_run:
            copilot_settings_backup = settings_backup_path(copilot_settings) if copilot_settings.exists() else None
        else:
            copilot_merged_settings, copilot_settings_backup = prepare_copilot_settings(copilot_settings, copilot_root)

    if args.install_cursor_global:
        global_root = cursor_global_template_root()
        global_files = template_files(global_root)
        global_rules_dir, global_note = detect_cursor_rules_dir()
        global_creates, global_updates, global_backups = build_global_plan(global_rules_dir, global_files)

    print_plan(
        args.project_name,
        target,
        root,
        creates,
        overwrites,
        conflicts,
        global_rules_dir,
        global_note,
        global_creates,
        global_updates,
        global_backups,
        copilot_root,
        copilot_settings,
        copilot_creates,
        copilot_updates,
        copilot_settings_backup,
        args.install_copilot_global,
        args.vscode_target,
        memory_mcp,
        args.install_memory_mcp,
    )

    if args.dry_run:
        print("\nDry run only; no files were written.")
        return 0

    if args.target_path is not None and not target.exists():
        confirm_missing_explicit_target(target)

    paths_to_write = set(workspace_files)
    if conflicts and not args.force:
        skipped_rel_paths = {path.relative_to(target) for path in conflicts}
        paths_to_write = paths_to_write.difference(skipped_rel_paths)
        print("\nExisting generated paths were preserved; skipped conflicting writes.")
        print("Run with --force to replace known harness files.")
    if memory_mcp.warning is not None:
        print(memory_mcp.warning)
    written_files = write_files(root, target, sorted(paths_to_write), args.project_name, memory_mcp.script_path, memory_mcp.cwd)
    manifest = build_manifest(
        project_name=args.project_name,
        target=target,
        installed_files=written_files,
        skipped_conflicts=[path.relative_to(target) for path in conflicts] if not args.force else [],
        forced_overwrites=[path.relative_to(target) for path in overwrites],
    )
    manifest_path = write_manifest(target, manifest)

    actual_copilot_settings_backup = None

    if args.install_copilot_global:
        assert copilot_root is not None
        assert copilot_settings is not None
        assert copilot_merged_settings is not None
        write_copilot_global_files(copilot_root_template, copilot_root, copilot_files)
        actual_copilot_settings_backup = write_copilot_settings(
            copilot_settings,
            copilot_merged_settings,
            copilot_settings_backup,
        )

    if args.install_cursor_global:
        assert global_root is not None
        assert global_rules_dir is not None
        write_global_files(global_root, global_rules_dir, global_files, global_backups)

    print("\nCompleted Pegasus VS Code/Copilot harness bootstrap.")
    print(f"Open the target workspace in VS Code with Copilot: {target}")
    print(f"Portable agent guidance: {target / 'AGENTS.md'}")
    print("Primary Copilot entry point: .github/agents/pegasus-orchestrator.agent.md")
    print(f"Install manifest: {manifest_path}")
    if args.install_copilot_global:
        print(f"Updated global VS Code/Copilot assets: {copilot_root}")
        print(f"Updated VS Code settings ({args.vscode_target}): {copilot_settings}")
        if actual_copilot_settings_backup is not None:
            print(f"Backup created: {actual_copilot_settings_backup}")
    if args.install_cursor_global:
        print(f"Updated legacy global Cursor rules: {global_rules_dir}")
        for backup in global_backups:
            print(f"Backup created: {backup}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
