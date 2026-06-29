# Design: {{PROJECT_NAME}}

## Inputs

| Source | Path | Status | Notes |
|--------|------|--------|-------|
| PRD | `docs/pegasus/prd.md` | Approved / Pending / Blocked | TBD |
| Proposal | `docs/pegasus/proposal.md` | Approved / Pending / Blocked | TBD |
| Spec | `docs/pegasus/spec.md` | Approved / Pending / Blocked | TBD |
| Memory / Decisions | `docs/pegasus/memory/` | Reviewed / Not reviewed | TBD |

Design work requires approved proposal and spec inputs. If the acceptance contract is unclear, stop and return to spec before designing.

## Design Goals / Non-Goals

| Type | Statement | Source |
|------|-----------|--------|
| Goal | TBD | TBD |
| Non-goal | TBD | TBD |

## Technical Approach

Describe the architecture and implementation strategy.

Document how the VS Code/Copilot entry points under `.github/` should guide the work, and how portable guidance in `AGENTS.md` and `docs/pegasus/` remains authoritative.

## Decisions and Tradeoffs

| Decision | Choice | Rationale | Tradeoffs |
|----------|--------|-----------|-----------|
| TBD | TBD | TBD | TBD |

## Alternatives Considered

| Alternative | Why not chosen | When to revisit |
|-------------|----------------|-----------------|
| TBD | TBD | TBD |

## Affected Areas / Files

| Area/File | Expected change | Owner/phase | Risk |
|-----------|-----------------|-------------|------|
| TBD | TBD | TBD | TBD |

## Data / Control Flow

```txt
TBD
```

## Files and Boundaries

| Area | Responsibility |
|------|----------------|
| `.github/` | Primary VS Code/Copilot instructions, prompts, and custom agents |
| `AGENTS.md` | Portable agent guidance for tools outside Copilot |
| `docs/pegasus/` | Local SDD source of truth and verification evidence |
| `docs/pegasus/memory/` | Markdown continuity layer for future or compacted sessions |
| `.cursor/` | Secondary legacy compatibility guidance |

## Testing Strategy

| Layer | What to verify | Evidence location |
|-------|----------------|-------------------|
| Unit | TBD | `docs/pegasus/verify.md` |
| Integration | TBD | `docs/pegasus/verify.md` |
| Manual / runtime | TBD | `docs/pegasus/verify.md` |

## Rollout / Rollback

| Topic | Plan |
|-------|------|
| Rollout | TBD |
| Rollback | TBD |
| Feature flag / migration | TBD |

## Risks / Open Questions

- TBD
