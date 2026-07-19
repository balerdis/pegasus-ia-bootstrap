# Pegasus Memory Maintenance Phase Contract

## Scope And Authority

This manually loaded phase reference owns only the detailed `memory-maintainer` explicit maintenance workflow. It is subordinate to the current macro and authoritative over shared references for maintenance-specific behavior. It does not authorize project/change artifact edits or implicit proactive work beyond the assigned operation.

## Health, Recovery, And Preconditions

Follow `.github/instructions/pegasus-memory.instructions.md`. Before the first recovery or save attempt, call Pegasus Memory MCP `health`. If healthy, recover/search only the context needed for the explicit operation. Treat tool inputs, outputs, and documented capabilities as the contract; do not rely on server internals.

Keep consumer states distinct. `not_found` is empty memory; `project_not_found` under `not_found` requires `ensure_project` before writes. `ambiguous` is multiple matching contexts, `read_error` is a failed read, and `persistence_error` is a failed write. Persistence or foreign-key errors are precondition/flow bugs, usually a missing ensure operation, not unavailability. Report them clearly and never trigger the unavailable warning for them.

Use minimal ensure inputs: `project_id` and, when scoped, `change_id`; add documented flat `key`, `title`, `status`, or `description` only when needed. If classification is needed, use `kind` only; never send `type` or both aliases. Call `ensure_project` before any write when the project is missing. Call `ensure_change` before `record_artifact` or change-scoped observations when creating or updating a change/PRD under `docs/pegasus/changes/<change-id>/`. Put decisions, questions, and summaries in record operations, not nested ensure metadata.

## Maintenance Operations

Write durable descriptive prose in English, preserve exact source data, and include `Artifact language: <language>` for every persisted artifact reference. Record only explicit, supported facts through the matching operation: `record_observation` for decisions, bugfixes, discoveries, conventions, configuration, constraints, and learnings; task progress for status/blockers/next action; handoffs for recovery state; `record_artifact` for exact paths, status, summaries, language, and immutable identity when available.

Validate each requested record against current authoritative source facts. Merge with useful history; do not overwrite prior progress, evidence, blockers, decisions, observations, artifacts, tasks, or handoffs unless the user explicitly authorized cleanup. Preserve unresolved contradictions and provenance. Never broaden one explicit maintenance request into a general scan or parallel executor.

If `pegasus-memory-mcp` is unavailable or `health` cannot be called successfully, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Do not write retrospective Markdown memory, use `docs/pegasus/memory/` as backend/fallback/co-source, or claim persistence. Return blocked because the assigned maintenance operation did not occur.

## Stop Boundary

Return after the explicit records and result are complete. Do not edit project/change artifacts, continue product work, create an extra session handoff unless explicitly assigned, or perform unrelated maintenance.
