## Verification Report

**Change**: adapt-bootstrap-to-vscode-copilot  
**Slice**: PR 1 / Work Unit 1 — CLI planning and layout foundation  
**Mode**: Standard verify; Strict TDD inactive per `openspec/config.yaml` (`strict_tdd: false`)  
**Verifier**: fresh-context corrective Slice 1 re-review

### Completeness

| Metric | Value |
|--------|-------|
| Phase 1 tasks total | 3 |
| Phase 1 tasks checked complete | 3 |
| Phase 1 tasks actually complete | 3 |
| Later-phase tasks incorrectly checked complete | 0 |

### Build & Tests Execution

**Build**: ➖ Not applicable — Python/Bash script project with no build manifest.

**Tests**: ✅ Passed

```text
$ bash tests/smoke.sh
Smoke tests passed.
```

**Additional manual probes**: ✅ Passed

```text
$ python3 bin/pegasus-harness-bootstrap --project-name conflict-check --target-path "$target-with-existing-.github"
status=2
Conflicts (preserved):
  .../target/.github/copilot-instructions.md
Run with --force to replace only known harness files.

$ python3 bin/pegasus-harness-bootstrap --project-name force-check --target-path "$target-with-existing-.github" --force
status=0
Overwrites (--force):
  .../target/.github/copilot-instructions.md
```

**Coverage**: ➖ Not available.

### Slice Task Compliance Matrix

| Task | Evidence | Result |
|------|----------|--------|
| 1.1 Update help, constants, plan output, and completion text for Copilot-first usage and legacy Cursor wording | `bin/pegasus-harness-bootstrap` now uses VS Code/Copilot-first docstring, argparse description, plan heading, primary IDE line, and completion text. Cursor global output is labeled legacy. `tests/smoke.sh` asserts new Copilot flag help and updated legacy Cursor wording. | ✅ COMPLIANT |
| 1.2 Add `--install-copilot-global` and `--vscode-target stable\|insiders`; keep `--install-cursor-global` as legacy | `parse_args()` defines `--install-copilot-global`, `--vscode-target` with `stable`/`insiders` choices, and preserves `--install-cursor-global` as a legacy option. Smoke covers help and `insiders` dry-run planning. | ✅ COMPLIANT |
| 1.3 Include `.github/`, `AGENTS.md`, `docs/pegasus/`, and `.cursor/` in conflict, force, dry-run, and reporting paths | `WORKSPACE_SURFACES` reports `.github/`, `.github/copilot-instructions.md`, `.github/instructions/`, `.github/prompts/`, `.github/agents/`, `AGENTS.md`, `docs/pegasus/`, and `.cursor/`. `workspace_inventory_files()` unions template-backed files with `PLANNED_WORKSPACE_FILES`, currently `.github/copilot-instructions.md`, before `build_plan()` handles creates/overwrites/conflicts. Smoke and manual probes confirm `.github/copilot-instructions.md` participates in conflict and force reporting. | ✅ COMPLIANT |

### Spec Compliance Matrix for Slice-Relevant Requirements

| Requirement | Scenario | Test / Evidence | Result |
|-------------|----------|-----------------|--------|
| Existing file protection | Existing file without overwrite approval | Smoke covers existing `AGENTS.md`, `docs/pegasus/memory/decisions.md`, and `.github/copilot-instructions.md`; manual probe confirms `.github/copilot-instructions.md` exits `2` and is preserved without `--force`. | ✅ COMPLIANT for Slice 1 |
| Optional global VS Code/Copilot configuration | Dry-run reports global plan | Smoke covers `--install-copilot-global --vscode-target insiders --dry-run` and confirms no target, VS Code Stable, or VS Code Insiders config writes. This remains planning-only by design for Slice 1. | ✅ COMPLIANT for Slice 1 |
| Completion output | Completion guidance | Completion text points users to VS Code/Copilot, `AGENTS.md`, and the future Copilot orchestrator entry point. | ✅ COMPLIANT for Slice 1 |
| Cursor legacy compatibility | Legacy Cursor guidance retained / default run does not touch global legacy configuration | Smoke confirms default run does not touch Cursor global config; legacy global flag remains available and output is labeled legacy. | ✅ COMPLIANT |

### Correctness (Static Evidence)

| Area | Status | Notes |
|------|--------|-------|
| CLI option surface | ✅ Implemented | New Copilot planning flags are accepted; invalid VS Code target values are rejected by argparse choices. |
| Workspace reporting | ✅ Implemented | Managed workspace surfaces include Copilot `.github` surfaces, portable `AGENTS.md`, `docs/pegasus/`, and legacy `.cursor/`. |
| Workspace conflict/force inventory | ✅ Implemented | `main()` passes `workspace_inventory_files(files)` into `build_plan()`, so planned `.github/copilot-instructions.md` participates in creates, conflicts, and `--force` overwrite reporting even before Phase 2 templates exist. |
| Phase 2 template scope | ✅ Preserved | No `templates/harness/.github/**` files exist; no Phase 2 Copilot workspace template content was added in this slice. |
| Out-of-slice config context | ✅ Accounted for | `openspec/config.yaml` remains modified in the working tree, but `apply-progress.md` documents it as pre-existing approved `sdd-init/testing-capabilities` context and explicitly does not count it as Slice 1 implementation. Phase 4.2 remains unchecked. |
| Apply bookkeeping | ✅ Corrected | `apply-progress.md` now records the corrective update, lists `.github/copilot-instructions.md` conflict/force coverage, identifies `openspec/config.yaml` as pre-existing/out-of-slice, and keeps later phases as remaining work. |

### Coherence (Design)

| Design decision | Followed? | Notes |
|-----------------|-----------|-------|
| Primary layout includes `.github`, `AGENTS.md`, `docs/pegasus`, and legacy `.cursor` | ✅ Yes for Slice 1 | CLI planning/reporting exposes the layout and protects the planned Copilot instructions entry file without adding Phase 2 templates. |
| Legacy Cursor remains available | ✅ Yes | Legacy global install behavior is retained and labeled legacy. |
| Global Copilot install is opt-in | ✅ Yes for Slice 1 | Flag is opt-in and planning-only; real settings path/merge behavior remains deferred to Phase 3. |
| Split implementation into reviewable slices | ✅ Yes | Phase 1 is complete; Phase 2/3/4 tasks remain unchecked. The pre-existing `openspec/config.yaml` diff is documented rather than treated as Slice 1 completion. |

### Issues Found

**CRITICAL**

None.

**WARNING**

1. `--force` reports `.github/copilot-instructions.md` in the overwrite inventory, but because Phase 2 templates are intentionally absent, no `.github` file is actually written or replaced by this slice. That matches the requested planning/protection scope, but reviewers should not interpret it as template delivery.

**SUGGESTION**

1. Keep Phase 4.2 unchecked until the archive/final docs/config slice decides whether `openspec/config.yaml` should be aligned with the stable spec state.

### Verdict

**PASS**

Corrected Slice 1 satisfies Phase 1 tasks 1.1–1.3. The previous blockers are resolved: `.github/copilot-instructions.md` is in the same CLI inventory used for conflict/force/dry-run/reporting, `openspec/config.yaml` is documented as pre-existing sdd-init context with Phase 4.2 still unchecked, and progress bookkeeping no longer overstates later-phase completion. No code was modified during this re-review; this report file was updated as the verification artifact.
