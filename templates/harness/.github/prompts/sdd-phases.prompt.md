---
name: pegasus-sdd-phases
description: Work through Pegasus IA SDD phases
tools:
  - read
  - search
  - edit
  - agent
---

# SDD phases prompt

Use `docs/pegasus/` as the source of truth: request → PRD → proposal → spec → design → tasks → apply → verify → handoff.

The `pegasus-orchestrator` is a thin coordinator. Delegate every phase to its matching specialized agent in a fresh context. A specialized phase agent executes directly and never recursively delegates its phase. If required delegation is unavailable, blocked, or fails, stop and report instead of absorbing the work. Apply and verify MUST be distinct fresh-context launches.

Follow `.github/instructions/pegasus-memory.instructions.md`. Call MCP `health` before first recovery/save, recover session context when healthy, call `ensure_project` before writes when recovery reports `project_not_found`, call `ensure_change` before new change-scoped artifact or observation writes, and proactively save decisions, discoveries, bugfixes, config changes, user constraints, artifact status, task progress, verification evidence, and handoff/session summaries through MCP after `health` succeeds.

Work only on the requested phase. Before moving forward, confirm the required prior docs exist and ask for user approval:

| Phase | Required docs/context | Output |
|-------|-----------------------|--------|
| PRD | User request and MCP memory after `health` succeeds | `docs/pegasus/prd.md` with approval status |
| Proposal | Approved current-change `docs/pegasus/changes/<change-id>/prd.md` | `docs/pegasus/changes/<change-id>/proposal.md` |
| Spec | Approved current-change PRD and proposal | `docs/pegasus/changes/<change-id>/spec.md` requirements and scenarios |
| Design | Approved current-change PRD, proposal, and spec | `docs/pegasus/changes/<change-id>/design.md` technical approach |
| Tasks | Approved current-change spec and design | `docs/pegasus/changes/<change-id>/tasks.md` reviewable slices |
| Apply | Approved current-change spec, design, tasks, and apply-progress | Implementation for only the next approved slice plus `docs/pegasus/changes/<change-id>/apply-progress.md` updates |
| Verify | Current-change tasks, apply-progress, verify log, implementation diff, and PRD/proposal/spec/design when possible | `docs/pegasus/changes/<change-id>/verify.md` evidence and verdict |

Before delegating or starting a phase/task, check MCP task progress and `docs/pegasus/changes/<change-id>/apply-progress.md` for the same phase/task already in progress or completed. Avoid duplicate launches. Root phase files are canonical templates only; root PRD is a natural-entry template only before an active change is selected.

Use the direct-fix path for small, punctual, low-risk changes with clear acceptance criteria. Do not force the full SDD flow when a documented direct fix is safer and faster.

Spec requires an approved PRD and approved proposal. It writes acceptance behavior only: requirements, edge cases, non-goals, traceability, and `GIVEN` / `WHEN` / `THEN` scenarios. Do not design architecture, write implementation tasks, or edit code from spec.

Design writes the technical approach only: decisions, tradeoffs, alternatives, affected areas/files, data/control flow, testing strategy, rollout/rollback, risks, and open questions. Do not implement code or create the task checklist from design.

Tasks writes the implementation plan only and forecasts implementation volume after session preflight. Include the exact lines `Decision needed before apply: Yes|No`, `Chained PRs recommended: Yes|No`, `Chain strategy: stacked-to-main|feature-branch-chain|size-exception|pending`, `400-line budget risk: Low|Medium|High`, `Estimated authored changed lines: <range>`, `Estimated generated changed lines: <range|none>`, and `Tests included in estimate: Yes`. Authored estimates include code, tests, docs, config, and migrations; generated goldens/snapshots/fixtures are counted separately. Every work unit declares implementation scope, test scope, focused test command, runtime validation, rollback boundary, and authored estimate. Tasks proposes work units but does not make the final delivery decision.

After tasks and before apply, the orchestrator inspects the forecast. If it exceeds the review budget, reports High risk, recommends chaining, or needs a decision, the orchestrator stops and asks the user to choose `stacked-to-main`, `feature-branch-chain`, or an explicit maintainer-approved `size:exception`; it never chooses silently. Apply receives the resolved strategy plus exactly one authorized slice or returns blocked before writing. Check duplicate identity by change, phase, and task slice. Apply may record preliminary notes/evidence, but it does not replace the verify phase. A distinct fresh-context verify phase owns verification.

For verification, use fresh context when possible: re-read current-change PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion. Verify the implementation against all of those sources, not just tests. Record a compliance matrix, commands/results, changed files reviewed, deviations, risks, runtime/manual evidence, and final verdict in `docs/pegasus/changes/<change-id>/verify.md`. Do not make unrelated implementation changes during verify unless the user separately asks for remediation. Call MCP `health` first; after `health` succeeds, save durable facts, decisions, task state, handoff notes, or learnings through MCP. Merge updates into existing useful history; do not overwrite prior progress, memory, apply-progress, or verification evidence.

If `pegasus-memory-mcp` is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Artifact work may continue, but do not claim persistent memory was saved and do not fall back to Markdown memory. If MCP active-context recovery is ambiguous, do not ask the user to resolve MCP recovery details; continue from available artifacts and record external MCP follow-up when possible. Treat `persistence_error` or foreign-key write failures as precondition/flow bugs to report clearly, not MCP unavailability.
