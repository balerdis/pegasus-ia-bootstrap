---
description: MCP-first operational memory rules
applyTo: "**"
---

# MCP-first memory

Use `pegasus-memory-mcp` as the project continuity layer. Call the MCP `health` tool before the first recovery or save attempt. If `health` succeeds, recover, search, and save operational memory through MCP tools. Use `health.capabilities.parent_bootstrap` when present as confirmation that project/change bootstrap preconditions are supported.

At session start, call `health` first, then recover active project/change context through MCP when healthy. Search MCP for prior decisions, observations, task progress, blockers, handoffs, artifact references, and learnings. Before applying or verifying work, also read `docs/pegasus/apply-progress.md`.

After context compaction, context loss, or a long pause, call `health` first, then recover MCP context when healthy before continuing. If recovery is partial, continue from project artifacts and record the recovery gap as a blocker or follow-up.

Keep phase artifacts as files under `docs/pegasus/` or change-scoped `docs/pegasus/changes/<change-id>/` paths. MCP memory records summaries, status, and artifact references; it does not replace those files as the source of truth.

Pegasus IA upgrade/sync may update generated harness configuration, prompts, agents, and Pegasus Memory binary/config references. It must not reset, delete, recreate, or overwrite the Pegasus Memory database. The only acceptable database mutation is an explicit Pegasus Memory schema migration performed by Pegasus Memory itself when that component detects or ships a newer schema version. Clean test memory must be created as explicit test setup, never as a sync side effect.

Save proactively after important changes. Call `health` before the first save and save the durable record through MCP immediately when healthy. If recovery returns `not_found` with `project_not_found`, call `ensure_project` before recording observations, artifacts, task progress, or handoff records. When creating a new change/PRD such as `docs/pegasus/changes/<change-id>/prd.md`, call `ensure_change` before `record_artifact` or change-scoped observations. For PRD closure, include a small MCP persistence summary with one line each for `ensure_project`, `ensure_change`, `record_artifact`, and `record_observation`, marking every call as `succeeded`, `not needed`, or `failed: <reason>`; if required artifact or observation persistence failed, say the PRD is file-only and include the reason. Keep this flow internal; users should not need to mention ensure tools. Save durable records for:

Use minimal compatible ensure payloads. `ensure_project` requires `project_id` and may include only documented flat fields: `key`, `name`, `workspace_root`, and `description`. `ensure_change` requires `project_id` plus `change_id` and may include only documented flat fields: `key`, `title`, `status`, `kind` or `type`, and `description`. For a new PRD/change, prefer `ensure_change({ project_id: <project-id>, change_id: <change-id>, key: <change-id>, title: <short title>, status: "draft", kind: "prd" })` when those values are known. Do not send nested `metadata`, arrays, product decisions, questions/answers, artifact summaries, or arbitrary extra fields to `ensure_change`; put those details in `record_observation` or `record_artifact` after the ensure call succeeds.

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
