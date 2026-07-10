# Delta for Pegasus Harness Bootstrap

## ADDED Requirements

### Requirement: Current-workspace sync

The system MUST provide a workspace sync/update command that operates only on the current workspace in the first version. The design MUST remain compatible with a future global registry, but it MUST NOT require global multi-workspace sync now. `--dry-run` MUST show planned updates, conflicts, obsolete managed files, and backup needs without writing.

#### Scenario: Dry-run plans current workspace only

- GIVEN an installed workspace with managed files
- WHEN sync runs with `--dry-run`
- THEN it reports only the current workspace plan
- AND it writes nothing

#### Scenario: Future registry remains optional

- GIVEN no global workspace registry exists
- WHEN sync runs
- THEN it still operates on the current workspace
- AND it does not fail because multi-workspace sync is unavailable

### Requirement: Safe ownership classification

The system MUST use `.pegasus-bootstrap-ia/manifest.json` ownership and checksums to classify workspace files as unmodified Pegasus-managed, user-modified Pegasus-managed, user-created, or obsolete Pegasus-managed. Safe update targets MUST include `.github/`, `.vscode/mcp.json`, `AGENTS.md`, and legacy `.cursor/` assets. User work artifacts under `docs/pegasus/prd.md`, root `proposal.md`, `spec.md`, `design.md`, `tasks.md`, `apply-progress.md`, `verify.md`, and `docs/pegasus/changes/**` MUST be preserved. `.vscode/mcp.json` MUST be updated to the current generated MCP config when it is safe to do so.

#### Scenario: Managed file matches recorded state

- GIVEN a managed file still matches the manifest checksum
- WHEN sync runs
- THEN it is eligible for update from the current bootstrap templates
- AND the plan identifies it as unmodified Pegasus-managed

#### Scenario: User artifact is preserved

- GIVEN a workspace contains `docs/pegasus/changes/x/spec.md`
- WHEN sync runs
- THEN the file is preserved
- AND it is not treated as a managed target

### Requirement: Conflict and backup policy

The system MUST report and skip user-modified Pegasus-managed files by default and MUST report obsolete Pegasus-managed files by default without removing them. Real writes MUST create timestamped backups for files changed by sync. An explicit overwrite override MAY back up and replace conflicting managed files; overwrite MUST NOT be the default.

#### Scenario: Default conflict is skip

- GIVEN a managed file changed outside Pegasus
- WHEN sync runs without override
- THEN it reports the conflict
- AND it does not overwrite the file

#### Scenario: Real write backs up files

- GIVEN a managed file is safe to update
- WHEN sync runs without `--dry-run`
- THEN it writes a timestamped backup first
- AND then updates the file

## MODIFIED Requirements

### Requirement: Manifest-owned lifecycle metadata

The manifest `.pegasus-bootstrap-ia/manifest.json` MUST record install, ownership, update, uninstall, and workspace metadata only. It MUST be workspace-local evidence for sync decisions and MUST NOT store operational memory, active-change pointers, recovery state, registry data, or any Markdown-memory backend data. Sync MUST use manifest evidence, not `docs/pegasus/memory/`, to decide workspace ownership and file state.
(Previously: Manifest was lifecycle metadata only, without sync-specific workspace-local classification or registry boundary language.)

#### Scenario: Manifest stays local

- GIVEN a successful workspace setup or sync
- WHEN the manifest is inspected
- THEN it contains only workspace-local lifecycle metadata
- AND it contains no memory backend or registry data
