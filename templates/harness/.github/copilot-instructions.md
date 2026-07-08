# Pegasus IA workspace instructions

This workspace uses the Pegasus IA VS Code/Copilot harness. The harness provides local workflow, documentation, and MCP-first operational memory. It does not authorize framework scaffolding, GitHub setup, CI, deployment, database setup, or business/domain application code by itself.

## Primary entry point

Use `.github/agents/pegasus-orchestrator.agent.md` as the primary Copilot agent for project work. The orchestrator coordinates SDD phase agents and selected specialist agents through Copilot custom-agent handoffs where supported.

## Source of truth and memory

Before changing files, call the `pegasus-memory-mcp` `health` tool before the first recovery attempt. If `health` succeeds, recover project/change context through MCP, then read `docs/pegasus/prd.md`, `proposal.md`, `spec.md`, `design.md`, `tasks.md`, and `apply-progress.md`.

Record implementation status in `docs/pegasus/apply-progress.md`, record verification in `docs/pegasus/verify.md`, and call `health` before the first MCP save attempt. When MCP is healthy, save durable decisions, observations, handoffs, artifact references, and task progress through MCP. Merge updates into existing useful history; do not overwrite prior progress, apply-progress, memory, or verification evidence.

Record the project-selected Copilot model preference through MCP after `health` succeeds or through workspace settings when available. Use one model for all phases in this first release; do not promise per-phase model routing or hard runtime control from Pegasus docs alone.

Use MCP tool inputs, outputs, and documented capabilities as the memory contract only. Do not rely on `pegasus-memory-mcp` implementation details. Treat failed or missing `health` as MCP unavailable and show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Artifact work may continue, but persistent memory saves are unavailable and there is no Markdown memory fallback.

Keep consumer states distinct: `not_found` means MCP is available but has no matching context; `ambiguous` means MCP is available but needs disambiguation; `read_error` and `persistence_error` are real MCP operation failures. Do not collapse those states into unavailability or show the unavailable warning for them.

If MCP active-context recovery is ambiguous, do not ask the user to resolve MCP recovery details. Continue from available project artifacts and record external `pegasus-memory-mcp` follow-up when possible. `docs/pegasus/memory/` is deprecated after MCP integration and must not be treated as an active backend, fallback, or co-source.

## Operating boundaries

- Keep work local-first and reversible.
- Do not create app code, remotes, CI, deployment, database, framework scaffolding, MCP services, or network dependencies unless the local SDD docs explicitly request them.
- Preserve user files unless overwrite behavior is explicitly approved.
- Use the direct-fix path for small, punctual, low-risk changes; use SDD for broader, ambiguous, architectural, or higher-risk changes.
- Before delegating or starting a phase/task, check MCP task progress and `docs/pegasus/apply-progress.md` for the same phase/task already in progress or completed, and avoid duplicate launches.
- Before large implementation, stop and ask whether to split into chained PRs if the estimate exceeds about 400 changed lines or touches multiple unrelated areas.
- For verification, use fresh context when possible by re-reading PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion.

Cursor files under `.cursor/rules/` are legacy compatibility guidance. Prefer the Copilot assets in `.github/` for VS Code/Copilot sessions.
