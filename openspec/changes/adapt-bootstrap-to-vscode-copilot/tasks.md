# Tasks: Adapt Bootstrap to VS Code/Copilot

## Phase 1: CLI Planning and Layout Foundation

- [x] 1.1 Update `bin/pegasus-harness-bootstrap` help, constants, plan output, and completion text for Copilot-first usage and legacy Cursor wording.
- [x] 1.2 Add `--install-copilot-global` and `--vscode-target stable|insiders`; keep `--install-cursor-global` as legacy.
- [x] 1.3 Include `.github/`, `AGENTS.md`, `docs/pegasus/`, and `.cursor/` in conflict, force, dry-run, and reporting paths.

## Phase 2: Workspace Copilot Templates

- [x] 2.1 Create `templates/harness/.github/copilot-instructions.md` as workspace-wide Copilot entry instructions.
- [x] 2.2 Create `templates/harness/.github/instructions/*.instructions.md` for workflow, memory, SDD boundaries, local-first/no-app-code rules, and legacy compatibility guidance.
- [x] 2.3 Create `templates/harness/.github/prompts/*.prompt.md` for SDD phases, handoff, and memory workflows referencing `docs/pegasus/`.
- [x] 2.4 Create `templates/harness/.github/agents/*.agent.md`: visible orchestrator, hidden/secondary SDD agents, and selected OpenCode-inspired agents excluding `review-risk` and `review-readability`.
- [x] 2.5 Update `templates/harness/AGENTS.md`, `templates/harness/docs/pegasus/*`, and memory templates for Copilot entry points and Markdown memory.
- [x] 2.6 Update `templates/harness/.cursor/rules/*` as secondary legacy compatibility that points primary usage back to VS Code/Copilot assets.

## Phase 3: Global/User Copilot Install

- [x] 3.1 Create `templates/copilot-global/{agents,instructions,prompts}/` with conservative assets and no unsupported parity claims.
- [x] 3.2 Add path resolution for Pegasus-managed root `~/.config/pegasus-ia/copilot/{agents,instructions,prompts}/` and Stable/Insiders settings paths respecting `XDG_CONFIG_HOME`.
- [x] 3.3 Implement Copilot global dry-run with no workspace, managed-root, settings, or backup writes.
- [x] 3.4 Back up settings and safely merge `chat.agentFilesLocations`, `chat.instructionsFilesLocations`, and `chat.promptFilesLocations` without removals.
- [x] 3.5 Preserve legacy `templates/cursor-global/` and Cursor global install behavior as secondary, with updated legacy wording.

## Phase 4: Docs, Config, and Verification

- [ ] 4.1 Update `README.md` with Copilot-first usage, layout, orchestrator, opt-in global install, dry-run, backups, Stable/Insiders, and legacy Cursor notes.
- [ ] 4.2 Update `openspec/config.yaml` if still Cursor-first; leave stable spec sync to archive unless orchestrator requires pre-archive alignment.
- [ ] 4.3 Extend `tests/smoke.sh` for flags, dry-run, Copilot layout, agents, excluded reviewers, banned references, conflicts/force, no `.git`, and conditional Cursor mentions.
- [ ] 4.4 Add smoke coverage for Copilot global dry-run/install/update/backups/settings merge for Stable and Insiders using isolated `HOME` and `XDG_CONFIG_HOME`.
- [ ] 4.5 Run `bash tests/smoke.sh` and inspect generated output for unsupported Copilot/OpenCode parity claims.

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 800-1,300 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 CLI/layout → PR 2 workspace templates → PR 3 global install → PR 4 docs/tests/config |
| Delivery strategy | ask-always / ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: pending
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | CLI/options and workspace planning | PR 1 | establishes flags, reports, protection |
| 2 | Copilot workspace templates and legacy `.cursor/` | PR 2 | depends on PR 1 layout |
| 3 | Opt-in global Copilot install/settings merge | PR 3 | isolated global behavior |
| 4 | README, config alignment, smoke verification | PR 4 | proves full change |
