# Apply Progress: Bootstrap CLI Lifecycle

## Scope

- Change: `bootstrap-cli-lifecycle`
- Applied slice: Slice 1 — Installability and README Cleanup; Slice 2 — Manifest and Conflict Safety; Slice 3 — Uninstall Safety; Slice 4 — Change-Cycle Creation
- Mode: Standard apply; strict TDD is disabled in `openspec/config.yaml`
- Artifact mode: hybrid — OpenSpec files plus Engram memory
- Previous apply progress: Slice 1, Slice 2, and Slice 3 read from OpenSpec and Engram observation `#4128`; Slice 4 status merged below

## Workload / PR Boundary

- Delivery: chained PR slice
- Chain strategy: stacked-to-main, as provided by the orchestrator/user for this apply batch
- Current PR boundary: PRD-only change-cycle creation through `--new-change`, including manifest-backed workspace validation and smoke coverage proving no later SDD phase artifacts are created.
- Out of scope for this slice: archive/final stable spec updates and creation of proposal/spec/design/tasks/apply-progress/verify files for new changes.

## Completed Tasks

- [x] 1.1 Created `pyproject.toml` with package metadata, Python requirement, and the `pegasus-harness-bootstrap` console entry point.
- [x] 1.2 Created `pegasus_harness_bootstrap/cli.py` by moving the existing CLI behavior without lifecycle feature expansion.
- [x] 1.3 Kept `bin/pegasus-harness-bootstrap` as a thin compatibility wrapper importing package `main()`.
- [x] 1.4 Updated `tests/smoke.sh` to verify the editable entry point and wrapper both run `--project-name demo --dry-run`.
- [x] 1.5 Updated `README.md` quick path to `.venv` editable and `pipx` usage, and removed stale generated-layout references to `docs/pegasus/memory/*`.
- [x] 2.1 Added `pegasus_harness_bootstrap/manifest.py` with manifest schema, ownership metadata, update/uninstall metadata, workspace metadata, checksum records, and guards against active/last change pointers.
- [x] 2.2 Updated setup planning/application so existing generated-path conflicts are reported and skipped by default while non-conflicting generated files and the manifest can still be written; `--force` remains the explicit overwrite path.
- [x] 2.3 Added Pegasus ownership markers around rendered workspace files to prove managed ownership for future uninstall/update flows.
- [x] 2.4 Extended smoke tests to assert manifest JSON contents, absence of active/last change pointers, marker ownership, and no-overwrite conflict preservation.
- [x] 3.1 Added workspace uninstall planning/application through `--uninstall-workspace`, including `--dry-run`, manifest-backed managed removals, marker checks, and empty-directory cleanup that preserves non-empty directories.
- [x] 3.2 Added global VS Code/Copilot uninstall through `--uninstall-copilot-global`, including pre-mutation settings parsing, Pegasus location removal, settings backups when affected, managed asset removal, and user setting/asset preservation.
- [x] 3.3 Extended smoke tests for invalid global settings, backup creation, dry-run behavior, real workspace/global removal, and non-empty directory preservation.
- [x] 4.1 Added `--new-change <change-id>` so an installed workspace can create only `docs/pegasus/changes/<change-id>/prd.md` using manifest-backed workspace validation without requiring `--project-name`.
- [x] 4.2 Extended smoke tests to assert `--new-change` creates `prd.md` only, does not create proposal/spec/design/tasks/apply-progress/verify artifacts, does not add active/last pointers to the manifest, and fails for a target without a Pegasus manifest.

## Verification Evidence

| Command | Result |
|---|---|
| `bash tests/smoke.sh` | PASS — smoke verification completed successfully. |
| `python3 -m venv /home/serg/tmp/opencode/pegasus-pip-install-test/venv && /home/serg/tmp/opencode/pegasus-pip-install-test/venv/bin/python -m pip install . && /home/serg/tmp/opencode/pegasus-pip-install-test/venv/bin/pegasus-harness-bootstrap --project-name demo --target-path /home/serg/tmp/opencode/pegasus-pip-install-test/demo --dry-run` | PASS — non-editable install entry point found packaged templates and ran dry-run setup. |
| `bash tests/smoke.sh` | PASS — Slice 2 smoke verification completed successfully, including manifest JSON and no-overwrite conflict behavior. |
| `bash tests/smoke.sh` | PASS — Slice 3 smoke verification completed successfully, including workspace uninstall dry-run/apply, global Copilot uninstall dry-run/apply, backup creation, invalid settings safety, and non-empty directory preservation. |
| `bash tests/smoke.sh` | PASS — Slice 4 smoke verification completed successfully, including PRD-only `--new-change`, no later phase artifacts, manifest pointer guard, and missing-manifest failure. |

## MCP-first Boundary Check

- No generated `docs/pegasus/memory/` backend was added.
- The exact unavailable-memory warning remains present in generated harness templates where relevant: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`.
- README no longer lists `docs/pegasus/memory/*` files as generated workspace layout.
- `--new-change` uses existing `docs/pegasus/changes/` only as source artifacts and does not treat files there as recovered operational memory.

## Files Changed

| File | Action | What changed |
|---|---|---|
| `pyproject.toml` | Created | Added setuptools package metadata and console script. |
| `pegasus_harness_bootstrap/__init__.py` | Created | Added package marker. |
| `pegasus_harness_bootstrap/cli.py` | Created | Moved existing CLI behavior from the `bin/` script into the package. |
| `bin/pegasus-harness-bootstrap` | Modified | Replaced the large script with a compatibility wrapper importing `main()`. |
| `tests/smoke.sh` | Modified | Added editable-install entry point and wrapper dry-run checks. |
| `README.md` | Modified | Documented `.venv` editable and `pipx` usage; removed stale generated memory layout entries. |
| `openspec/changes/bootstrap-cli-lifecycle/tasks.md` | Modified | Marked Slice 1 tasks complete. |
| `pegasus_harness_bootstrap/manifest.py` | Created | Added workspace manifest helpers, ownership modes, rendered-content markers, checksum records, and active/last pointer guard. |
| `pegasus_harness_bootstrap/cli.py` | Modified | Integrated manifest planning/writes and changed default conflict handling to skip conflicting generated paths unless `--force` is used. |
| `tests/smoke.sh` | Modified | Added Slice 2 assertions for manifest JSON, ownership markers, conflict skipping, and preserved user content. |
| `openspec/changes/bootstrap-cli-lifecycle/tasks.md` | Modified | Marked Slice 2 tasks complete. |
| `openspec/changes/bootstrap-cli-lifecycle/apply-progress.md` | Modified | Merged Slice 2 progress with existing Slice 1 history. |
| `pegasus_harness_bootstrap/cli.py` | Modified | Added workspace and global VS Code/Copilot uninstall planning/application, managed-only deletion checks, settings backup handling, and user setting preservation. |
| `tests/smoke.sh` | Modified | Added Slice 3 uninstall smoke coverage for dry-run, real removal, invalid global settings, backups, and non-empty directory preservation. |
| `openspec/changes/bootstrap-cli-lifecycle/tasks.md` | Modified | Marked Slice 3 tasks complete. |
| `openspec/changes/bootstrap-cli-lifecycle/apply-progress.md` | Modified | Merged Slice 3 progress with existing Slice 1 and Slice 2 history. |
| `pegasus_harness_bootstrap/cli.py` | Modified | Added `--new-change`, optional `--project-name` parsing for that flow, manifest-backed workspace validation, PRD template rendering, and PRD-only file creation. |
| `tests/smoke.sh` | Modified | Added Slice 4 assertions for help output, no-project-name `--new-change`, PRD-only creation, no later phase artifacts, missing-manifest failure, and manifest pointer preservation. |
| `openspec/changes/bootstrap-cli-lifecycle/tasks.md` | Modified | Marked Slice 4 tasks complete. |
| `openspec/changes/bootstrap-cli-lifecycle/apply-progress.md` | Modified | Merged Slice 4 progress with existing Slice 1, Slice 2, and Slice 3 history. |

## Deviations from Design

None — implementation matches the approved Slice 1, Slice 2, Slice 3, and Slice 4 design.

## Remaining Tasks

- [ ] Verification/rollback tasks for later slices and final verification
