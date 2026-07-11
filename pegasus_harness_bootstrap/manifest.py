"""Workspace install manifest helpers for Pegasus harness bootstrap."""

from __future__ import annotations

import datetime as dt
import hashlib
import json
from pathlib import Path
from typing import Any

from pegasus_harness_bootstrap import __version__


MANIFEST_RELATIVE_PATH = Path(".pegasus-bootstrap-ia/manifest.json")
MANAGED_BY = "pegasus-harness-bootstrap"
MANIFEST_SCHEMA_VERSION = 1
TEMPLATE_VERSION = __version__
OWNERSHIP_MARKER = "pegasus-harness"

FORBIDDEN_POINTER_KEYS = (
    "active_change",
    "active-change",
    "activeChange",
    "memory",
    "memory_state",
    "memory-state",
    "memoryState",
    "last_change",
    "last-change",
    "lastChange",
    "operational_memory",
    "operational-memory",
    "operationalMemory",
    "recovery_state",
    "recovery-state",
    "recoveryState",
)

MARKER_MANAGED_FILES = {
    Path("AGENTS.md"),
    Path(".github/copilot-instructions.md"),
}

SYNC_MANAGED_PREFIXES = (
    Path(".github"),
    Path(".cursor"),
)

SYNC_MANAGED_FILES = {
    Path("AGENTS.md"),
    Path(".vscode/mcp.json"),
}


def ownership_mode(rel_path: Path) -> str:
    """Return the ownership mode used by future uninstall planning."""
    return "marker-managed" if rel_path in MARKER_MANAGED_FILES else "full-file"


def checksum_text(content: str) -> str:
    return hashlib.sha256(content.encode("utf-8")).hexdigest()


def checksum_file(path: Path) -> str:
    return checksum_text(path.read_text(encoding="utf-8").rstrip("\n"))


def is_safe_sync_managed_path(rel_path: Path) -> bool:
    clean = Path(rel_path.as_posix())
    return clean in SYNC_MANAGED_FILES or any(clean == prefix or prefix in clean.parents for prefix in SYNC_MANAGED_PREFIXES)


def has_exact_ownership_marker(path: Path, rel_path: Path) -> bool:
    """Return whether a managed text file proves its own Pegasus ownership."""
    if rel_path.suffix == ".json" or not path.is_file():
        return False
    try:
        content = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return False
    rel = rel_path.as_posix()
    mode = ownership_mode(rel_path)
    return (
        f"<!-- {OWNERSHIP_MARKER}:start path={rel} ownership={mode} -->" in content
        and f"<!-- {OWNERSHIP_MARKER}:end path={rel} -->" in content
    )


def manifest_file_records(manifest: dict[str, Any]) -> dict[Path, dict[str, Any]]:
    install = manifest.get("install", {})
    records = install.get("files", []) if isinstance(install, dict) else []
    indexed: dict[Path, dict[str, Any]] = {}
    for record in records:
        if not isinstance(record, dict):
            continue
        raw_path = record.get("path")
        if not isinstance(raw_path, str) or raw_path.startswith("/") or ".." in Path(raw_path).parts:
            continue
        if record.get("managed_by") != MANAGED_BY:
            continue
        indexed[Path(raw_path)] = record
    return indexed


def classify_manifest_path(target: Path, rel_path: Path, record: dict[str, Any] | None) -> str:
    destination = target / rel_path
    if record is None:
        return "untouched" if destination.exists() else "create"
    if not destination.exists():
        return "create"
    expected_checksum = record.get("checksum_sha256")
    if not isinstance(expected_checksum, str):
        return "conflict"
    return "updateable" if checksum_file(destination) == expected_checksum else "conflict"


def update_manifest_for_sync(
    manifest: dict[str, Any],
    *,
    updated_records: list[dict[str, Any]],
    overwritten_conflicts: list[Path],
) -> dict[str, Any]:
    now = dt.datetime.now(dt.timezone.utc).isoformat()
    next_manifest = dict(manifest)
    existing = manifest_file_records(manifest)
    for record in updated_records:
        raw_path = record.get("path")
        if isinstance(raw_path, str):
            existing[Path(raw_path)] = record

    records = [existing[path] for path in sorted(existing)]
    install = dict(next_manifest.get("install", {})) if isinstance(next_manifest.get("install"), dict) else {}
    install["files"] = records
    install["skipped_conflicts"] = []
    next_manifest["install"] = install

    ownership = dict(next_manifest.get("ownership", {})) if isinstance(next_manifest.get("ownership"), dict) else {}
    ownership["mode"] = "manifest-backed"
    ownership["marker"] = OWNERSHIP_MARKER
    ownership["files"] = records
    next_manifest["ownership"] = ownership

    # Old manifests used template version "1" and did not identify the CLI
    # package. Upgrade only on an explicit sync; normal bootstrap never rewrites
    # a manifest-backed workspace.
    next_manifest["template_version"] = TEMPLATE_VERSION
    next_manifest["package_version"] = __version__

    update = dict(next_manifest.get("update", {})) if isinstance(next_manifest.get("update"), dict) else {}
    update["last_run_at"] = now
    update["overwrite_conflicts"] = [path.as_posix() for path in overwritten_conflicts]
    next_manifest["update"] = update

    _assert_no_forbidden_pointers(next_manifest)
    return next_manifest


def render_workspace_content(content: str, rel_path: Path) -> str:
    """Wrap generated content with Pegasus ownership markers."""
    if rel_path.suffix == ".json":
        return content.rstrip("\n")
    path = rel_path.as_posix()
    mode = ownership_mode(rel_path)
    body = content.rstrip("\n")
    return (
        f"<!-- {OWNERSHIP_MARKER}:start path={path} ownership={mode} -->\n"
        f"{body}\n"
        f"<!-- {OWNERSHIP_MARKER}:end path={path} -->"
    )


def file_record(rel_path: Path, content: str, action: str) -> dict[str, Any]:
    return {
        "path": rel_path.as_posix(),
        "ownership": ownership_mode(rel_path),
        "managed_by": MANAGED_BY,
        "template_version": TEMPLATE_VERSION,
        "package_version": __version__,
        "checksum_sha256": checksum_text(content),
        "action": action,
    }


def build_manifest(
    *,
    project_name: str,
    target: Path,
    installed_files: list[dict[str, Any]],
    skipped_conflicts: list[Path],
    forced_overwrites: list[Path],
) -> dict[str, Any]:
    now = dt.datetime.now(dt.timezone.utc).isoformat()
    manifest = {
        "schema_version": MANIFEST_SCHEMA_VERSION,
        "managed_by": MANAGED_BY,
        "template_version": TEMPLATE_VERSION,
        "installed_at": now,
        "workspace": {
            "project_name": project_name,
            "target_path": str(target),
        },
        "install": {
            "files": installed_files,
            "skipped_conflicts": [path.as_posix() for path in skipped_conflicts],
        },
        "ownership": {
            "mode": "manifest-backed",
            "marker": OWNERSHIP_MARKER,
            "files": installed_files,
        },
        "update": {
            "last_run_at": now,
            "force_overwrites": [path.as_posix() for path in forced_overwrites],
        },
        "uninstall": {
            "source": "manifest",
            "remove_only_managed": True,
            "empty_directories_only": True,
        },
    }
    _assert_no_forbidden_pointers(manifest)
    return manifest


def write_manifest(target: Path, manifest: dict[str, Any]) -> Path:
    _assert_no_forbidden_pointers(manifest)
    destination = target / MANIFEST_RELATIVE_PATH
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return destination


def _assert_no_forbidden_pointers(value: Any) -> None:
    if isinstance(value, dict):
        for key, nested in value.items():
            if key in FORBIDDEN_POINTER_KEYS:
                raise ValueError(f"manifest must not contain {key}")
            _assert_no_forbidden_pointers(nested)
    elif isinstance(value, list):
        for nested in value:
            _assert_no_forbidden_pointers(nested)
