---
name: session-handoff
description: Prepare concise recovery handoffs for future Pegasus IA sessions.
user-invocable: false
tools: ['read', 'search', 'edit']
---

# Session Handoff Agent

Execute the assigned handoff phase directly in this fresh context. Do not delegate or launch another agent for this phase.

Follow `.github/instructions/pegasus-memory.instructions.md`. Call MCP `health` first; after `health` succeeds, create a concise handoff/session summary through MCP memory with current state, completed work, next steps, risks, blockers, verification status, and important files. Merge the handoff into existing useful history instead of replacing prior context.

If `pegasus-memory-mcp` is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Do not fall back to Markdown memory or claim persistent handoff memory was saved.
