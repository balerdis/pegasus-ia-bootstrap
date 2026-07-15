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

### Requirement: Pegasus Memory operational persistence

The generated harness MUST use Pegasus Memory, served by `pegasus-memory-mcp`, as the operational persistence interface for recovery, search, persistence, and availability checks. It MUST configure the server by default, MUST support `--install-memory-mcp` as the explicit install/config flag, MUST resolve the executable from PATH first and then the default local install path, and MUST generate VS Code workspace stdio config that launches `node` with the absolute built script path and sets `cwd` to the resolved Pegasus Memory root. The clone/build fallback MUST use the published `stable/0.1.1` branch. Generated guidance MUST recognize `health.capabilities.parent_bootstrap` when present. It MUST NOT require users or agents to write operational memory to `docs/pegasus/memory/`, and it MUST NOT depend on Pegasus Memory internals, SQLite details, database paths, or source modules.

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
- THEN the harness guidance requires saving those records through Pegasus Memory

#### Scenario: Pegasus Memory responsibility boundary

- GIVEN Pegasus Memory is configured and other MCP servers may also be connected
- WHEN generated guidance describes operational persistence
- THEN it identifies Pegasus Memory or `pegasus-memory-mcp` as responsible for project/change records, artifacts, observations, task progress, and handoffs
- AND it does not treat another MCP server as a substitute for Pegasus Memory persistence
- AND it does not mention tables, SQLite schema, internal modules, or private implementation files

### Requirement: Memory unavailable behavior

The generated harness MUST call `health` before the first recovery or save attempt and MUST detect unavailable memory before relying on persistence. If `pegasus-memory-mcp` is unavailable, the user-facing warning MUST be exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Pegasus MAY continue project/change artifact work, but it MUST NOT claim persistent memory was saved and MUST NOT fall back to Markdown memory. It MUST distinguish `not_found`, `ambiguous`, `read_error`, and `persistence_error` from true unavailability. When recovery returns `not_found` with `project_not_found`, generated guidance MUST call `ensure_project` before recording observations, artifacts, task progress, or handoff records. When creating a new change/PRD, generated guidance MUST call `ensure_change` before `record_artifact` or change-scoped observations. Generated guidance MUST use the minimal compatible `ensure_change` payload by default: required `project_id` and `change_id`; optional flat `key`, `title`, `status`, or `description` only when needed. If classification is needed, it MUST use `kind` only; it MUST NOT send `type` or both aliases, even with equal values. Product decisions, questions, artifact summaries, and other details MUST be written with `record_observation` or `record_artifact`, not arbitrary `ensure_change` metadata. `persistence_error` or foreign-key write failures MUST be reported as write-flow precondition failures, not MCP unavailability.

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
- AND its default payload contains only `project_id` and `change_id`
- AND it adds optional flat fields only when needed and uses `kind` as the sole classification alias
- AND it never sends `type` or simultaneous `kind` and `type` fields
- AND product decisions and artifact details are recorded separately

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

### Requirement: Agent artifact and durable memory language

The generated harness MUST default all generated or agent-consumed artifacts to English, including PRD, proposal, spec, design, tasks, apply-progress, verify, handoff/session summaries, prompts, instructions, workflows, skills, and internal agent communication. Only an explicit user instruction naming the desired language for the artifact MAY override English. Chat language, persona language, dominant source language, and prior artifact language MUST NOT implicitly select artifact language. User-facing Pegasus Orchestrator conversation, README/user documentation, commit messages, and intentionally localized public runtime messages MAY use Spanish.

Durable Pegasus Memory descriptive prose MUST be English regardless of chat or artifact language. This includes titles, summaries, rationale, decisions, status, blockers, next actions, progress notes, handoffs, observations, and artifact descriptions. Immutable identifiers, paths, tool/server names, exact approved titles, user quotations, validation literals, and required public warnings MUST remain unchanged and be clearly identified as data. Persistence MUST NOT translate or mutate source artifacts merely to store them; it MUST summarize their meaning separately in English and record `Artifact language: <language>`.

#### Scenario: English is selected despite Spanish context

- GIVEN the conversation and approved source artifacts are in Spanish
- WHEN the user requests a new agent-consumed artifact without explicitly naming its language
- THEN the artifact language is English
- AND neither chat language nor dominant source language overrides the default

#### Scenario: Explicit artifact-language override

- GIVEN the user explicitly requests a Spanish spec
- WHEN the spec is generated
- THEN its artifact language is Spanish
- AND the override applies to that named artifact rather than durable Pegasus Memory prose

#### Scenario: Durable memory remains English

- GIVEN an artifact or user conversation uses a language other than English
- WHEN Pegasus Memory records descriptive project or change state
- THEN titles, summaries, rationale, status, blockers, next actions, progress notes, handoffs, observations, and artifact descriptions are English
- AND exact source data remains unchanged, clearly labelled, with `Artifact language: <language>` recorded

### Requirement: PRD and SDD document templates

The system MUST create a PRD template and production-ready SDD templates under `docs/pegasus` or change-scoped `docs/pegasus/changes/<change-id>/` locations for proposal, spec, design, tasks, apply-progress, and verification, and Copilot prompts/instructions SHOULD reference those templates as the workflow source of truth. The guided SDD flow MUST be `request -> PRD -> proposal -> spec -> design -> tasks -> apply -> verify -> handoff`, and proposal work MUST require an explicitly approved PRD artifact. PRD guidance MUST capture product discovery and explicit approval, while proposal guidance MUST stay proposal-only as a bridge from approved PRD to spec.

#### Scenario: SDD templates available

- GIVEN a successful bootstrap run
- WHEN `docs/pegasus` and `.github/prompts/` are inspected
- THEN each SDD template file exists with clear headings for future project work
- AND Copilot prompt assets guide the user through those SDD phases

#### Scenario: PRD gates proposal

- GIVEN a future Copilot-guided project session
- WHEN the user requests SDD proposal work
- THEN the generated guidance requires the PRD artifact to exist and be approved first

#### Scenario: Proposal validates in-file PRD approval

- GIVEN a referenced PRD has an Approval table/status and an approval checkbox
- WHEN proposal work is requested
- THEN generated guidance reads the PRD artifact and requires `Approved` status plus a checked checkbox when both exist
- AND it stops for a Draft, unchecked, or inconsistent artifact rather than accepting conversational approval

#### Scenario: Proposal reports MCP persistence outcomes

- GIVEN proposal work writes a proposal artifact after MCP health succeeds
- WHEN the proposal phase closes
- THEN generated guidance reports `ensure_project`, `ensure_change`, `record_artifact`, `record_observation`, `record_task_progress`, and `record_handoff` as `succeeded`, `not needed`, or `failed: <reason>`
- AND it reports file-only status with the reason when required proposal artifact or observation persistence fails

#### Scenario: Proposal preserves only explicit PRD decisions

- GIVEN an approved PRD omits a material product decision
- WHEN generated guidance drafts a proposal
- THEN it MUST NOT invent a default or call the omitted detail a preserved PRD assumption
- AND it MUST ask for clarification before finalizing or record the exact unresolved gap and impact

#### Scenario: Proposal gives every material gap a terminal disposition

- GIVEN an approved PRD or current-change evidence leaves a material gap about scope, user-visible behavior, acceptance, risk, or a phase gate
- WHEN generated guidance drafts or finalizes a proposal
- THEN it MUST reconcile that gap before marker validation and MCP persistence to exactly one terminal disposition
- AND it MUST resolve the gap only with explicit reliable current-change evidence or a direct user answer, recording that evidence
- AND it MUST record resolved evidence, including a blocking gap resolved before writing, in `Open Decisions / Material Gaps`
- OR it MUST retain a visible unresolved entry in `Open Decisions / Material Gaps` with owner, impact, next step, and needed-by gate
- AND it MUST NOT leave the gap implicit, duplicated, or as an unqualified `TBD`

#### Scenario: Blocking material gap stops proposal work

- GIVEN a material gap prevents safe proposal scope, acceptance, or a proposal-phase gate
- WHEN generated guidance identifies the gap before proposal writing or finalization
- THEN it MUST ask one concise question and stop before writing or finalizing the proposal
- AND it MUST NOT validate proposal markers or make MCP persistence calls

#### Scenario: Non-blocking material gap remains visible

- GIVEN a material gap does not prevent safe proposal scope, acceptance, or a proposal-phase gate
- WHEN generated guidance writes the proposal
- THEN it MUST record the gap in the dedicated `Open Decisions / Material Gaps` section
- AND the entry MUST name its owner, impact, next step, and needed-by gate
- AND the final response MUST summarize it as unresolved rather than claiming no open questions

#### Scenario: Ambiguous MCP does not resolve a material gap

- GIVEN MCP active-context recovery is `ambiguous` while a material gap remains
- WHEN generated guidance reconciles proposal gaps
- THEN it MUST NOT treat the ambiguous MCP response as reliable current-change evidence or as a resolution
- AND it MUST continue from reliable current-change artifacts and retain the gap as unresolved unless a direct user answer or explicit reliable evidence resolves it

#### Scenario: Change-scoped proposal is managed and closes explicitly

- GIVEN generated guidance creates `docs/pegasus/changes/<change-id>/proposal.md`
- WHEN the proposal phase closes
- THEN a new proposal MUST use `<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/proposal.md ownership=full-file -->` as its exact first line and `<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/proposal.md -->` as its exact final line, with `<change-id>` replaced by the actual path
- AND a refinement MUST preserve both existing managed markers exactly and edit only the content between them
- AND generated guidance MUST reread and validate those exact first/last marker lines after writing and before any MCP persistence call or success response
- AND, if marker validation fails, it MUST repair the markers, reread, and validate again before MCP persistence; if validation still fails, it MUST stop with a file-only failure and MUST NOT report success or advance the phase
- AND the user-facing final response MUST contain the exact `MCP persistence summary:` block with one status line for each required proposal MCP tool, even when MCP is unavailable

#### Scenario: Proposal preserves target-language orthography

- GIVEN proposal work writes an artifact in a target language
- WHEN generated guidance drafts or refines its prose
- THEN it MUST preserve that language's standard orthography and diacritics
- AND Spanish technical artifacts MUST use neutral, professional Spanish with correct accents and no conversational persona wording

#### Scenario: Proposal isolates unrelated changes by default

- GIVEN an approved PRD for the current change and unrelated neighboring change artifacts
- WHEN generated guidance drafts or refines the proposal
- THEN it MUST use the current change PRD as the only default product-content source
- AND it MUST use the canonical managed proposal template and current change placeholder as the only default structure/format source
- AND it MUST NOT search, read, inspect, or reuse unrelated change artifacts for content, scope, decisions, assumptions, wording, style, or formatting

#### Scenario: Proposal consults an explicitly related change with disclosure

- GIVEN the current PRD, active MCP context, or a direct user instruction explicitly declares a dependency or relation to another change
- WHEN generated guidance consults that related change artifact
- THEN the proposal artifact or final report MUST disclose the reference/change consulted and its exact purpose/dependency
- AND it MUST explicitly state that the related artifact was not used as an implicit scope source
- AND it MUST NOT implicitly inherit scope, decisions, assumptions, wording, or style from that related change

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
- THEN generated guidance requires requirements and OpenSpec-style `GIVEN` / `WHEN` / `THEN` scenarios in `docs/pegasus/changes/<change-id>/spec.md`
- AND it records PRD/proposal source status, edge cases, non-goals, and traceability
- AND it excludes architecture, implementation details, task checklists, and code changes

#### Scenario: Spec validates approved current-change sources

- GIVEN spec work is requested for a current change
- WHEN the PRD or proposal is Draft, Pending, unchecked, or has inconsistent in-file approval indicators
- THEN generated guidance MUST stop before finalizing the spec
- AND it MUST NOT treat conversational approval as overriding the artifact

#### Scenario: Spec isolates unrelated changes

- GIVEN the current change has an approved PRD and proposal and neighboring changes exist
- WHEN generated guidance writes the spec
- THEN it MUST use only the current change PRD and proposal as default product and requirements sources
- AND it MUST NOT inspect or reuse neighboring requirements, scenarios, wording, style, or formatting
- AND a permitted explicit dependency MUST be disclosed with its reference, purpose, and non-implicit-scope statement

#### Scenario: Spec reconciles material acceptance gaps

- GIVEN current-change evidence leaves a material requirements or acceptance gap
- WHEN spec guidance prepares finalization
- THEN it MUST resolve the gap only with reliable current-change evidence or a direct user answer
- OR it MUST retain owner, impact, next step, and needed-by gate visibly
- AND an ambiguous MCP response MUST NOT resolve the gap
- AND a blocking gap MUST ask one concise question and stop before finalization

#### Scenario: Spec validates markers and reports Pegasus Memory persistence state

- GIVEN a change-scoped spec is written or refined
- WHEN the agent prepares Pegasus Memory persistence
- THEN it MUST preserve or create exact `docs/pegasus/changes/<change-id>/spec.md` managed start and end markers and reread them first
- AND it MUST repair and reread invalid markers before Pegasus Memory persistence
- AND, if repair and reread still fail validation, it MUST block Pegasus Memory persistence and success, report a file-only failure, and stop the phase
- AND, after marker validation and whenever Pegasus Memory is healthy, it MUST call or attempt `record_task_progress` before `record_handoff`; for a successfully drafted spec ready for user review, its first attempt MUST use supported status `completed` and record phase `spec`, artifact path, `ready for review` / draft complete, open gaps/blockers, and next action `user review/approval` in descriptive fields or notes
- AND it MUST use only the supported status enum `pending`, `in_progress`, `blocked`, `completed`: `blocked` for blocked work, `in_progress` for active work, and `pending` for work not yet started; it MUST NOT send unsupported review-state aliases as status values
- AND it MUST not return a final response until all six Pegasus Memory operations have a terminal status
- AND it MUST provide the exact `Pegasus Memory persistence summary:` heading and six status lines, each using only `succeeded`, `not needed`, or `failed: <reason>`, even when Pegasus Memory is unavailable
- AND it MUST NOT claim `succeeded` for a call that was omitted; it MUST attempt the call or report a truthful failed/not-needed status
- AND `record_artifact` or `record_observation` failure MUST report `Spec persistence: file-only — <reason>`
- AND, when both artifact and observation persistence succeeded, `record_task_progress` or `record_handoff` failure MUST report `Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>`
- AND every failed required closure operation MUST prevent a full durable-completion or Pegasus Memory-success claim

#### Scenario: Spec preserves language and phase boundary

- GIVEN spec prose is written in a target language
- WHEN the acceptance contract is generated
- THEN it MUST select exactly one artifact language before writing: an explicit user instruction naming the spec language takes precedence, otherwise it MUST use English
- AND chat language, persona language, dominant approved-source language, and prior artifact language MUST NOT override that choice
- AND it MUST keep headings, table labels, metadata labels, and body prose in the selected language, except immutable identifiers, deliberately standardized normative keywords, code, paths, and tool names
- AND, for Spanish, it MUST use neutral, professional Spanish with correct diacritics and approved-source terminology, including translated human-readable canonical headings and labels; its structural metadata MUST use `Creado:` and `Destino:`
- AND, after marker validation and before Pegasus Memory persistence, it MUST run a separate language/terminology validation for language consistency, untranslated canonical headings/labels, diacritics, malformed or near-match terms, and PRD/proposal terminology
- AND the Spanish validation MUST concretely require `Creado:` and `Destino:` and reject `Created:`, `Target:`, and every applicable default-English canonical heading/table label from the canonical spec-template vocabulary
- AND the structural-label scan MUST allow standardized `GIVEN` / `WHEN` / `THEN`, contractually required canonical enum values such as `Approved` or `Draft`, paths, identifiers, tool/server names, code, source-section references, and established technical terms
- AND, when that validation finds issues, it MUST repair only affected language blocks, reread the complete artifact, revalidate markers, and rerun the language/terminology validation
- AND, if issues remain, it MUST report every exact unresolved issue, MUST NOT persist or claim success, and MUST report `Spec persistence: file-only — language validation failed: <exact issues>`
- AND it MUST NOT report `Language gate: passed` while any prohibited English structural label remains
- AND the final response MUST state `Artifact language: <selected language>` and `Language gate: <passed|blocked: exact unresolved issues>` before the exact Pegasus Memory persistence summary
- AND each normative requirement MUST trace to approved PRD/proposal evidence or a visible unresolved gap
- AND it MUST NOT create architecture, task, or implementation content

#### Scenario: Design captures technical approach only

- GIVEN an approved proposal and approved spec
- WHEN the design phase is run
- THEN generated guidance records inputs, design goals/non-goals, technical approach, decisions, tradeoffs, alternatives, affected areas/files, data/control flow, testing strategy, rollout/rollback, risks, and open questions in `docs/pegasus/changes/<change-id>/design.md`
- AND every flow, alternative, affected area, testing, rollout/rollback, and risk entry MUST include a spec requirement or explicit repository-evidence traceability field
- AND a compact `Proposal Risk Coverage` matrix MUST map every approved proposal risk to at least one design-risk entry with source reference and mitigation, plus at least one testing/measurement entry when validation or measurement mitigates it, or an explicit N/A rationale otherwise, with owner and trigger where relevant
- AND omission of any approved risk, including mobile rendering performance, MUST block completion
- AND the material-gap structure MUST include invariant architecture, deferred choice, and why a deferred choice is non-blocking
- AND any deferred technical choice MUST appear in a dedicated `Deferred Technical Choices` section/table, not only in risks or prose
- AND each deferred row MUST include choice/topic, canonical status `deferred-non-blocking` or selected-language translation, owner, impact, next step, needed-by gate, invariant architecture, why non-blocking, and evidence/source; if evidence establishes none exist, it MUST state `None` / `Ninguna`
- AND in Greenfield context without concrete implementation stack, framework, or runtime evidence, `None` / `Ninguna` MUST be invalid; stack/framework/runtime selection MUST be a structured non-blocking deferred choice needed before tasks/apply, and its invariant architecture MUST preserve logical components, responsibilities, boundaries, interfaces, and control flow independently of the eventual selection
- AND root `docs/pegasus/design.md` MUST be described only as the canonical template, never as an active change artifact
- AND it excludes implementation code and task checklist creation

#### Scenario: Design specialist returns a complete gatekeeping envelope

- GIVEN the orchestrator delegates design to `sdd-design` in a fresh context
- WHEN the specialist completes or blocks the phase
- THEN `sdd-design` MUST return separate canonical fields for status, specialist agent, fresh-context delegation, artifact path, artifact writer/validator/persistence owner, artifact language, explicit non-English override evidence, language gate, marker validation, traceability validation, proposal risk coverage validation, deferred technical choices, initial recovery result, ordered recovery/ensure transitions, final artifact revision, persistence artifact revision, post-persistence edits, risks/blockers, and next action, plus the exact six-state Pegasus Memory persistence summary
- AND specialist/delegation fields MUST identify `sdd-design`, the fresh-context invocation, and `sdd-design` as artifact writer, validator, and persistence owner using only observable or returned evidence
- AND a missing or partial field MUST block success and phase advancement
- AND the orchestrator MUST reproduce the complete returned envelope verbatim or field-for-field with canonical English labels and unchanged data, even when transcript export omits nested-agent details
- AND it MUST NOT narratively summarize success, request approval, or advance when any field or operation state is missing or partial
- AND proposal-risk coverage validation is specialist-owned; the orchestrator MUST check only that its field and terminal state exist
- AND successful closure MUST report matching final/persistence revision identities and exact `Post-persistence edits: none`; omission, rephrasing, another value, or mismatch MUST fail closed
- AND after complete envelope reproduction the orchestrator MUST ask `¿Aprobás el diseño para avanzar a la fase de tareas?`; `Next action: review/approval` alone MUST NOT satisfy explicit approval

#### Scenario: Design closure is atomic across artifact and persistence

- GIVEN `sdd-design` is closing a completed design
- WHEN it prepares durable completion evidence
- THEN it MUST finish every content/formatting edit, fully reread, validate markers, language, per-entry traceability, proposal-risk design/test or measurement coverage, deferred choices, and sources, and freeze a content hash or explicit revision token before persistence
- AND after ensure preconditions it MUST persist exactly `record_artifact`, `record_observation`, `record_task_progress`, then `record_handoff`
- AND no artifact edit, repair, formatting rewrite, or content mutation may occur after any persistence operation begins
- AND if a later edit occurs or is required, all earlier completion/persistence evidence is stale; success MUST remain blocked until full reread/validation, a new frozen revision, and refreshed affected persistence records in the required order complete

#### Scenario: English design default survives Spanish context

- GIVEN chat and all approved design source artifacts are Spanish
- WHEN the user does not explicitly name a non-English language for the design artifact
- THEN `sdd-design` MUST produce an English design
- AND any non-English result MUST include the exact user instruction or precise reference that explicitly selected that artifact language

#### Scenario: Design requires approved isolated evidence and technical context

- GIVEN design work is requested for a current change
- WHEN its PRD, proposal, or spec is missing approval, Draft, Pending, unchecked, or inconsistent
- THEN guidance MUST prohibit design artifact writing, artifact finalization, and `record_artifact`, while allowing and requiring minimal blocked control-state persistence when Pegasus Memory is healthy: `ensure_project`/`ensure_change` as needed, `record_observation`, phase `design` `record_task_progress` with status `blocked`, and `record_handoff`
- AND conversational approval MUST NOT override the artifact
- AND it MUST use only current-change sources by default, disclose an explicit related dependency, and classify `existing system with implementation evidence` or the semantic Greenfield state without implementation evidence; it MUST render that state as `Greenfield / no implementation evidence` in English artifacts and `Greenfield / sin evidencia de implementación` in Spanish artifacts
- AND it MUST distinguish blocked artifact finalization/persistence from allowed blocked control-state persistence: when healthy, ensure project/change as needed, record a blocker observation, record phase `design` task progress as `blocked`, then record handoff, while `record_artifact` is `not needed` because no design artifact was written

#### Scenario: Design reconciles technical gaps and closes truthfully

- GIVEN platform/runtime/framework, integration, persistence, deployment, or existing-stack decisions are material
- WHEN design guidance prepares the artifact
- THEN it MUST reconcile each gap before writing and again before persistence
- AND a blocking gap MUST ask one concise question and stop before writing or finalizing the design artifact
- AND a non-blocking deferred choice MUST state choice/topic, status `deferred-non-blocking` or selected-language translation, owner, impact, next step, needed-by gate, invariant architecture, why non-blocking, and evidence/source in the dedicated section
- AND a missing deferred field MUST block completed/ready-for-review status until repaired or explicitly blocked
- AND it MUST reconcile material gaps and deferred rows before marker validation, language validation, and persistence; it MUST preserve/readback/repair/revalidate exact change-scoped markers, apply the selected-language gate, and never ask a required close-out question after persistence
- AND on a healthy blocking path it MUST record only blocked state: ensure project/change, observation, phase `design` task progress with status `blocked`, then handoff; `record_artifact` MUST be `not needed` because no design artifact was written
- AND it MUST record Pegasus Memory task progress before handoff using only `pending`, `in_progress`, `blocked`, `completed`; `completed` requires no blocking gap and `blocked` reflects a blocker
- AND its task-progress notes and final response MUST summarize deferred choices (or `None` / `Ninguna`) and their next gate
- AND narrative prose alone MUST NOT satisfy closure; its response MUST include the exact structured labels `Artifact language:`, `Language gate:`, `Deferred technical choices:`, and the exact `Pegasus Memory persistence summary:` with the six states `ensure_project`, `ensure_change`, `record_artifact`, `record_observation`, `record_task_progress`, and `record_handoff`, plus truthful file-only or incomplete/partial failure classification
- AND unresolved language validation MUST block artifact persistence, report `record_artifact` as not needed with the language reason, record the truthful blocked control state, and never claim full durable success

#### Scenario: Design Spanish language and product naming gate

- GIVEN a Spanish design artifact has passed marker validation
- WHEN guidance validates language and terminology before Pegasus Memory persistence
- THEN it MUST require the exact canonical heading `Decisiones y compensaciones` and reject `Tradeoffs`, legacy headings `Costos y compromisos` and `Compensaciones`, awkward composite `Decisiones y costos y compromisos`, and other composite variants as headings
- AND it MUST reject both English classification variants `Greenfield/no implementation evidence` and `Greenfield / no implementation evidence` in Spanish artifacts and require `Greenfield / sin evidencia de implementación`; English artifacts MAY use `Greenfield / no implementation evidence`
- AND it MUST allow only justified immutable technical exceptions such as markers, identifiers, code, paths, tool/server names, and deliberately standardized terms
- AND it MUST reject standalone/generic product names `MCP`, `Contexto MCP`, `Memoria MCP`, and `Memoria Pegasus`, requiring `Pegasus Memory` or exact server annotation `pegasus-memory-mcp` instead
- AND it MUST validate every `MCP` occurrence independently, allowing it only in the exact protocol phrase `protocolo MCP` or inside the exact server annotation `pegasus-memory-mcp`; an allowed occurrence MUST NOT permit a separate standalone occurrence elsewhere in the document
- AND it MUST repair affected blocks, reread the complete artifact, revalidate markers, and rerun language validation before any persistence attempt

#### Scenario: Tasks define reviewable slices

- GIVEN an approved spec and approved design
- WHEN the tasks phase is run
- THEN generated guidance records implementation slices with dependency/order, verification, risk, and rollback details in `docs/pegasus/changes/<change-id>/tasks.md`
- AND it includes the exact forecast lines `Decision needed before apply: Yes|No`, `Chained PRs recommended: Yes|No`, `Chain strategy: stacked-to-main|feature-branch-chain|size-exception|pending`, `400-line budget risk: Low|Medium|High`, `Estimated authored changed lines: <range>`, `Estimated generated changed lines: <range|none>`, and `Tests included in estimate: Yes`
- AND it includes `Strategy decision evidence: <exact current-session user quote/message reference|none>` and `Size-exception approval evidence: <distinct current maintainer approval quote/message reference|none>`; Decision Yes without an explicit current user choice MUST keep strategy exactly `pending` and both evidence values exactly `none`
- AND authored estimates include code, tests, docs, config, and migrations while generated goldens, snapshots, and fixtures are counted separately
- AND each work unit declares implementation scope, test scope, focused test command, runtime validation, rollback boundary, and estimated authored changed lines
- AND it excludes implementation code

#### Scenario: Tasks specialist closes atomically and gates apply

- GIVEN the orchestrator delegates tasks to a fresh `sdd-tasks` context
- WHEN the specialist completes the task plan
- THEN it MUST finish edits, fully reread, validate language, exact markers, current-change source identity, exactly seven forecast lines and values, strategy evidence, complete work units and assigned scope, authored/generated estimates, and test inclusion before computing and freezing the SHA-256 final tasks revision
- AND it MUST set persistence revision equal to the frozen value before completion persistence, then ensure preconditions if needed, call `record_task_progress` carrying it, call `record_handoff` carrying it, perform no later edit or hash recomputation, and return the envelope
- AND calling or attempting `record_task_progress` or `record_handoff` before freeze MUST fail validation; a post-freeze or post-persistence edit MUST block that closure rather than refresh or recompute inside the same run
- AND a non-pending strategy MUST have an observable current-session user message explicitly selecting that exact strategy; design recommendation, memory, cached preference, architecture, previous conversation/session, default, inference, and fabricated/generic text MUST be rejected
- AND `size:exception` MUST additionally have a distinct observable current fact recording maintainer approval; user selection alone MUST block envelope completion, persistence, and apply
- AND it MUST return the complete flat canonical envelope with owner/delegation fields, every validation, all seven forecast values, strategy evidence, work-unit count and assigned scope, matching final/persistence revisions, exact `Post-persistence edits: none`, initial recovery, ordered transitions, truthful operation states, risks/blockers, decision required, and next action
- AND the orchestrator MUST reproduce the entire envelope field-for-field in flat output, explicitly consume the forecast, and fail closed on omission, dropped numeric fields, narrative substitution, unauthorized strategy, revision mismatch, post-persistence edits, or non-truthful persistence states
- AND before asking it MUST cite the returned authored range such as `590-720`, generated range, High risk, tests included, and work-unit count, then ask the exact three options
- AND Decision Yes, chaining Yes, High risk, or an over-budget authored estimate MUST block apply until the orchestrator asks the user in Spanish to choose exactly `stacked-to-main`, `feature-branch-chain`, or maintainer-approved `size:exception`, states no apply starts until the answer, and records the current resolved strategy
- AND a tasks-only request MUST NOT bypass this post-tasks guard, and no current selection may be inferred from prior preferences

#### Scenario: Apply implements only the approved slice

- GIVEN an approved task slice and existing apply-progress history
- WHEN the apply phase is run
- THEN generated guidance requires reading spec, design, tasks, apply-progress, and MCP task progress before editing
- AND it checks MCP task progress and `docs/pegasus/changes/<change-id>/apply-progress.md` to avoid duplicate work
- AND it records approved slice source, duplicate-check result, changed files, preliminary evidence, verification status per slice, risks, blockers, and next action with merge-not-overwrite discipline
- AND it states that preliminary apply evidence does not replace the verify phase

#### Scenario: Verify checks the full SDD contract

- GIVEN implementation is ready for verification
- WHEN the verify phase is run
- THEN generated guidance verifies against PRD, proposal, spec, design, tasks, apply-progress, changed files, and runtime evidence where possible
- AND it records a compliance matrix, changed files reviewed, commands/results, test coverage/manual checks, deviations, risks, and final verdict in `docs/pegasus/changes/<change-id>/verify.md`
- AND it forbids unrelated implementation changes unless the user separately asks for remediation

### Requirement: Lightweight orchestration guardrails

The generated Pegasus guidance MUST make `pegasus-orchestrator` a thin coordinator. It MUST delegate every SDD phase to its matching specialized agent in a fresh context and MUST stop when required delegation is unavailable, blocked, or fails. Specialized phase agents MUST execute directly and MUST NOT recursively delegate their phase. The orchestrator MUST NOT write phase artifacts, implement tasks, run phase tests/builds, or perform verification. For design, pre-delegation approval, path, phase, and duplicate-launch reads MAY remain mechanical. After specialist return, the orchestrator MUST validate only the returned result envelope and MUST NOT read or reread `design.md`, inspect source content, rerun marker/language/traceability/phase checks, or perform design persistence. It MUST reproduce the complete canonical specialist envelope verbatim or field-for-field with unchanged labels and values in its final response, without claiming direct artifact validation, and explicitly request phase approval only after the envelope passes. Lossy narrative summarization MUST NOT substitute for complete envelope reproduction. `sdd-apply` MUST implement only one authorized slice and return control; a distinct fresh-context `sdd-verify` MUST verify it. Outside SDD, delegation MUST occur when understanding requires reading 4 or more files, implementation touches 2 or more non-trivial files, tests/builds/installs/external tooling must run, or complexity exceeds small mechanical coordination. The guidance MUST avoid duplicate launches by change, phase, and task-slice identity using MCP task progress and apply-progress, and MUST preserve useful history by merging updates.

#### Scenario: Direct fix avoids unnecessary SDD

- GIVEN a small, punctual, low-risk change with clear acceptance criteria
- WHEN the orchestrator selects the workflow
- THEN the orchestrator may coordinate a narrowly defined small mechanical task instead of forcing all SDD phases
- AND that direct work does not include phase artifacts or implementation code

#### Scenario: Large change triggers review budget decision

- GIVEN session preflight established a review budget and general delivery preference
- WHEN `sdd-tasks` emits a forecast that exceeds the budget, reports High risk, recommends chaining, or says a decision is needed
- THEN the orchestrator stops after tasks and before apply and asks the user to choose `stacked-to-main`, `feature-branch-chain`, or explicit maintainer-approved `size:exception`
- AND it does not choose silently
- AND apply returns blocked before writing unless it receives the resolved strategy and one authorized slice

#### Scenario: Required delegation cannot run

- GIVEN a matching phase agent is unavailable, blocked, or fails
- WHEN the orchestrator coordinates that phase
- THEN it stops and reports the blocker
- AND it does not absorb phase execution into orchestrator context

#### Scenario: Apply and verify remain isolated

- GIVEN one authorized apply slice and resolved delivery strategy
- WHEN implementation and verification run
- THEN `sdd-apply` implements only that slice and returns control
- AND a distinct fresh-context `sdd-verify` performs verification

#### Scenario: Progress history is preserved

- GIVEN existing useful progress, memory, handoff, or verification history
- WHEN new status or evidence is recorded
- THEN generated guidance requires integrating the new update without replacing prior useful content

#### Scenario: Duplicate launch is avoided

- GIVEN MCP task progress or `docs/pegasus/changes/<change-id>/apply-progress.md` shows a phase/task is already in progress or completed
- WHEN orchestration considers delegating that same phase/task
- THEN generated guidance requires avoiding duplicate work and moving to recovery, verification, handoff, or the next approved task slice as appropriate

#### Scenario: Apply progress is tracked

- GIVEN an approved implementation slice
- WHEN apply work starts or completes
- THEN generated guidance records implementation slices, current in-progress work, completed work, changed files, verification evidence, unresolved risks, blockers, and next action in `docs/pegasus/changes/<change-id>/apply-progress.md`
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
