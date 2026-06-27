# Design: {{PROJECT_NAME}}

## Technical Approach

Describe the architecture and implementation strategy.

Document how the VS Code/Copilot entry points under `.github/` should guide the work, and how portable guidance in `AGENTS.md` and `docs/pegasus/` remains authoritative.

## Decisions

| Decision | Choice | Rationale | Tradeoffs |
|----------|--------|-----------|-----------|
| TBD | TBD | TBD | TBD |

## Data Flow

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

Describe unit, integration, and manual verification expectations.

## Risks

- TBD
