---
description: SDD boundaries for Pegasus IA work
applyTo: "**"
---

# SDD boundaries

## Language contract

Generate every agent-consumed artifact in English by default: PRD, proposal, spec, design, tasks, apply-progress, verify, handoff/session summaries, prompts, instructions, workflows, skills, and internal agent communication. Override English only when the user explicitly names the desired language for the artifact. Never infer artifact language from chat, persona, dominant source language, or prior artifacts. User-facing orchestrator conversation, README/user documentation, commit messages, and intentionally localized public runtime messages may use Spanish.

Preserve immutable identifiers, paths, tool/server names, exact approved titles, user quotations, validation literals, and required public warnings in their original form as clearly labelled data. Language-specific validation applies only after an explicit artifact-language override. Follow `.github/instructions/pegasus-memory.instructions.md` for the independent durable-memory language contract.

Treat proposal, spec, design, and tasks as gates:

- The orchestrator coordinates only. Every SDD phase runs through its matching specialized agent in a fresh context; if delegation is unavailable, blocked, or fails, stop instead of executing the phase in orchestrator context.
- Specialized phase agents execute directly and do not recursively delegate their assigned phase. Apply and verify always use distinct contexts.
- After design delegation, the orchestrator validates only the specialist result envelope. It never rereads or revalidates `design.md`, reruns phase gates, or performs design persistence; `sdd-design` owns artifact writing, marker/language/traceability validation, and phase persistence.
- Preserve visible delegated-agent/tool attribution when the runtime exposes it. Design closure reports only observable invocation and returned evidence, including the specialist name, fresh-context invocation, and artifact writer/validator/persistence owner.

- Do not implement behavior that is outside active `docs/pegasus/changes/<change-id>/tasks.md`.
- Do not bypass active `docs/pegasus/changes/<change-id>/spec.md`; acceptance scenarios are the contract.
- Keep PRD, proposal, spec, design, tasks, apply-progress, and verify as file artifacts under `docs/pegasus/` or `docs/pegasus/changes/<change-id>/`.
- Do not change architecture without updating the active `docs/pegasus/changes/<change-id>/design.md`, calling MCP `health` first, and recording the durable decision through MCP after `health` succeeds. Root `docs/pegasus/design.md` is a canonical template only, never the active change artifact.
- Do not duplicate phase/task work already marked in progress or completed in MCP task progress or `docs/pegasus/changes/<change-id>/apply-progress.md`.
- Do not skip active `docs/pegasus/changes/<change-id>/apply-progress.md` when implementing; merge implementation status, changed files, evidence, blockers, and next action there.
- Do not mark work complete until active `docs/pegasus/changes/<change-id>/verify.md` contains the commands and outcomes used to validate it.
- Do not use `docs/pegasus/memory/` as an operational memory backend, fallback, or co-source. It is deprecated after MCP integration.

If a change exceeds the current task scope, split it into a new documented work unit before editing. Identify launches by change, phase, and task slice so MCP task progress and apply-progress prevent duplicate launches.
