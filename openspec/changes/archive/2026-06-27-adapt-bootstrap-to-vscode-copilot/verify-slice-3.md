# Verification Report: adapt-bootstrap-to-vscode-copilot — Slice 3

## Scope

Post-correction gate review for PR 3 / Work Unit 3 only: Global/User Copilot install.

## Verdict

PASS — the prior invalid VS Code `settings.json` write-safety blocker is resolved.

## Completeness

| Task | Status | Evidence |
|---|---|---|
| 3.1 Create `templates/copilot-global/{agents,instructions,prompts}/` with conservative assets and no unsupported parity claims. | Complete | `templates/copilot-global/agents/pegasus-global-orchestrator.agent.md`, `instructions/pegasus-global.instructions.md`, and `prompts/pegasus-start.prompt.md` exist. The text explicitly avoids runtime parity claims and defers to workspace-local assets. |
| 3.2 Add path resolution for Pegasus-managed root and Stable/Insiders settings paths respecting `XDG_CONFIG_HOME`. | Complete | `xdg_config_root()`, `copilot_managed_root()`, and `vscode_settings_path()` resolve through `XDG_CONFIG_HOME` when set and otherwise through `Path.home() / ".config"`. Stable uses `Code/User/settings.json`; Insiders uses `Code - Insiders/User/settings.json`. |
| 3.3 Implement Copilot global dry-run with no workspace, managed-root, settings, or backup writes. | Complete | `main()` prepares only plan data for dry-run and returns before `write_files()`, `write_copilot_global_files()`, and `write_copilot_settings()`. Smoke coverage asserts no target, Stable/Insiders settings dirs, or managed root are created. |
| 3.4 Back up settings and safely merge `chat.agentFilesLocations`, `chat.instructionsFilesLocations`, and `chat.promptFilesLocations` without removals. | Complete | `prepare_copilot_settings()` validates and computes the merge before non-dry-run writes. `write_copilot_settings()` backs up existing settings before writing. Smoke validates existing scalar settings, object values, and array values are preserved while Pegasus paths are appended. |
| 3.5 Preserve legacy `templates/cursor-global/` and Cursor global install behavior as secondary, with updated legacy wording. | Complete | `templates/cursor-global/pegasus-global.mdc` is retained with legacy wording; existing Cursor global install/update/backup behavior and legacy path preference still pass smoke coverage. |

## Runtime Evidence

| Command | Result |
|---|---|
| `bash tests/smoke.sh` | PASS — `Smoke tests passed.` |
| Targeted invalid-settings safety check | PASS — command exited `1` with `invalid VS Code settings JSON`; target workspace did not exist; settings content stayed `{ invalid json`; backup count stayed `0`; existing managed asset content stayed `existing managed asset`; managed `instructions/` and `prompts/` dirs were not created. |
| `git diff --stat` / `git status --short` inspection | PASS — Slice 3 implementation files are changed/untracked as expected; Phase 4 task checkboxes remain unchecked. |

## Spec Compliance Matrix

| Requirement / Scenario | Status | Evidence |
|---|---|---|
| Optional global VS Code/Copilot configuration — default is repository-only | PASS | Default smoke run creates the target harness and asserts no Cursor/XDG global config is touched. Copilot global code only activates behind `--install-copilot-global`. |
| Optional global VS Code/Copilot configuration — dry-run reports global plan | PASS | Dry-run prints managed root, selected settings path, asset creates/updates, backup plan, and settings merge keys. Smoke asserts no target, settings, or managed root writes. |
| Optional global VS Code/Copilot configuration — settings merge is backed up and non-destructive | PASS | Valid settings are backed up and preserve existing `editor.fontSize`, existing object entries, false values, and array entries. Pegasus-managed paths are added without removing existing values. |
| Optional global VS Code/Copilot configuration — invalid settings fail before writes | PASS | `main()` calls `prepare_copilot_settings()` before `write_files()` and `write_copilot_global_files()` for non-dry-run Copilot global installs. Smoke and targeted review prove invalid JSON creates no workspace, no settings backup, no settings change, and no managed asset writes. |
| Cursor legacy compatibility | PASS | Cursor global template remains in `templates/cursor-global/`, is labeled legacy, and smoke verifies global install/update backups plus legacy path preference. |

## Design Coherence

| Design Item | Status | Evidence |
|---|---|---|
| Explicit opt-in global install | PASS | `--install-copilot-global` gates Copilot global template discovery, managed root planning, and settings mutation. |
| Pegasus-managed global root | PASS | Global assets are written under `xdg_config_root() / "pegasus-ia" / "copilot"`. |
| Stable/Insiders separate targets | PASS | `--vscode-target stable|insiders` selects `Code` vs `Code - Insiders`; smoke verifies Insiders does not create Stable settings. |
| Backups before settings mutation | PASS | `prepare_copilot_settings()` determines the backup path; `write_copilot_settings()` copies existing settings before writing merged JSON. Missing settings files are created without a backup. |
| Safe failure on invalid settings | PASS | Invalid settings are parsed in `prepare_copilot_settings()` before any non-dry-run workspace or Copilot managed-root write. Targeted evidence proves no workspace, managed-root asset, settings, or backup writes occur on invalid JSON. |

## Issues

### CRITICAL

None.

### WARNING

None.

### SUGGESTION

None.

## Out-of-Scope Check

Phase 3 tasks remain complete and Phase 4 remains unchecked in `tasks.md`. The changed files are consistent with Slice 3 implementation plus focused smoke coverage and progress tracking. README/config alignment and full Phase 4 verification remain deferred.

## Final Gate

Slice 3 is ready for the next slice. The prior invalid-settings blocker is resolved, valid settings merge remains non-destructive, dry-run remains write-free, and legacy Cursor behavior still passes runtime smoke coverage.
