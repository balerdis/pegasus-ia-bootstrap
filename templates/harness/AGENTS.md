# {{PROJECT_NAME}} Agent Guide

Target path: `{{TARGET_PATH}}`  
Harness created: `{{DATE}}`

This target workspace uses the Pegasus IA VS Code/Copilot harness. The harness is a documentation and workflow scaffold with MCP-first operational memory; Pegasus IA does not generate the business/domain MVP. Build business MVP code later only after the project docs explicitly define and approve that work.

VS Code/Copilot entry points live under `.github/`. `AGENTS.md` stays as portable guidance for agents and tools that can read repository instructions.

## Start Here

1. In VS Code with Copilot, start with `.github/agents/pegasus-orchestrator.agent.md`.
2. Read `.github/copilot-instructions.md` and the scoped files under `.github/instructions/`.
3. Recover current project context through `pegasus-memory-mcp` tools when available.
4. Read `docs/pegasus/prd.md`, `docs/pegasus/proposal.md`, `docs/pegasus/spec.md`, `docs/pegasus/design.md`, `docs/pegasus/tasks.md`, and `docs/pegasus/apply-progress.md` before changing files.
5. Use `docs/pegasus/apply-progress.md` to track implementation slices and `docs/pegasus/verify.md` to record verification commands and outcomes.
6. Save durable decisions, observations, handoffs, artifact references, and task progress through MCP when available.

## Pegasus IA Workflow

- Direct fix handles small, punctual, low-risk changes with clear acceptance criteria.
- PRD defines the user problem, outcome, scope, success criteria, and approval for SDD.
- Proposal defines intent, scope, risks, and rollback. It requires an approved PRD.
- Spec defines requirements and acceptance scenarios.
- Design defines the technical approach and constraints.
- Tasks define the next small, reviewable work units.
- Apply-progress records current implementation slices, changed files, evidence, blockers, and next action.
- Verify records evidence that the implementation matches the docs.

Before moving to the next SDD phase, confirm the required docs exist and ask for user approval. The default SDD path is `request → PRD → proposal → spec → design → tasks → apply → verify → handoff`.

Before delegating or starting a phase/task, check MCP task progress and `docs/pegasus/apply-progress.md` for the same phase/task already in progress or completed. Avoid duplicate launches.

Before large implementation, estimate review workload. If work is likely to exceed about 400 changed lines or touch multiple unrelated areas, stop and ask whether to split it into chained PRs.

Verification should use fresh context when possible: re-read PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion. This is an operational rule, not a runtime guarantee.

Copilot prompts under `.github/prompts/` provide starting points for SDD phases, handoff, and memory updates. They reference `docs/pegasus/` as the source of truth.

## MCP Memory Policy

Use `pegasus-memory-mcp` as the operational memory interface for future or compacted sessions. Use MCP tools to recover, search, and save:

- active project/change context;
- decisions and rationale;
- task progress, blockers, and duplicate-work checks;
- handoffs and recovery notes;
- observations, gotchas, and reusable learnings;
- artifact paths, status, and summaries.

Treat MCP tool inputs, outputs, and documented capabilities as the memory contract. Do not rely on `pegasus-memory-mcp` implementation details.

If `pegasus-memory-mcp` is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Project/change artifact work may continue, but do not claim persistent memory was saved and do not fall back to Markdown memory.

If MCP returns ambiguous active context, do not ask the user to resolve MCP recovery details. Continue from available project artifacts and record external follow-up for `pegasus-memory-mcp` support when possible.

`docs/pegasus/memory/` is deprecated after MCP integration. Existing files may remain historical, but they are not an active backend, fallback, or co-source for operational memory.

Before ending a session, record a handoff through MCP when available. Merge new progress, apply-progress, memory, and verification evidence into existing useful history instead of replacing prior content.

## Legacy Cursor Compatibility

Cursor rules under `.cursor/rules/` are retained as secondary compatibility guidance. Prefer the VS Code/Copilot assets under `.github/` for new sessions.

## Boundaries

- Do not assume network access or external services.
- Do not create GitHub remotes, CI, deployment, database, framework scaffolding, or business/domain MVP code from this harness alone.
- Prefer small, reversible changes backed by documented requirements.
