# Verification Report: Bootstrap CLI Lifecycle — Slice 2

## Summary

| Field | Result |
|---|---|
| Change | `bootstrap-cli-lifecycle` |
| Slice | Slice 2 — Manifest and Conflict Safety |
| Mode | Fresh-context SDD verification, hybrid persistence |
| Verdict | PASS |
| Scope checked | Manifest helpers, setup conflict planning/application, ownership markers, smoke coverage, apply progress |
| Out-of-scope leakage | No Slice 3 uninstall flags/flow or Slice 4 `--new-change` implementation found |

Slice 2 implements manifest-backed workspace ownership and conservative conflict skipping. Runtime smoke verification passed. The initially detected stale optional global Copilot prompt reference was cleaned up before commit.

## Completeness

| Task | Status | Evidence |
|---|---|---|
| 2.1 Add `manifest.py` for install, ownership, update, uninstall, workspace metadata; exclude active/last pointers | PASS | `pegasus_harness_bootstrap/manifest.py` writes `.pegasus-bootstrap-ia/manifest.json` with install, ownership, update, uninstall, and workspace sections. It guards forbidden active/last pointer keys. |
| 2.2 Existing generated-path conflicts report and skip writes unless `--force` is used | PASS | `cli.py` reports `Conflicts (skipped unless --force)`, writes only non-conflicting paths by default, records skipped paths in the manifest, and uses `--force` for overwrites. |
| 2.3 Templates or markers needed to prove Pegasus-managed ownership | PASS | Rendered workspace files are wrapped with `<!-- pegasus-harness:start ... -->` and `<!-- pegasus-harness:end ... -->` markers with ownership mode metadata. |
| 2.4 Smoke tests for manifest JSON and no-overwrite conflict behavior | PASS | `tests/smoke.sh` asserts manifest contents, no active/last pointers, ownership modes, marker presence, skipped conflicts, non-conflicting writes, and force overwrite behavior. |

## Runtime Evidence

| Command | Result | Notes |
|---|---|---|
| `bash tests/smoke.sh` | PASS | Smoke suite completed successfully with Slice 2 manifest/conflict assertions. |

## Spec Compliance Matrix

| Requirement / Scenario | Slice 2 Applicability | Status | Evidence |
|---|---:|---|---|
| Manifest-owned lifecycle metadata / Manifest supports uninstall | In scope | PASS | Generated manifest records workspace metadata, install file records, ownership metadata, update metadata, and uninstall metadata. Smoke verifies no `active_change`, `activeChange`, `last_change`, or `lastChange` appears. |
| Existing file protection / Conflict and overwrite | In scope | PASS | Default existing generated-path conflicts are reported and skipped; user content remains unchanged. `--force` reports overwrites and replaces known harness files. |
| MCP-first lifecycle boundary / no generated Markdown memory backend | Boundary check | PASS | Workspace generation still does not create `docs/pegasus/memory/`, the exact unavailable-memory warning remains in generated harness templates, and the optional global Copilot prompt now points to MCP-first memory instead of stale Markdown memory files. |
| Installable CLI lifecycle | Dependency from Slice 1 | PASS | Entry point and wrapper still exercised by smoke. |
| Workspace uninstall safety | Out of scope for Slice 2 | SKIPPED | Slice 3 remains unchecked in `tasks.md`; no `--uninstall-workspace` implementation found. |
| Global VS Code/Copilot uninstall safety | Out of scope for Slice 2 | SKIPPED | Slice 3 remains unchecked; no `--uninstall-copilot-global` implementation found. |
| Change-cycle creation starts with PRD only | Out of scope for Slice 2 | SKIPPED | Slice 4 remains unchecked; no `--new-change` implementation found. |

## Design Coherence

| Design Decision | Status | Evidence |
|---|---|---|
| Manifest scope excludes active/last change pointers | PASS | Manifest helper includes explicit forbidden-key guard and smoke validates absence in generated JSON. |
| Existing conflicts default to report-and-skip/no-write | PASS | `main()` removes conflicting relative paths from `paths_to_write` unless `--force` is set. |
| Chained PR boundary | PASS | Changed-line budget remains under 400: tracked diff 115 lines plus 122-line new `manifest.py` = ~237 changed lines. |
| Preserve MCP-first memory | PASS | No generated workspace Markdown memory backend found; exact warning preserved. Optional global Copilot prompt stale references were removed before commit. |

## Codebase Memory Evidence

| Check | Result |
|---|---|
| CBM index status | Ready for project key `home-serg-ia-scripts-pegasus-ia-bootstrap` with 1012 nodes and 1072 edges. |
| CBM changed surface | Reported tracked changes in `apply-progress.md`, `tasks.md`, `pegasus_harness_bootstrap/cli.py`, and `tests/smoke.sh`; untracked `manifest.py` was inspected manually. |
| CBM impact trace | `build_manifest` is called by `pegasus_harness_bootstrap.cli.main`, matching the expected setup flow. |

## Issues

### Critical

None.

### Warnings

None.

### Remediated During Orchestrator Review

- Updated `templates/copilot-global/prompts/pegasus-start.prompt.md` to remove stale `docs/pegasus/memory/context.md` and `docs/pegasus/memory/handoff.md` reads. The prompt now directs operational memory recovery through `pegasus-memory-mcp`, preserves the exact unavailable-memory warning, and explicitly forbids falling back to `docs/pegasus/memory/` as an active backend.
- Re-ran `bash tests/smoke.sh` after the prompt cleanup: PASS.

### Suggestions

- Add future uninstall-slice tests that consume the manifest records written by Slice 2, including marker-managed shared files and full-file owned Pegasus files.

## Changed Files Reviewed

- `PRD-bootstrap-cli-lifecycle.md`
- `openspec/changes/bootstrap-cli-lifecycle/proposal.md`
- `openspec/changes/bootstrap-cli-lifecycle/specs/pegasus-harness-bootstrap/spec.md`
- `openspec/changes/bootstrap-cli-lifecycle/design.md`
- `openspec/changes/bootstrap-cli-lifecycle/tasks.md`
- `openspec/changes/bootstrap-cli-lifecycle/apply-progress.md`
- `openspec/changes/bootstrap-cli-lifecycle/verify-slice-1.md`
- `pegasus_harness_bootstrap/manifest.py`
- `pegasus_harness_bootstrap/cli.py`
- `tests/smoke.sh`
- `README.md`
- `templates/copilot-global/prompts/pegasus-start.prompt.md`

## Final Verdict

PASS — Slice 2 is functionally complete, passes runtime verification, and the stale global prompt warning was resolved before commit.
