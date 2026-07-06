# Design: {{PROJECT_NAME}}

Use this template inside `docs/pegasus/changes/<change-id>/design.md` for change-specific SDD work. The design file is the technical source of truth; MCP memory may store decision summaries, status, and artifact references only.

## Inputs

| Source | Path | Status | Notes |
|--------|------|--------|-------|
| PRD | `docs/pegasus/changes/<change-id>/prd.md` | Approved / Pending / Blocked | TBD |
| Proposal | `docs/pegasus/changes/<change-id>/proposal.md` | Approved / Pending / Blocked | TBD |
| Spec | `docs/pegasus/changes/<change-id>/spec.md` | Approved / Pending / Blocked | TBD |
| MCP decisions/status | MCP summary/status memory | Reviewed / Not reviewed / Unavailable | TBD |

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
| `docs/pegasus/changes/<change-id>/` | Local SDD source of truth and verification evidence for a change |
| MCP memory | Operational summaries, active context, task status, handoffs, observations, and artifact references |
| `.cursor/` | Secondary legacy compatibility guidance |

## Testing Strategy

| Layer | What to verify | Evidence location |
|-------|----------------|-------------------|
| Unit | TBD | `docs/pegasus/changes/<change-id>/verify.md` |
| Integration | TBD | `docs/pegasus/changes/<change-id>/verify.md` |
| Manual / runtime | TBD | `docs/pegasus/changes/<change-id>/verify.md` |

## Rollout / Rollback

| Topic | Plan |
|-------|------|
| Rollout | TBD |
| Rollback | TBD |
| Feature flag / migration | TBD |

## Risks / Open Questions

- TBD
