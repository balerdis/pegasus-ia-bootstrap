# SDD Tasks Phase Contract

## Scope And Authority

This manually loaded phase reference owns only the detailed `sdd-tasks` planning, validation, and persistence workflow. It is subordinate to the current macro and does not own the canonical result schema or transport mechanics. Tasks forecasts work; only the orchestrator consults the user and authorizes delivery strategy or Apply.

## Sources And Isolation

Read `.github/copilot-instructions.md`, `.github/instructions/pegasus-sdd-boundaries.instructions.md`, and `.github/instructions/pegasus-memory.instructions.md`. Call Pegasus Memory `health` first and, when healthy, recover only the active project's current-change context, task progress, decisions, blockers, and handoff. Read the exact current-change approved Spec and Design, then the existing Tasks artifact and canonical managed Tasks template/current placeholder for structure only.

The approved current-change Spec and Design are the only default requirement and architecture sources. Do not inspect or reuse neighboring or unrelated changes for content, scope, decisions, estimates, wording, style, or formatting. Consult another change only when a current source, reliable active Pegasus Memory context, or direct user instruction explicitly declares a dependency; disclose the reference, exact purpose, and that it was not an implicit scope source. Ambiguous memory never resolves a material gap.

Record exact Spec and Design source paths, approval state, and requirement/design traceability for each work unit. A missing, contradictory, or unverified detail that can alter scope, behavior, acceptance, dependency order, risk, estimate, or an Apply gate is material. Resolve it only from reliable current-change evidence or a direct user answer, or retain a visible gap with owner, impact, next step, and needed-by gate. A blocking gap stops finalization; do not invent a default.

## Reviewable Work Units

Plan small autonomous units that keep behavior with its tests and map cleanly to commits or chained PR slices. Each unit MUST have a unique ID and declare `Implementation scope:`, `Test scope:`, `Focused test command:`, `Runtime validation:`, `Rollback boundary:`, `Depends on:`, `Required by:`, `Estimated authored code changed lines:`, `Estimated authored test changed lines:`, `Estimated authored docs changed lines:`, `Estimated authored config changed lines:`, `Estimated authored changed lines:`, and `Estimated generated changed lines:`. Components may be `0` but cannot be omitted. Include migrations in authored config and generated goldens, snapshots, and fixtures only in generated estimates and complete snapshot identity.

State behavior verified by every test, not only filenames or test types. Give each unit a clear start state, finished state, focused command, runtime harness scenario or explicit N/A reason, independently useful rollback boundary, risks, and expected handoff evidence. Do not implement code, edit apply-progress as started work, create verification verdicts, or mix unrelated areas. Preserve completed/in-progress state, prior blockers, progress, and user decisions when merging an existing plan. Order units so Apply can identify the next approved slice without guessing.

Build the dependency graph during planning. Every referenced ID MUST exist; `WU2 Depends on: WU1` MUST be mirrored by `WU1 Required by: WU2`; `Required by: none` forbids an inbound dependent. Reject self-dependencies, contradictory inverse declarations, missing nodes, and cycles.

## Review Workload Forecast

The artifact MUST contain exactly these seven standalone forecast lines once, with exact labels and allowed values:

```text
Decision needed before apply: Yes|No
Chained PRs recommended: Yes|No
Chain strategy: stacked-to-main|feature-branch-chain|size-exception|pending
400-line budget risk: Low|Medium|High
Estimated authored changed lines: <range>
Estimated generated changed lines: <range|none>
Tests included in estimate: Yes
```

Authored count includes code, tests, docs, config, and migrations. Generated count is separate but generated files remain in full snapshot identity. Parse every component and total as an inclusive integer range: `N` means `N-N`, commas are digit separators, and negatives, reversed ranges, malformed values, and non-integers are invalid. For every unit, the four component minima MUST sum exactly to its authored minimum and maxima MUST sum exactly to its authored maximum. All unit authored minima and maxima MUST sum exactly to the global authored forecast endpoints. Tests are always included.

Forecast review risk and recommend chaining around the 400 authored-line review budget. Include current review-budget and delivery-preference inputs without treating preflight preference as a final decision. When `Decision needed before apply: Yes` and no explicit current-session user selection exists, require exact `Chain strategy: pending`, `Strategy decision evidence: none`, and `Size-exception approval evidence: none`. A resolved strategy requires observable current-session user evidence selecting that exact strategy. Design recommendations, memory, cached preferences, architecture, earlier sessions, defaults, inference, and fabricated or generic text are invalid. `size:exception` additionally requires distinct observable current maintainer approval; selection alone is insufficient.

High risk, chaining recommended, decision required, or forecast over the session review budget blocks Apply until the orchestrator obtains a valid current-session strategy decision. Tasks never asks the strategy question or launches Apply.

## Artifact And Validation

Preserve existing Pegasus managed markers and edit only between them. A new artifact starts exactly `<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/tasks.md ownership=full-file -->` and ends exactly `<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/tasks.md -->`, using the actual change ID. Construct the result artifact path directly as `docs/pegasus/changes/` + supplied current change ID + `/tasks.md`; never copy, shorten, or derive it from a tool result, filename, basename, or artifact metadata. It MUST equal the separately supplied canonical output path.

Select artifact language under the boundaries contract: an explicit user instruction naming the Tasks artifact language wins; otherwise English is mandatory. Return exact override evidence for non-English output. Validate coherent selected-language headings, labels, work-unit prose, markers, and source identity; do not infer an override from chat, source, persona, or previous artifact language.

Finish every content and formatting edit, then completely reread the artifact. Validate language, exact first/last markers, current-change source identity and traceability, canonical path equality, exactly seven forecast lines and allowed values, both pending evidence lines when pending, all material gaps, work-unit completeness/count/assigned scope, exact component and aggregate endpoint reconciliation, generated estimates, complete acyclic dependency graph, behavior-bearing tests, rollback boundaries, and strategy evidence. `Work-unit validation: passed`, `Forecast validation: passed`, and completed status are prohibited while any check is invalid.

If an estimate is invalid, correct it before freeze, then perform a NEW complete reread and every validation from the beginning. If correction or revalidation cannot complete, return blocked without completion persistence.

## Atomic Persistence And Apply Readiness

Execute one irreversible writer thread exactly once: edit → complete reread → all validations → revision freeze → ensure preconditions when needed → `record_task_progress` for phase `tasks` → exactly one `record_handoff` → immutable result. Compute `Final tasks revision` as SHA-256 of the validated final artifact and set every persistence payload's `Persistence tasks revision` to that same frozen value before any completion persistence call.

Calling or attempting either completion persistence operation before freeze is prohibited. Carry the same frozen revision in both calls and record one observable handoff invocation identity and its result when exposed; one invocation display plus its matching result is one invocation, not two. Reject known duplicate identities or multiple confirmed invocations. Truthfully report omitted or failed operations; never call an omitted operation `succeeded`.

After freeze there are no artifact edits, formatting changes, hash recomputation, persistence refreshes, or result reconstruction. If any mutation occurs or becomes necessary, block this closure, report exact operation states and the mutation, and require a new run beginning before reread. Completed closure requires equal final/persistence revisions, exact decoded `Post-persistence edits: none`, all validations passed, and exactly one successful final-revision handoff when observable.

Return control to the orchestrator after the task plan. The orchestrator retains its unchanged validation/copy behavior and owns consultation before Apply. Tasks completion is plan readiness, not approval or implementation authorization.
