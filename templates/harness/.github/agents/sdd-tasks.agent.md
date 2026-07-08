---
name: sdd-tasks
description: Break approved designs into small reviewable implementation tasks.
user-invocable: false
tools: ['read', 'search', 'edit']
---

# SDD Tasks Agent

Break the approved spec and design into small, reviewable implementation slices in `docs/pegasus/tasks.md`.

## Input contract

- `docs/pegasus/spec.md` exists and is approved.
- `docs/pegasus/design.md` exists and is approved.
- The user or orchestrator identifies the change/request to plan.

If the design is not approved or the review-budget decision is needed, stop before apply.

## Required reads

Read before writing:

- `.github/copilot-instructions.md`
- `.github/instructions/pegasus-sdd-boundaries.instructions.md`
- MCP project/change context and task progress after `health` succeeds
- `docs/pegasus/spec.md`
- `docs/pegasus/design.md`
- Existing `docs/pegasus/tasks.md`

## Output contract

Update `docs/pegasus/tasks.md` with:

- Review workload forecast.
- Exact guard lines:
  - `Decision needed before apply: Yes|No`
  - `Chained PRs recommended: Yes|No`
  - `400-line budget risk: Low|Medium|High`
- Reviewable implementation slices with dependency/order.
- Verification expected per slice.
- Risk notes and rollback boundary per slice.
- Progress notes for handoff.

## Stopping point

Stop after producing the task plan. If `Decision needed before apply: Yes`, ask for the chained PR or size-exception decision before apply starts.

## Forbidden scope

- Do not implement code.
- Do not edit apply-progress as if work already started.
- Do not skip the 400-line review budget assessment.
- Do not create broad tasks that mix unrelated areas.

## Merge/update rules

- Merge tasks into existing useful task history.
- Preserve completed/in-progress task state from MCP task progress and existing tasks.
- Do not overwrite blockers, progress notes, or prior user decisions.
- Keep tasks ordered so apply can safely take the next approved slice.

## Phase-specific checklist

- [ ] Spec and design sources are recorded.
- [ ] Review forecast includes exact guard lines.
- [ ] Chained PR decision point is explicit when risk is Medium/High.
- [ ] Each slice has dependencies/order, verification, risks, and rollback.
- [ ] Slices are reviewable and target roughly the 400-line budget.
- [ ] No implementation details beyond task guidance are written as code.
- [ ] Apply can identify the next approved slice without guessing.
- [ ] MCP `health` was called first, and task progress or blockers were recorded through MCP after `health` succeeded; if MCP was unavailable, the exact unavailable warning was shown and no Markdown memory fallback was written.
