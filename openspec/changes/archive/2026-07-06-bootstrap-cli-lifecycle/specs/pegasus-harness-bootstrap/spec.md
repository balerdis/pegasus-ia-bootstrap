# Delta for Pegasus Harness Bootstrap

## ADDED Requirements

### Requirement: Installable CLI lifecycle

The system MUST be installable as a Python package exposing `pegasus-harness-bootstrap`. Documentation MUST cover `.venv` editable usage and `pipx` usage.

#### Scenario: Development or pipx command

- GIVEN editable `.venv` install or `pipx` install
- WHEN `pegasus-harness-bootstrap --project-name demo --dry-run` runs
- THEN it works without an absolute repository script path

### Requirement: Manifest-owned lifecycle metadata

The manifest `.pegasus-bootstrap-ia/manifest.json` MUST record install, ownership, update, uninstall, and workspace metadata. It MUST NOT store active-change or last-change pointers.

#### Scenario: Manifest supports uninstall

- GIVEN a successful workspace setup
- WHEN the manifest is inspected
- THEN it records Pegasus-managed ownership for uninstall
- AND it contains no active-change or last-change pointer

### Requirement: Workspace uninstall safety

Workspace uninstall MUST be non-interactive by default, support `--dry-run`, remove only Pegasus-managed content, and remove only directories that become empty.

#### Scenario: Dry-run and cleanup

- GIVEN an installed workspace with Pegasus and user files
- WHEN workspace uninstall runs dry-run or real
- THEN dry-run reports removals without writing
- AND real execution leaves non-empty directories in place and reports them

### Requirement: Global VS Code/Copilot uninstall safety

Global VS Code/Copilot uninstall MUST back up affected `settings.json`, remove only Pegasus-managed assets/settings entries, and preserve user settings.

#### Scenario: Global uninstall preserves settings

- GIVEN VS Code settings contain Pegasus and non-Pegasus entries
- WHEN global uninstall runs
- THEN a backup is written before mutation
- AND non-Pegasus entries remain unchanged

### Requirement: Change-cycle creation starts with PRD only

`--new-change <change-id>` MUST create only `docs/pegasus/changes/<change-id>/prd.md`; later SDD artifacts MUST be created by phase progression.

#### Scenario: New change creates PRD

- GIVEN a workspace has a Pegasus manifest
- WHEN the CLI runs with `--new-change feature-a --target-path <workspace>`
- THEN only `docs/pegasus/changes/feature-a/prd.md` is created

### Requirement: MCP-first lifecycle boundary

The harness MUST use `pegasus-memory-mcp` as operational memory for recovery, search, persistence, active context, decisions, status, handoffs, and learnings. `docs/pegasus/changes/<change-id>/` files remain source of truth. The harness MUST NOT generate or fall back to `docs/pegasus/memory/`.

#### Scenario: MCP unavailable

- GIVEN MCP memory is unavailable
- WHEN Pegasus needs persistent memory
- THEN it shows exactly `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`
- AND it does not claim memory was saved

#### Scenario: Artifacts are not memory

- GIVEN MCP is unavailable and change files exist
- WHEN Pegasus inspects `docs/pegasus/changes/`
- THEN it may use files as artifacts only, not recovered operational memory

## MODIFIED Requirements

### Requirement: Bootstrap inputs

The system MUST accept target path and project name for initial setup, with a safe default from project name. If an explicit target path does not exist, non-dry-run execution MUST report the exact path and require confirmation before creation.
(Previously: missing target paths were not required to pause for explicit confirmation.)

#### Scenario: Target selection

- GIVEN a writable explicit target and project name, or only project name
- WHEN setup runs
- THEN it uses the explicit path or `/var/www/html/personal/<project-name>`

#### Scenario: Missing target confirmation

- GIVEN an explicit target path that does not exist
- WHEN non-dry-run setup starts
- THEN it reports the exact path and waits for confirmation before writing

### Requirement: Existing file protection

The system MUST NOT overwrite existing files unless an explicit overwrite flag is provided. Default conflict behavior MUST report conflicts and perform no writes for conflicting paths.
(Previously: overwrite used interactive confirmation.)

#### Scenario: Conflict and overwrite

- GIVEN a target contains an existing generated-path file
- WHEN setup runs without or with the explicit overwrite flag
- THEN default reports the conflict and does not write that path
- AND the explicit flag may replace it and reports overwritten files
