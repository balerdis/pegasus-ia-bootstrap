# Tasks: Integrate Pegasus Memory MCP

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated changed lines | 500-800 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 guidance contract -> PR 2 template removal/wiring -> PR 3 smoke/spec follow-up docs |
| Delivery strategy | ask-on-risk; Slice 1 approved for apply |
| Chain strategy | stacked-to-main |

Decision needed before apply: No for Slice 1
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|---|---|---|---|
| 1 | MCP-first generated guidance | PR 1 | Independent docs/template behavior slice. |
| 2 | Remove generated Markdown memory output | PR 2 | Depends on PR 1 wording and inventory decisions. |
| 3 | Smoke/OpenSpec/external follow-up | PR 3 | Depends on final generated tree and assertions. |

## Phase 1: Guidance Contract

- [x] 1.1 Update `templates/harness/AGENTS.md` and `.github/copilot-instructions.md` to define MCP-first recovery/search/save behavior, exact unavailable warning, and no Markdown fallback. Verify generated text covers spec scenarios: memory available, unavailable, and MCP-contract-only.
- [x] 1.2 Update `.github/instructions/pegasus-memory.instructions.md`, `pegasus-workflow.instructions.md`, and `pegasus-sdd-boundaries.instructions.md` to use MCP for durable memory and `docs/pegasus/changes/<change-id>/` for phase artifacts. Verify no instruction tells agents to write operational memory files.
- [x] 1.3 Update `.github/agents/pegasus-orchestrator.agent.md` and SDD phase agents to recover active context via MCP, avoid user-facing ambiguity prompts, and record task/artifact progress through MCP when available. Verify duplicate-work checks reference MCP task progress plus `docs/pegasus/apply-progress.md`.

## Phase 2: Deprecated Memory Output

- [x] 2.1 Delete `templates/harness/docs/pegasus/memory/*` and update `bin/pegasus-harness-bootstrap` only if inventory/copy behavior needs explicit exclusion. Verify a new harness no longer contains `docs/pegasus/memory/`.
- [x] 2.2 Repurpose or rename `.github/agents/memory-maintainer.agent.md` and `.github/prompts/memory-update.prompt.md` so they describe MCP memory writes, blocked-save behavior, and no retrospective Markdown memory. Verify names/content do not imply file-backed memory.
- [x] 2.3 Update `.cursor/rules/pegasus-memory.mdc` and `.cursor/rules/pegasus-workflow.mdc` as legacy compatibility guidance with the same MCP-first/no-fallback rules. Verify legacy assets do not contradict Copilot guidance.

## Phase 3: Change-Cycle Artifacts and Follow-up

- [x] 3.1 Update `templates/harness/docs/pegasus/{prd,proposal,spec,design,tasks,apply-progress,verify}.md` to keep phase artifacts file-based and change-scoped under `docs/pegasus/changes/<change-id>/`. Verify MCP is described as summary/status memory, not artifact source of truth.
- [x] 3.2 Create or update a follow-up note for `pegasus-memory-mcp` API gaps covering `projectKey`/`projectId`, health/ping, and active-context ambiguity support. Verify it is clearly external to this bootstrap implementation.

## Phase 4: Validation and Archive Prep

- [ ] 4.1 Update `tests/smoke.sh` expected files/assertions: no generated `docs/pegasus/memory/*`, exact Spanish warning present, MCP-first guidance present, and no banned Markdown-memory persistence references. Verify smoke passes locally.
- [ ] 4.2 Run OpenSpec validation for `integrate-pegasus-memory-mcp` and record evidence in the apply/verify artifacts. Verify no spec/task guard line is missing.
- [ ] 4.3 During archive later, merge this delta into `openspec/specs/pegasus-harness-bootstrap/spec.md` and preserve lineage. Rollback: revert template/test/spec changes; no data migration required.

## Risks / Rollback

- Risk: broad Markdown edits may exceed review budget; use the suggested chained PRs before apply.
- Risk: MCP API gaps may block precise guidance; keep bootstrap contract-level and document external follow-up.
- Rollback: revert generated guidance, deleted templates, and smoke assertions; no MCP data or migration rollback.
