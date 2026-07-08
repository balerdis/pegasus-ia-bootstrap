"""Workspace install manifest helpers for Pegasus harness bootstrap."""

from __future__ import annotations

import datetime as dt
import hashlib
import json
from pathlib import Path
from typing import Any


MANIFEST_RELATIVE_PATH = Path(".pegasus-bootstrap-ia/manifest.json")
MANAGED_BY = "pegasus-harness-bootstrap"
MANIFEST_SCHEMA_VERSION = 1
TEMPLATE_VERSION = "1"
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


def ownership_mode(rel_path: Path) -> str:
    """Return the ownership mode used by future uninstall planning."""
    return "marker-managed" if rel_path in MARKER_MANAGED_FILES else "full-file"


def checksum_text(content: str) -> str:
    return hashlib.sha256(content.encode("utf-8")).hexdigest()


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
