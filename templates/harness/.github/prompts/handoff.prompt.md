---
name: pegasus-handoff
description: Prepare a compact session handoff
tools:
  - read
  - search
  - edit
---

# Handoff prompt

Call MCP `health` first. After `health` succeeds, recover task progress, decisions, and prior handoff context through MCP, then read `docs/pegasus/verify.md`.

Save an MCP handoff with current state, completed work, open risks, next steps, and files that matter for the next session.

If `pegasus-memory-mcp` is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Do not write a Markdown memory fallback or claim persistent handoff memory was saved.
