---
name: pegasus-memory-update
description: Record Pegasus operational memory through MCP
tools:
  - read
  - search
---

# Memory update prompt

Review recent changes and record durable operational memory through `pegasus-memory-mcp` when available:

- Active project/change context.
- Decisions and tradeoffs.
- Task progress, status, and blockers.
- Artifact paths, status, and summaries.
- Handoffs and recovery state.
- Observations, gotchas, and reusable discoveries.

Keep records concise and factual. Use MCP tool inputs, outputs, and documented capabilities as the contract; do not depend on server internals.

If `pegasus-memory-mcp` is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Continue artifact work only if appropriate, but do not claim persistent memory was saved.

Do not write retrospective Markdown memory. `docs/pegasus/memory/` is deprecated and is not an active backend, fallback, or co-source for operational memory.
