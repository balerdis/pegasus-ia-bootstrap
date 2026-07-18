# SDD Spec Phase Contract

## Scope And Authority

This manually loaded phase reference owns only the detailed `sdd-spec` workflow. It is subordinate to the current macro and authoritative over shared references for Spec-specific behavior. It does not approve the Spec or authorize Design.

## Sources And Isolation

Read the exact current-change PRD and proposal directly before drafting, then read the existing current-change Spec and the canonical managed Spec template/current placeholder for structure only. Use the approved PRD and proposal as the only default product and requirements sources. Do not search, read, inspect, or reuse neighboring or unrelated change artifacts for requirements, scenarios, wording, style, or formatting.

Consult another change only when the current PRD, active Pegasus Memory context, or direct user instruction explicitly declares its dependency or relation. Add a `Related Change Traceability` entry naming the reference, exact purpose/dependency, and that it was not used as an implicit scope source. Never implicitly inherit scope, decisions, assumptions, wording, or style.

Follow `.github/instructions/pegasus-memory.instructions.md`. Call Pegasus Memory `health` first. When healthy, recover current project/change decisions, task progress, handoff, and learnings. Pegasus Memory is supporting context, not requirements evidence; an ambiguous MCP response never resolves a material gap.

## Acceptance Contract

Record exact PRD/proposal paths and observed approval status. Define testable normative requirements using MUST/SHOULD/MAY language. Every normative requirement MUST trace to explicit approved PRD/proposal evidence or a visible unresolved gap and MUST have at least one OpenSpec-style `GIVEN` / `WHEN` / `THEN` acceptance scenario.

Capture acceptance-level edge cases, failure behavior, non-goals, requirement/source traceability, and related-change disclosure. Preserve the approved scope and user-visible behavior. Do not design architecture, choose implementation details, create task checklists or PR slices, edit code, or widen scope. Stop before Design, Tasks, and implementation.

## Material Gaps

A material gap is missing, contradictory, or unverified detail that can change scope, user-visible behavior, acceptance, risk, or a phase gate. Reconcile every requirements or acceptance gap before persistence and final response. Resolve it only with explicit reliable current-change evidence or a direct user answer, recording that evidence, or retain a visible unresolved entry with owner, impact, next step, and needed-by gate. Never invent a default or use ambiguous Pegasus Memory context as resolution.

A blocking gap asks one concise question and stops before finalization. A non-blocking gap remains visible with every required field. Do not leave a gap implicit, duplicated, or as an unqualified `TBD`; summarize resolved and unresolved gaps truthfully in the result.

## Artifact Validation

Preserve existing Pegasus managed markers exactly and edit only between them. A new Spec's exact first line is `<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/spec.md ownership=full-file -->`; its exact final line is `<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/spec.md -->`, with the actual change ID.

Before writing, select exactly one artifact language under the shared language contract: an explicit user request naming the Spec language wins; otherwise use English. Chat, persona, approved-source language, and prior artifacts never infer an override. Keep human-readable headings, table labels, metadata labels, and prose consistently in that language. Immutable markers, identifiers, deliberately standardized RFC 2119 terms, `GIVEN` / `WHEN` / `THEN`, canonical enum values, paths, code, tools, source references, and established technical terms may remain unchanged.

After writing and gap reconciliation, reread the complete artifact. Validate exact first/final markers, requirement-to-source traceability, one or more acceptance scenarios per requirement, edge/failure cases, non-goals, gap dispositions, and phase boundaries. Repair only between preserved/restored markers, then fully reread and revalidate. If marker repair still fails, stop before persistence and report `Spec persistence: file-only — marker validation failed`.

After marker validation and before persistence, run a separate language and terminology gate over the reread artifact. In Spanish mode, require `Creado:` and `Destino:`; reject `Created:`, `Target:`, every applicable default-English canonical heading/table label, and malformed `Especificacion`, `aceptacion`, `version`, or `contractacion`; require neutral professional Spanish, correct diacritics (`Especificación`, `aceptación`, `versión`, `contratación` where applicable), and approved-source terminology. Repair affected language blocks only, fully reread, revalidate markers, and rerun the language gate. Never report `Language gate: passed` while a prohibited structural label or language issue remains. If unresolved, stop without persistence or success and report every issue plus `Spec persistence: file-only — language validation failed: <exact issues>`.

## Persistence And Return

Only after full reread and all validation, merge requirement decisions, scenario coverage, open questions, gaps, approval status, and artifact references into useful Pegasus Memory history. Complete truthful terminal outcomes for `ensure_project`, `ensure_change`, `record_artifact`, `record_observation`, `record_task_progress`, and `record_handoff`; when healthy, call or attempt `record_task_progress` before `record_handoff`. A successfully drafted Spec ready for review uses status `completed` on the first attempt and records phase `spec`, the exact Spec artifact path, `ready for review` / draft complete, open gaps/blockers, and next action `user review/approval` in descriptive fields or notes. The supported status enum is exactly `pending`, `in_progress`, `blocked`, `completed`; never use unsupported review-state aliases.

Before the persistence summary, state `Artifact language: <selected language>` and `Language gate: <passed|blocked: exact unresolved issues>`. Do not return the final response until all six Pegasus Memory operations have a terminal status in this exact block, including when memory is unavailable:

```text
Pegasus Memory persistence summary:
ensure_project: <succeeded|not needed|failed: reason>
ensure_change: <succeeded|not needed|failed: reason>
record_artifact: <succeeded|not needed|failed: reason>
record_observation: <succeeded|not needed|failed: reason>
record_task_progress: <succeeded|not needed|failed: reason>
record_handoff: <succeeded|not needed|failed: reason>
```

Never claim `succeeded` for an omitted call. If `record_artifact` or `record_observation` fails, add `Spec persistence: file-only — <reason>`. If both succeeded but task-progress or handoff failed, add `Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>`. A failed required closure operation MUST prevent claiming full durable completion or Pegasus Memory success.

Return control for human Spec review/approval before Design.
