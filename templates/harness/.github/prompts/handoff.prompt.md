---
name: pegasus-handoff
description: Prepare a compact session handoff
tools:
  - read
  - search
  - edit
---

# Handoff prompt

Follow `.github/instructions/pegasus-sdd-boundaries.instructions.md`. Generate the handoff in English unless the user explicitly names another language for that artifact; do not infer an override from chat, persona, source, or prior artifact language.

Follow `.github/instructions/pegasus-memory.instructions.md`. Call MCP `health` first. After `health` succeeds, recover task progress, decisions, artifact status, verification evidence, and prior handoff context through MCP, then read `docs/pegasus/changes/<change-id>/verify.md`. Root phase files are canonical templates only.

Save an MCP handoff/session summary with current state, completed work, open risks, blockers, next steps, verification status, and files that matter for the next session. Merge with existing useful history instead of replacing prior handoffs.

If `pegasus-memory-mcp` is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Do not write a Markdown memory fallback or claim persistent handoff memory was saved.
