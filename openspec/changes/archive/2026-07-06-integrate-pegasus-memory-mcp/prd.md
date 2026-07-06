# PRD: Integrate Pegasus Memory MCP

## Problem

Pegasus currently teaches generated workspaces to recover and persist operational context through `docs/pegasus/memory/` Markdown files. That keeps context portable, but it makes memory manual, file-shaped, and easy to expose as workflow mechanics instead of a product capability.

Pegasus needs an MCP-first memory system backed by the local `pegasus-memory-mcp` server, while staying decoupled from server internals.

## Target users and situations

- Developers using a Pegasus-generated VS Code/Copilot workspace across multiple sessions.
- Orchestrator agents recovering active project/change context after context loss, compaction, or a fresh session.
- Project maintainers who need persistent decisions, task state, handoffs, learnings, and change-cycle context without manually managing memory files.

## Current gap

- Generated guidance treats `docs/pegasus/memory/` as the persistent memory source.
- Active change/project recovery depends on reading project files instead of asking a memory service.
- Markdown memory exposes internal organization during normal workflow.
- There is no product rule for what happens when persistent memory is unavailable.

## Outcome

Pegasus uses `pegasus-memory-mcp` as the product memory system. The orchestrator recovers active project/change context from MCP when available, records persistent memories through MCP, and clearly degrades when memory is unavailable without silently falling back to Markdown persistence.

## Product and business rules

- Policy is MCP-first.
- After integrating `pegasus-memory-mcp`, `docs/pegasus/memory/` is deprecated.
- Do NOT keep Markdown memory as ongoing fallback/human-readable co-source.
- Transitional behavior may exist only for migration if needed, but target architecture is MCP as memory system.
- If `pegasus-memory-mcp` is unavailable, Pegasus must notify the user and cannot save persistent memories.
- The exact user-facing warning when MCP memory is unavailable is: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`
- No silent fallback to Markdown persistence.
- Pegasus may continue working on project/change artifacts when memory is unavailable, but memory saves are disabled/degraded.
- Pegasus should not expose internal memory organization to the user during normal workflow.
- Orchestrator should recover active change/project context from MCP when available.
- If MCP returns ambiguous active context, the orchestrator must not ask the user to resolve internal Pegasus ecosystem state. It should continue without exposing memory organization and document required `pegasus-memory-mcp` follow-up work in a dedicated artifact/file for that separate project/session.
- Pegasus must consume the MCP tool contract, not couple to `pegasus-memory-mcp` server internals, database schema, or source modules.
- `pegasus-memory-mcp` is local, private/not published to npm, expected to expose bin `pegasus-memory-mcp`, and uses default DB `~/.local/share/pegasus-memory-mcp/memory.db`.

## Scope

### In scope

- Update generated Pegasus guidance so MCP is the primary memory interface.
- Deprecate generated `docs/pegasus/memory/` guidance as ongoing memory persistence.
- Define user-visible degraded behavior when MCP is unavailable.
- Define recovery behavior for active project/change context through MCP.
- Define non-interactive behavior for ambiguous MCP active-context recovery.
- Document local setup expectations for the private MCP package, including rebuild guidance for `better-sqlite3` when npm scripts are ignored.

### Out of scope

- Publishing `pegasus-memory-mcp` to npm.
- Changing `pegasus-memory-mcp` server internals or database schema.
- Building a one-time Markdown memory migration command; Pegasus Bootstrap has not yet been used in real target projects with the old Markdown memory.
- Building a remote/cloud memory service.
- Keeping Markdown memory as a parallel long-term source of truth.
- Implementing this change in code during PRD work.

## Non-goals

- Make users understand memory storage layout, tables, or event organization.
- Guarantee memory saves when the MCP server cannot start.
- Replace project/change SDD artifacts such as PRD, proposal, spec, design, tasks, apply-progress, or verify documents.

## Success criteria

- Pegasus guidance states MCP-first memory policy and deprecates `docs/pegasus/memory/` for ongoing persistence.
- A fresh orchestrator session can recover active project/change context from MCP when available.
- When MCP is unavailable, Pegasus notifies the user and disables persistent memory saves.
- No guidance promises silent Markdown fallback for memory persistence.
- Normal user workflow does not require knowing internal memory organization.
- Existing project/change artifact work can continue in degraded mode when memory is unavailable.
- Ambiguous MCP active-context recovery does not produce a user-facing resolution prompt.

## Edge cases

- MCP binary is missing, not executable, or not on PATH.
- MCP starts but default DB is missing, stale, corrupted, or has no active context.
- Multiple active or ambiguous changes are returned by MCP recovery; Pegasus records follow-up work for `pegasus-memory-mcp` instead of asking the user to resolve internal state.
- npm is configured with `ignore-scripts=true`; after `npm ci`, users may need `npm_config_ignore_scripts=false npm rebuild better-sqlite3 --foreground-scripts`.
- Existing Markdown memory is present in a generated project; no guided migration command is required for this change, and Markdown must not be retained as ongoing fallback.

## External dependencies and follow-up

- `pegasus-memory-mcp` must expose enough MCP API behavior for Pegasus to recover active project/change context without leaking internal memory organization to users.
- If the current MCP contract cannot represent or disambiguate active context safely, document the needed change in the `pegasus-memory-mcp` project as follow-up work for a separate session/project.
- No open PRD questions remain for the unavailable-memory warning, Markdown migration, or ambiguous active-context behavior.

## Approval metadata

| Field | Value |
|---|---|
| Change | `integrate-pegasus-memory-mcp` |
| Status | Draft PRD |
| Approval owner | Sergio |
| Approval date | Pending |
| Source context | Exploration and user decisions from 2026-07-05 |
