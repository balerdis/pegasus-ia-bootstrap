# {{PROJECT_NAME}} Agent Guide

Target path: `{{TARGET_PATH}}`  
Harness created: `{{DATE}}`

This target workspace uses the Pegasus IA Cursor harness. The harness is a documentation, workflow, and memory scaffold only; Pegasus IA does not generate the business/domain MVP. Build business MVP code later inside Cursor only after the project docs explicitly define and approve that work.

## Start Here

1. Read `docs/pegasus/memory/context.md` to recover current project context.
2. Read `docs/pegasus/proposal.md`, `docs/pegasus/spec.md`, `docs/pegasus/design.md`, and `docs/pegasus/tasks.md` before changing files.
3. Use `docs/pegasus/verify.md` to record verification commands and outcomes.
4. Update project-local Markdown memory as work progresses.

## Pegasus IA Workflow

- Proposal defines intent, scope, risks, and rollback.
- Spec defines requirements and acceptance scenarios.
- Design defines the technical approach and constraints.
- Tasks define the next small, reviewable work units.
- Verify records evidence that the implementation matches the docs.

## Local Memory Policy

Use `docs/pegasus/memory/` as the continuity source for future or compacted sessions:

- `context.md` — current project facts and operating assumptions.
- `decisions.md` — dated decisions with rationale and tradeoffs.
- `tasks-log.md` — task progress and blockers.
- `handoff.md` — short recovery notes for the next session.
- `learnings.md` — gotchas and reusable discoveries.

Before ending a session, update `handoff.md` and any memory files affected by your work.

## Boundaries

- Do not assume network access or external services.
- Do not create GitHub remotes, CI, deployment, database, framework scaffolding, or business/domain MVP code from this harness alone.
- Prefer small, reversible changes backed by documented requirements.
