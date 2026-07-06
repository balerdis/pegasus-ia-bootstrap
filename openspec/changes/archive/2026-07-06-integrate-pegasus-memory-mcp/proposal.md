# Proposal: Integrate Pegasus Memory MCP

## Intent

Make Pegasus workspaces MCP-first for operational memory. The current stable spec and generated Markdown guidance still require or mention `docs/pegasus/memory/`; this proposal explicitly changes that direction.

## PRD Source

| Source | Status |
|---|---|
| `openspec/changes/integrate-pegasus-memory-mcp/prd.md` | Draft; user-approved product decisions, approval date pending |

## Context Consulted

- `openspec/specs/pegasus-harness-bootstrap/spec.md`
- `templates/harness/**` mentions of `docs/pegasus/memory/`.

## Scope

### In Scope
- Change stable spec direction from Markdown memory to MCP-first persistence.
- Update generated `.md` guidance, agents, and prompts to use `pegasus-memory-mcp` when available.
- Deprecate `docs/pegasus/memory/` after integration; it must not remain an ongoing memory backend, fallback, or co-source.
- If MCP is unavailable, show the approved warning and do not save persistent memory.
- Keep SDD/project artifacts as files; memory becomes MCP-owned.

### Out of Scope / Non-goals
- No Markdown memory fallback or migration command.
- No MCP internals, database/schema coupling, npm publishing, cloud memory, implementation, design, spec, or tasks.

## Approach

Replace Markdown-memory recovery/save rules with MCP recovery/save/search rules. If MCP is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Work may continue on SDD artifacts, but persistent memory saves are disabled.

Remaining Markdown must be transitional or non-memory docs only, not memory source of truth.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `pegasus-harness-bootstrap`: generated memory behavior, SDD guidance, agent/prompt instructions, unavailable-memory behavior, and removal/replacement of Markdown-memory requirements.

## Affected Areas

| Area | Impact | Description |
|---|---|---|
| `openspec/specs/pegasus-harness-bootstrap/spec.md` | Modified | Spec phase removes/replaces `docs/pegasus/memory/` source-of-truth requirements. |
| `templates/harness/**` | Modified | Use MCP-first memory and no Markdown fallback. |

## Risks / Rollback

| Risk | Mitigation |
|---|---|
| MCP unavailable causes lost continuity | Warn explicitly; continue only without persistent saves. |
| Old generated docs imply Markdown persistence | Spec deltas must remove/replace Markdown-memory requirements. |
| Guidance leaks MCP internals | Consume only MCP tool contract. |

Rollback by reverting template/instruction changes; no data migration rollback is needed.

## Dependencies

- `pegasus-memory-mcp` must expose enough MCP tools for health, recovery, save, and search.

## Success Criteria

- [ ] Spec deltas remove/replace Markdown-memory requirements.
- [ ] Generated guidance says MCP-first and deprecates `docs/pegasus/memory/` after integration.
- [ ] No guidance promises Markdown fallback, co-source memory, or ongoing Markdown persistence.
- [ ] MCP-unavailable warning matches the approved Spanish text exactly.
- [ ] SDD artifacts remain file-based, not memory source of truth.

## Handoff to Spec

Create a `pegasus-harness-bootstrap` delta that removes/replaces Markdown-memory requirements and defines MCP-first persistence, unavailable behavior, generated-harness impacts, and no Markdown fallback.
