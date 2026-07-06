# Apply Progress: Integrate Pegasus Memory MCP

## Current slice

| Field | Value |
|---|---|
| Slice | Phase 4 — Validation and Archive Prep |
| Mode | Standard |
| Review strategy | Stacked PR slice to main |
| Scope | Smoke assertions, OpenSpec validation evidence, task guard-line check, and archive-prep documentation only |
| Out of scope | Stable spec archive sync, actual archive execution, CLI lifecycle PRD, commits, pushes, PRs, and any changes to `/home/serg/ia-scripts/pegasus-memory-mcp` |

## Latest slice

| Field | Value |
|---|---|
| Slice | Phase 4 — Validation and Archive Prep |
| Mode | Standard |
| Review strategy | Stacked PR slice to main |
| Scope | Final smoke/OpenSpec checks for generated MCP-first memory behavior plus archive-prep lineage notes |
| Out of scope | Stable spec archive sync, actual archive execution, CLI lifecycle PRD, commits, pushes, PRs, and any changes to `/home/serg/ia-scripts/pegasus-memory-mcp` |

## Completed tasks

- [x] 1.1 Updated `templates/harness/AGENTS.md` and `.github/copilot-instructions.md` to define MCP-first recovery/search/save behavior, the exact unavailable warning, no Markdown fallback, MCP-contract-only boundaries, and non-user-facing handling for ambiguous active context.
- [x] 1.2 Updated `.github/instructions/pegasus-memory.instructions.md`, `pegasus-workflow.instructions.md`, and `pegasus-sdd-boundaries.instructions.md` to use MCP for durable memory and keep phase artifacts file-based under `docs/pegasus/` or `docs/pegasus/changes/<change-id>/`.
- [x] 1.3 Updated `.github/agents/pegasus-orchestrator.agent.md`, SDD phase agents, `session-handoff.agent.md`, and phase/handoff prompts to recover context via MCP, avoid user-facing ambiguity prompts, and record task/artifact/handoff state through MCP when available.
- [x] 2.1 Deleted generated `templates/harness/docs/pegasus/memory/*` templates. No explicit `bin/pegasus-harness-bootstrap` exclusion was needed because the CLI inventory is derived from existing template files.
- [x] 2.2 Repurposed `.github/agents/memory-maintainer.agent.md` and `.github/prompts/memory-update.prompt.md` to describe MCP memory writes, blocked-save behavior, and no retrospective Markdown memory while keeping filenames for this slice.
- [x] 2.3 Updated `.cursor/rules/pegasus-memory.mdc` and `.cursor/rules/pegasus-workflow.mdc` as legacy compatibility guidance with MCP-first recovery/search/write behavior, exact unavailable warning, and no Markdown fallback.
- [x] 3.1 Updated `templates/harness/docs/pegasus/{prd,proposal,spec,design,tasks,apply-progress,verify}.md` so generated phase templates point change-specific work to `docs/pegasus/changes/<change-id>/` and state MCP memory stores summaries/status/references rather than replacing file artifacts.
- [x] 3.2 Added `openspec/changes/integrate-pegasus-memory-mcp/pegasus-memory-mcp-follow-up.md` documenting external `pegasus-memory-mcp` API gaps for `projectKey`/`projectId`, health/ping, and active-context ambiguity support without modifying the MCP repo.
- [x] 4.1 Updated `tests/smoke.sh` with explicit generated harness assertions for no `docs/pegasus/memory/` directory, exact Spanish MCP-unavailable warning, MCP-first guidance, and banned legacy Markdown-memory persistence references.
- [x] 4.2 Ran `git diff --check`, `bash tests/smoke.sh`, and `npx @fission-ai/openspec validate --all`; verified the required spec/task guard lines are present and recorded evidence here and in `verify-slice-4.md`.
- [x] 4.3 Documented archive preparation: the later archive phase must merge the delta into `openspec/specs/pegasus-harness-bootstrap/spec.md`, preserve this change folder as dated lineage, and avoid changing `/home/serg/ia-scripts/pegasus-memory-mcp`.

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
| `tests/smoke.sh` | Modified | Added generated MCP-first guidance assertions, exact warning checks, repeated no-memory-directory checks, and banned legacy Markdown-memory persistence reference guard. |
| `openspec/changes/integrate-pegasus-memory-mcp/tasks.md` | Modified | Marked Phase 4 tasks complete and corrected the workload guard line to exact `Decision needed before apply: No` shape. |
| `openspec/changes/integrate-pegasus-memory-mcp/apply-progress.md` | Added/modified | Recorded Slice 1, Slice 2, Slice 3, and Phase 4 progress without removing prior evidence. |
| `openspec/changes/integrate-pegasus-memory-mcp/verify-slice-1.md` | Added/modified | Recorded Slice 1 verification and cleanup result. |
| `templates/harness/docs/pegasus/prd.md` | Modified | Added change-scoped artifact source-of-truth guidance and changed proposal approval path to `docs/pegasus/changes/<change-id>/proposal.md`. |
| `templates/harness/docs/pegasus/proposal.md` | Modified | Replaced Markdown-memory context checklist with MCP context/status checks and change-scoped artifact review. |
| `templates/harness/docs/pegasus/spec.md` | Modified | Pointed source, duplicate-work, and boundary references to change-scoped artifacts. |
| `templates/harness/docs/pegasus/design.md` | Modified | Replaced Markdown-memory inputs/boundaries with MCP summary/status memory and change-scoped file artifacts. |
| `templates/harness/docs/pegasus/tasks.md` | Modified | Pointed task inputs, verification notes, and duplicate checks to change-scoped artifacts plus MCP task progress. |
| `templates/harness/docs/pegasus/apply-progress.md` | Modified | Replaced Markdown task-log checks with MCP task progress and change-scoped task/verify references. |
| `templates/harness/docs/pegasus/verify.md` | Modified | Pointed verification scope and acceptance evidence to change-scoped artifacts. |
| `openspec/changes/integrate-pegasus-memory-mcp/pegasus-memory-mcp-follow-up.md` | Added | Captured external MCP API follow-up for project identity, health/ping, and active-context ambiguity. |
| `openspec/changes/integrate-pegasus-memory-mcp/verify-slice-4.md` | Added | Recorded Phase 4 validation evidence, guard-line check, and archive-prep instructions. |

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

## Evidence from Phase 4

| Check | Result |
|---|---|
| `git diff --check` | Passed |
| `bash tests/smoke.sh` | Passed — `Smoke tests passed.` |
| `npx @fission-ai/openspec validate --all` | Passed — 2 items (`change/integrate-pegasus-memory-mcp`, `spec/pegasus-harness-bootstrap`) |
| Generated memory directory assertions | Passed in smoke for initial and forced bootstrap: generated harness must not include `docs/pegasus/memory/` |
| Exact Spanish warning assertion | Passed in smoke: generated `AGENTS.md` contains the approved warning exactly |
| MCP-first guidance assertion | Passed in smoke: generated `AGENTS.md` and `pegasus-memory.instructions.md` contain MCP-first guidance |
| Banned Markdown-memory persistence references | Passed in smoke: no generated references to legacy memory files (`context.md`, `tasks-log.md`, `decisions.md`, `handoff.md`, `learnings.md`) or legacy read/write/update/source-of-truth/backend phrases |
| Spec/task guard lines | Passed: delta spec requires the exact guard lines; `tasks.md` includes `Decision needed before apply: No`, `Chained PRs recommended: Yes`, and `400-line budget risk: High` |

## Archive preparation notes

- Later archive MUST merge the delta in `openspec/changes/integrate-pegasus-memory-mcp/specs/pegasus-harness-bootstrap/spec.md` into the stable spec at `openspec/specs/pegasus-harness-bootstrap/spec.md`.
- Preserve lineage by moving the full change folder to `openspec/changes/archive/YYYY-MM-DD-integrate-pegasus-memory-mcp/` during archive, keeping PRD/proposal/spec/design/tasks/apply/verify evidence together.
- Do not archive during apply or verify; archive only after explicit approval following verification.
- Rollback remains file-only: revert template/test/spec changes; no MCP data migration or changes to `/home/serg/ia-scripts/pegasus-memory-mcp` are required.

## Deviations

- Filenames `memory-maintainer.agent.md` and `memory-update.prompt.md` were retained for Slice 2 to avoid broader lifecycle/entry-point rename churn; content now describes MCP memory writes and blocked-save behavior.
- `bin/pegasus-harness-bootstrap` did not require code changes because template copy/inventory behavior follows the files present under `templates/harness`.
- Slice 3 added the external MCP API-gap note under this bootstrap change folder, not in `/home/serg/ia-scripts/pegasus-memory-mcp`, to keep the follow-up visible without changing the separate MCP repo.
- Phase 4 corrected the tasks guard line from `Decision needed before apply: No for Slice 1` to the exact guard-line shape `Decision needed before apply: No` required by the SDD workload guard.

## Risks and follow-ups

- External MCP API follow-up for `projectKey`/`projectId`, health/ping, and active-context ambiguity is documented but remains unimplemented in the separate `pegasus-memory-mcp` project.
- Archive/stable spec sync remains intentionally pending until the archive phase is explicitly requested after verification.

## Next action

Run `sdd-verify` for the full `integrate-pegasus-memory-mcp` change. If verification passes and the user explicitly approves, run `sdd-archive` to merge the delta into the stable spec while preserving lineage.
