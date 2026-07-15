---
description: MCP-first operational memory rules
applyTo: "**"
---

# Pegasus Memory operational persistence

## Durable prose language

Write all durable Pegasus Memory descriptive prose in English, regardless of chat, persona, source, or artifact language. This includes titles, summaries, rationale, decisions, status, blockers, next actions, progress notes, handoffs, observations, and artifact descriptions. Artifact-language overrides never override memory prose language.

Preserve immutable identifiers, paths, tool/server names, exact approved titles, user quotations, validation literals, and required public warnings in their original form as clearly labelled data. Do not translate or mutate a source artifact merely for persistence. Summarize its meaning separately in English and record `Artifact language: <language>`.

Use Pegasus Memory, provided by `pegasus-memory-mcp`, as the project continuity and operational persistence layer. Call its `health` tool before the first recovery or save attempt. If `health` succeeds, recover, search, and save operational memory through Pegasus Memory. Use `health.capabilities.parent_bootstrap` when present as confirmation that project/change bootstrap preconditions are supported.

`pegasus-memory-mcp` owns project/change operational persistence: artifacts, observations, task progress, and handoffs. Other MCP servers may coexist for other capabilities, but they are not substitutes for Pegasus Memory persistence and must not receive or stand in for these records.

At session start, call `health` first, then recover active project/change context through MCP when healthy. Search MCP for prior decisions, observations, task progress, blockers, handoffs, artifact references, and learnings. Before applying or verifying work, also read active `docs/pegasus/changes/<change-id>/apply-progress.md`; root phase files are canonical templates only.

After context compaction, context loss, or a long pause, call `health` first, then recover MCP context when healthy before continuing. If recovery is partial, continue from project artifacts and record the recovery gap as a blocker or follow-up.

Keep phase artifacts as files under `docs/pegasus/` or change-scoped `docs/pegasus/changes/<change-id>/` paths. MCP memory records summaries, status, and artifact references; it does not replace those files as the source of truth.

Pegasus IA upgrade/sync may update generated harness configuration, prompts, agents, and Pegasus Memory binary/config references. It must not reset, delete, recreate, or overwrite the Pegasus Memory database. The only acceptable database mutation is an explicit Pegasus Memory schema migration performed by Pegasus Memory itself when that component detects or ships a newer schema version. Clean test memory must be created as explicit test setup, never as a sync side effect.

Save proactively after important changes. Call `health` before the first save and save the durable record through MCP immediately when healthy. If recovery returns `not_found` with `project_not_found`, call `ensure_project` before recording observations, artifacts, task progress, or handoff records. When creating a new change/PRD such as `docs/pegasus/changes/<change-id>/prd.md`, call `ensure_change` before `record_artifact` or change-scoped observations. For PRD closure, include a small MCP persistence summary with one line each for `ensure_project`, `ensure_change`, `record_artifact`, and `record_observation`, marking every call as `succeeded`, `not needed`, or `failed: <reason>`; if required artifact or observation persistence failed, say the PRD is file-only and include the reason. Keep this flow internal; users should not need to mention ensure tools. Save durable records for:

For proposal closure, the final response MUST contain this exact block even when MCP is unavailable: `MCP persistence summary:` followed by one line each for `ensure_project`, `ensure_change`, `record_artifact`, `record_observation`, `record_task_progress`, and `record_handoff`, using only `succeeded`, `not needed`, or `failed: <reason>`. If required proposal artifact or observation persistence fails, append exactly `Proposal persistence: file-only — <reason>`.

For spec closure, the final response MUST contain this exact block even when Pegasus Memory is unavailable: `Pegasus Memory persistence summary:` followed by one line each for `ensure_project`, `ensure_change`, `record_artifact`, `record_observation`, `record_task_progress`, and `record_handoff`, using only `succeeded`, `not needed`, or `failed: <reason>`. After marker validation, when Pegasus Memory is healthy, call or attempt `record_task_progress` before `record_handoff`. For a successfully drafted spec ready for user review, the first task-progress attempt MUST use status `completed`; record phase `spec`, artifact path, `ready for review` / draft complete, open gaps/blockers, and next action `user review/approval` in descriptive fields or notes. The supported status enum is exactly `pending`, `in_progress`, `blocked`, `completed`: use `blocked` when blocked, `in_progress` for active work, and `pending` for work not yet started. Never send unsupported review-state aliases as a status. Do not return until every operation has a terminal status. Never mark an omitted call as `succeeded`: attempt it before closing, or report its truthful `failed: <reason>` or `not needed` status. If `record_artifact` or `record_observation` fails, append exactly `Spec persistence: file-only — <reason>`. If both succeeded but `record_task_progress` or `record_handoff` fails, append exactly `Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>`. Any failed required closure operation prevents a full durable-completion or Pegasus Memory-success claim.

For design closure, use Pegasus Memory/`pegasus-memory-mcp` terminology only: reject standalone/generic `MCP`, `Contexto MCP`, `Memoria MCP`, and `Memoria Pegasus` for this product. `MCP` is allowed only in an explicit protocol discussion such as `protocolo MCP`, or inside exact server annotation `pegasus-memory-mcp`. The exact `Pegasus Memory persistence summary:` has the same six terminal-status lines even when unavailable. Reconcile deferred technical choices before marker, language, and persistence gates: each uses the dedicated table, canonical `deferred-non-blocking` status (or translation), owner, impact, next step, needed-by gate, invariant architecture, why non-blocking, and evidence/source; `None` / `Ninguna` is explicit when absent. Missing fields block completion. Use minimal `ensure_change` payloads and `kind` only, never `type`. On an approval/source blocker or blocking technical gap, block artifact finalization/persistence without blocking minimal control-state persistence: do not write/finalize or `record_artifact` the design; the summary is `record_artifact: not needed — design artifact was not written because of blocking gap`, but when healthy the required blocked-state operations are `ensure_project`, `ensure_change`, `record_observation` with the blocker/question, `record_task_progress` for phase `design` with status `blocked`, and `record_handoff`, in that progress-before-handoff order. On unresolved language validation, do not `record_artifact`; report `record_artifact: not needed — language validation failed before artifact persistence` and use the same blocked control-state operations with the exact language reason. On a validated completed path, record artifact and observation, then progress before handoff; use `completed` only when ready for review with no blocking gap. The progress and final response summarize deferred choices and their next gate. The supported enum only is `pending`, `in_progress`, `blocked`, `completed`. Required completed-path artifact/observation failure is `Design persistence: file-only — <reason>`; later progress/handoff failure, or a required blocked-state operation failure, is `Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>`. No required failure permits a full durable-success claim.

In Greenfield context without concrete implementation stack, framework, or runtime evidence, `None` / `Ninguna` is invalid. Record stack/framework/runtime selection as a structured non-blocking deferred choice needed before tasks/apply, while preserving logical architecture independently of it. Narrative prose is insufficient for design closure: require exact `Artifact language:`, `Language gate:`, `Deferred technical choices:`, and the six-state `Pegasus Memory persistence summary:` structures. Spanish design uses the exact heading `Decisiones y compensaciones` and rejects `Tradeoffs`, `Costos y compromisos`, `Compensaciones`, and awkward composite headings.

The design result records `Initial recovery result:` independently from ordered `Recovery/ensure transitions:`. An initial missing-project result remains the initial result after ensure/recovery succeeds; never collapse both moments into contradictory current-state claims.

Each design artifact checks `MCP` per occurrence: only exact `protocolo MCP` and exact `pegasus-memory-mcp` are allowed; an allowed occurrence never permits a separate standalone `MCP` elsewhere.

The complete task-progress payload records phase `spec`, artifact path, review semantics in descriptive fields or notes, open gaps/blockers, and next action `user review/approval`; its status uses only the supported enum.

Use minimal compatible ensure payloads. `ensure_project` requires `project_id` and may include only documented flat fields: `key`, `name`, `workspace_root`, and `description`. By default, call `ensure_change({ project_id: <project-id>, change_id: <change-id> })`. Add flat `key`, `title`, `status`, or `description` only when needed. If classification is needed, use `kind` only. Never send `type`, and never send both `kind` and `type`, even with equal values. Do not send nested `metadata`, arrays, product decisions, questions/answers, artifact summaries, or arbitrary extra fields to `ensure_change`; put those details in `record_observation` or `record_artifact` after the ensure call succeeds.

- decisions, rationale, assumptions, and tradeoffs;
- bugfixes, root causes, and remediation notes;
- discoveries, gotchas, edge cases, and reusable learnings;
- conventions, naming, structure, or workflow patterns;
- configuration or environment changes;
- user constraints, preferences, approvals, and scope choices;
- artifact status, paths, summaries, and approval state;
- task progress, blockers, duplicate-work checks, and next actions;
- verification commands, evidence, deviations, verdicts, and remediation needs;
- handoffs and session summaries before ending or pausing work.

Merge updates into existing useful history; do not replace prior progress, apply-progress, verification evidence, decisions, blockers, or learnings unless the user explicitly approves cleanup. Before ending or pausing a session, call `health` first, then save a concise handoff/session summary through MCP when healthy.

Treat MCP tool inputs, outputs, and documented capabilities as the memory contract. Do not rely on `pegasus-memory-mcp` implementation details.

If `pegasus-memory-mcp` is unavailable or `health` cannot be called successfully, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Continue project/change artifact work only if appropriate, but do not claim persistent memory was saved and do not fall back to Markdown memory.

Keep consumer states distinct. `not_found` means MCP is healthy but has no matching context; when it includes `project_not_found`, satisfy the precondition with `ensure_project` before writes. `ambiguous` means MCP is healthy but returned multiple candidates. `read_error` is a failed read. `persistence_error` and database foreign-key failures during writes are flow bugs/precondition failures, usually missing `ensure_project` or `ensure_change`; report them clearly and fix the write flow. Do not treat these states as unavailable memory and do not show the unavailable warning for them. Preserve the exact unavailable warning only for true MCP unavailability or failed `health`.

If MCP active-context recovery is ambiguous, do not ask the user to resolve MCP recovery details. Continue from available project artifacts and record external follow-up for `pegasus-memory-mcp` support when possible.

`docs/pegasus/memory/` is deprecated after MCP integration. Existing files may remain historical, but they are not an active backend, fallback, or co-source for operational memory.
