# Verification: {{PROJECT_NAME}}

Use this file to prove that implementation matches the PRD, proposal, spec, design, and tasks. This is the sole authority for readiness, advancement, archive, and delivery eligibility.

Use this template inside `docs/pegasus/changes/<change-id>/verify.md` for change-specific SDD work. This verify file is the source of truth for validation evidence and verdicts; MCP memory may store summaries, status, and artifact references only.

Default the generated artifact to English regardless of chat language, persona, dominant approved-source language, or prior artifact language. Use another language only when the user explicitly names it; then localize every human-readable heading, label, and scaffold consistently and run the existing language gate.

Use `.github/prompts/sdd-phases.prompt.md` for Copilot-guided verification, but record the actual commands, observations, and outcomes here.

Append new verification evidence to preserve useful history. Do not remove prior commands, failures, deviations, or caveats unless the user explicitly approves cleanup.

When approved scope is incomplete, preserve Apply history and reopen the original task checkbox without changing its text. New remediation scope requires separate approval and evidence linked from this file.

Verify from fresh context when possible. Before judging completion, re-read PRD, proposal, spec, design, tasks, `docs/pegasus/changes/<change-id>/apply-progress.md`, this verify log, and changed files. This is an operational rule, not a runtime guarantee.

Merge-not-overwrite instructions: add new entries below while preserving useful prior evidence, failures, deviations, risks, and final verdicts. Mark superseded evidence clearly instead of deleting it.

## Verification Scope

| Item | Path / reference | Status | Notes |
|------|------------------|--------|-------|
| PRD | `docs/pegasus/changes/<change-id>/prd.md` | Reviewed / Not reviewed | TBD |
| Proposal | `docs/pegasus/changes/<change-id>/proposal.md` | Reviewed / Not reviewed | TBD |
| Spec | `docs/pegasus/changes/<change-id>/spec.md` | Reviewed / Not reviewed | TBD |
| Design | `docs/pegasus/changes/<change-id>/design.md` | Reviewed / Not reviewed | TBD |
| Tasks | `docs/pegasus/changes/<change-id>/tasks.md` | Reviewed / Not reviewed | TBD |
| Apply progress | `docs/pegasus/changes/<change-id>/apply-progress.md` | Reviewed / Not reviewed | TBD |

## Compliance Matrix

| Source | Requirement / decision / task | Evidence | Result | Notes |
|--------|-------------------------------|----------|--------|-------|
| PRD | TBD | TBD | Pass / Fail / Blocked | TBD |
| Proposal | TBD | TBD | Pass / Fail / Blocked | TBD |
| Spec | TBD | TBD | Pass / Fail / Blocked | TBD |
| Design | TBD | TBD | Pass / Fail / Blocked | TBD |
| Tasks | TBD | TBD | Pass / Fail / Blocked | TBD |

## Changed Files Reviewed

| File | Reviewed? | Notes |
|------|-----------|-------|
| TBD | Yes / No | TBD |

## Test Coverage / Manual Checks

| Area | Check | Evidence | Result |
|------|-------|----------|--------|
| TBD | TBD | TBD | TBD |

## Commands

| Date | Command | Result | Notes |
|------|---------|--------|-------|
| {{DATE}} | TBD | TBD | TBD |

## Acceptance Evidence

- [ ] Compliance matrix checked against PRD, proposal, spec, design, and tasks.
- [ ] Requirements checked against `docs/pegasus/changes/<change-id>/spec.md`.
- [ ] Task completion checked against `docs/pegasus/changes/<change-id>/tasks.md`.
- [ ] Apply-progress checked against `docs/pegasus/changes/<change-id>/apply-progress.md`.
- [ ] Changed files reviewed from fresh context where possible.
- [ ] PRD and proposal approval checked before SDD implementation.
- [ ] Risks or deviations documented.

## Deviations

Document any implementation differences and why they are acceptable.

| Deviation | Source affected | Impact | Follow-up |
|-----------|-----------------|--------|-----------|
| TBD | TBD | TBD | TBD |

## Risks

- TBD

## Example Verification Entry

| Date | Scope | Evidence | Verdict |
|------|-------|----------|---------|
| {{DATE}} | Slice EX-1 | Reviewed changed file and ran `bash tests/smoke.sh` successfully | Pass |

## Final Verdict

Verdict: Pass / Pass with caveats / Blocked / Fail

Rationale: TBD
