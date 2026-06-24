# Tasks: Create Cursor Harness Bootstrap

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 700-950 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 CLI planner/writer -> PR 2 templates -> PR 3 tests/policy docs |
| Delivery strategy | auto-forecast |
| Chain strategy | stacked-to-main |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Create Python CLI planning, validation, dry-run, conflict, and safe-write behavior in `bin/pegasus-harness-bootstrap` | PR 1 | Base `main`; include minimal smoke tests for CLI safety. |
| 2 | Add mirrored harness templates under `templates/harness/` | PR 2 | Depends on PR 1; public artifacts must avoid Gentle AI and Engram. |
| 3 | Add full shell test harness and verification docs | PR 3 | Depends on PR 2; validates spec scenarios and policy constraints. |

## Phase 1: CLI Foundation

- [x] 1.1 Create executable `bin/pegasus-harness-bootstrap` with `--project-name`, optional `--target-path`, `--dry-run`, `--force`, and help output.
- [x] 1.2 Implement project-name validation and default target derivation: `/var/www/html/personal/<project-name>`.
- [x] 1.3 Implement known harness path planning from `templates/harness/`, including token values `{{PROJECT_NAME}}`, `{{TARGET_PATH}}`, and `{{DATE}}`.
- [x] 1.4 Implement conflict detection so non-force runs preserve existing generated-path files and report conflicts before writes.
- [x] 1.5 Implement dry-run, safe directory creation, safe file writes, force overwrite listing, and completion guidance pointing to `AGENTS.md`.

## Phase 2: Harness Templates

- [x] 2.1 Create `templates/harness/AGENTS.md` with Pegasus IA workflow, SDD document usage, local memory policy, and no external-service assumptions.
- [x] 2.2 Create `.cursor/rules/pegasus-workflow.mdc` and `.cursor/rules/pegasus-memory.mdc` focused on Cursor workflow and memory recovery.
- [x] 2.3 Create `docs/pegasus/proposal.md`, `spec.md`, `design.md`, `tasks.md`, and `verify.md` templates with clear headings for future project work.
- [x] 2.4 Create `docs/pegasus/memory/context.md`, `decisions.md`, `tasks-log.md`, `handoff.md`, and `learnings.md` with read/write rules.
- [x] 2.5 Review generated-template wording to ensure no public/generated artifact mentions Gentle AI or Engram.

## Phase 3: Tests and Verification

- [x] 3.1 Create shell test runner under `tests/` using isolated temporary target directories.
- [x] 3.2 Test explicit inputs, default target derivation, successful structure generation, and project-name token rendering.
- [x] 3.3 Test dry-run writes nothing, conflict blocking preserves files, and `--force` reports overwritten known harness paths.
- [x] 3.4 Test policy constraints: no app-code paths, no Git/GitHub/CI/deployment side effects, and no banned public references.
- [x] 3.5 Add a verification command note to `openspec/changes/create-cursor-harness-bootstrap/tasks.md` during apply after commands are known.

## Final Verification

- Command: `bash tests/smoke.sh`
- Command: `/home/serg/tmp/opencode/openspec-cli-1.4.1-verify/node_modules/.bin/openspec validate create-cursor-harness-bootstrap --strict` if the pinned OpenSpec CLI is present.
- Scope: isolated temporary target directories; explicit and default inputs; harness structure generation; project-name token rendering; dry-run no-write behavior; conflict preservation; `--force` overwrite reporting; no app-code, Git, GitHub, CI, deployment side effects from the product bootstrap; and banned public-reference checks.
- Remediation note: tasks 3.1 through 3.5 were marked complete because the existing shell smoke runner and prior verification evidence already satisfy the verification scope; no new product features were added.

## Slice 1 Verification

- Command: `bash tests/smoke.sh`
- Runtime decision: product CLI is Python; the smoke wrapper remains shell for convenience.
- Scope: CLI help, default target derivation, dry-run no-write behavior, explicit target creation, token rendering, conflict preservation, force overwrite reporting path, and project-name validation.

## Slice 2 Verification

- Command: `bash tests/smoke.sh`
- Scope: full mirrored harness generation, dry-run no-write behavior, conflict preservation for root and nested generated paths, force overwrite reporting, project-name token rendering, and banned generated-reference check.

## Terminology Alignment Slice

- [x] Align SDD artifacts and implemented docs/templates to clarify the bootstrap configures a target workspace Cursor harness and does not generate business/domain MVP code.
- [x] Update misleading public CLI/help/docs wording from target project terminology to target workspace terminology where it could imply app generation.
- Verification: `bash tests/smoke.sh`
