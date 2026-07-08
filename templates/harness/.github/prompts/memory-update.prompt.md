---
name: pegasus-memory-update
description: Record Pegasus operational memory through MCP
tools:
  - read
  - search
---

# Memory update prompt

Review recent changes and call the `pegasus-memory-mcp` `health` tool before the first recovery or save attempt. If `health` succeeds, record durable operational memory through MCP:

- Active project/change context.
- Decisions and tradeoffs.
- Task progress, status, and blockers.
- Artifact paths, status, and summaries.
- Handoffs and recovery state.
- Observations, gotchas, and reusable discoveries.

Keep records concise and factual. Use MCP tool inputs, outputs, and documented capabilities as the contract; do not depend on server internals. Preserve MCP consumer states: `not_found`, `ambiguous`, `read_error`, and `persistence_error` are not MCP unavailability.

If `pegasus-memory-mcp` is unavailable or `health` cannot be called successfully, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Continue artifact work only if appropriate, but do not claim persistent memory was saved.

Do not write retrospective Markdown memory. `docs/pegasus/memory/` is deprecated and is not an active backend, fallback, or co-source for operational memory.
