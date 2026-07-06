# Apply Progress: Integrate Pegasus Memory MCP

## Current slice

| Field | Value |
|---|---|
| Slice | Slice 3 — Change-Cycle Artifacts and Follow-up |
| Mode | Standard |
| Review strategy | Stacked PR slice to main |
| Scope | Change-cycle artifact templates and external `pegasus-memory-mcp` API-gap follow-up note only |
| Out of scope | Phase 4 broader smoke/OpenSpec/archive prep, stable spec archive sync, CLI lifecycle PRD, commits, pushes, PRs, and any changes to `/home/serg/ia-scripts/pegasus-memory-mcp` |

## Latest slice

| Field | Value |
|---|---|
| Slice | Slice 3 — Change-Cycle Artifacts and Follow-up |
| Mode | Standard |
| Review strategy | Stacked PR slice to main |
| Scope | Keep PRD/proposal/spec/design/tasks/apply-progress/verify templates file-based and change-scoped; document external MCP API gaps |
| Out of scope | Phase 4 broader smoke/OpenSpec/archive prep, stable spec archive sync, CLI lifecycle PRD, commits, pushes, PRs, and any changes to `/home/serg/ia-scripts/pegasus-memory-mcp` |

## Completed tasks

- [x] 1.1 Updated `templates/harness/AGENTS.md` and `.github/copilot-instructions.md` to define MCP-first recovery/search/save behavior, the exact unavailable warning, no Markdown fallback, MCP-contract-only boundaries, and non-user-facing handling for ambiguous active context.
- [x] 1.2 Updated `.github/instructions/pegasus-memory.instructions.md`, `pegasus-workflow.instructions.md`, and `pegasus-sdd-boundaries.instructions.md` to use MCP for durable memory and keep phase artifacts file-based under `docs/pegasus/` or `docs/pegasus/changes/<change-id>/`.
- [x] 1.3 Updated `.github/agents/pegasus-orchestrator.agent.md`, SDD phase agents, `session-handoff.agent.md`, and phase/handoff prompts to recover context via MCP, avoid user-facing ambiguity prompts, and record task/artifact/handoff state through MCP when available.
- [x] 2.1 Deleted generated `templates/harness/docs/pegasus/memory/*` templates. No explicit `bin/pegasus-harness-bootstrap` exclusion was needed because the CLI inventory is derived from existing template files.
- [x] 2.2 Repurposed `.github/agents/memory-maintainer.agent.md` and `.github/prompts/memory-update.prompt.md` to describe MCP memory writes, blocked-save behavior, and no retrospective Markdown memory while keeping filenames for this slice.
- [x] 2.3 Updated `.cursor/rules/pegasus-memory.mdc` and `.cursor/rules/pegasus-workflow.mdc` as legacy compatibility guidance with MCP-first recovery/search/write behavior, exact unavailable warning, and no Markdown fallback.
- [x] 3.1 Updated `templates/harness/docs/pegasus/{prd,proposal,spec,design,tasks,apply-progress,verify}.md` so generated phase templates point change-specific work to `docs/pegasus/changes/<change-id>/` and state MCP memory stores summaries/status/references rather than replacing file artifacts.
- [x] 3.2 Added `openspec/changes/integrate-pegasus-memory-mcp/pegasus-memory-mcp-follow-up.md` documenting external `pegasus-memory-mcp` API gaps for `projectKey`/`projectId`, health/ping, and active-context ambiguity support without modifying the MCP repo.

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
| `openspec/changes/integrate-pegasus-memory-mcp/tasks.md` | Modified | Marked Slice 1, Slice 2, and Slice 3 tasks complete while leaving Phase 4 tasks pending. |
| `openspec/changes/integrate-pegasus-memory-mcp/apply-progress.md` | Added/modified | Recorded Slice 1 progress and merged Slice 2 and Slice 3 progress without removing prior evidence. |
| `openspec/changes/integrate-pegasus-memory-mcp/verify-slice-1.md` | Added/modified | Recorded Slice 1 verification and cleanup result. |
| `templates/harness/docs/pegasus/prd.md` | Modified | Added change-scoped artifact source-of-truth guidance and changed proposal approval path to `docs/pegasus/changes/<change-id>/proposal.md`. |
| `templates/harness/docs/pegasus/proposal.md` | Modified | Replaced Markdown-memory context checklist with MCP context/status checks and change-scoped artifact review. |
| `templates/harness/docs/pegasus/spec.md` | Modified | Pointed source, duplicate-work, and boundary references to change-scoped artifacts. |
| `templates/harness/docs/pegasus/design.md` | Modified | Replaced Markdown-memory inputs/boundaries with MCP summary/status memory and change-scoped file artifacts. |
| `templates/harness/docs/pegasus/tasks.md` | Modified | Pointed task inputs, verification notes, and duplicate checks to change-scoped artifacts plus MCP task progress. |
| `templates/harness/docs/pegasus/apply-progress.md` | Modified | Replaced Markdown task-log checks with MCP task progress and change-scoped task/verify references. |
| `templates/harness/docs/pegasus/verify.md` | Modified | Pointed verification scope and acceptance evidence to change-scoped artifacts. |
| `openspec/changes/integrate-pegasus-memory-mcp/pegasus-memory-mcp-follow-up.md` | Added | Captured external MCP API follow-up for project identity, health/ping, and active-context ambiguity. |

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

## Evidence from Slice 3

| Check | Result |
|---|---|
| `git diff --check` | Passed |
| `bash tests/smoke.sh` | Passed |
| `npx @fission-ai/openspec validate --all` | Passed — 2 items |
| Artifact template stale memory search | Passed — no `docs/pegasus/memory` references remain in `templates/harness/docs/pegasus/*.md` |

## Deviations

- Filenames `memory-maintainer.agent.md` and `memory-update.prompt.md` were retained for Slice 2 to avoid broader lifecycle/entry-point rename churn; content now describes MCP memory writes and blocked-save behavior.
- `bin/pegasus-harness-bootstrap` did not require code changes because template copy/inventory behavior follows the files present under `templates/harness`.
- Slice 3 added the external MCP API-gap note under this bootstrap change folder, not in `/home/serg/ia-scripts/pegasus-memory-mcp`, to keep the follow-up visible without changing the separate MCP repo.

## Risks and follow-ups

- External MCP API follow-up for `projectKey`/`projectId`, health/ping, and active-context ambiguity is documented but remains unimplemented in the separate `pegasus-memory-mcp` project.
- Final broader smoke/spec/archive cleanup remains for Phase 4; Slice 3 only updated change-cycle templates, external follow-up notes, and validation evidence required for this slice.

## Next action

Run `sdd-verify` for Slice 3, then proceed to Phase 4 validation/archive prep only after explicit orchestration.
