# Verification: {{PROJECT_NAME}}

Use this file to prove that implementation matches the PRD, proposal, spec, design, and tasks.

Use `.github/prompts/sdd-phases.prompt.md` for Copilot-guided verification, but record the actual commands, observations, and outcomes here.

Append new verification evidence to preserve useful history. Do not remove prior commands, failures, deviations, or caveats unless the user explicitly approves cleanup.

Verify from fresh context when possible. Before judging completion, re-read PRD, proposal, spec, design, tasks, `docs/pegasus/apply-progress.md`, this verify log, and changed files. This is an operational rule, not a runtime guarantee.

Merge-not-overwrite instructions: add new entries below while preserving useful prior evidence, failures, deviations, risks, and final verdicts. Mark superseded evidence clearly instead of deleting it.

## Verification Scope

| Item | Path / reference | Status | Notes |
|------|------------------|--------|-------|
| PRD | `docs/pegasus/prd.md` | Reviewed / Not reviewed | TBD |
| Proposal | `docs/pegasus/proposal.md` | Reviewed / Not reviewed | TBD |
| Spec | `docs/pegasus/spec.md` | Reviewed / Not reviewed | TBD |
| Design | `docs/pegasus/design.md` | Reviewed / Not reviewed | TBD |
| Tasks | `docs/pegasus/tasks.md` | Reviewed / Not reviewed | TBD |
| Apply progress | `docs/pegasus/apply-progress.md` | Reviewed / Not reviewed | TBD |

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
- [ ] Requirements checked against `docs/pegasus/spec.md`.
- [ ] Task completion checked against `docs/pegasus/tasks.md`.
- [ ] Apply-progress checked against `docs/pegasus/apply-progress.md`.
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
