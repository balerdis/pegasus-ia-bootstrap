# Apply Progress: Bootstrap CLI Lifecycle

## Scope

- Change: `bootstrap-cli-lifecycle`
- Applied slice: Slice 1 — Installability and README Cleanup
- Mode: Standard apply; strict TDD is disabled in `openspec/config.yaml`
- Artifact mode: hybrid — OpenSpec files plus Engram memory
- Previous apply progress: none found

## Workload / PR Boundary

- Delivery: chained PR slice
- Chain strategy: stacked-to-main, as provided by the orchestrator/user for this apply batch
- Current PR boundary: installable package entry point, compatibility wrapper, smoke coverage, and README cleanup only
- Out of scope for this slice: manifest/conflict safety, uninstall flows, and `--new-change`

## Completed Tasks

- [x] 1.1 Created `pyproject.toml` with package metadata, Python requirement, and the `pegasus-harness-bootstrap` console entry point.
- [x] 1.2 Created `pegasus_harness_bootstrap/cli.py` by moving the existing CLI behavior without lifecycle feature expansion.
- [x] 1.3 Kept `bin/pegasus-harness-bootstrap` as a thin compatibility wrapper importing package `main()`.
- [x] 1.4 Updated `tests/smoke.sh` to verify the editable entry point and wrapper both run `--project-name demo --dry-run`.
- [x] 1.5 Updated `README.md` quick path to `.venv` editable and `pipx` usage, and removed stale generated-layout references to `docs/pegasus/memory/*`.

## Verification Evidence

| Command | Result |
|---|---|
| `bash tests/smoke.sh` | PASS — smoke verification completed successfully. |
| `python3 -m venv /home/serg/tmp/opencode/pegasus-pip-install-test/venv && /home/serg/tmp/opencode/pegasus-pip-install-test/venv/bin/python -m pip install . && /home/serg/tmp/opencode/pegasus-pip-install-test/venv/bin/pegasus-harness-bootstrap --project-name demo --target-path /home/serg/tmp/opencode/pegasus-pip-install-test/demo --dry-run` | PASS — non-editable install entry point found packaged templates and ran dry-run setup. |

## MCP-first Boundary Check

- No generated `docs/pegasus/memory/` backend was added.
- The exact unavailable-memory warning remains present in generated harness templates where relevant: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`.
- README no longer lists `docs/pegasus/memory/*` files as generated workspace layout.

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

## Deviations from Design

None — implementation matches the approved Slice 1 design.

## Remaining Tasks

- [ ] Slice 2: Manifest and Conflict Safety
- [ ] Slice 3: Uninstall Safety
- [ ] Slice 4: Change-Cycle Creation
- [ ] Verification/rollback tasks for later slices and final verification
