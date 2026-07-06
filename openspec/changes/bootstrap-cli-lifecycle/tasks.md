# Tasks: Bootstrap CLI Lifecycle

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 600-900 full change; 180-300 Slice 1 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 installability + README; PR 2 manifest/conflicts; PR 3 uninstall; PR 4 new-change |
| Delivery strategy | ask-always |
| Chain strategy | stacked-to-main |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Installable CLI with wrapper and README cleanup | PR 1 | Independent; preserves current behavior. |
| 2 | Manifest-owned lifecycle metadata and conflict safety | PR 2 | Depends on package boundary. |
| 3 | Workspace and global uninstall safety | PR 3 | Depends on manifest inventory. |
| 4 | PRD-only change-cycle creation | PR 4 | Depends on manifest workspace detection. |

## Slice 1: Installability and README Cleanup

- [x] 1.1 Create `pyproject.toml` with package metadata, Python requirement, and `pegasus-harness-bootstrap` console entry point.
- [x] 1.2 Create `pegasus_harness_bootstrap/cli.py` by moving existing CLI behavior without lifecycle feature expansion.
- [x] 1.3 Keep `bin/pegasus-harness-bootstrap` as a thin compatibility wrapper importing package `main()`.
- [x] 1.4 Update `tests/smoke.sh` to verify editable entry point and wrapper both run `--project-name demo --dry-run`.
- [x] 1.5 Update `README.md` quick path to `.venv` editable and `pipx` usage; remove stale `docs/pegasus/memory/*` layout references.

## Slice 2: Manifest and Conflict Safety

- [x] 2.1 Add `pegasus_harness_bootstrap/manifest.py` for install, ownership, update, uninstall, and workspace metadata; exclude active/last change pointers.
- [x] 2.2 Add planning support so existing generated-path conflicts report and skip writes unless `--force` is used.
- [x] 2.3 Update templates or markers needed to prove Pegasus-managed ownership.
- [x] 2.4 Extend smoke tests for manifest JSON and no-overwrite conflict behavior.

## Slice 3: Uninstall Safety

- [x] 3.1 Add workspace uninstall planning/apply flow with `--dry-run`, Pegasus-managed removals only, and empty-directory cleanup.
- [x] 3.2 Add global VS Code/Copilot uninstall with settings backup before mutation and user setting preservation.
- [x] 3.3 Test invalid/global settings, backups, dry-run, real removal, and non-empty directory preservation.

## Slice 4: Change-Cycle Creation

- [x] 4.1 Add `--new-change <change-id>` flow that creates only `docs/pegasus/changes/<change-id>/prd.md`.
- [x] 4.2 Test no proposal/spec/design/tasks/apply-progress/verify files are created.

## Verification, Risk, and Rollback

- [ ] 5.1 Run `tests/smoke.sh` after each slice and record commands/results in apply or verify artifacts.
- [ ] 5.2 Verify MCP-first boundary remains: no generated `docs/pegasus/memory/` backend and exact unavailable-memory warning preserved.
- [ ] 5.3 Roll back Slice 1 by reverting package/refactor/docs; later slices roll back by reverting their PR only.
