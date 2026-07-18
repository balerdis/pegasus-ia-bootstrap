# SDD Design Phase Contract

## Scope And Authority

This manually loaded phase reference owns only the detailed `sdd-design` workflow. It is subordinate to the current macro and authoritative over shared references for Design-specific behavior. It does not approve the Design or authorize Tasks.

## Sources And Isolation

Read the exact current-change PRD, proposal, and spec directly before drafting, then read the existing Design and canonical managed Design template/current placeholder for structure only. Use current-change approved artifacts as the only default product and acceptance sources. Inspect relevant current repository code, architecture, configuration, deployment, and operational evidence when implementation evidence exists. Do not search, read, inspect, or reuse neighboring or unrelated change artifacts by default.

Consult another change only when a current source, reliable Pegasus Memory context, or direct user instruction explicitly declares a dependency. Disclose the exact reference, purpose, and that it was not an implicit scope source. Pegasus Memory is supporting context, not requirements or technical-fact evidence; an ambiguous response never resolves a gap.

Follow `.github/instructions/pegasus-memory.instructions.md`. Call Pegasus Memory `health` first and, when healthy, recover current project/change decisions, progress, handoff, and learnings without replacing useful history.

## Technical Design

Classify context as exactly **existing system with implementation evidence** or **Greenfield / no implementation evidence**, and record concrete evidence inspected. In Spanish use exactly **Greenfield / sin evidencia de implementación** and reject both spaced and unspaced English variants. Existing-system architecture MUST follow repository evidence; Greenfield design MUST NOT invent files, modules, runtime, framework, or stack precision.

Define goals/non-goals, components and responsibilities, architecture boundaries and coupling, interfaces/contracts, data and control flow, and evidence-based affected areas. Address data/persistence, error handling, observability, migration, rollout/rollback, security, privacy, performance, compatibility, and operational constraints when applicable; explicitly mark an area not applicable with rationale rather than silently omitting a material concern.

Trace every decision to a spec requirement or explicit technical evidence and record rationale, alternatives, tradeoffs, coupling/impact, and revisit conditions. Per-entry traceability is required for every flow step, alternative, affected area, testing row, rollout/rollback row, and risk row; a section-level source statement is insufficient. Do not redefine acceptance behavior owned by Spec, widen approved scope, implement code, or create Tasks, work units, PR slices, implementation checklists, tests, or verification artifacts.

## Material Gaps And Deferred Choices

Identify platform/runtime/framework constraints, required stack, integration boundaries, persistence, deployment constraints, and every decision that changes architecture, delivery risk, or acceptance. Reconcile each material gap with reliable current-change evidence or a direct user answer, or keep one visible unresolved entry with owner, impact, next step, and needed-by gate. Never use ambiguous Pegasus Memory context or an unqualified `TBD` as resolution.

A blocking technical gap requires one concise question and a stop before writing or finalizing the Design. Never ask a required close-out question after completed-path persistence or finalization. A non-blocking gap may remain stack-agnostic only as a complete deferred choice in `Deferred Technical Choices` with canonical status `deferred-non-blocking` (or selected-language translation), choice/topic, owner, impact, next step, needed-by gate, invariant architecture, why non-blocking, and evidence/source. A missing deferred field is blocking.

In Greenfield context without concrete implementation stack, framework, or runtime evidence, `None` / `Ninguna` is invalid: defer that selection before Tasks/Apply while preserving logical components, responsibilities, boundaries, interfaces, and control flow independently. Otherwise state `None` / `Ninguna` when no deferred choices exist. Before marker, language, persistence, or return validation, reconcile every reasoned gap and choice to its artifact disposition.

## Risk And Readiness Coverage

Reread the approved proposal and build a complete `Proposal Risk Coverage` matrix. Every proposal risk, including mobile rendering performance when present, MUST map by exact reference to at least one Design risk and mitigation. A mitigation requiring validation or measurement MUST map to a testing-strategy row; otherwise include an explicit N/A rationale. Include owner and trigger where relevant. Missing design, mitigation, or test/measurement coverage is a terminal blocked state.

Define a traceable test strategy for applicable unit, integration, contract, migration, security, performance, failure, observability, and rollback behavior. Before closure, validate architecture coherence, impact/coupling, interfaces/data/error paths, operational concerns, all proposal-risk coverage, every material-gap disposition, and readiness for Tasks without creating Tasks.

## Artifact And Language Validation

Preserve existing Pegasus managed markers exactly and edit only between them. A new Design's exact first line is `<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/design.md ownership=full-file -->`; its exact final line is `<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/design.md -->`, with the actual change ID.

Select language under `.github/instructions/pegasus-sdd-boundaries.instructions.md`: an explicit user instruction naming the Design artifact language wins; otherwise English is mandatory. Spanish chat, Spanish approved sources, persona, dominant source language, and prior artifacts never infer an override. For non-English output, return the exact override evidence.

In Spanish mode require coherent neutral professional Spanish and heading `Decisiones y compensaciones`; reject untranslated structural vocabulary including `Inputs`, `Rationale`, `Tradeoffs`, `Unit`, and `Integration`, headings `Costos y compromisos`, `Compensaciones`, and `Decisiones y costos y compromisos`, and either English Greenfield form. Require `Pegasus Memory` or exact `pegasus-memory-mcp` annotation; reject standalone/generic `MCP`, `Contexto MCP`, `Memoria MCP`, and `Memoria Pegasus`. Allow `MCP` only in an explicit protocol discussion such as `protocolo MCP`. Validate every `MCP` occurrence independently; one allowed occurrence does not permit another.

Finish every edit and formatting mutation, then reread the complete artifact. Validate exact markers, language/terminology, per-entry traceability, source evidence, architecture and applicable-concern coverage, material gaps/deferred choices, complete proposal-risk design/test or measurement coverage, and Tasks readiness. Repair affected blocks, reread the whole artifact, revalidate markers, and rerun every affected gate. If markers still fail, do not persist and report `Design persistence: file-only — marker validation failed`. If language still fails, do not call `record_artifact`; use blocked control-state persistence and report `record_artifact: not needed — language validation failed before artifact persistence`.

## Atomic Persistence And Closure

Treat completed closure as one atomic writer thread: all edits → complete reread → every validation → final artifact identity freeze → ensure preconditions → `record_artifact` → `record_observation` → `record_task_progress` → `record_handoff` → result envelope. Use an observable content hash or explicit stable revision token bound to the validated read. Every affected record MUST carry or reference that frozen revision. No artifact mutation is permitted after the first persistence operation begins.

On completed closure, use status `completed` only when ready for review with no blocking gap; deferred non-blocking choices remain visible. Phase progress names `design`, artifact path, frozen revision, all deferred choices and needed-by gates (or `None` / `Ninguna`), blockers/gaps, and next action `review/approval`. Final and persistence artifact revisions MUST be equal and `Post-persistence edits: none` is exact, case-sensitive wire behavior: it means no content or formatting mutation occurred after persistence began.

If any edit occurs or becomes necessary after persistence begins, all earlier completion and persistence evidence is stale. Block success, finish the edit, repeat the full reread and every validation, freeze a new identity, and refresh every affected record in exact `record_artifact` → `record_observation` → `record_task_progress` → `record_handoff` order. Do not return completed until revision equality holds and no later mutation occurred.

For an approval/source or material technical blocker, do not write/refine or validate the Design and do not call `record_artifact`. When memory is healthy, attempt `ensure_project`, `ensure_change`, `record_observation` with the exact blocker/question, `record_task_progress` for phase `design` with status `blocked`, blockers/gaps and next action `user answer`, then `record_handoff`. Report `record_artifact: not needed — design artifact was not written because of blocking gap`, `Artifact language: not selected — blocking gap`, and `Language gate: not run — design artifact was not written`.

Do not return until all six operation states are truthful and terminal. Keep the initial recovery result separate from later ensure/recovery transitions. Required artifact/observation failure adds `Design persistence: file-only — <reason>`; later required control-state failure adds `Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>`. Never claim full durable success after any required failure. Return control for human Design review/approval before Tasks.
