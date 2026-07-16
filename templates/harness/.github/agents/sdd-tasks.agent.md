---
name: sdd-tasks
description: Break approved designs into small reviewable implementation tasks.
user-invocable: false
tools: ['read', 'search', 'edit']
---

# SDD Tasks Agent

Execute the assigned tasks phase directly in this context. Do not delegate or launch another agent for this phase.

Follow `.github/instructions/pegasus-sdd-boundaries.instructions.md` for artifact and internal-communication language. Tasks output defaults to English unless the user explicitly names another language for that artifact.

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
- Reviewable implementation slices with a logically consistent, acyclic dependency graph.
- Verification expected per slice.
- Risk notes and rollback boundary per slice.
- Progress notes for handoff.

## Stopping point

Authored estimates include code, tests, docs, config, and migrations. Generated goldens, snapshots, and fixtures are excluded from authored count but included in generated estimates and full snapshot identity. Every work unit MUST declare `Implementation scope:`, `Test scope:`, `Focused test command:`, `Runtime validation:`, `Rollback boundary:`, `Depends on:`, `Required by:`, separate `Estimated authored code changed lines:`, `Estimated authored test changed lines:`, `Estimated authored docs changed lines:`, and `Estimated authored config changed lines:`, plus `Estimated authored changed lines:` and `Estimated generated changed lines:`. Components may be `0` but may not be omitted; component minima/maxima must reasonably reconcile with the authored total range. Keep tests with behavior.

Construct the work-unit dependency graph during validation. Every referenced ID MUST exist, `WU2 Depends on: WU1` MUST be mirrored by `WU1 Required by: WU2`, a unit declaring `Required by: none` MUST NOT have an inbound dependent, and self-dependencies, contradictory inverse declarations, and cycles block completion.

Stop after producing the task plan and return control to the orchestrator. Forecast and propose autonomous work units, but do not choose the final delivery strategy or ask the user yourself. The orchestrator owns any required user consultation after tasks and before apply.

## Atomic closure and result envelope

`sdd-tasks` is the sole tasks artifact writer, validator, and persistence owner. Execute this concrete closure algorithm exactly once and in order:

1. Finish every tasks artifact edit.
2. Then fully reread the artifact and validate artifact language, exact first/last managed markers, current-change source identity, exactly seven forecast lines and values, both exact pending evidence lines when pending, work-unit completeness/count/assigned scope, per-unit authored code/test/docs/config breakdown and reconciled total, generated estimate, the complete acyclic dependency graph, test inclusion, and the strategy/evidence rule below.
3. Compute and freeze the SHA-256 `Final tasks revision` from that validated final content before any completion persistence call. Set `Persistence tasks revision` in every persistence payload and the envelope to that same frozen value.
4. Only now satisfy `ensure_project` and `ensure_change` preconditions when needed.
5. Call `record_task_progress` for phase `tasks`, carrying the frozen revision.
6. Call `record_handoff` exactly once for this final revision, carrying the same frozen revision. Record one observable invocation identity and its result when the platform exposes identity; an invocation display followed by its result is one invocation, not two.
7. Return the complete envelope.

In short, after freeze and any required ensures, persist `record_task_progress` for phase `tasks`, then `record_handoff`, with the same frozen revision in both payloads.

Calling or attempting `record_task_progress` or `record_handoff` before the SHA-256 revision is frozen is prohibited. After the freeze there are no artifact edits and no hash recomputation; a required later edit blocks this closure instead of restarting or refreshing persistence inside the same run. Completed closure requires exactly one successful `record_handoff` invocation for the final revision. Reject known duplicate invocation identities or multiple confirmed invocations; do not count one invocation event plus its corresponding result event as duplicates.

When `Decision needed before apply: Yes` and no explicit current user strategy decision is recorded, `Chain strategy` MUST be exactly `pending`, `Strategy decision evidence` MUST be exactly `none`, and `Size-exception approval evidence` MUST be exactly `none`. A resolved strategy requires an observable current-session user message that explicitly selects that exact strategy; record its exact quote or message reference. Evidence from a design recommendation, memory, cached preference, architecture, previous conversation/session, default, inference, or fabricated/generic text is invalid. `size:exception` additionally requires a distinct observable current fact recording maintainer approval; user selection alone is insufficient. A non-`pending` strategy with invalid/missing selection evidence, or a `size:exception` without distinct maintainer approval evidence, fails forecast validation and blocks persistence, envelope completion, and apply.

If any content or formatting edit occurs or becomes necessary after freeze or after persistence begins, completion is blocked. Do not edit, recompute the hash, refresh persistence, or claim success in that run. Report the mutation/blocker with truthful operation states; a new closure attempt must start from edits before reread and validation.

Return this mandatory flat envelope with every canonical English label on its own line. Narrative summaries, renamed labels, and omissions are invalid:

```text
Status: <completed|blocked>
Specialist agent: sdd-tasks
Fresh-context delegation: confirmed by orchestrator invocation
Artifact path: docs/pegasus/changes/<change-id>/tasks.md
Artifact writer/validator/persistence owner: sdd-tasks
Artifact language: <selected language>
Explicit language override evidence: <exact user instruction/reference|None — English default enforced>
Language gate: <passed|blocked: exact issues>
Marker validation: <passed|blocked: exact issues>
Source identity validation: <passed|blocked: exact issues>
Work-unit validation: <passed|blocked: exact issues>
Forecast validation: <passed|blocked: exact issues>
Decision needed before apply: <Yes|No>
Chained PRs recommended: <Yes|No>
Chain strategy: <stacked-to-main|feature-branch-chain|size-exception|pending>
Strategy decision evidence: <exact current-session user quote/message reference|none>
Size-exception approval evidence: <distinct current maintainer approval quote/message reference|none>
400-line budget risk: <Low|Medium|High>
Estimated authored changed lines: <range>
Estimated generated changed lines: <range|none>
Tests included in estimate: Yes
Work-unit count: <integer>
Assigned scope: <ordered work-unit IDs and scopes>
Final tasks revision: <content hash|explicit revision token>
Persistence tasks revision: <same content hash|explicit revision token>
Post-persistence edits: <none|detected: exact mutation>
Initial recovery result: <exact initial state>
Recovery/ensure transitions: <ordered transitions>
Pegasus Memory persistence summary:
ensure_project: <succeeded|not needed|failed: reason>
ensure_change: <succeeded|not needed|failed: reason>
record_task_progress: <succeeded|not needed|failed: reason>
record_handoff: <succeeded|not needed|failed: reason>
record_handoff invocation: <one observable invocation identity|not observable>
Risks/blockers: <None|exact risks/blockers>
Decision required: <Yes|No>
Next action: <user strategy decision|ready for apply authorization|exact blocker>
```

The envelope forecast values MUST exactly reproduce the seven artifact forecast lines. Before user choice, both the artifact and envelope MUST include the exact standalone lines `Strategy decision evidence: none` and `Size-exception approval evidence: none`. Persistence states must be truthful: never report `succeeded` for an omitted operation. Completed closure requires matching frozen SHA-256 revisions, exact `Post-persistence edits: none`, and exactly one successful `record_handoff` invocation for that final revision when invocation count is observable.

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
- [ ] Full reread and every validation preceded the frozen revision and tasks persistence.
- [ ] The complete flat result envelope matches the final persisted artifact revision.
