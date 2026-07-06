# Apply Progress: Integrate Pegasus Memory MCP

## Current slice

| Field | Value |
|---|---|
| Slice | Slice 1 — Guidance Contract |
| Mode | Standard |
| Review strategy | Stacked PR slice to main |
| Scope | Generated guidance, instructions, agents, and phase prompts only |
| Out of scope | Removing generated `docs/pegasus/memory/*`, repurposing memory-maintainer/update assets, legacy Cursor cleanup, final smoke assertions, archive/stable spec sync, and `pegasus-memory-mcp` repo changes |

## Completed tasks

- [x] 1.1 Updated `templates/harness/AGENTS.md` and `.github/copilot-instructions.md` to define MCP-first recovery/search/save behavior, the exact unavailable warning, no Markdown fallback, MCP-contract-only boundaries, and non-user-facing handling for ambiguous active context.
- [x] 1.2 Updated `.github/instructions/pegasus-memory.instructions.md`, `pegasus-workflow.instructions.md`, and `pegasus-sdd-boundaries.instructions.md` to use MCP for durable memory and keep phase artifacts file-based under `docs/pegasus/` or `docs/pegasus/changes/<change-id>/`.
- [x] 1.3 Updated `.github/agents/pegasus-orchestrator.agent.md`, SDD phase agents, `session-handoff.agent.md`, and phase/handoff prompts to recover context via MCP, avoid user-facing ambiguity prompts, and record task/artifact/handoff state through MCP when available.

## Changed files

| File | Action | Notes |
|---|---|---|
| `templates/harness/AGENTS.md` | Modified | Replaced Markdown memory policy with MCP-first memory policy and approved unavailable warning. |
| `templates/harness/.github/copilot-instructions.md` | Modified | Replaced Markdown-memory source-of-truth guidance with MCP memory and file-artifact guidance. |
| `templates/harness/.github/instructions/pegasus-memory.instructions.md` | Modified | Reframed memory instruction as MCP-first, contract-only, no fallback. |
| `templates/harness/.github/instructions/pegasus-workflow.instructions.md` | Modified | Added MCP durable state and file-artifact boundaries. |
| `templates/harness/.github/instructions/pegasus-sdd-boundaries.instructions.md` | Modified | Removed operational Markdown-memory requirements from SDD boundaries. |
| `templates/harness/.github/agents/pegasus-orchestrator.agent.md` | Modified | Added MCP recovery, unavailable behavior, ambiguity handling, and duplicate-work checks. |
| `templates/harness/.github/agents/sdd-*.agent.md` | Modified | Updated SDD phase agents to read/save MCP memory when available. |
| `templates/harness/.github/agents/session-handoff.agent.md` | Modified | Updated handoff to use MCP memory and blocked-save behavior. |
| `templates/harness/.github/prompts/sdd-phases.prompt.md` | Modified | Updated SDD phase prompt to use MCP task progress and memory saves. |
| `templates/harness/.github/prompts/handoff.prompt.md` | Modified | Updated handoff prompt to use MCP memory. |
| `openspec/changes/integrate-pegasus-memory-mcp/tasks.md` | Modified | Marked Slice 1 tasks complete while leaving Slice 2 and later tasks pending. |
| `openspec/changes/integrate-pegasus-memory-mcp/apply-progress.md` | Added | Recorded Slice 1 progress. |
| `openspec/changes/integrate-pegasus-memory-mcp/verify-slice-1.md` | Added/modified | Recorded Slice 1 verification and cleanup result. |

## Corrective cleanup after Slice 1 verification

- [x] Replaced generated guidance wording that named MCP implementation-detail examples with the public-contract statement: MCP tool inputs, outputs, and documented capabilities are the memory contract; Pegasus must not rely on implementation details.
- [x] Replaced generated guidance wording about ambiguous active-context recovery so it avoids asking users to resolve MCP recovery details without naming implementation-specific records.
- [x] Left legitimate non-memory `database` boundary wording in generated guidance because it describes the no-app-scaffolding policy, not MCP behavior.

## Evidence from Slice 1

| Check | Result |
|---|---|
| `git diff --check` | Passed |
| `bash tests/smoke.sh` | Passed |
| `npx @fission-ai/openspec validate --all` | Passed — 2 items |
| Corrective cleanup search | Passed — generated harness guidance no longer names MCP implementation-detail examples; remaining `database` matches are no-app-scaffolding boundaries |

## Deviations

- Slice 2 was not applied. Generated `docs/pegasus/memory/*`, `memory-maintainer`, `memory-update`, Cursor legacy cleanup, and final smoke updates remain pending.

## Risks and follow-ups

- Slice 2 must remove/deprecate generated Markdown memory output and remaining Markdown-memory references.
- External MCP API follow-up for `projectKey`/`projectId`, health/ping, and active-context ambiguity remains for later work.
- Smoke coverage still needs final MCP-first assertions in a later slice.

## Next action

Commit/push Slice 1, then resume `sdd-apply` Slice 2.
