# Pegasus Harness Bootstrap Specification

## Purpose

Define a local-first bootstrap that configures only the VS Code/Copilot-first Pegasus IA harness for a target workspace by default. The bootstrap prepares .github Copilot assets, AGENTS.md, docs/pegasus/, and project-local Markdown memory; it MUST NOT generate business/domain MVP application code, Git metadata, or remote resources. Optional global VS Code/Copilot user configuration is permitted only behind an explicit flag with backup safety.

## Requirements
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

The system MUST initialize a VS Code/Copilot-first Pegasus harness and MUST NOT create framework scaffolds, domain files, UI, API, database, CI, deployment, or other business/domain MVP application code. The default workspace output MUST include `.github/` Copilot assets, `AGENTS.md`, and `docs/pegasus/`; Cursor assets MAY be generated only as clearly secondary legacy compatibility.

#### Scenario: Copilot-first structure generation

- GIVEN an empty target workspace directory
- WHEN the bootstrap completes
- THEN `.github/copilot-instructions.md`, `.github/instructions/`, `.github/prompts/`, `.github/agents/`, `AGENTS.md`, and `docs/pegasus/` exist
- AND `docs/pegasus` contains PRD, proposal, spec, design, tasks, verify, and memory templates

#### Scenario: No app code

- GIVEN any successful bootstrap run
- WHEN the target tree is inspected
- THEN only harness, documentation, Copilot, legacy guidance, and memory files were created
- AND business MVP code is built later by the user/team using the harness

### Requirement: Portable agent guidance

The system MUST create a portable `AGENTS.md` that explains the Pegasus IA workflow, local memory policy, VS Code/Copilot usage, and how future agents should continue work without relying on external services. `AGENTS.md` MUST remain portable guidance rather than the primary Copilot-native control surface.

#### Scenario: Agent instructions created

- GIVEN a successful bootstrap run
- WHEN `AGENTS.md` is opened
- THEN it describes Pegasus IA workflow usage and VS Code/Copilot entry points
- AND it directs sessions to read and update `docs/pegasus/memory/`

### Requirement: Cursor legacy compatibility

The system MUST preserve Cursor compatibility as legacy behavior and MUST make VS Code/Copilot assets the primary generated experience. Generated public artifacts MUST NOT mention Gentle AI or Engram.

#### Scenario: Legacy Cursor guidance retained

- GIVEN a successful bootstrap run
- WHEN legacy Cursor compatibility artifacts are inspected
- THEN they exist only as secondary compatibility guidance
- AND the primary instructions point users to VS Code/Copilot assets first

#### Scenario: Default run does not touch global legacy configuration

- GIVEN no global install flag is provided
- WHEN the bootstrap runs successfully
- THEN it creates or updates only target workspace harness files
- AND it does not create, modify, or back up global user configuration files

### Requirement: Optional global VS Code/Copilot configuration

The system MUST support global/user-level VS Code/Copilot asset installation only behind an explicit opt-in flag. It MUST write Pegasus-managed assets under `~/.config/pegasus-ia/copilot/{agents,instructions,prompts}/`, MUST support dry-run planning, MUST back up `settings.json` before mutation, MUST merge JSON settings without removing existing entries, MUST report every created/updated/backed-up path, and MUST treat Stable and Insiders as separate targets.

#### Scenario: Default is repository-only

- GIVEN no global VS Code/Copilot install flag is provided
- WHEN the bootstrap runs successfully
- THEN it does not modify VS Code user settings or Pegasus-managed user directories
- AND it reports any manual global setup as optional

#### Scenario: Dry-run reports global plan

- GIVEN the global VS Code/Copilot install flag and `--dry-run` are provided
- WHEN the bootstrap plans work
- THEN it prints planned Pegasus-managed asset paths and VS Code setting changes
- AND it writes neither workspace files nor user settings

#### Scenario: Settings merge is backed up and non-destructive

- GIVEN the global VS Code/Copilot install flag is provided for Stable or Insiders
- WHEN the bootstrap changes the selected target settings
- THEN it writes a timestamped backup of that target `settings.json`
- AND it merges `chat.agentFilesLocations`, `chat.instructionsFilesLocations`, and `chat.promptFilesLocations` without removing existing values

### Requirement: PRD and SDD document templates

The system MUST create a PRD template and SDD templates under `docs/pegasus` for proposal, spec, design, tasks, and verification, and Copilot prompts/instructions SHOULD reference those templates as the workflow source of truth. The guided SDD flow MUST be `request -> PRD -> proposal -> spec -> design -> tasks -> apply -> verify -> handoff`, and proposal work MUST require an approved PRD.

#### Scenario: SDD templates available

- GIVEN a successful bootstrap run
- WHEN `docs/pegasus` and `.github/prompts/` are inspected
- THEN each SDD template file exists with clear headings for future project work
- AND Copilot prompt assets guide the user through those SDD phases

#### Scenario: PRD gates proposal

- GIVEN a future Copilot-guided project session
- WHEN the user requests SDD proposal work
- THEN the generated guidance requires `docs/pegasus/prd.md` to exist and be approved first

### Requirement: Lightweight orchestration guardrails

The generated Pegasus guidance MUST support a direct-fix path for small, punctual, low-risk changes, MUST require required-doc checks and user approval before phase transitions, MUST require review-budget confirmation before large implementation, and MUST preserve useful progress, memory, and verification history by merging updates instead of overwriting content.

#### Scenario: Direct fix avoids unnecessary SDD

- GIVEN a small, punctual, low-risk change with clear acceptance criteria
- WHEN the orchestrator selects the workflow
- THEN it may use a direct-fix path with memory and verification updates instead of forcing all SDD phases

#### Scenario: Large change triggers review budget decision

- GIVEN an implementation estimate above about 400 changed lines or touching multiple unrelated areas
- WHEN implementation is about to start
- THEN generated guidance requires the orchestrator to stop and ask whether to split the work into chained PRs

#### Scenario: Progress history is preserved

- GIVEN existing useful progress, memory, handoff, or verification history
- WHEN new status or evidence is recorded
- THEN generated guidance requires integrating the new update without replacing prior useful content

### Requirement: Model preference documentation

The generated guidance MUST use a single project-selected Copilot model for all phases in the first Pegasus release and MUST document where to record that preference without promising hard runtime control or per-phase model routing.

#### Scenario: Model preference recorded as project context

- GIVEN a project team chooses a Copilot model preference
- WHEN the generated guidance is followed
- THEN the preference is recorded in project context or workspace settings
- AND Pegasus guidance does not claim per-phase model routing control

### Requirement: Project-local memory templates

The system MUST create `context.md`, `decisions.md`, `tasks-log.md`, `handoff.md`, and `learnings.md` under `docs/pegasus/memory`, each with clear read/write rules for VS Code/Copilot sessions and portable agents.

#### Scenario: Memory recovery files available

- GIVEN a successful bootstrap run
- WHEN the memory directory is inspected
- THEN all memory templates exist
- AND each template states when future VS Code/Copilot sessions should read from and write to it

#### Scenario: Compacted session recovery

- GIVEN a future VS Code/Copilot session with limited prior context
- WHEN the session follows generated guidance
- THEN it can recover context, decisions, task state, handoff notes, and learnings from Markdown memory

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

The system MUST print completion output that identifies initialized VS Code/Copilot harness paths, names the Pegasus orchestrator entry point, reports global/user-level actions when requested, and explains next steps for opening the target workspace in VS Code with Copilot. Cursor MUST be mentioned only when legacy compatibility output or legacy flags are relevant.

#### Scenario: Completion guidance

- GIVEN a successful bootstrap run
- WHEN output is displayed
- THEN it summarizes `.github/`, `AGENTS.md`, `docs/pegasus/`, and the Pegasus orchestrator agent
- AND it tells the user to open the target workspace in VS Code with Copilot
