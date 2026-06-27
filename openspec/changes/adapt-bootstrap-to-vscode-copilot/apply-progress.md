# Apply Progress: Adapt Bootstrap to VS Code/Copilot

## Slice Implemented

PR 1 / Work Unit 1: CLI planning and layout foundation.

Completed tasks:

- [x] 1.1 Updated `bin/pegasus-harness-bootstrap` help, constants, plan output, and completion text for Copilot-first usage and legacy Cursor wording.
- [x] 1.2 Added `--install-copilot-global` and `--vscode-target stable|insiders`; kept `--install-cursor-global` as a legacy flag.
- [x] 1.3 Included `.github/`, `AGENTS.md`, `docs/pegasus/`, and `.cursor/` in the CLI workspace inventory used for conflict detection, `--force` overwrite reporting, dry-run output, and managed-surface reporting.

## Corrective Update After Slice 1 Review

Fresh verification blocked the first Slice 1 apply because `.github` paths were only listed as managed surfaces, not protected by the same conflict/force inventory as generated template-backed files. The corrective update now adds planned Copilot workspace paths to the CLI workspace inventory without creating Phase 2 templates.

The inventory is intentionally limited to Slice 1 planning/protection behavior:

- Existing `.github/copilot-instructions.md` now causes a preserved conflict without `--force`.
- `--force` reports `.github/copilot-instructions.md` in the overwrite inventory.
- Dry-run and normal plan output continue to report the Copilot-first workspace surfaces.
- Actual `.github` template files remain out of scope until Phase 2.

## Files Changed by Slice 1

| File | Change |
|---|---|
| `bin/pegasus-harness-bootstrap` | Repositioned CLI messaging around VS Code/Copilot, added Copilot global planning flags, listed managed workspace surfaces, and added planned Copilot paths to the conflict/force/dry-run workspace inventory. |
| `tests/smoke.sh` | Added smoke assertions for Copilot flags, Copilot-first dry-run layout reporting, planning-only Copilot global dry-run behavior, and `.github/copilot-instructions.md` conflict/force inventory coverage. |
| `openspec/changes/adapt-bootstrap-to-vscode-copilot/tasks.md` | Marks Phase 1 tasks complete for this slice only; later phases remain unchecked. |
| `openspec/changes/adapt-bootstrap-to-vscode-copilot/apply-progress.md` | Records this apply slice, corrective review response, verification, remaining tasks, and rollback notes. |

## Pre-existing / Out-of-Slice Working Tree Context

| File | Status |
|---|---|
| `openspec/config.yaml` | Modified before this corrective Slice 1 work as approved sdd-init/testing-capabilities context (`sdd-init/pegasus-ia-bootstrap`). It is documented here because it is present in the working tree, but it is not counted as Slice 1 implementation and does not complete Phase 4.2. |

Phase 4.2 remains unchecked in `tasks.md`; stable spec/config alignment is still a later Phase 4 concern unless the orchestrator explicitly scopes it earlier.

## Verification

| Command | Result |
|---|---|
| `bash tests/smoke.sh` | Passed after the corrective update. |

## Remaining Tasks

- [ ] Phase 2: Workspace Copilot templates.
- [ ] Phase 3: Global/user Copilot install behavior and settings merge.
- [ ] Phase 4: Docs, config alignment, and full verification coverage, including Phase 4.2 `openspec/config.yaml` alignment if still needed.

## Rollback Notes

Revert the Slice 1 changes to `bin/pegasus-harness-bootstrap`, `tests/smoke.sh`, this progress file, and the Phase 1 checkbox updates in `tasks.md`. Do not revert `openspec/config.yaml` as part of Slice 1 rollback unless the sdd-init context update is explicitly being undone.

## Notes and Deviations

- `--install-copilot-global` is accepted and reported as planning-only in this slice. Actual managed asset writes, VS Code settings resolution, backups, and settings merge remain intentionally deferred to Phase 3.
- No Phase 2 Copilot workspace templates were created in this slice.
- `.github/copilot-instructions.md` is included in the planned/protected workspace inventory before its template exists so existing user files are not silently ignored during Slice 1 planning.
