---
description: Pegasus IA workflow and documentation order
applyTo: "**"
---

# Pegasus IA workflow

Use the smallest safe workflow. Small, punctual, low-risk changes with clear acceptance criteria may use a direct-fix path with MCP memory and verification updates. Broader, ambiguous, architectural, or higher-risk changes use the local SDD flow under `docs/pegasus/`: request, PRD, proposal, spec, design, tasks, apply, verify, and handoff.

Natural-language product intent should trigger PRD discovery automatically. If the user describes an idea or asks to draft a PRD, do not expose Pegasus internals; call MCP `health` before recovery, recover/search context if healthy, ensure the project exists when recovery reports `project_not_found`, ask one concise round of key product questions before drafting or finalizing when the idea lacks product detail, draft or refine `docs/pegasus/prd.md`, tell the user the PRD file path and ask them to review it, call `ensure_change` before recording a new change PRD under `docs/pegasus/changes/<change-id>/`, save PRD status/decisions/questions and artifact reference through MCP after `health` succeeds, wait for explicit PRD approval before proposal/spec/design/tasks/apply, and do not implement code during PRD flow.

Phase artifacts stay file-based under `docs/pegasus/` or change-scoped `docs/pegasus/changes/<change-id>/` paths. Use MCP for durable memory summaries, task progress, handoffs, observations, and artifact references.

If requirements are missing, contradictory, or too broad, stop and clarify or update the docs before editing implementation files.

Prefer small, reviewable work units. Each unit should include its verification evidence and a clear rollback boundary.

Before moving to the next SDD phase, confirm the required prior docs exist and ask for user approval. Proposal requires an approved PRD.

Before delegating or starting a phase/task, check MCP task progress and `docs/pegasus/apply-progress.md` for matching work already in progress or completed. Do not launch duplicate work for the same phase/task.

Before implementation, estimate review workload. If the change is likely to exceed about 400 changed lines or touch multiple unrelated areas, stop and ask whether to split into chained PRs.

During apply, merge implementation slices, changed files, evidence, blockers, and next action into `docs/pegasus/apply-progress.md`.

When durable workflow state changes, call MCP `health` first. After `health` succeeds, call `ensure_project` before writes when recovery reports `project_not_found`, and call `ensure_change` before change-scoped artifact or observation writes. Then save decisions, observations, task progress, artifact references, and handoffs through MCP. If MCP is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`; artifact work may continue, but do not fall back to Markdown memory.

During verify, use fresh context when possible by re-reading PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion. This is an operational rule, not a runtime guarantee.
