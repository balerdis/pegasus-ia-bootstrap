# Design: Workspace Sync Command

## Technical Approach

Add a conservative `--sync-workspace` path to `pegasus_harness_bootstrap/cli.py` that reuses existing template rendering and manifest helpers, but replaces path-existence planning with manifest/checksum classification. The first slice resolves one `WorkspaceTarget` from the current `--target-path`/`--project-name` flow only; the sync engine accepts a target object so future registry fanout can call the same planner later. Do not create the future XDG registry now.

## Architecture Decisions

| Decision | Choice | Alternatives considered | Rationale |
|---|---|---|---|
| Targeting | Sync one current workspace via a `WorkspaceTarget` abstraction. | Implement global multi-workspace sync now. | Lowest blast radius while preserving future fanout shape. |
| Ownership source | Use `.pegasus-bootstrap-ia/manifest.json` ownership/checksums as workspace-local evidence only. | Store registry or operational memory in the manifest. | Keeps lifecycle metadata separate from future `~/.config/pegasus-ia-bootstrap/workspaces.json`. |
| Default safety | Update only Pegasus-managed files whose current checksum matches the manifest record. | Overwrite any existing harness path. | Prevents destroying user edits. |
| Obsolete files | Report obsolete managed files by default. | Delete during sync. | Removal needs a later explicit prune policy. |
| Override shape | Add an explicit conflict override concept (`--overwrite-conflicts` or equivalent), but default remains skip. | Reuse broad `--force` silently. | Sync needs clearer semantics than initial install replacement. |

## Data Flow

```
CLI args ──→ WorkspaceTarget ──→ manifest load/validate
                         │              │
                         └── templates/rendered current files
                                      │
                              SyncPlanner classify
                                      │
                     dry-run report or backup + write + manifest update
```

Classification states:
- `updateable`: manifest-owned file exists and current checksum equals recorded checksum.
- `conflict`: manifest-owned file exists but checksum differs; skip unless explicit override.
- `untouched`: user-created file, including preserved product/SDD artifacts.
- `obsolete`: manifest-owned file no longer in current template inventory; report-only by default.
- `create`: current managed template missing from workspace.

Dry-run MUST print target, manifest path, template source, creates, updateable files, conflicts, obsolete managed files, preserved user artifacts, and backups that would be created; it writes nothing.

Real writes MUST create `.pegasus-bootstrap-ia/backups/<timestamp>/<relative-path>` before replacing any existing file. New files do not need backups. After successful writes, update manifest ownership records/checksums and `update.last_run_at`; do not add memory, active-change, recovery, or registry pointers.

## File Changes

| File | Action | Description |
|---|---|---|
| `pegasus_harness_bootstrap/cli.py` | Modify | Add sync flag/branch, `WorkspaceTarget`, sync planning/reporting, timestamped backup/write path, and `.vscode/mcp.json` refresh using current `resolve_memory_mcp()` + template rendering. |
| `pegasus_harness_bootstrap/manifest.py` | Modify | Add helpers to index manifest ownership records, validate schema shape, compare `checksum_sha256`, and build updated manifest records. |
| `tests/smoke.sh` | Modify | Cover help output, dry-run no-write, safe update, conflict skip, backup creation, obsolete report-only, MCP config refresh, and preserved artifacts. |
| `openspec/specs/pegasus-harness-bootstrap/spec.md` | Modify during archive | Merge accepted sync requirements after implementation/verification. |

File change count forecast: 3 implementation/test files now, 1 spec file during archive, 0 deletes.

## Interfaces / Contracts

```python
@dataclass(frozen=True)
class WorkspaceTarget:
    project_name: str
    root: Path

SyncState = Literal["create", "updateable", "conflict", "untouched", "obsolete"]

@dataclass(frozen=True)
class SyncPlanItem:
    rel_path: Path
    state: SyncState
    backup_path: Path | None = None
    reason: str = ""
```

Preserved user artifacts MUST include `docs/pegasus/prd.md`, root `proposal.md`, `spec.md`, `design.md`, `tasks.md`, `apply-progress.md`, `verify.md`, and `docs/pegasus/changes/**`. Do not use or reintroduce `docs/pegasus/memory/`. Do not touch `install_and_usage.txt`.

`.vscode/mcp.json` is treated as a managed JSON full-file: render the current template with the current MCP script/cwd, classify by manifest checksum, then update only when safe or explicitly overridden.

## Testing Strategy

| Layer | What to Test | Approach |
|---|---|---|
| CLI smoke | Help flag and dry-run reporting/no-write | Extend `tests/smoke.sh`. |
| Sync safety | updateable, conflict, untouched, obsolete, backup | Temporary workspace fixtures in Bash. |
| Manifest/MCP | checksum updates, forbidden pointer absence, `.vscode/mcp.json` refresh | Parse JSON with inline Python assertions. |

## Migration / Rollout

No migration required. Existing installed workspaces without a valid Pegasus manifest should fail safely with a clear message instead of guessing ownership.

## Open Questions

- [ ] Final flag name for conflict override (`--overwrite-conflicts` recommended) can be confirmed during task planning.
