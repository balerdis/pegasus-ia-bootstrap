# Tasks: {{PROJECT_NAME}}

Use this template inside `docs/pegasus/changes/<change-id>/tasks.md` for change-specific SDD work. This task file is the source of truth for implementation slices; MCP memory may store task status, blockers, summaries, and artifact references only.

Keep tasks small, reviewable, and tied to the proposal, spec, and design.

Use `.github/prompts/sdd-phases.prompt.md` to help maintain this file in VS Code/Copilot. The task list remains the source of truth; prompts and agents should not expand scope on their own.

## Review Workload Forecast

Estimate before implementation starts. If estimated changes exceed about 400 changed lines or touch multiple unrelated areas, stop and ask whether to split the work into chained PRs.

Decision needed before apply: Yes|No
Chained PRs recommended: Yes|No
400-line budget risk: Low|Medium|High

| Question | Answer |
|----------|--------|
| Estimated changed lines | TBD |
| Multiple areas touched | TBD |
| 400-line budget risk | Low / Medium / High |
| Chained PRs recommended | Yes / No |
| Decision needed before apply | Yes / No |
| User decision | TBD |

## Inputs

| Source | Path | Status |
|--------|------|--------|
| Spec | `docs/pegasus/changes/<change-id>/spec.md` | Approved / Pending / Blocked |
| Design | `docs/pegasus/changes/<change-id>/design.md` | Approved / Pending / Blocked |

## Implementation Slices

Use small slices that can be reviewed independently and rolled back safely. Tasks phase plans work only; it does not implement code.

### Slice 1: TBD

| Field | Value |
|-------|-------|
| Task IDs | 1.1, 1.2 |
| Dependency / order | Starts after approved design |
| Scope | TBD |
| Verification | TBD command or manual check |
| Risk | TBD |
| Rollback boundary | Revert files changed by this slice |

- [ ] 1.1 TBD
- [ ] 1.2 TBD

### Example Slice: Apply deduplication guard

| Field | Value |
|-------|-------|
| Task IDs | EX-1 |
| Dependency / order | After tasks-log and apply-progress templates exist |
| Scope | Add duplicate-check instructions to apply guidance |
| Verification | Confirm generated apply agent mentions duplicate-check and apply-progress |
| Risk | Low; docs-only change |
| Rollback boundary | Revert apply guidance/template edits |

- [ ] EX-1 Add duplicate-check instructions to apply guidance.

## Verification Notes

- Track implementation status, changed files, evidence, blockers, and next action in `docs/pegasus/changes/<change-id>/apply-progress.md`.
- Record commands and outcomes in `docs/pegasus/changes/<change-id>/verify.md`.
- Keep Copilot-generated changes bounded to the currently approved task slice.

## Progress Log

- Also update MCP task progress when available.
- Before starting or delegating a task, check MCP task progress and `docs/pegasus/changes/<change-id>/apply-progress.md` for matching work already in progress or completed.
- Merge progress into existing useful history; do not replace prior task notes, apply-progress, blockers, or completed work.

| Date | Slice/Task | Status | Notes |
|------|------------|--------|-------|
| {{DATE}} | TBD | Not started | TBD |

## No Implementation in Tasks Phase

- Do not edit application/source files from this phase.
- Do not mark apply or verify complete from this phase.
- Stop and ask before apply if any exact guard line above says a decision is needed.
