# Pegasus Harness Bootstrap Specification

## Purpose

Define a local-first bootstrap that configures only the Cursor/Pegasus IA harness for a target workspace by default. The bootstrap prepares agent guidance, Cursor rules, SDD templates, and project-local Markdown memory; it MUST NOT generate business/domain MVP application code, Git metadata, or remote resources. Optional global Cursor user configuration is permitted only behind an explicit flag with backup safety.

## ADDED Requirements

### Requirement: Bootstrap inputs

The system MUST accept a target workspace path and project name, with a safe default target path derived from the project name when no explicit path is provided.

#### Scenario: Explicit target path and project name

- GIVEN a writable target path and a project name
- WHEN the bootstrap is run with both inputs
- THEN it initializes the harness under the target workspace path
- AND generated templates reference the provided project name where relevant

#### Scenario: Default target path

- GIVEN only a valid project name
- WHEN the bootstrap is run
- THEN it targets `/var/www/html/personal/<project-name>`

### Requirement: Harness-only output

The system MUST initialize the exact Pegasus harness structure and MUST NOT create framework scaffolds, domain files, UI, API, database, CI, deployment, or other business/domain MVP application code.

#### Scenario: Structure generation

- GIVEN an empty target workspace directory
- WHEN the bootstrap completes
- THEN `AGENTS.md`, `.cursor/rules/`, and `docs/pegasus/` exist
- AND `docs/pegasus` contains `proposal.md`, `spec.md`, `design.md`, `tasks.md`, `verify.md`, and `memory/`

#### Scenario: No app code

- GIVEN any successful bootstrap run
- WHEN the target tree is inspected
- THEN only harness, documentation, rule, and memory files were created
- AND business MVP code is built later inside Cursor by the user/team using the harness

### Requirement: Portable agent guidance

The system MUST create a portable `AGENTS.md` that explains the Pegasus IA workflow, local memory policy, and how future agents should continue work without relying on external services.

#### Scenario: Agent instructions created

- GIVEN a successful bootstrap run
- WHEN `AGENTS.md` is opened
- THEN it describes Pegasus IA workflow usage
- AND it directs sessions to read and update `docs/pegasus/memory/`

### Requirement: Cursor-specific rules

The system MUST create Cursor-specific guidance under `.cursor/rules/` and generated public artifacts MUST NOT mention Gentle AI or Engram.

#### Scenario: Cursor rules created

- GIVEN a successful bootstrap run
- WHEN `.cursor/rules/` is inspected
- THEN at least one Cursor rule file exists with Pegasus IA usage guidance
- AND the generated files contain no references to Gentle AI or Engram

#### Scenario: Default run does not touch global Cursor configuration

- GIVEN no global Cursor flag is provided
- WHEN the bootstrap runs successfully
- THEN it creates or updates only target workspace harness files
- AND it does not create, modify, or back up global Cursor user configuration files

### Requirement: Optional global Cursor configuration

The system MUST install or update global Cursor user configuration only when `--install-cursor-global` is explicitly provided, and MUST protect any existing global config with a backup before changing it.

#### Scenario: Explicit global Cursor install

- GIVEN `--install-cursor-global` is provided
- WHEN the bootstrap runs successfully
- THEN it detects the Linux Cursor user config or rules path
- AND it installs or updates the Pegasus global Cursor configuration at that detected path
- AND it reports the global path changed

#### Scenario: Existing global config is backed up

- GIVEN an existing global Cursor configuration file would be changed
- WHEN the bootstrap runs with `--install-cursor-global`
- THEN it writes a timestamped backup before modifying the existing file
- AND it reports the backup path

#### Scenario: Dry-run includes global operations without writes

- GIVEN `--install-cursor-global` and `--dry-run` are provided
- WHEN the bootstrap plans work
- THEN it prints planned global Cursor config creates, updates, and backups
- AND it does not write target workspace files or global Cursor config files

### Requirement: SDD document templates

The system MUST create SDD templates under `docs/pegasus` for proposal, spec, design, tasks, and verification.

#### Scenario: SDD templates available

- GIVEN a successful bootstrap run
- WHEN `docs/pegasus` is inspected
- THEN each SDD template file exists with clear headings for future project work

### Requirement: Project-local memory templates

The system MUST create `context.md`, `decisions.md`, `tasks-log.md`, `handoff.md`, and `learnings.md` under `docs/pegasus/memory`, each with clear read/write rules.

#### Scenario: Memory recovery files available

- GIVEN a successful bootstrap run
- WHEN the memory directory is inspected
- THEN all memory templates exist
- AND each template states when future Cursor sessions should read from and write to it

#### Scenario: Compacted session recovery

- GIVEN a future Cursor session with limited prior context
- WHEN the session follows generated guidance
- THEN it can recover project context, decisions, task state, handoff notes, and learnings from Markdown memory

### Requirement: Existing file protection

The system MUST NOT overwrite existing files unless an explicit overwrite flag or interactive confirmation is provided.

#### Scenario: Existing file without overwrite approval

- GIVEN a target containing an existing generated-path file
- WHEN the bootstrap runs without overwrite approval
- THEN it preserves the existing file
- AND reports the conflict clearly

#### Scenario: Existing file with overwrite approval

- GIVEN a target containing an existing generated-path file
- WHEN the bootstrap runs with explicit overwrite approval
- THEN it may replace that file
- AND reports which files were overwritten

### Requirement: Local-first operation

The system MUST complete without running `git init`, creating GitHub remotes, commits, CI, deployments, MCP servers, or requiring network services.

#### Scenario: Offline bootstrap

- GIVEN local filesystem access only
- WHEN the bootstrap runs
- THEN it can complete the harness generation locally

#### Scenario: No Git initialization

- GIVEN any bootstrap invocation
- WHEN the bootstrap completes or reports conflicts
- THEN it has not run `git init`
- AND no `.git/` directory or local Git metadata was created by the bootstrap


### Requirement: Completion output

The system MUST print clear completion output that identifies initialized harness paths and explains the next steps to open and use the target workspace in Cursor.

#### Scenario: Completion guidance

- GIVEN a successful bootstrap run
- WHEN output is displayed
- THEN it summarizes created harness artifacts
- AND tells the user to open the target workspace in Cursor and start from `AGENTS.md`
