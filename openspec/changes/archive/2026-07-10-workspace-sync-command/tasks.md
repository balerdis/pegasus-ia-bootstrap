# Tasks: Workspace Sync Command

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated changed lines | 260-380 |
| 400-line budget risk | Medium |
| Chained PRs recommended | No |
| Suggested split | Single PR |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Medium

## Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|---|---|---|---|
| 1 | Current-workspace sync slice | PR 1 | `pegasus_harness_bootstrap/cli.py` + `pegasus_harness_bootstrap/manifest.py` + `tests/smoke.sh`; keep `install_and_usage.txt` untouched. |

## Phase 1: Sync Planning Foundation

- [x] 1.1 Add `WorkspaceTarget` and sync-plan data in `pegasus_harness_bootstrap/cli.py` so the current workspace is resolved once and future registry fanout can reuse the same target object.
- [x] 1.2 Extend `pegasus_harness_bootstrap/manifest.py` with checksum/ownership lookup helpers that classify files as `create`, `updateable`, `conflict`, `untouched`, or `obsolete` without storing registry or memory pointers.

## Phase 2: Safe Sync Execution

- [x] 2.1 Wire `--sync-workspace` and `--overwrite-conflicts` into `pegasus_harness_bootstrap/cli.py`, keeping `--dry-run` mandatory for plan-only output and defaulting conflicts to skip.
- [x] 2.2 Implement timestamped backups under `.pegasus-bootstrap-ia/backups/<timestamp>/` before real writes, then update manifest ownership/checksums and `update.last_run_at`.
- [x] 2.3 Refresh `.vscode/mcp.json` from the current MCP config path only when its recorded checksum is safe to replace; preserve `docs/pegasus/prd.md`, root SDD files, `docs/pegasus/changes/**`, and `install_and_usage.txt`.
- [x] 2.4 Report obsolete managed files by default without deleting them, and surface user-modified managed files as conflicts unless `--overwrite-conflicts` is set.

## Phase 3: Verification

- [x] 3.1 Extend `tests/smoke.sh` for `--sync-workspace` help, dry-run no-write, current-workspace-only reporting, and preserved user artifacts.
- [x] 3.2 Add smoke coverage for conflict skip, `--overwrite-conflicts` backup behavior, obsolete report-only output, and `.vscode/mcp.json` refresh.
