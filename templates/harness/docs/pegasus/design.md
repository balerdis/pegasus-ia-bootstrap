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

**Required Spanish rendering and classification:** use `Greenfield / no implementation evidence` in English artifacts and `Greenfield / sin evidencia de implementación` in Spanish artifacts. Spanish translates all human-readable headings, labels, table cells, and prose coherently. The canonical Spanish heading is exactly `Decisiones y compensaciones`; reject `Tradeoffs`, `Costos y compromisos`, `Compensaciones`, `Decisiones y costos y compromisos`, and other composite variants as headings. Do not leave `Inputs`, `Rationale`, `Unit`, or `Integration` untranslated. In Spanish, reject both `Greenfield/no implementation evidence` and `Greenfield / no implementation evidence`.

**Pegasus Memory product naming:** when naming persistence, write `Pegasus Memory` or the exact server annotation `pegasus-memory-mcp`. Reject standalone/generic `MCP`, `Contexto MCP`, `Memoria MCP`, and `Memoria Pegasus`. Validate every `MCP` occurrence independently: allow it only in the exact protocol phrase `protocolo MCP` or inside the exact server annotation. An allowed `protocolo MCP` occurrence never permits another standalone occurrence elsewhere in the document.

## Technical Context Classification

| Classification | Evidence inspected | Consequence for design precision |
|----------------|--------------------|----------------------------------|
| Existing system with implementation evidence / Greenfield / no implementation evidence | TBD | TBD |

## Material Technical Decisions and Gaps

| Decision or gap | Materiality | Disposition | Evidence / owner | Impact | Invariant architecture | Deferred choice | Why non-blocking | Next step | Needed-by gate |
|-----------------|-------------|-------------|------------------|--------|------------------------|-----------------|------------------|-----------|----------------|
| TBD | Platform/runtime, integration, persistence, deployment, or existing-stack constraint | Confirmed / assumption / deferred non-blocking / blocking | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

Blocking gaps prohibit design artifact writing, artifact finalization, and `record_artifact`; when Pegasus Memory is healthy, they still require minimal blocked control-state persistence: `ensure_project`/`ensure_change` as needed, `record_observation`, `record_task_progress` with status `blocked`, and `record_handoff`. A deferred non-blocking choice states the invariant architecture and why the stack choice can wait.

## Deferred Technical Choices

Use this dedicated section whenever any technical choice is deferred. Every deferred row is required to use status `deferred-non-blocking` (or its selected-language translation) and complete every column. A missing field is a blocking design gap: repair it or block before marker, language, or Pegasus Memory persistence gates. If there are no deferred choices, retain the explicit `None` / `Ninguna` row; never use ambiguous `TBD`. Exception: in Greenfield context without concrete implementation stack, framework, or runtime evidence, `None` / `Ninguna` is invalid. Record stack/framework/runtime selection as a structured non-blocking deferred choice needed before tasks/apply. Its invariant architecture MUST state that logical components, responsibilities, boundaries, interfaces, and control flow remain independent of the eventual framework/runtime selection.

| Choice / topic | Status | Owner | Impact | Next step | Needed-by gate | Invariant architecture | Why non-blocking | Evidence / source |
|----------------|--------|-------|--------|-----------|----------------|------------------------|------------------|-------------------|
| None / Ninguna | N/A | N/A | No deferred technical choice | N/A | N/A | N/A | N/A | Current-change evidence reviewed |

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

For a Spanish artifact, render this heading exactly as `## Decisiones y compensaciones`.

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
