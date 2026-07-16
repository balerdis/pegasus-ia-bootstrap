<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/tasks.md ownership=full-file -->

# Tasks: {{PROJECT_NAME}}

Use this template inside `docs/pegasus/changes/<change-id>/tasks.md` for change-specific SDD work. This task file is the source of truth for implementation slices; MCP memory may store task status, blockers, summaries, and artifact references only.

Default the generated artifact to English regardless of chat language, persona, dominant approved-source language, or prior artifact language. Use another language only when the user explicitly names it; then localize every human-readable heading, label, and scaffold consistently and run the existing language gate.

Keep tasks small, reviewable, and tied to the proposal, spec, and design.

Use `.github/prompts/sdd-phases.prompt.md` to help maintain this file in VS Code/Copilot. The task list remains the source of truth; prompts and agents should not expand scope on their own.

## Review Workload Forecast

Estimate implementation volume before finalizing tasks. Session preflight review budget and delivery preference are inputs, not this forecast. The orchestrator inspects the forecast after tasks and owns any user decision before apply.

Decision needed before apply: Yes|No
Chained PRs recommended: Yes|No
Chain strategy: stacked-to-main|feature-branch-chain|size-exception|pending
Strategy decision evidence: <exact current-session user quote/message reference|none>
Size-exception approval evidence: <distinct current maintainer approval quote/message reference|none>
400-line budget risk: Low|Medium|High
Estimated authored changed lines: <range>
Estimated generated changed lines: <range|none>
Tests included in estimate: Yes

| Question | Answer |
|----------|--------|
| Estimated authored changed lines | TBD range; includes code, tests, docs, config, and migrations |
| Estimated generated changed lines | TBD range or none; goldens/snapshots/fixtures only |
| Multiple areas touched | TBD |
| 400-line budget risk | Low / Medium / High |
| Chained PRs recommended | Yes / No |
| Decision needed before apply | Yes / No |
| User decision | TBD |
| Chain strategy | stacked-to-main / feature-branch-chain / size-exception / pending |
| Strategy decision evidence | Exact current user decision reference / none |
| Size-exception approval evidence | Distinct current maintainer approval reference / none |

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

Implementation scope: TBD
Test scope: TBD
Focused test command: TBD
Runtime validation: TBD or N/A with reason
Rollback boundary: TBD
Depends on: none or comma-separated work-unit IDs
Required by: none or comma-separated work-unit IDs
Estimated authored code changed lines: 0 or TBD range
Estimated authored test changed lines: 0 or TBD range
Estimated authored docs changed lines: 0 or TBD range
Estimated authored config changed lines: 0 or TBD range
Estimated authored changed lines: TBD total range
Estimated generated changed lines: none or TBD range

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
- When a decision is needed and no explicit current user choice exists, keep `Chain strategy: pending`, `Strategy decision evidence: none`, and `Size-exception approval evidence: none`; never infer a choice from design, risk, delivery preference, memory, architecture, a previous session, defaults, or generic text. `size:exception` requires both a current user selection and a distinct recorded maintainer approval.
- Every work unit states authored code, tests, docs, and config ranges separately, including explicit `0` values, plus one authored total and a generated range or `none`. Component minima and maxima must reconcile with the authored total range.
- Treat `Depends on` and `Required by` as one dependency graph. Every referenced work unit must exist, inverse declarations must agree, and the graph must contain no contradiction, self-dependency, or cycle.

<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/tasks.md -->
