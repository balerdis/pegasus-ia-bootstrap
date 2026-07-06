# Design: Bootstrap CLI Lifecycle

## Technical Approach

Refactor the current single executable `bin/pegasus-harness-bootstrap` into an installable Python package while preserving the existing CLI behavior first. The implementation should be staged: Slice 1 delivers packaging, entry point, compatibility wrapper, and documentation so review can focus on installability; later slices add manifest-backed ownership, conservative conflict handling refinements, uninstall planners/executors, global Copilot uninstall, and PRD-only change creation.

The bootstrap remains local-first filesystem tooling. MCP remains operational memory only; file artifacts remain under `docs/pegasus/changes/<change-id>/`, and no Markdown memory backend is reintroduced.

## Architecture Decisions

| Decision | Choice | Alternatives considered | Rationale |
|---|---|---|---|
| Package boundary | Create a `pegasus_harness_bootstrap` package with `cli.py`, `planning.py`, `templates.py`, `global_config.py`, `manifest.py`, `uninstall.py`, and `change_cycle.py` | Keep one large script or build a broad dispatcher framework | Modules map to existing responsibilities without adding framework weight. |
| First slice | Ship installability only: `pyproject.toml`, console script, `.venv` editable flow, `pipx` docs, and `bin/` wrapper | Include uninstall/change-cycle in the first PR | Protects the 400-line review budget and reduces regression risk. |
| Compatibility | Keep `bin/pegasus-harness-bootstrap` as a thin wrapper importing package `main()` | Delete the script immediately | Existing smoke tests and local workflows continue while package usage becomes primary. |
| Manifest scope | Store installed inventory, ownership mode, template/version/checksum, workspace metadata, and uninstall metadata; no active/last change pointers | Store active change in manifest | Active recovery belongs to `pegasus-memory-mcp`; manifest is install/ownership state only. |
| Existing conflicts | Default to report-and-skip/no-write; explicit `--force` or future overwrite flag is required | Prompt interactively for each conflict | Non-interactive conservative behavior is safer for existing projects and automation. |

## Data / Control Flow

```text
Console script / bin wrapper
  -> cli.parse_args()
  -> command planner
       setup: templates + manifest inventory -> plan -> optional write
       uninstall: manifest -> removal/settings plan -> dry-run or apply
       new-change: manifest -> docs/pegasus/changes/<id>/prd.md only
  -> reporter prints exact target paths, conflicts, backups, removals
```

If MCP memory is unavailable during guided operations, Pegasus must show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. It may inspect `docs/pegasus/changes/` as artifacts only, not as recovered operational memory.

## File Changes

| File / Area | Action | Description |
|---|---|---|
| `pyproject.toml` | Create | Package metadata, Python requirement, and `pegasus-harness-bootstrap` console script. |
| `pegasus_harness_bootstrap/` | Create | Package modules split from the current script by responsibility. |
| `bin/pegasus-harness-bootstrap` | Modify | Thin compatibility wrapper to package entry point. |
| `templates/harness/` | Modify | Add manifest/change PRD template support and ownership markers as later slices require. |
| `README.md` | Modify in Slice 1 | Replace path-based quick path with `.venv` editable and `pipx` usage; remove stale Markdown-memory layout as part of installability documentation. |
| `tests/smoke.sh` | Modify | Cover console entry point, wrapper compatibility, conservative conflicts, manifest, uninstall, global uninstall, and PRD-only change creation. |

## Interfaces / Contracts

- CLI entry point: `pegasus-harness-bootstrap`.
- Initial setup keeps `--project-name`, `--target-path`, `--dry-run`, `--force`, `--install-copilot-global`, `--vscode-target`, and `--install-cursor-global`.
- New lifecycle flags should be additive: `--uninstall-workspace`, `--uninstall-copilot-global`, and `--new-change <change-id>`.
- `.pegasus-bootstrap-ia/manifest.json` must exclude `active_change`, `last_change`, and equivalents.
- `--new-change <change-id>` creates only `docs/pegasus/changes/<change-id>/prd.md`.

## Testing Strategy

| Layer | What to Test | Approach |
|---|---|---|
| Smoke | Editable/pipx-equivalent entry point and `bin/` wrapper both run | Extend `tests/smoke.sh` using isolated temp targets. |
| Smoke | Existing-project conflict defaults to no overwrite | Assert files remain unchanged unless explicit overwrite flag is used. |
| Smoke | Manifest records ownership but no active/last change | Inspect generated JSON. |
| Smoke | Workspace/global uninstall dry-run and apply safety | Temp HOME/XDG targets, backups, settings preservation, empty-dir cleanup. |
| Smoke | `--new-change` creates PRD only | Assert no proposal/spec/design/tasks/apply-progress/verify files are created. |

## Migration / Rollout

No data migration required. Roll out in reviewable slices: installability first, then manifest/conflict safety, then uninstall flows, then change-cycle creation. Roll back by reverting the package/refactor slice; the wrapper keeps legacy execution stable during transition.

## Resolved Design Follow-ups

- README stale `docs/pegasus/memory/*` references are not a separate unresolved risk. They are part of Slice 1 documentation cleanup because installability changes must update the quick path and generated-layout explanation in the same review unit.

## Risks / Open Questions

- Global uninstall must handle invalid `settings.json` before writing any asset/removal changes.
- Open question: exact naming of explicit overwrite flag beyond current `--force` if product wants clearer semantics.
