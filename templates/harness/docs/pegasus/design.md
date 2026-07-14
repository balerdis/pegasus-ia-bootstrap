<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/design.md ownership=full-file -->
# Design: <change-id>

This root file is the canonical template only. Copy it to `docs/pegasus/changes/<change-id>/design.md` for the active change; only that change-scoped file is the technical source of truth. Pegasus Memory stores summaries, status, and references. Render every human-readable label in the selected artifact language before persistence.

## Inputs and Source Status

| Source | Path | In-file status | Notes |
|--------|------|----------------|-------|
| PRD | `docs/pegasus/changes/<change-id>/prd.md` | Approved | TBD |
| Proposal | `docs/pegasus/changes/<change-id>/proposal.md` | Approved | TBD |
| Spec | `docs/pegasus/changes/<change-id>/spec.md` | Approved | TBD |
| Pegasus Memory context | Project/change context | Reviewed / unavailable | TBD |

Design requires all three current-change artifacts approved in-file. Conversational approval cannot override an artifact. Related changes are forbidden unless an explicit dependency is disclosed.

## Artifact Language

| Selection rule | Selected language | Gate result | Explicit technical exceptions |
|----------------|-------------------|-------------|-------------------------------|
| User request, otherwise dominant approved-source language | TBD | Pending | Managed markers, identifiers, code, paths, tool/server names, deliberately standardized terms |

**Required Spanish rendering:** translate all human-readable headings, labels, table cells, and prose coherently. Do not leave labels such as `Inputs`, `Rationale`, `Tradeoffs`, `Unit`, or `Integration` untranslated.

## Technical Context Classification

| Classification | Evidence inspected | Consequence for design precision |
|----------------|--------------------|----------------------------------|
| Existing system with implementation evidence / Greenfield/no implementation evidence | TBD | TBD |

## Material Technical Decisions and Gaps

| Decision or gap | Materiality | Disposition | Evidence / owner | Impact | Invariant architecture | Deferred choice | Why non-blocking | Next step | Needed-by gate |
|-----------------|-------------|-------------|------------------|--------|------------------------|-----------------|------------------|-----------|----------------|
| TBD | Platform/runtime, integration, persistence, deployment, or existing-stack constraint | Confirmed / assumption / deferred non-blocking / blocking | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

Blocking gaps prohibit design artifact writing, artifact finalization, and `record_artifact`; when Pegasus Memory is healthy, they still require minimal blocked control-state persistence: `ensure_project`/`ensure_change` as needed, `record_observation`, `record_task_progress` with status `blocked`, and `record_handoff`. A deferred non-blocking choice states the invariant architecture and why the stack choice can wait.

## Design Goals / Non-Goals

| Type | Statement | Source |
|------|-----------|--------|
| Goal | TBD | TBD |
| Non-goal | TBD | TBD |

## Components, Responsibilities, and Boundaries

| Component / boundary | Responsibility | Interface or contract | Evidence |
|----------------------|----------------|-----------------------|----------|
| TBD | TBD | TBD | Spec requirement or repository evidence |

## Technical Approach and Flow

Describe the architecture without inventing modules or files absent from evidence.

## Confirmed Decisions, Assumptions, and Tradeoffs

| Decision | State | Choice | Rationale / evidence | Tradeoffs |
|----------|--------|-----------|-----------|
| TBD | Confirmed / Assumption / Deferred non-blocking | TBD | Spec requirement or evidence | TBD |

## Alternatives Considered

| Alternative | Why not chosen | Evidence / tradeoff | When to revisit |
|-------------|----------------|---------------------|-----------------|
| TBD | TBD | TBD | TBD |

## Affected Areas

| Area/File | Expected change | Evidence / traceability | Risk |
|-----------|-----------------|-------------------------|------|
| TBD | TBD | Spec requirement or repository evidence | TBD |

## Data / Control Flow

| Flow step | Trigger / input | Component or boundary | Output / control | Evidence / traceability |
|-----------|-----------------|-----------------------|------------------|------------------------|
| TBD | TBD | TBD | TBD | Spec requirement or repository evidence |

```txt
TBD
```

## Testing Strategy

| Layer | What to verify | Requirement / risk traceability | Evidence location |
|-------|----------------|-------------------------------|-------------------|
| Unit | TBD | TBD | `docs/pegasus/changes/<change-id>/verify.md` |
| Integration | TBD | TBD | `docs/pegasus/changes/<change-id>/verify.md` |
| Manual / runtime | TBD | TBD | `docs/pegasus/changes/<change-id>/verify.md` |

## Rollout / Rollback

| Topic | Plan | Evidence / trigger |
|-------|------|--------------------|
| Rollout | TBD | TBD |
| Rollback | TBD | TBD |
| Feature flag / migration | TBD | TBD |

## Risks and Open Questions

| Risk or question | Impact | Mitigation / owner | Evidence / traceability | Needed-by |
|------------------|--------|--------------------|-------------------------|-----------|
| TBD | TBD | TBD | TBD | TBD |
<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/design.md -->
