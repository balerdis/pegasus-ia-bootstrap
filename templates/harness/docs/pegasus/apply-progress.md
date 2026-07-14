# Apply Progress: {{PROJECT_NAME}}

Use this file to track implementation progress for approved SDD task slices.

Use this template inside `docs/pegasus/changes/<change-id>/apply-progress.md` for change-specific SDD work. This file is the source of truth for apply evidence; MCP memory may store slice summaries, task status, blockers, and artifact references only.

Default the generated artifact to English regardless of chat language, persona, dominant approved-source language, or prior artifact language. Use another language only when the user explicitly names it; then localize every human-readable heading, label, and scaffold consistently and run the existing language gate.

Merge updates into the existing useful history. Do not overwrite prior implementation slices, changed files, verification evidence, blockers, risks, or next actions unless the user explicitly approves cleanup.

Before starting a slice, check this file and MCP task progress when available for the same phase/task already in progress or completed. Avoid duplicate launches.

## Current In-Progress Work

| Phase/Task | Approved task slice source | Owner/Agent | Started | Status | Notes |
|------------|----------------------------|-------------|---------|--------|-------|
| TBD | `docs/pegasus/changes/<change-id>/tasks.md` section TBD | TBD | {{DATE}} | Not started | TBD |

## Duplicate Check

Check this file and MCP task progress when available before editing.

| Date | Slice/Task | Duplicate-check result | Action |
|------|------------|------------------------|--------|
| {{DATE}} | TBD | No matching in-progress or completed work found / Duplicate found | Start slice / Stop and recover |

## Completed Work

| Date | Phase/Task | Summary | Verification Evidence |
|------|------------|---------|-----------------------|
| {{DATE}} | TBD | TBD | See `docs/pegasus/changes/<change-id>/verify.md` |

## Implementation Slices

| Slice | Approved source | Scope | Rollback Boundary | Status |
|-------|-----------------|-------|-------------------|--------|
| TBD | `docs/pegasus/changes/<change-id>/tasks.md` | TBD | TBD | TBD |

## Changed Files

| File | Change | Related Task | Notes |
|------|--------|--------------|-------|
| TBD | TBD | TBD | TBD |

## Verification Evidence

- Record commands and outcomes in `docs/pegasus/changes/<change-id>/verify.md`.
- Summarize relevant evidence here only when it helps future apply or verify sessions recover context quickly.
- Apply evidence is preliminary. It helps handoff, but it does not replace the verify phase.

| Slice/Task | Verification status | Preliminary evidence | Verify log reference |
|------------|---------------------|----------------------|----------------------|
| TBD | Not run / Pending verify / Passed locally / Blocked | TBD | `docs/pegasus/changes/<change-id>/verify.md` |

## Unresolved Risks

- TBD

## Blockers

- TBD

## Next Action

- TBD
