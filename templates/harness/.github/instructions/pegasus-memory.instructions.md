---
description: MCP-first operational memory rules
applyTo: "**"
---

# MCP-first memory

Use `pegasus-memory-mcp` as the project continuity layer. Recover, search, and save operational memory through MCP tools when available.

At session start or after context compaction, recover active project/change context through MCP. Search MCP for prior decisions, observations, task progress, blockers, handoffs, artifact references, and learnings. Before applying or verifying work, also read `docs/pegasus/apply-progress.md`.

Keep phase artifacts as files under `docs/pegasus/` or change-scoped `docs/pegasus/changes/<change-id>/` paths. MCP memory records summaries, status, and artifact references; it does not replace those files as the source of truth.

When work changes facts, decisions, tasks, blockers, artifact state, handoff state, or learnings, save the durable record through MCP immediately. Merge updates into existing useful history; do not replace prior progress, apply-progress, verification evidence, decisions, blockers, or learnings unless the user explicitly approves cleanup. Before ending a session, save a concise handoff through MCP.

Treat MCP tool inputs, outputs, and documented capabilities as the memory contract. Do not rely on `pegasus-memory-mcp` implementation details.

If `pegasus-memory-mcp` is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Continue project/change artifact work only if appropriate, but do not claim persistent memory was saved and do not fall back to Markdown memory.

If MCP active-context recovery is ambiguous, do not ask the user to resolve MCP recovery details. Continue from available project artifacts and record external follow-up for `pegasus-memory-mcp` support when possible.

`docs/pegasus/memory/` is deprecated after MCP integration. Existing files may remain historical, but they are not an active backend, fallback, or co-source for operational memory.
