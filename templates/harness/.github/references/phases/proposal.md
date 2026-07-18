# SDD Proposal Phase Contract

## Scope And Authority

This manually loaded phase reference owns only the detailed `sdd-proposal` workflow. It is subordinate to the current macro and authoritative over shared references for Proposal-specific behavior. It does not approve the proposal or authorize Spec.

## Sources And Isolation

Read the exact current-change PRD directly before drafting. Use it as the only default product-content source. Use the canonical managed proposal template and current-change placeholder as the only default structure/format source. Do not search, read, inspect, or reuse neighboring or unrelated change artifacts for content, scope, decisions, assumptions, wording, style, or formatting.

Consult another change only when the current PRD, active Pegasus Memory context, or direct user instruction explicitly declares its dependency or relation. Add a Related Change Traceability entry naming the reference, exact purpose/dependency, and that it was not used as an implicit scope source. Never implicitly inherit scope, decisions, assumptions, wording, or style.

Call Pegasus Memory `health` first. When healthy, recover current project/change decisions, task progress, handoff, and learnings. Pegasus Memory is supporting context, not product-decision evidence; `ambiguous` context never resolves a material gap.

## Proposal Content

Bridge the approved PRD to future Spec with PRD source/approval status, consulted context, intent, current-state gap and impact, scope, users/situations, a lightweight product/workflow direction, explicit PRD-supported assumptions, risks and mitigations, product/workflow rollback, acceptance/readiness criteria, and handoff items for requirements/scenarios.

Every product claim, scope item, user, rule, preserved assumption, and acceptance statement MUST trace to explicit PRD text. Do not label an unstated detail as a preserved assumption. Do not add a requirements matrix, technical design, architecture, data models, implementation tasks, PR splitting, review-budget decisions, or code changes. Stop before Spec, Design, Tasks, and implementation.

## Material Gaps

A material gap is missing, contradictory, or unverified detail that can change scope, user-visible behavior, acceptance, risk, or a phase gate. Classify every gap before writing. A blocking gap asks one concise question and stops before writing/finalizing. A non-blocking gap belongs only in `Open Decisions / Material Gaps` with owner, impact, next step, and needed-by gate; never invent a default.

Before marker validation and persistence, reconcile every material gap to exactly one terminal disposition: resolved by explicit reliable current-change evidence or direct user answer recorded in the gap section, or visibly unresolved with all required fields. Do not leave a gap implicit, duplicated, or as an unqualified `TBD`. The final response must summarize resolved and unresolved gaps and must not claim no open questions/decisions while any remain.

## Artifact Validation

Preserve existing Pegasus managed markers exactly and edit only between them. A new proposal's exact first line is `<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/proposal.md ownership=full-file -->`; its exact final line is `<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/proposal.md -->`, with the actual change ID. Never reuse the PRD or root proposal path.

Select artifact language under the shared language contract. Preserve standard orthography and diacritics; Spanish technical artifacts use neutral professional Spanish, including correct forms such as `única`, `técnicas`, and `implementación`, without conversational persona wording.

After writing and gap reconciliation, reread the complete artifact and validate exact first/last marker lines. Repair by preserving/restoring both markers and editing only between them, then reread and revalidate. Do not persist or report success until validation passes. If it cannot pass, stop with a file-only failure.

## Persistence And Return

Only after validation, merge proposal status, assumptions, scope decisions, risks, approval state, gaps, and artifact references into useful Pegasus Memory history. Complete truthful terminal outcomes for `ensure_project`, `ensure_change`, `record_artifact`, `record_observation`, `record_task_progress`, and `record_handoff`; when healthy, record task progress before handoff. Required artifact/observation failure adds `Proposal persistence: file-only — <reason>` and blocks advancement.

The user-facing response includes exactly this heading and all six status lines, even when memory is unavailable:

```text
MCP persistence summary:
ensure_project: <succeeded|not needed|failed: reason>
ensure_change: <succeeded|not needed|failed: reason>
record_artifact: <succeeded|not needed|failed: reason>
record_observation: <succeeded|not needed|failed: reason>
record_task_progress: <succeeded|not needed|failed: reason>
record_handoff: <succeeded|not needed|failed: reason>
```

Return control for proposal review/approval before Spec.
