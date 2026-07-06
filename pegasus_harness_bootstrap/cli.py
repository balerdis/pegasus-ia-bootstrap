"""Bootstrap a Pegasus VS Code/Copilot harness into a target workspace."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import shutil
import sys
from pathlib import Path

from pegasus_harness_bootstrap.manifest import (
    MANIFEST_RELATIVE_PATH,
    build_manifest,
    file_record,
    render_workspace_content,
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


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="pegasus-harness-bootstrap",
        description="Configure a local Pegasus VS Code/Copilot harness in a target workspace.",
    )
    parser.add_argument(
        "--project-name",
        required=True,
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
    return parser.parse_args(argv)


def fail(message: str, exit_code: int = 1) -> None:
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(exit_code)


def validate_project_name(project_name: str) -> None:
    if project_name in {"", ".", ".."} or "/" in project_name or " " in project_name:
        fail("project name must be non-empty and contain no spaces or slashes")
    if not PROJECT_NAME_RE.fullmatch(project_name):
        fail("project name may contain only letters, numbers, dot, underscore, and hyphen")


def target_path_for(project_name: str, target_path: str | None) -> Path:
    target = Path(target_path).expanduser() if target_path else DEFAULT_ROOT / project_name
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
) -> None:
    print("Pegasus VS Code/Copilot harness bootstrap plan")
    print(f"Project: {project_name}")
    print(f"Target: {target}")
    print(f"Template root: {root}")
    print("Primary IDE: VS Code with GitHub Copilot")
    print(f"Manifest: {target / MANIFEST_RELATIVE_PATH}")

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


def render_template(content: str, project_name: str, target: Path) -> str:
    today = dt.date.today().isoformat()
    return (
        content.replace("{{PROJECT_NAME}}", project_name)
        .replace("{{TARGET_PATH}}", str(target))
        .replace("{{DATE}}", today)
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


def write_files(root: Path, target: Path, files: list[Path], project_name: str) -> list[dict]:
    written: list[dict] = []
    for rel_path in files:
        source = root / rel_path
        destination = target / rel_path
        destination.parent.mkdir(parents=True, exist_ok=True)
        content = source.read_text(encoding="utf-8")
        rendered = render_workspace_content(render_template(content, project_name, target), rel_path)
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


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    validate_project_name(args.project_name)

    target = target_path_for(args.project_name, args.target_path)
    root = template_root()
    files = template_files(root)
    workspace_files = workspace_inventory_files(files)
    creates, overwrites, conflicts = build_plan(target, workspace_files, args.force)

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
    )

    if args.dry_run:
        print("\nDry run only; no files were written.")
        return 0

    paths_to_write = set(workspace_files)
    if conflicts and not args.force:
        skipped_rel_paths = {path.relative_to(target) for path in conflicts}
        paths_to_write = paths_to_write.difference(skipped_rel_paths)
        print("\nExisting generated paths were preserved; skipped conflicting writes.")
        print("Run with --force to replace known harness files.")
    written_files = write_files(root, target, sorted(paths_to_write), args.project_name)
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
