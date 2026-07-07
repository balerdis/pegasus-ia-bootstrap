# Verification Report: Bootstrap CLI Lifecycle — Slice 3

## Summary

| Field | Result |
|---|---|
| Change | `bootstrap-cli-lifecycle` |
| Slice | Slice 3 — Uninstall Safety |
| Mode | Fresh-context SDD verification, hybrid persistence |
| Verdict | PASS WITH WARNINGS |
| Scope checked | Workspace uninstall, global VS Code/Copilot uninstall, smoke coverage, apply progress |
| Out-of-scope leakage | No Slice 4 `--new-change` implementation found in changed implementation or tests |

Slice 3 implements manifest-backed workspace uninstall and global VS Code/Copilot uninstall safety. Runtime verification passed, including the full smoke suite, whitespace check, compile check, and an additional marker-managed shared-file preservation probe. The only warning is reviewer workload: the slice is focused but exceeds the 400-line review budget at 442 changed lines.

## Completeness

| Task | Status | Evidence |
|---|---|---|
| 3.1 Add workspace uninstall planning/apply flow with `--dry-run`, Pegasus-managed removals only, and empty-directory cleanup | PASS | `pegasus_harness_bootstrap/cli.py` adds `--uninstall-workspace`, loads `.pegasus-bootstrap-ia/manifest.json`, plans removals from manifest records, removes marker blocks, preserves files without Pegasus markers, and removes only empty directories. |
| 3.2 Add global VS Code/Copilot uninstall with settings backup before mutation and user setting preservation | PASS | `--uninstall-copilot-global` removes Pegasus settings locations and managed assets only, writes a timestamped settings backup when settings mutate, and preserves unrelated settings/assets. Invalid settings abort before asset removal. |
| 3.3 Test invalid/global settings, backups, dry-run, real removal, and non-empty directory preservation | PASS | `tests/smoke.sh` covers workspace dry-run/apply, non-empty directory preservation, global dry-run/apply, backup creation, invalid settings safety, managed asset removal, and user asset/setting preservation. |

## Runtime Evidence

| Command | Result | Notes |
|---|---|---|
| `bash tests/smoke.sh` | PASS | Full smoke suite completed successfully. |
| `git diff --check` | PASS | No whitespace errors. |
| `python3 -m compileall pegasus_harness_bootstrap` | PASS | Package modules compile. |
| Marker-managed preservation probe | PASS | Added user content to generated `AGENTS.md`, ran `--uninstall-workspace`, verified user content remained and Pegasus marker was removed. |

## Spec Compliance Matrix

| Requirement / Scenario | Slice 3 Applicability | Status | Evidence |
|---|---:|---|---|
| Workspace uninstall safety / Dry-run and cleanup | In scope | PASS | Smoke verifies dry-run writes nothing, real uninstall removes managed files/manifest, and non-empty `docs/pegasus` and `.github/agents` directories with user files remain. Additional probe verifies marker-managed shared-file user content survives. |
| Global VS Code/Copilot uninstall safety / Global uninstall preserves settings | In scope | PASS | Smoke verifies backup creation, removal of Pegasus settings entries, preservation of `editor.fontSize`, preservation of `/user/agents`, preservation of non-managed global asset, and invalid settings abort before mutation. |
| Manifest-owned lifecycle metadata / Manifest supports uninstall | Dependency from Slice 2 | PASS | Workspace uninstall uses the manifest install records as the source of truth. Smoke still verifies manifest contents and forbidden active/last pointers. |
| MCP-first lifecycle boundary / no generated Markdown memory backend | Boundary check | PASS | Smoke asserts no generated `docs/pegasus/memory` directory and checks the exact unavailable-memory warning. No changed Slice 3 implementation reintroduces Markdown memory persistence. |
| Change-cycle creation starts with PRD only | Out of scope for Slice 3 | SKIPPED | Slice 4 remains unchecked. No `--new-change`, `new_change`, or `docs/pegasus/changes` implementation was found in `pegasus_harness_bootstrap/cli.py` or `tests/smoke.sh`. |

## Design Coherence

| Design Decision | Status | Evidence |
|---|---|---|
| Uninstall uses manifest-backed ownership | PASS | `load_workspace_manifest()` rejects missing, invalid, or non-Pegasus manifests before workspace uninstall planning. |
| Remove only Pegasus-managed content | PASS | Workspace uninstall requires Pegasus ownership markers before file mutation/removal; global uninstall requires `PEGASUS-COPILOT-GLOBAL` marker before asset removal. |
| Back up global settings before mutation | PASS | `plan_copilot_global_uninstall()` computes a backup path only when settings change; `apply_copilot_global_uninstall()` writes the backup through `write_copilot_settings()` before writing updated settings. |
| Preserve MCP-first memory | PASS | Generated workspace smoke still rejects generated Markdown memory backend and preserves the exact MCP-unavailable warning. |
| Chained PR review boundary | WARNING | The slice is focused, but `git diff --stat` reports 433 insertions and 9 deletions, totaling 442 changed lines, over the 400-line review budget. |

## Codebase Memory Evidence

| Check | Result |
|---|---|
| CBM index status | Ready for project key `home-serg-ia-scripts-pegasus-ia-bootstrap` with 1052 nodes and 1143 edges. |
| CBM changed surface | Reported tracked changes in `openspec/changes/bootstrap-cli-lifecycle/apply-progress.md`, `openspec/changes/bootstrap-cli-lifecycle/tasks.md`, `pegasus_harness_bootstrap/cli.py`, and `tests/smoke.sh`. |
| CBM limitation | Initial lookup by display project name failed; verification used the indexed project key. Working-tree code inspection and runtime tests were the source of truth. |

## Issues

### Critical

None.

### Warnings

- Review budget exceeded: Slice 3 is 442 changed lines (`433 insertions + 9 deletions`). Scope is still limited to uninstall safety, but chained-PR policy requires maintainer acceptance of this slight size exception or a follow-up split before PR review.

### Suggestions

- If reviewer load becomes a concern, split the smoke-only additions from the implementation into a dedicated review slice only if the project accepts cross-slice test/code separation for this already-applied work; otherwise keep tests with behavior and record the size exception.

## Changed Files Reviewed

- `PRD-bootstrap-cli-lifecycle.md`
- `openspec/changes/bootstrap-cli-lifecycle/proposal.md`
- `openspec/changes/bootstrap-cli-lifecycle/specs/pegasus-harness-bootstrap/spec.md`
- `openspec/changes/bootstrap-cli-lifecycle/design.md`
- `openspec/changes/bootstrap-cli-lifecycle/tasks.md`
- `openspec/changes/bootstrap-cli-lifecycle/apply-progress.md`
- `openspec/changes/bootstrap-cli-lifecycle/verify-slice-1.md`
- `openspec/changes/bootstrap-cli-lifecycle/verify-slice-2.md`
- `pegasus_harness_bootstrap/cli.py`
- `tests/smoke.sh`

## Final Verdict

PASS WITH WARNINGS — Slice 3 is functionally complete, runtime verification passed, no Slice 4 implementation leaked in, and no safety blocker was found. The warning is the 442-line review burden above the 400-line budget.
