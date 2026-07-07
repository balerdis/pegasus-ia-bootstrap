# Proposal: Bootstrap CLI Lifecycle

## Intent

Traceability: approved PRD `PRD-bootstrap-cli-lifecycle.md`.

Make Pegasus usable as an installable CLI, not an absolute-path script, while adding safe lifecycle operations for new/existing workspaces, uninstall, and change-cycle creation.

## Scope

### In Scope
- Python package structure with `pyproject.toml`, console entry point, editable `.venv` development flow, and everyday `pipx` usage.
- Conservative setup for existing projects: report conflicts and do not write unless an explicit overwrite flag is used.
- Workspace/global uninstall planning and execution with `--dry-run`, backups where settings mutate, and non-interactive workspace uninstall by default.
- Workspace install manifest at `.pegasus-bootstrap-ia/manifest.json` for install, ownership, update, and uninstall metadata only.
- `--new-change <change-id>` creates `docs/pegasus/changes/<change-id>/prd.md` only; later phase artifacts are created by SDD phase progression.
- Preserve MCP-first memory: active change recovery belongs to `pegasus-memory-mcp`; no generated Markdown memory backend.

### Out of Scope
- Publishing to PyPI, custom installer scripts, Git/repository creation, business app scaffolding, and broad runtime dispatcher work.
- Writing active-change or last-change pointers into the manifest.
- Creating proposal/spec/design/tasks/apply-progress/verify files during `--new-change` bootstrap.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `pegasus-harness-bootstrap`: installable CLI lifecycle, safe existing-project setup, manifest-backed uninstall, global uninstall, and change-cycle artifact creation.

## Approach

Refactor `bin/pegasus-harness-bootstrap` into a package without changing the product surface unnecessarily. Prioritize the first slice around installability and entry point support, then add manifest-backed lifecycle planning, uninstall, and change-cycle creation. Keep file artifacts under `docs/pegasus/changes/<change-id>/` and use MCP only for operational memory/status.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `bin/pegasus-harness-bootstrap` | Modified | Current script becomes compatibility wrapper or moves into package entry point. |
| `pyproject.toml` | New | Package metadata and console script. |
| `pegasus_*` package modules | New | CLI parsing, planning, manifest, uninstall, templates, global settings. |
| `templates/harness/` | Modified | Manifest/change-cycle templates and ownership markers. |
| `tests/smoke.sh` | Modified | Validate installability, conflicts, uninstall, and change creation. |
| `README.md` | Modified | Document `.venv` and `pipx` usage. |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Refactor breaks current script behavior | Med | Keep smoke coverage and compatibility wrapper during transition. |
| Uninstall deletes user content | Med | Manifest inventory, Pegasus markers, dry-run, and conservative directory cleanup. |
| Manifest becomes operational memory | Low | Explicitly forbid active/last-change pointers; MCP remains recovery source. |

## Rollback Plan

Revert the package/refactor and lifecycle commits. Existing installed workspaces remain safe because uninstall uses the manifest present at install time; global settings changes must have backups before mutation.

## Dependencies

- Approved PRD: `PRD-bootstrap-cli-lifecycle.md`.
- Stable spec: `openspec/specs/pegasus-harness-bootstrap/spec.md`.

## Success Criteria

- [ ] Proposal hands off one modified capability to spec.
- [ ] Spec phase can derive requirements for installability, conservative conflicts, manifest lifecycle, uninstall, and `--new-change` PRD-only creation.
- [ ] MCP-first memory and exact unavailable-memory warning remain preserved.
