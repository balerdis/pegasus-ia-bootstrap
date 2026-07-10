# Pegasus Harness Bootstrap Specification

## Purpose

Define a local-first bootstrap that configures only the VS Code/Copilot-first Pegasus IA harness for a target workspace by default. The bootstrap prepares .github Copilot assets, AGENTS.md, docs/pegasus/, and MCP-first operational memory guidance; it MUST NOT generate business/domain MVP application code, Git metadata, or remote resources. Optional global VS Code/Copilot user configuration is permitted only behind an explicit flag with backup safety.

## Requirements
### Requirement: Bootstrap inputs

The system MUST accept a target workspace path and project name, with a safe default target path derived from the project name when no explicit path is provided. If an explicit target path does not exist, non-dry-run execution MUST report the exact path and require confirmation before creation.

#### Scenario: Explicit target path and project name

- GIVEN a writable target path and a project name
- WHEN the bootstrap is run with both inputs
- THEN it initializes the harness under the target workspace path
- AND generated templates reference the provided project name where relevant

#### Scenario: Default target path

- GIVEN only a valid project name
- WHEN the bootstrap is run
- THEN it targets `/var/www/html/personal/<project-name>`

#### Scenario: Missing target confirmation

- GIVEN an explicit target path that does not exist
- WHEN non-dry-run setup starts
- THEN it reports the exact path and waits for confirmation before writing

### Requirement: Installable CLI lifecycle

The system MUST be installable as a Python package exposing `pegasus-harness-bootstrap`. Documentation MUST cover `.venv` editable usage and `pipx` usage.

#### Scenario: Development or pipx command

- GIVEN editable `.venv` install or `pipx` install
- WHEN `pegasus-harness-bootstrap --project-name demo --dry-run` runs
- THEN it works without an absolute repository script path

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

### Requirement: Manifest-owned lifecycle metadata

The manifest `.pegasus-bootstrap-ia/manifest.json` MUST record install, ownership, update, uninstall, and workspace metadata only. It MUST be workspace-local evidence for sync decisions and MUST NOT store operational memory, active-change pointers, recovery state, registry data, or any Markdown-memory backend data. Sync MUST use manifest evidence, not `docs/pegasus/memory/`, to decide workspace ownership and file state.

#### Scenario: Manifest supports uninstall

- GIVEN a successful workspace setup
- WHEN the manifest is inspected
- THEN it records Pegasus-managed ownership for uninstall
- AND it contains no active-change or last-change pointer

#### Scenario: Manifest stays local

- GIVEN workspace sync needs ownership evidence
- WHEN it reads `.pegasus-bootstrap-ia/manifest.json`
- THEN it treats the manifest as workspace-local metadata only
- AND it does not use it as a global workspace registry or operational memory store

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

### Requirement: Harness-only output

The system MUST initialize a VS Code/Copilot-first Pegasus harness and MUST NOT create framework scaffolds, domain files, UI, API, database, CI, deployment, or other business/domain MVP application code. The default workspace output MUST include `.github/` Copilot assets, `AGENTS.md`, and `docs/pegasus/`; Cursor assets MAY be generated only as clearly secondary legacy compatibility.

#### Scenario: Copilot-first structure generation

- GIVEN an empty target workspace directory
- WHEN the bootstrap completes
- THEN `.github/copilot-instructions.md`, `.github/instructions/`, `.github/prompts/`, `.github/agents/`, `AGENTS.md`, and `docs/pegasus/` exist
- AND `docs/pegasus` contains PRD, proposal, spec, design, tasks, apply-progress, and verify templates

#### Scenario: No app code

- GIVEN any successful bootstrap run
- WHEN the target tree is inspected
- THEN only harness, documentation, Copilot, and legacy guidance files were created
- AND business MVP code is built later by the user/team using the harness

### Requirement: Portable agent guidance

The system MUST create a portable `AGENTS.md` that explains the Pegasus IA workflow, MCP-first memory policy, VS Code/Copilot usage, and how future agents should continue work through the MCP tool contract when available. `AGENTS.md` MUST remain portable guidance rather than the primary Copilot-native control surface.

#### Scenario: Agent instructions created

- GIVEN a successful bootstrap run
- WHEN `AGENTS.md` is opened
- THEN it describes Pegasus IA workflow usage and VS Code/Copilot entry points
- AND it directs sessions to use MCP-first memory with the approved unavailable-memory warning

### Requirement: MCP-first operational memory

The generated harness MUST use the `pegasus-memory-mcp` MCP tool contract as the operational memory interface for recovery, search, persistence, and availability checks. It MUST configure memory by default, MUST support `--install-memory-mcp` as the explicit install/config flag, MUST resolve the executable from PATH first and then the default local install path, and MUST generate VS Code workspace stdio config that launches `node` with the absolute built script path and sets `cwd` to the resolved MCP root. The clone/build fallback MUST use the published `stable/0.1.1` branch. Generated guidance MUST recognize `health.capabilities.parent_bootstrap` when present. It MUST NOT require users or agents to write operational memory to `docs/pegasus/memory/`, and it MUST NOT depend on MCP server internals, SQLite details, database paths, or source modules.

#### Scenario: Session starts with memory available

- GIVEN `pegasus-memory-mcp` is available on PATH or at the default local path
- WHEN the bootstrap writes workspace harness files
- THEN it emits VS Code `.vscode/mcp.json` stdio config for `node`, the built script path, and the resolved MCP root `cwd`
- AND it uses the resolved executable for memory availability checks

#### Scenario: Missing install falls back to clone/build

- GIVEN `pegasus-memory-mcp` is absent from PATH and the default local path
- WHEN bootstrap reaches memory setup
- THEN it warns and attempts GitHub clone/install/build into the default local location
- AND the clone fallback uses branch `stable/0.1.1`
- AND normal bootstrap flow remains default-on

#### Scenario: Durable records are produced

- GIVEN work changes project state
- WHEN observations, decisions, handoffs, artifacts, task progress, or active change context are created or updated
- THEN the harness guidance requires saving those records through MCP

#### Scenario: MCP contract only

- GIVEN MCP-backed memory is configured
- WHEN generated guidance describes memory behavior
- THEN it names MCP capabilities and tool outcomes only
- AND it does not mention tables, SQLite schema, internal modules, or private implementation files

### Requirement: Memory unavailable behavior

The generated harness MUST call `health` before the first recovery or save attempt and MUST detect unavailable memory before relying on persistence. If `pegasus-memory-mcp` is unavailable, the user-facing warning MUST be exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Pegasus MAY continue project/change artifact work, but it MUST NOT claim persistent memory was saved and MUST NOT fall back to Markdown memory. It MUST distinguish `not_found`, `ambiguous`, `read_error`, and `persistence_error` from true unavailability. When recovery returns `not_found` with `project_not_found`, generated guidance MUST call `ensure_project` before recording observations, artifacts, task progress, or handoff records. When creating a new change/PRD, generated guidance MUST call `ensure_change` before `record_artifact` or change-scoped observations. `persistence_error` or foreign-key write failures MUST be reported as write-flow precondition failures, not MCP unavailability.

#### Scenario: MCP missing or unreachable

- GIVEN MCP memory is missing, not executable, not on PATH, or health fails
- WHEN Pegasus needs persistent memory
- THEN it shows the exact approved warning
- AND persistent memory saves are treated as unavailable

#### Scenario: Recoverable states stay distinct

- GIVEN MCP is running and recovery returns `not_found` or `ambiguous`
- WHEN the consumer handles context
- THEN it reports the recoverable state rather than unavailable memory
- AND it does not show the approved warning

#### Scenario: Missing project is ensured before writes

- GIVEN MCP is running and recovery returns `not_found` with `project_not_found`
- WHEN Pegasus needs to record observations, artifacts, task progress, or handoff records
- THEN it calls `ensure_project` before the write
- AND it keeps this precondition flow internal to the agent guidance

#### Scenario: New change is ensured before change-scoped writes

- GIVEN MCP is running and Pegasus creates a new PRD/change under `docs/pegasus/changes/<change-id>/prd.md`
- WHEN it records the artifact or change-scoped observations
- THEN it calls `ensure_change` before `record_artifact` or change-scoped observation writes

#### Scenario: Read and persistence errors are not availability failures

- GIVEN MCP is running and a read or write fails
- WHEN the consumer handles persistence
- THEN it surfaces `read_error` or `persistence_error`
- AND it does not collapse the failure into unavailable memory
- AND foreign-key write failures are treated as precondition/flow bugs to report clearly

#### Scenario: Work continues without memory saves

- GIVEN memory is unavailable and the user continues
- WHEN PRD, proposal, spec, design, tasks, apply-progress, or verify artifacts are edited
- THEN file artifacts may still be updated
- AND no Markdown memory fallback is written

### Requirement: Active-context recovery stays internal

The orchestrator MUST recover active project/change context through MCP when available and MUST NOT expose active-context storage organization or ambiguity resolution to the user. If MCP cannot provide a safe active context, Pegasus MUST continue without leaking internals and SHOULD record follow-up needed in the separate `pegasus-memory-mcp` project/session.

#### Scenario: Active change recovered

- GIVEN MCP returns one safe active change for the project
- WHEN orchestration starts
- THEN Pegasus uses that active context for phase and artifact decisions
- AND the user is not asked to choose an internal memory record

#### Scenario: Active context is ambiguous

- GIVEN MCP recovery returns ambiguous active context
- WHEN orchestration needs a current change
- THEN Pegasus does not ask the user to resolve memory internals
- AND it documents external follow-up for MCP support if better disambiguation is required

### Requirement: Change-cycle artifacts remain file-based

The harness MUST keep PRD, proposal, spec, design, tasks, apply-progress, and verify artifacts as files under `docs/pegasus/` or `docs/pegasus/changes/<change-id>/` when the generated workflow uses change folders. MCP memory MUST reference and summarize artifact state, not replace those artifacts as the source of truth.

#### Scenario: Change artifact and memory both update

- GIVEN work advances a change phase
- WHEN an artifact under `docs/pegasus/changes/<change-id>/` is created or updated
- THEN the artifact remains the phase source of truth
- AND MCP memory records the active change context, artifact path, status, and next action

### Requirement: No Markdown-memory migration required

The harness MUST NOT provide a guided migration command for old `docs/pegasus/memory/` content because Pegasus Bootstrap has not been used operationally with that memory backend. Existing Markdown memory MAY remain as historical project files, but generated guidance MUST NOT treat it as an active backend, fallback, or co-source.

#### Scenario: Old memory files exist

- GIVEN a workspace contains `docs/pegasus/memory/`
- WHEN updated Pegasus guidance is followed
- THEN no migration command is required
- AND operational memory reads/writes use MCP only

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

The system MUST create a PRD template and production-ready SDD templates under `docs/pegasus` or change-scoped `docs/pegasus/changes/<change-id>/` locations for proposal, spec, design, tasks, apply-progress, and verification, and Copilot prompts/instructions SHOULD reference those templates as the workflow source of truth. The guided SDD flow MUST be `request -> PRD -> proposal -> spec -> design -> tasks -> apply -> verify -> handoff`, and proposal work MUST require an approved PRD. PRD guidance MUST capture product discovery and explicit approval, while proposal guidance MUST stay proposal-only as a bridge from approved PRD to spec.

#### Scenario: SDD templates available

- GIVEN a successful bootstrap run
- WHEN `docs/pegasus` and `.github/prompts/` are inspected
- THEN each SDD template file exists with clear headings for future project work
- AND Copilot prompt assets guide the user through those SDD phases

#### Scenario: PRD gates proposal

- GIVEN a future Copilot-guided project session
- WHEN the user requests SDD proposal work
- THEN the generated guidance requires the PRD artifact to exist and be approved first

#### Scenario: PRD captures product discovery

- GIVEN a future Copilot-guided project session
- WHEN the PRD is drafted or refined
- THEN generated guidance captures problem, users or situations, current gap, outcome, product or business rules, scope, non-goals, edge cases, open questions, and approval owner/date/status
- AND it excludes technical design, implementation tasks, PR splitting, and review-budget decisions from PRD work

#### Scenario: Proposal stays proposal-only

- GIVEN an approved PRD
- WHEN the proposal is drafted or refined
- THEN generated guidance records PRD source/status, consulted project context, intent, scope, users, lightweight approach, assumptions, decision gaps, risks, rollback, acceptance, and handoff to spec
- AND it excludes requirements matrices, technical design, implementation tasks, PR splitting decisions, and code changes

#### Scenario: Spec captures acceptance behavior

- GIVEN an approved PRD and approved proposal
- WHEN the spec phase is run
- THEN generated guidance requires requirements and OpenSpec-style `GIVEN` / `WHEN` / `THEN` scenarios in `docs/pegasus/spec.md`
- AND it records PRD/proposal source status, edge cases, non-goals, and traceability
- AND it excludes architecture, implementation details, task checklists, and code changes

#### Scenario: Design captures technical approach only

- GIVEN an approved proposal and approved spec
- WHEN the design phase is run
- THEN generated guidance records inputs, design goals/non-goals, technical approach, decisions, tradeoffs, alternatives, affected areas/files, data/control flow, testing strategy, rollout/rollback, risks, and open questions in `docs/pegasus/design.md`
- AND it excludes implementation code and task checklist creation

#### Scenario: Tasks define reviewable slices

- GIVEN an approved spec and approved design
- WHEN the tasks phase is run
- THEN generated guidance records implementation slices with dependency/order, verification, risk, and rollback details in `docs/pegasus/tasks.md`
- AND it includes the exact guard lines `Decision needed before apply: Yes|No`, `Chained PRs recommended: Yes|No`, and `400-line budget risk: Low|Medium|High`
- AND it excludes implementation code

#### Scenario: Apply implements only the approved slice

- GIVEN an approved task slice and existing apply-progress history
- WHEN the apply phase is run
- THEN generated guidance requires reading spec, design, tasks, apply-progress, and MCP task progress before editing
- AND it checks MCP task progress and `docs/pegasus/apply-progress.md` to avoid duplicate work
- AND it records approved slice source, duplicate-check result, changed files, preliminary evidence, verification status per slice, risks, blockers, and next action with merge-not-overwrite discipline
- AND it states that preliminary apply evidence does not replace the verify phase

#### Scenario: Verify checks the full SDD contract

- GIVEN implementation is ready for verification
- WHEN the verify phase is run
- THEN generated guidance verifies against PRD, proposal, spec, design, tasks, apply-progress, changed files, and runtime evidence where possible
- AND it records a compliance matrix, changed files reviewed, commands/results, test coverage/manual checks, deviations, risks, and final verdict in `docs/pegasus/verify.md`
- AND it forbids unrelated implementation changes unless the user separately asks for remediation

### Requirement: Lightweight orchestration guardrails

The generated Pegasus guidance MUST support a direct-fix path for small, punctual, low-risk changes, MUST require required-doc checks and user approval before phase transitions, MUST require review-budget confirmation before large implementation, MUST avoid duplicate launches for the same phase/task when MCP task progress or apply-progress already shows work exists, and MUST preserve useful apply-progress, memory, and verification history by merging updates instead of overwriting content.

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

#### Scenario: Duplicate launch is avoided

- GIVEN MCP task progress or `docs/pegasus/apply-progress.md` shows a phase/task is already in progress or completed
- WHEN orchestration considers delegating that same phase/task
- THEN generated guidance requires avoiding duplicate work and moving to recovery, verification, handoff, or the next approved task slice as appropriate

#### Scenario: Apply progress is tracked

- GIVEN an approved implementation slice
- WHEN apply work starts or completes
- THEN generated guidance records implementation slices, current in-progress work, completed work, changed files, verification evidence, unresolved risks, blockers, and next action in `docs/pegasus/apply-progress.md`
- AND updates are merged with existing useful apply-progress history

#### Scenario: Verification uses fresh context when possible

- GIVEN implementation is ready for verification
- WHEN generated verification guidance is followed
- THEN the verifier re-reads PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion
- AND the guidance treats fresh-context verification as an operational rule rather than a guaranteed runtime capability

### Requirement: Model preference documentation

The generated guidance MUST use a single project-selected Copilot model for all phases in the first Pegasus release and MUST document where to record that preference without promising hard runtime control or per-phase model routing.

#### Scenario: Model preference recorded as project context

- GIVEN a project team chooses a Copilot model preference
- WHEN the generated guidance is followed
- THEN the preference is recorded in project context or workspace settings
- AND Pegasus guidance does not claim per-phase model routing control

### Requirement: Existing file protection

The system MUST NOT overwrite existing files unless an explicit overwrite flag or interactive confirmation is provided. Default conflict behavior MUST report conflicts and perform no writes for conflicting paths.

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
