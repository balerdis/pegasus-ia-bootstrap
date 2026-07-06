# Apply Progress: Integrate Pegasus Memory MCP

## Current slice

| Field | Value |
|---|---|
| Slice | Slice 1 — Guidance Contract |
| Mode | Standard |
| Review strategy | Stacked PR slice to main |
| Scope | Generated guidance, instructions, agents, and phase prompts only |
| Out of scope | Removing generated `docs/pegasus/memory/*`, repurposing memory-maintainer/update assets, legacy Cursor cleanup, final smoke assertions, archive/stable spec sync, and `pegasus-memory-mcp` repo changes |

## Latest slice

| Field | Value |
|---|---|
| Slice | Slice 2 — Deprecated Memory Output |
| Mode | Standard |
| Review strategy | Stacked PR slice to main |
| Scope | Remove generated Markdown memory templates; repurpose memory update assets; align legacy Cursor memory/workflow guidance; minimal smoke updates required to validate generated tree no longer contains `docs/pegasus/memory/` |
| Out of scope | Slice 3 change-cycle artifact cleanup, external `pegasus-memory-mcp` follow-up note, archive/stable spec sync, commits, pushes, PRs, and any changes to `/home/serg/ia-scripts/pegasus-memory-mcp` |

## Completed tasks

- [x] 1.1 Updated `templates/harness/AGENTS.md` and `.github/copilot-instructions.md` to define MCP-first recovery/search/save behavior, the exact unavailable warning, no Markdown fallback, MCP-contract-only boundaries, and non-user-facing handling for ambiguous active context.
- [x] 1.2 Updated `.github/instructions/pegasus-memory.instructions.md`, `pegasus-workflow.instructions.md`, and `pegasus-sdd-boundaries.instructions.md` to use MCP for durable memory and keep phase artifacts file-based under `docs/pegasus/` or `docs/pegasus/changes/<change-id>/`.
- [x] 1.3 Updated `.github/agents/pegasus-orchestrator.agent.md`, SDD phase agents, `session-handoff.agent.md`, and phase/handoff prompts to recover context via MCP, avoid user-facing ambiguity prompts, and record task/artifact/handoff state through MCP when available.
- [x] 2.1 Deleted generated `templates/harness/docs/pegasus/memory/*` templates. No explicit `bin/pegasus-harness-bootstrap` exclusion was needed because the CLI inventory is derived from existing template files.
- [x] 2.2 Repurposed `.github/agents/memory-maintainer.agent.md` and `.github/prompts/memory-update.prompt.md` to describe MCP memory writes, blocked-save behavior, and no retrospective Markdown memory while keeping filenames for this slice.
- [x] 2.3 Updated `.cursor/rules/pegasus-memory.mdc` and `.cursor/rules/pegasus-workflow.mdc` as legacy compatibility guidance with MCP-first recovery/search/write behavior, exact unavailable warning, and no Markdown fallback.

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
| `templates/harness/docs/pegasus/memory/*` | Deleted | Removed deprecated generated Markdown memory templates. |
| `templates/harness/.github/agents/memory-maintainer.agent.md` | Modified | Repurposed maintainer agent from Markdown file maintenance to MCP memory writes and blocked-save behavior. |
| `templates/harness/.github/prompts/memory-update.prompt.md` | Modified | Repurposed memory update prompt for MCP durable memory writes and no retrospective Markdown memory. |
| `templates/harness/.cursor/rules/pegasus-memory.mdc` | Modified | Legacy Cursor memory guidance now points to MCP and no Markdown fallback. |
| `templates/harness/.cursor/rules/pegasus-workflow.mdc` | Modified | Legacy Cursor workflow guidance now checks MCP task progress and preserves the exact unavailable warning. |
| `tests/smoke.sh` | Modified | Removed generated memory-file expectations, added generated no-directory assertion, and updated conflict/force checks to use `apply-progress.md`. |
| `openspec/changes/integrate-pegasus-memory-mcp/tasks.md` | Modified | Marked Slice 1 and Slice 2 tasks complete while leaving Slice 3 and later tasks pending. |
| `openspec/changes/integrate-pegasus-memory-mcp/apply-progress.md` | Added/modified | Recorded Slice 1 progress and merged Slice 2 progress without removing prior evidence. |
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

## Evidence from Slice 2

| Check | Result |
|---|---|
| `git diff --check` | Passed |
| `bash tests/smoke.sh` | Passed |
| `npx @fission-ai/openspec validate --all` | Passed — 2 items |
| Generated memory directory assertion | Passed in smoke: generated harness must not include `docs/pegasus/memory/` after initial or forced bootstrap |

## Deviations

- Filenames `memory-maintainer.agent.md` and `memory-update.prompt.md` were retained for Slice 2 to avoid broader lifecycle/entry-point rename churn; content now describes MCP memory writes and blocked-save behavior.
- `bin/pegasus-harness-bootstrap` did not require code changes because template copy/inventory behavior follows the files present under `templates/harness`.

## Risks and follow-ups

- Slice 3 still owns change-cycle artifact cleanup in `templates/harness/docs/pegasus/{prd,proposal,spec,design,tasks,apply-progress,verify}.md`; some old Markdown-memory references remain there by design until that slice.
- External MCP API follow-up for `projectKey`/`projectId`, health/ping, and active-context ambiguity remains for later work.
- Final broader smoke/spec/archive cleanup remains for later phases; Slice 2 only added minimal smoke assertions needed to prove no generated `docs/pegasus/memory/` directory.

## Next action

Run `sdd-verify` for Slice 2, then continue with Slice 3 change-cycle artifact cleanup and external MCP follow-up note.
