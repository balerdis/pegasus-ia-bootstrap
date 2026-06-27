# Apply Progress: Adapt Bootstrap to VS Code/Copilot

## Slice Implemented

PR 1 / Work Unit 1: CLI planning and layout foundation.

PR 2 / Work Unit 2: Workspace Copilot templates and legacy Cursor compatibility.

PR 3 / Work Unit 3: Opt-in global VS Code/Copilot assets and settings merge.

Completed tasks:

- [x] 1.1 Updated `bin/pegasus-harness-bootstrap` help, constants, plan output, and completion text for Copilot-first usage and legacy Cursor wording.
- [x] 1.2 Added `--install-copilot-global` and `--vscode-target stable|insiders`; kept `--install-cursor-global` as a legacy flag.
- [x] 1.3 Included `.github/`, `AGENTS.md`, `docs/pegasus/`, and `.cursor/` in the CLI workspace inventory used for conflict detection, `--force` overwrite reporting, dry-run output, and managed-surface reporting.
- [x] 2.1 Created `templates/harness/.github/copilot-instructions.md` as workspace-wide Copilot entry instructions.
- [x] 2.2 Created scoped Copilot instruction files for workflow, memory, SDD boundaries, local-first/no-app-code rules, and legacy compatibility.
- [x] 2.3 Created Copilot prompt files for SDD phases, handoff, and Markdown memory workflows that reference `docs/pegasus/`.
- [x] 2.4 Created Copilot custom agent files with a visible Pegasus orchestrator, hidden/secondary SDD agents, and selected OpenCode-inspired agents while excluding `review-risk` and `review-readability`.
- [x] 2.5 Updated `AGENTS.md`, `docs/pegasus/*`, and memory templates for VS Code/Copilot entry points and project-local Markdown memory.
- [x] 2.6 Updated `.cursor/rules/*` as secondary legacy compatibility that points primary usage back to VS Code/Copilot assets.
- [x] 3.1 Created `templates/copilot-global/{agents,instructions,prompts}/` with conservative user-level Copilot assets and no unsupported parity claims.
- [x] 3.2 Added path resolution for Pegasus-managed root under the XDG config root and Stable/Insiders VS Code settings paths.
- [x] 3.3 Implemented Copilot global dry-run reporting without workspace, managed-root, settings, or backup writes.
- [x] 3.4 Added safe settings JSON loading, existing-settings backup, and non-destructive merge for Copilot agent, instruction, and prompt locations.
- [x] 3.5 Preserved Cursor global install behavior as legacy secondary support and updated legacy wording.

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

## Files Changed by Slice 2

| File | Change |
|---|---|
| `templates/harness/.github/copilot-instructions.md` | Added workspace-wide Copilot instructions, primary orchestrator entry point, source-of-truth order, and local-first guardrails. |
| `templates/harness/.github/instructions/*.instructions.md` | Added scoped workflow, memory, SDD boundary, local-first/no-app-code, and legacy compatibility instructions. |
| `templates/harness/.github/prompts/*.prompt.md` | Added prompt coverage for SDD phases, handoff, and memory update workflows. |
| `templates/harness/.github/agents/*.agent.md` | Added the visible `pegasus-orchestrator`, secondary/non-primary SDD agents, and selected specialist agents; omitted `review-risk` and `review-readability`. |
| `templates/harness/AGENTS.md` | Repositioned portable guidance around VS Code/Copilot entry points and Markdown memory. |
| `templates/harness/docs/pegasus/*` | Added Copilot entry-point references to SDD templates. |
| `templates/harness/docs/pegasus/memory/*` | Updated memory templates for Copilot-first recovery and handoff guidance. |
| `templates/harness/.cursor/rules/*` | Marked Cursor rules as secondary legacy compatibility and pointed primary usage back to `.github/`. |
| `bin/pegasus-harness-bootstrap` | Updated completion text now that the orchestrator template exists. |
| `tests/smoke.sh` | Added minimal smoke coverage for generated Copilot template files, orchestrator visibility, hidden secondary agents, legacy guidance, and excluded reviewer names. |
| `openspec/changes/adapt-bootstrap-to-vscode-copilot/tasks.md` | Marked Phase 2 tasks complete only. |
| `openspec/changes/adapt-bootstrap-to-vscode-copilot/apply-progress.md` | Merged Slice 2 progress with existing Slice 1 progress. |

## Files Changed by Slice 3

| File | Change |
|---|---|
| `bin/pegasus-harness-bootstrap` | Implemented Copilot global template discovery, XDG-aware managed root/settings paths, dry-run reporting, asset writes, invalid JSON failure, settings backup, and non-destructive settings merge. |
| `templates/copilot-global/agents/pegasus-global-orchestrator.agent.md` | Added conservative user-level Copilot orchestrator guidance. |
| `templates/copilot-global/instructions/pegasus-global.instructions.md` | Added conservative global Copilot instructions that defer to workspace-local assets. |
| `templates/copilot-global/prompts/pegasus-start.prompt.md` | Added a safe start/resume prompt for Pegasus workspaces. |
| `templates/cursor-global/pegasus-global.mdc` | Reworded Cursor global guidance as secondary legacy compatibility. |
| `tests/smoke.sh` | Added Phase 3 smoke coverage for Copilot global dry-run, Stable/Insiders install paths, settings backup/merge, invalid JSON failure, and legacy Cursor behavior. |
| `openspec/changes/adapt-bootstrap-to-vscode-copilot/tasks.md` | Marked Phase 3 tasks complete only. |
| `openspec/changes/adapt-bootstrap-to-vscode-copilot/apply-progress.md` | Merged Slice 3 progress with prior Slice 1 and Slice 2 progress. |

## Corrective Update After Slice 3 Review

Fresh verification blocked Slice 3 because invalid VS Code `settings.json` was parsed only after workspace files and Pegasus-managed Copilot assets had already been written. The corrective update now validates and computes the Copilot settings merge plan before any non-dry-run writes when `--install-copilot-global` is active.

The write-safety behavior is intentionally limited to Slice 3 global install scope:

- Invalid VS Code settings JSON exits non-zero with a clear `invalid VS Code settings JSON` error before workspace writes.
- Existing invalid settings content is preserved and no settings backup is created.
- Existing Pegasus-managed Copilot assets are not overwritten, and missing managed asset directories are not created.
- Dry-run remains write-free, and legacy Cursor global behavior is unchanged.

## Pre-existing / Out-of-Slice Working Tree Context

| File | Status |
|---|---|
| `openspec/config.yaml` | Modified before this corrective Slice 1 work as approved sdd-init/testing-capabilities context (`sdd-init/pegasus-ia-bootstrap`). It is documented here because it is present in the working tree, but it is not counted as Slice 1 implementation and does not complete Phase 4.2. |

Phase 4.2 remains unchecked in `tasks.md`; stable spec/config alignment is still a later Phase 4 concern unless the orchestrator explicitly scopes it earlier.

## Verification

| Command | Result |
|---|---|
| `bash tests/smoke.sh` | Passed after the corrective update. |
| `bash tests/smoke.sh` | Passed after Slice 2 template and smoke updates. |
| `bash tests/smoke.sh` | Passed after Slice 3 global install and smoke updates. |
| `bash tests/smoke.sh` | Passed after the Slice 3 invalid-settings write-safety fix. |

## Remaining Tasks

- [ ] Phase 4: Docs, config alignment, and full verification coverage, including Phase 4.2 `openspec/config.yaml` alignment if still needed.

## Rollback Notes

For Slice 1 rollback, revert the Slice 1 changes to `bin/pegasus-harness-bootstrap`, `tests/smoke.sh`, this progress file, and the Phase 1 checkbox updates in `tasks.md`. Do not revert `openspec/config.yaml` as part of Slice 1 rollback unless the sdd-init context update is explicitly being undone.

For Slice 2 rollback, remove the new `templates/harness/.github/` workspace templates, restore the prior Cursor-first wording in `templates/harness/AGENTS.md`, `templates/harness/docs/pegasus/*`, `templates/harness/docs/pegasus/memory/*`, and `.cursor/rules/*`, revert the completion text and smoke additions, and uncheck Phase 2 tasks in `tasks.md`.

For Slice 3 rollback, revert Copilot global install changes in `bin/pegasus-harness-bootstrap`, remove `templates/copilot-global/`, restore the prior Cursor global wording, revert Slice 3 smoke additions, and uncheck Phase 3 tasks in `tasks.md`. For any local test/user installation already run, remove the Pegasus-managed Copilot root and restore VS Code `settings.json` from the timestamped backup if needed.

## Notes and Deviations

- Phase 2 created workspace Copilot templates only; Slice 3 now implements global/user Copilot assets, settings merge behavior, and focused smoke coverage for that behavior.
- `.github/copilot-instructions.md` is included in the planned/protected workspace inventory before its template exists so existing user files are not silently ignored during Slice 1 planning.
- Copilot custom agent files use conservative Markdown frontmatter and prose. They do not claim exact parity with OpenCode agents.
- Slice 3 keeps settings merge conservative: existing object values are preserved, existing array values are appended without duplication, invalid JSON fails before any workspace, managed asset, settings, or backup writes, and missing settings files are created without backup.
