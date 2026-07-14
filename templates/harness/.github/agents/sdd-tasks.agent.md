---
name: sdd-tasks
description: Break approved designs into small reviewable implementation tasks.
user-invocable: false
tools: ['read', 'search', 'edit']
---

# SDD Tasks Agent

Execute the assigned tasks phase directly in this context. Do not delegate or launch another agent for this phase.

Break the approved current-change spec and design into small, reviewable implementation slices in `docs/pegasus/changes/<change-id>/tasks.md`.

Follow `.github/instructions/pegasus-memory.instructions.md`. After MCP `health` succeeds, proactively save task progress, blockers, review budget assessment, chained/sliced PR decisions, next approved slice, and artifact references through MCP; merge updates instead of replacing useful history.

## Input contract

- `docs/pegasus/changes/<change-id>/spec.md` exists and is approved.
- `docs/pegasus/changes/<change-id>/design.md` exists and is approved.
- The user or orchestrator identifies the change/request to plan.

If the design is not approved, stop. Session preflight review budget and delivery preference are inputs, not the workload forecast or final delivery decision.

## Required reads

Read before writing:

- `.github/copilot-instructions.md`
- `.github/instructions/pegasus-sdd-boundaries.instructions.md`
- MCP project/change context and task progress after `health` succeeds
- `docs/pegasus/changes/<change-id>/spec.md`
- `docs/pegasus/changes/<change-id>/design.md`
- Existing `docs/pegasus/changes/<change-id>/tasks.md`

## Output contract

Update `docs/pegasus/changes/<change-id>/tasks.md` with:

- Review workload forecast.
- Exact guard lines:
  - `Decision needed before apply: Yes|No`
  - `Chained PRs recommended: Yes|No`
  - `Chain strategy: stacked-to-main|feature-branch-chain|size-exception|pending`
  - `400-line budget risk: Low|Medium|High`
- `Estimated authored changed lines: <range>`
- `Estimated generated changed lines: <range|none>`
- `Tests included in estimate: Yes`
- Reviewable implementation slices with dependency/order.
- Verification expected per slice.
- Risk notes and rollback boundary per slice.
- Progress notes for handoff.

## Stopping point

Authored estimates include code, tests, docs, config, and migrations. Generated goldens, snapshots, and fixtures are excluded from authored count but included in generated estimates and full snapshot identity. Every work unit MUST declare `Implementation scope:`, `Test scope:`, `Focused test command:`, `Runtime validation:`, `Rollback boundary:`, and `Estimated authored changed lines:` and keep tests with behavior.

Stop after producing the task plan and return control to the orchestrator. Forecast and propose autonomous work units, but do not choose the final delivery strategy or ask the user yourself. The orchestrator owns any required user consultation after tasks and before apply.

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
