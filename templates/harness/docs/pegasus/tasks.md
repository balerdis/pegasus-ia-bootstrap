# Tasks: {{PROJECT_NAME}}

Keep tasks small, reviewable, and tied to the proposal, spec, and design.

Use `.github/prompts/sdd-phases.prompt.md` to help maintain this file in VS Code/Copilot. The task list remains the source of truth; prompts and agents should not expand scope on their own.

## Review Workload Forecast

Estimate before implementation starts. If estimated changes exceed about 400 changed lines or touch multiple unrelated areas, stop and ask whether to split the work into chained PRs.

| Question | Answer |
|----------|--------|
| Estimated changed lines | TBD |
| Multiple areas touched | TBD |
| 400-line budget risk | TBD |
| Chained PRs recommended | TBD |
| User decision | TBD |

## Phase 1: TBD

- [ ] 1.1 TBD
- [ ] 1.2 TBD

## Verification Notes

- Track implementation status, changed files, evidence, blockers, and next action in `docs/pegasus/apply-progress.md`.
- Record commands and outcomes in `docs/pegasus/verify.md`.
- Keep Copilot-generated changes bounded to the currently approved task slice.

## Progress Log

- Also update `docs/pegasus/memory/tasks-log.md` when task status changes.
- Before starting or delegating a task, check `docs/pegasus/memory/tasks-log.md` and `docs/pegasus/apply-progress.md` for matching work already in progress or completed.
- Merge progress into existing useful history; do not replace prior task notes, apply-progress, blockers, or completed work.
