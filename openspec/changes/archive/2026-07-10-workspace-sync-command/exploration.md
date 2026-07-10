# Exploration: workspace-sync-command

### Current State
- The bootstrap is a Python CLI (`pegasus_harness_bootstrap.cli:main`) with `--dry-run`, `--force`, uninstall flags, and `--new-change`, but no sync/update command yet.
- Workspace generation is template-driven from `templates/harness/` into the target workspace; `build_plan()` currently classifies only by path existence, not by manifest checksum or ownership state.
- The per-workspace manifest lives at `.pegasus-bootstrap-ia/manifest.json` and records install metadata, per-file checksums, ownership mode, update timestamps, and uninstall policy.
- Managed surfaces currently include `AGENTS.md`, `.github/copilot-instructions.md`, `.github/instructions/*`, `.github/prompts/*`, `.github/agents/*`, `.vscode/mcp.json`, `.cursor/rules/*`, and `docs/pegasus/*` templates.
- Existing protection is path-based plus a few marker-managed files; `load_workspace_manifest()` only validates `managed_by`, so it is not yet a full sync trust boundary.

### Affected Areas
- `pegasus_harness_bootstrap/cli.py` — sync command, target resolution, plan reporting, backup/rollback, and conflict handling.
- `pegasus_harness_bootstrap/manifest.py` — manifest schema evolution, checksum/ownership interpretation, sync metadata.
- `templates/harness/**` — current source of truth for generated workspace files.
- `tests/smoke.sh` — CLI contract, dry-run reporting, conflict/overwrite behavior, and safe-update verification.
- `openspec/specs/pegasus-harness-bootstrap/spec.md` — required behavior and safety rules for sync/update.
- Future registry storage (not yet present) — needed only for multi-workspace fanout.

### Approaches
1. **Current-workspace-only sync with future-proof target abstraction** — sync a single installed workspace by default, but structure the engine around a reusable target interface.
   - Pros: smallest safe slice, matches today’s manifest model, easy to dry-run and verify, low blast radius.
   - Cons: does not discover other installs yet, registry support remains future work.
   - Effort: Medium

2. **Global registry + current target implementation** — add a user-scoped registry now, but only sync the current workspace in v1.
   - Pros: sets up multi-workspace discovery early, avoids reworking target discovery later.
   - Cons: adds a new persistent state surface before the core sync rules are proven, more failure modes, more design surface than the first slice needs.
   - Effort: High

3. **Immediate full multi-workspace sync** — scan and sync every registered workspace in one command.
   - Pros: complete end-state in one shot.
   - Cons: highest risk, requires registry, locking, partial failure semantics, and stronger rollback guarantees immediately.
   - Effort: Very High

### Recommendation
Ship **current-workspace-only sync** first, but define it with a `WorkspaceTarget`/`ManifestView` abstraction so the same core can later fan out to a registry of installed workspaces. Keep the registry out of the workspace manifest; if added later, store it under the user config scope (`XDG_CONFIG_HOME` / platform equivalent), not in `docs/pegasus/` and not as fallback memory.

Sync should be conservative by default:
- `--dry-run` is mandatory.
- Update only files that are Pegasus-managed **and** still match the recorded manifest checksum.
- Treat user-modified Pegasus files as conflicts; do not overwrite without an explicit force flag.
- Treat files missing from the current template set but present in the manifest as obsolete managed files; report them, and remove only with confirmation or an explicit prune flag.
- Preserve new user files even if they live under managed directories.
- Create backups before every write, ideally under `.pegasus-bootstrap-ia/backups/<timestamp>/`, and keep a restore plan for rollback.

### Risks
- Current `load_workspace_manifest()` is too weak for sync unless schema/shape validation is added.
- Path-existence planning alone cannot distinguish stale safe updates from user edits; checksum comparison is required.
- Obsolete managed files need explicit policy, or sync will either be too destructive or too noisy.
- Multi-workspace registry design can easily leak into the wrong layer; keep registry separate from per-workspace ownership metadata.

### Ready for Proposal
Yes — the scope is clear enough for a proposal/spec slice, but the first implementation should stay single-workspace and conservative.
