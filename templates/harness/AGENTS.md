# {{PROJECT_NAME}} Agent Guide

Target path: `{{TARGET_PATH}}`  
Harness created: `{{DATE}}`

This target workspace uses the Pegasus IA VS Code/Copilot harness. The harness is a documentation, workflow, and memory scaffold only; Pegasus IA does not generate the business/domain MVP. Build business MVP code later only after the project docs explicitly define and approve that work.

VS Code/Copilot entry points live under `.github/`. `AGENTS.md` stays as portable guidance for agents and tools that can read repository instructions.

## Start Here

1. In VS Code with Copilot, start with `.github/agents/pegasus-orchestrator.agent.md`.
2. Read `.github/copilot-instructions.md` and the scoped files under `.github/instructions/`.
3. Read `docs/pegasus/memory/context.md` to recover current project context.
4. Read `docs/pegasus/prd.md`, `docs/pegasus/proposal.md`, `docs/pegasus/spec.md`, `docs/pegasus/design.md`, `docs/pegasus/tasks.md`, and `docs/pegasus/apply-progress.md` before changing files.
5. Use `docs/pegasus/apply-progress.md` to track implementation slices and `docs/pegasus/verify.md` to record verification commands and outcomes.
6. Update project-local Markdown memory as work progresses.

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

Before delegating or starting a phase/task, check `docs/pegasus/memory/tasks-log.md` and `docs/pegasus/apply-progress.md` for the same phase/task already in progress or completed. Avoid duplicate launches.

Before large implementation, estimate review workload. If work is likely to exceed about 400 changed lines or touch multiple unrelated areas, stop and ask whether to split it into chained PRs.

Verification should use fresh context when possible: re-read PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion. This is an operational rule, not a runtime guarantee.

Copilot prompts under `.github/prompts/` provide starting points for SDD phases, handoff, and memory updates. They reference `docs/pegasus/` as the source of truth.

## Local Memory Policy

Use `docs/pegasus/memory/` as the continuity source for future or compacted sessions:

- `context.md` — current project facts and operating assumptions.
- `decisions.md` — dated decisions with rationale and tradeoffs.
- `tasks-log.md` — task progress and blockers.
- `handoff.md` — short recovery notes for the next session.
- `learnings.md` — gotchas and reusable discoveries.

Before ending a session, update `handoff.md` and any memory files affected by your work. Merge new progress, apply-progress, memory, and verification evidence into the existing useful history instead of replacing prior content.

## Legacy Cursor Compatibility

Cursor rules under `.cursor/rules/` are retained as secondary compatibility guidance. Prefer the VS Code/Copilot assets under `.github/` for new sessions.

## Boundaries

- Do not assume network access or external services.
- Do not create GitHub remotes, CI, deployment, database, framework scaffolding, or business/domain MVP code from this harness alone.
- Prefer small, reversible changes backed by documented requirements.
