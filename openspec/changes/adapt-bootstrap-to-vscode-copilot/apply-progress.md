# Apply Progress: Adapt Bootstrap to VS Code/Copilot

## Slice Implemented

PR 1 / Work Unit 1: CLI planning and layout foundation.

PR 2 / Work Unit 2: Workspace Copilot templates and legacy Cursor compatibility.

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

## Remaining Tasks

- [ ] Phase 3: Global/user Copilot install behavior and settings merge.
- [ ] Phase 4: Docs, config alignment, and full verification coverage, including Phase 4.2 `openspec/config.yaml` alignment if still needed.

## Rollback Notes

For Slice 1 rollback, revert the Slice 1 changes to `bin/pegasus-harness-bootstrap`, `tests/smoke.sh`, this progress file, and the Phase 1 checkbox updates in `tasks.md`. Do not revert `openspec/config.yaml` as part of Slice 1 rollback unless the sdd-init context update is explicitly being undone.

For Slice 2 rollback, remove the new `templates/harness/.github/` workspace templates, restore the prior Cursor-first wording in `templates/harness/AGENTS.md`, `templates/harness/docs/pegasus/*`, `templates/harness/docs/pegasus/memory/*`, and `.cursor/rules/*`, revert the completion text and smoke additions, and uncheck Phase 2 tasks in `tasks.md`.

## Notes and Deviations

- `--install-copilot-global` is accepted and reported as planning-only in this slice. Actual managed asset writes, VS Code settings resolution, backups, and settings merge remain intentionally deferred to Phase 3.
- Phase 2 creates workspace Copilot templates only. Global/user Copilot assets under `templates/copilot-global/`, settings merge behavior, and global install smoke coverage remain deferred to Phase 3 and Phase 4.
- `.github/copilot-instructions.md` is included in the planned/protected workspace inventory before its template exists so existing user files are not silently ignored during Slice 1 planning.
- Copilot custom agent files use conservative Markdown frontmatter and prose. They do not claim exact parity with OpenCode agents.
