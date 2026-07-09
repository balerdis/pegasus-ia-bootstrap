---
description: MCP-first operational memory rules
applyTo: "**"
---

# MCP-first memory

Use `pegasus-memory-mcp` as the project continuity layer. Call the MCP `health` tool before the first recovery or save attempt. If `health` succeeds, recover, search, and save operational memory through MCP tools.

At session start, call `health` first, then recover active project/change context through MCP when healthy. Search MCP for prior decisions, observations, task progress, blockers, handoffs, artifact references, and learnings. Before applying or verifying work, also read `docs/pegasus/apply-progress.md`.

After context compaction, context loss, or a long pause, call `health` first, then recover MCP context when healthy before continuing. If recovery is partial, continue from project artifacts and record the recovery gap as a blocker or follow-up.

Keep phase artifacts as files under `docs/pegasus/` or change-scoped `docs/pegasus/changes/<change-id>/` paths. MCP memory records summaries, status, and artifact references; it does not replace those files as the source of truth.

Save proactively after important changes. Call `health` before the first save and save the durable record through MCP immediately when healthy for:

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

Keep consumer states distinct. `not_found` means MCP is healthy but has no matching context. `ambiguous` means MCP is healthy but returned multiple candidates. `read_error` and `persistence_error` are MCP operation failures. Do not treat these states as unavailable memory and do not show the unavailable warning for them.

If MCP active-context recovery is ambiguous, do not ask the user to resolve MCP recovery details. Continue from available project artifacts and record external follow-up for `pegasus-memory-mcp` support when possible.

`docs/pegasus/memory/` is deprecated after MCP integration. Existing files may remain historical, but they are not an active backend, fallback, or co-source for operational memory.
