# {{PROJECT_NAME}} Agent Guide

Target path: `{{TARGET_PATH}}`  
Harness created: `{{DATE}}`

This target workspace uses the Pegasus IA VS Code/Copilot harness. The harness is a documentation and workflow scaffold with Pegasus Memory operational persistence; Pegasus IA does not generate the business/domain MVP. Build business MVP code later only after the project docs explicitly define and approve that work.

VS Code/Copilot entry points live under `.github/`. `AGENTS.md` stays as portable guidance for agents and tools that can read repository instructions.

## Start Here

1. In VS Code with Copilot, start with `.github/agents/pegasus-orchestrator.agent.md`.
2. Read `.github/copilot-instructions.md` and the scoped files under `.github/instructions/`.
3. Recover current project context through `pegasus-memory-mcp` tools when available.
4. For an active change, read `docs/pegasus/changes/<change-id>/prd.md`, `proposal.md`, `spec.md`, `design.md`, `tasks.md`, and `apply-progress.md` before changing files. Root `docs/pegasus/design.md` is the canonical template only, not an active artifact.
5. Use `docs/pegasus/changes/<change-id>/apply-progress.md` to track implementation slices and `docs/pegasus/changes/<change-id>/verify.md` to record verification commands and outcomes.
6. Call Pegasus Memory `health` first, ensure the project/change exists when Pegasus Memory recovery reports missing preconditions, then save durable decisions, observations, handoffs, artifact references, and task progress through `pegasus-memory-mcp` when healthy.

## Pegasus IA Workflow

`pegasus-orchestrator` is a thin coordinator. Every SDD phase MUST be delegated to its matching specialized agent in a fresh context. Specialized agents execute their assigned phase directly and do not recursively delegate it. If delegation is unavailable, blocked, or fails, stop and report rather than absorbing phase work. Apply implements one authorized slice and returns; a distinct fresh-context verify agent evaluates it.

- Direct fix handles small, punctual, low-risk changes with clear acceptance criteria.
- PRD defines the user problem, outcome, scope, success criteria, and approval for SDD.
- Proposal defines intent, scope, risks, and rollback. It requires an approved PRD.
- Spec defines requirements and acceptance scenarios.
- Design defines the technical approach and constraints.
- Tasks define the next small, reviewable work units.
- Apply-progress records current implementation slices, changed files, evidence, blockers, and next action.
- Verify records evidence that the implementation matches the docs.

Before moving to the next SDD phase, confirm the required docs exist and ask for user approval. The default SDD path is `request → PRD → proposal → spec → design → tasks → apply → verify → handoff`.

Before delegating or starting a phase/task, check MCP task progress and `docs/pegasus/changes/<change-id>/apply-progress.md` for the same phase/task already in progress or completed. Avoid duplicate launches.

Session preflight sets the review budget and delivery preference only. `sdd-tasks` forecasts implementation volume before finalizing tasks. After tasks and before apply, the orchestrator must consult the user when the forecast exceeds budget, is High risk, recommends chaining, or needs a decision. The choices are `stacked-to-main`, `feature-branch-chain`, or explicit maintainer-approved `size:exception`; apply receives the resolved strategy and one authorized slice.

Outside SDD, delegate whenever understanding requires 4 or more files, implementation touches 2 or more non-trivial files, tests/builds/installs/external tools must run, or the work exceeds small mechanical coordination.

Verification should use fresh context when possible: re-read PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion. This is an operational rule, not a runtime guarantee.

Copilot prompts under `.github/prompts/` provide starting points for SDD phases, handoff, and memory updates. They reference `docs/pegasus/` as the source of truth.

## Pegasus Memory Policy

Use Pegasus Memory, served by `pegasus-memory-mcp`, as the operational memory interface for future or compacted sessions. Use its tools to recover, search, and save:

- active project/change context;
- decisions and rationale;
- task progress, blockers, and duplicate-work checks;
- handoffs and recovery notes;
- observations, gotchas, and reusable learnings;
- artifact paths, status, and summaries.
- bugfixes, discoveries/gotchas, conventions/patterns, configuration changes, user constraints, verification evidence, and session summaries.

`pegasus-memory-mcp` owns project/change operational persistence, artifacts, observations, task progress, and handoffs. Other MCP servers may coexist for other capabilities, but they must not substitute for Pegasus Memory records. Treat Pegasus Memory tool inputs, outputs, and documented capabilities as the memory contract. Do not rely on `pegasus-memory-mcp` implementation details.

After `health` succeeds, if recovery returns `not_found` with `project_not_found`, call `ensure_project` before recording observations, artifacts, task progress, or handoffs. When creating a new PRD/change under `docs/pegasus/changes/<change-id>/prd.md`, call `ensure_change` before `record_artifact` or change-scoped observations. Treat `persistence_error` or foreign-key write failures as precondition/flow bugs to report clearly, not MCP unavailability. Keep this internal; users should not need to mention ensure tools.

If `pegasus-memory-mcp` is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Project/change artifact work may continue, but do not claim persistent memory was saved and do not fall back to Markdown memory.

If MCP returns ambiguous active context, do not ask the user to resolve MCP recovery details. Continue from available project artifacts and record external follow-up for `pegasus-memory-mcp` support when possible.

`docs/pegasus/memory/` is deprecated after MCP integration. Existing files may remain historical, but they are not an active backend, fallback, or co-source for operational memory.

Before ending or pausing a session, call MCP `health` first and record a concise handoff/session summary through MCP when healthy. Merge new progress, apply-progress, memory, and verification evidence into existing useful history instead of replacing prior content.

## Legacy Cursor Compatibility

Cursor rules under `.cursor/rules/` are retained as secondary compatibility guidance. Prefer the VS Code/Copilot assets under `.github/` for new sessions.

## Boundaries

- Do not assume network access or external services.
- Do not create GitHub remotes, CI, deployment, database, framework scaffolding, or business/domain MVP code from this harness alone.
- Prefer small, reversible changes backed by documented requirements.
