# Proposal: Durable Agent Communication

## Decision

Replace stateful result contracts with compact launches, disposable responses, and durable authority. This proposal authorizes specification and design only; it does **not** authorize implementation or decide technical design.

## Problem and Outcomes

Long reference chains burden specialists, while envelopes can become accidental recovery state. Operators need compact dispatches, continuity, visible failures, and unambiguous advancement authority.

## Scope

### In Scope
- Execution-only launches carrying objective, current intent, identity, store mode, exact context handles, outputs/focus/detail, resolved skills, and exceptional constraints. Generic behavior remains in skills/lazy references.
- Six-field ephemeral responses: `status`, `executive_summary`, `artifacts`, `durable_state_written`, `next_recommended`, `risks`, with independent status domains.
- Durable authority: OpenSpec/artifacts own phase truth; Pegasus Memory indexes revisions, summaries, blockers, and next action; visual TODOs are non-authoritative.
- Controlled-mutable `tasks.md` checkboxes, cumulative `apply-progress.md` evidence, and `verify.md` readiness authority.
- Event-time material observations; closure-time summary, progress, handoff, and references.
- Stable hierarchical identities, append-only observation lineage, semantic deduplication, and proportional recovery from orchestrator-supplied intent.
- Relative artifact paths with SHA-256 revisions; optional Git commit metadata.

### Non-Goals
- Prior-response continuation, adapters, dual contracts, Markdown fallback, or implementation planning.
- Changing manifest ownership or exposing external product terminology.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `pegasus-harness-bootstrap`: change orchestration, phase communication, persistence, artifact authority, and recovery behavior.

## Rollout and Compatibility

Migrate vertically by phase, starting with PRD. Durable artifact/Pegasus Memory evidence is required before deleting each phase's old envelope. A terminal slice deletes `shared/result-envelope.md`, remaining versioned contracts, and common routing complexity. Pegasus is under construction: mixed-state operation between slices has no compatibility guarantee. Keep slices reversible and within 800 lines or pause under ask-on-risk policy.

## Risks and Rollback

| Risk | Mitigation / rollback posture |
|---|---|
| Lost identity, authorization, or duplicate detection | Preserve fail-closed manifest gates; establish durable evidence before removing envelope logic. |
| Stale or fragmented state | Digest validation, deterministic manifests, stable hierarchy, explicit lineage. |
| Required persistence fails | Allow truthful partial response delivery, return blocked/not-written, and prohibit advancement until explicit recovery succeeds. |
| Checkbox edits replan scope | Permit state edits only; separately approve remediation work. |

## Success Criteria

- Every migrated phase uses the six-field response and no legacy result contract.
- Each old phase envelope is deleted only after durable artifact/Pegasus Memory evidence satisfies acceptance.
- Recovery and advancement use current artifacts plus Pegasus Memory, never prior envelopes or visual TODOs.
- Required durable writes are independently observable; failures block continuation.
- References validate by relative path and SHA-256 across workspace relocation.
- Apply history remains cumulative, task authority remains controlled-mutable, and Verify alone determines readiness.

## Open Decisions / Material Gaps

None at proposal scope.
