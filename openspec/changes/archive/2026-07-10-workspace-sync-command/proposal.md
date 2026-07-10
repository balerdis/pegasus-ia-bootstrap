# Proposal: Workspace Sync Command

## Intent

Add a safe command that updates an installed Pegasus workspace to the current bootstrap harness without destroying user work. It must refresh managed harness files, preserve project artifacts, and stay ready for registry fanout.

## Scope

### In Scope
- Sync only the current target workspace in the first slice.
- Support `--dry-run` and visible non-dry-run plans.
- Update Pegasus-managed harness files when safe: `.github/`, `.vscode/mcp.json`, `AGENTS.md`, and legacy `.cursor/` assets.
- Use manifest ownership/checksums to skip user-modified managed files by default.
- Write timestamped backups before real writes.
- Report obsolete Pegasus-managed files without removing them by default.

### Out of Scope
- Global multi-workspace sync execution.
- Writing a global registry in the first slice; future storage should use XDG config such as `~/.config/pegasus-ia-bootstrap/workspaces.json`.
- Mixing registry data into `.pegasus-bootstrap-ia/manifest.json`.
- Using `docs/pegasus/memory/` as fallback memory.
- Touching local draft `install_and_usage.txt`.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `pegasus-harness-bootstrap`: add current-workspace sync behavior, safe conflicts, backups, obsolete reporting, and a future-compatible target workspace abstraction.

## Approach

Introduce current-workspace sync backed by a reusable target workspace abstraction. Compare templates against manifest-owned files and recorded checksums. Update only when the managed file still matches the recorded installed state; otherwise report and skip. Keep `.pegasus-bootstrap-ia/manifest.json` as local ownership/install/update metadata only.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `pegasus_harness_bootstrap/cli.py` | Modified | Sync flow, planning, reporting, backups, conflicts. |
| `pegasus_harness_bootstrap/manifest.py` | Modified | Ownership/checksum interpretation. |
| `templates/harness/**` | Modified | Source for refreshed managed files. |
| `tests/smoke.sh` | Modified | Dry-run, safe update, conflict skip, backup, obsolete reporting. |
| `openspec/specs/pegasus-harness-bootstrap/spec.md` | Modified | Sync safety requirements. |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| User-modified harness files are overwritten | Med | Default to checksum conflict report/skip; require future explicit override. |
| Obsolete managed files cause destructive cleanup | Med | Report only by default; defer prune/remove to explicit future flag. |
| Registry concerns leak into local manifest | Low | Keep registry out of first slice and document manifest boundary. |

## Rollback Plan

Revert the implementation and stop running sync. For synced workspaces, restore files from `.pegasus-bootstrap-ia/backups/<timestamp>/`; skipped conflicts remain untouched.

## Dependencies

- Existing Pegasus manifest data and harness templates.
- Current MCP config generation for `.vscode/mcp.json`.

## Success Criteria

- [ ] Current-workspace sync refreshes safe Pegasus-managed files and updates `.vscode/mcp.json` when safe.
- [ ] User artifacts such as `docs/pegasus/prd.md`, root SDD files, and `docs/pegasus/changes/**` are preserved.
- [ ] User-modified managed files are reported and skipped by default.
- [ ] Real writes produce timestamped backups and a visible plan.
