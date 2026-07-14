# Delta for Pegasus Harness Bootstrap

## ADDED Requirements

### Requirement: MCP-first operational memory

The generated harness MUST use the `pegasus-memory-mcp` MCP tool contract as the operational memory interface for recovery, search, and persistence. It MUST NOT require users or agents to write operational memory to `docs/pegasus/memory/`, and it MUST NOT depend on MCP server internals, SQLite details, database paths, or source modules.

#### Scenario: Session starts with memory available

- GIVEN `pegasus-memory-mcp` tools are available
- WHEN the orchestrator starts or recovers context
- THEN it recovers project, active change context, decisions, observations, handoffs, artifact references, task progress, and learnings through MCP
- AND it does not ask the user to inspect memory storage layout

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

The generated harness MUST detect unavailable memory before relying on persistence. If `pegasus-memory-mcp` is unavailable, the user-facing warning MUST be exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Pegasus MAY continue project/change artifact work, but it MUST NOT claim persistent memory was saved and MUST NOT fall back to Markdown memory.

#### Scenario: MCP missing or unreachable

- GIVEN MCP memory is missing, not executable, not on PATH, or fails health/recovery
- WHEN Pegasus needs persistent memory
- THEN it shows the exact approved warning
- AND persistent memory saves are treated as unavailable

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

## MODIFIED Requirements

### Requirement: Harness-only output

The system MUST initialize a VS Code/Copilot-first Pegasus harness and MUST NOT create framework scaffolds, domain files, UI, API, database, CI, deployment, or other business/domain MVP application code. The default workspace output MUST include `.github/` Copilot assets, `AGENTS.md`, and `docs/pegasus/`; Cursor assets MAY be generated only as clearly secondary legacy compatibility. Generated `docs/pegasus/memory/` templates MUST NOT be created as the operational memory layer.
(Previously: default output included `docs/pegasus/memory` templates as generated memory files.)

#### Scenario: Copilot-first structure generation

- GIVEN an empty target workspace directory
- WHEN the bootstrap completes
- THEN `.github/copilot-instructions.md`, `.github/instructions/`, `.github/prompts/`, `.github/agents/`, `AGENTS.md`, and `docs/pegasus/` exist
- AND generated guidance points operational memory to MCP, not `docs/pegasus/memory/`

#### Scenario: No app code

- GIVEN any successful bootstrap run
- WHEN the target tree is inspected
- THEN only harness, documentation, Copilot, and legacy guidance files were created
- AND business MVP code is built later by the user/team using the harness

### Requirement: Portable agent guidance

The system MUST create a portable `AGENTS.md` that explains the Pegasus IA workflow, MCP-first memory policy, VS Code/Copilot usage, and how future agents should continue work through the MCP tool contract when available. `AGENTS.md` MUST remain portable guidance rather than the primary Copilot-native control surface.
(Previously: AGENTS.md directed sessions to read and update `docs/pegasus/memory/`.)

#### Scenario: Agent instructions created

- GIVEN a successful bootstrap run
- WHEN `AGENTS.md` is opened
- THEN it describes Pegasus IA workflow usage and VS Code/Copilot entry points
- AND it directs sessions to use MCP-first memory with the approved unavailable-memory warning

### Requirement: PRD and SDD document templates

The system MUST create PRD and SDD templates under `docs/pegasus` or change-scoped `docs/pegasus/changes/<change-id>/` locations for proposal, spec, design, tasks, apply-progress, and verification, and Copilot prompts/instructions SHOULD reference those templates as workflow artifacts. The guided SDD flow MUST be `request -> PRD -> proposal -> spec -> design -> tasks -> apply -> verify -> handoff`, and proposal work MUST require an approved PRD. Generated phase guidance MUST use MCP for operational memory and MUST stop telling Pegasus to write Markdown memory.
(Previously: phase guidance referenced flat docs plus `docs/pegasus/memory/` for context, tasks-log, handoff, decisions, and learnings.)

#### Scenario: SDD templates available

- GIVEN a successful bootstrap run
- WHEN `docs/pegasus` and `.github/prompts/` are inspected
- THEN each SDD template file exists with clear headings for future project work
- AND Copilot prompt assets guide phases without Markdown-memory write instructions

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
- THEN generated guidance requires requirements and OpenSpec-style `GIVEN` / `WHEN` / `THEN` scenarios in the spec artifact
- AND it excludes architecture, implementation details, task checklists, and code changes

#### Scenario: Design captures technical approach only

- GIVEN an approved proposal and approved spec
- WHEN the design phase is run
- THEN generated guidance records approach, decisions, tradeoffs, affected areas, data/control flow, testing, rollout/rollback, risks, and open questions in the design artifact
- AND it excludes implementation code and task checklist creation

#### Scenario: Tasks define reviewable slices

- GIVEN an approved spec and approved design
- WHEN the tasks phase is run
- THEN generated guidance records implementation slices with dependency/order, verification, risk, and rollback details in the tasks artifact
- AND it includes the exact forecast lines `Decision needed before apply: Yes|No`, `Chained PRs recommended: Yes|No`, `Chain strategy: stacked-to-main|feature-branch-chain|size-exception|pending`, `400-line budget risk: Low|Medium|High`, `Estimated authored changed lines: <range>`, `Estimated generated changed lines: <range|none>`, and `Tests included in estimate: Yes`
- AND every work unit declares implementation scope, test scope, focused test command, runtime validation, rollback boundary, and estimated authored changed lines

#### Scenario: Apply implements only the approved slice

- GIVEN an approved task slice and existing apply-progress history
- WHEN the apply phase is run
- THEN generated guidance requires reading approved artifacts and MCP task progress before editing
- AND it records slice status in file artifacts and MCP memory without Markdown fallback

#### Scenario: Verify checks the full SDD contract

- GIVEN implementation is ready for verification
- WHEN the verify phase is run
- THEN generated guidance verifies against PRD, proposal, spec, design, tasks, apply-progress, changed files, and runtime evidence where possible
- AND durable observations, decisions, handoff notes, and learnings are saved through MCP when available

### Requirement: Lightweight orchestration guardrails

The generated Pegasus guidance MUST make `pegasus-orchestrator` a thin coordinator that delegates every SDD phase to the matching specialized agent in a fresh context and stops when delegation is unavailable, blocked, or fails. Specialized agents MUST execute directly without recursively delegating their phase. Apply MUST implement one authorized slice and return control; a distinct fresh-context verify agent MUST verify it. Outside SDD, delegation MUST be mandatory for 4 or more required file reads, 2 or more non-trivial implementation files, tests/builds/installs/external tooling, or complexity beyond small mechanical coordination. Duplicate protection MUST use change, phase, and task-slice identity across MCP task progress and apply-progress.
(Previously: duplicate checks and memory history depended on `docs/pegasus/memory/tasks-log.md`.)

#### Scenario: Duplicate launch is avoided

- GIVEN MCP task progress or `docs/pegasus/apply-progress.md` shows a phase/task is already in progress or completed
- WHEN orchestration considers delegating that same phase/task
- THEN generated guidance requires avoiding duplicate work
- AND it moves to recovery, verification, handoff, or the next approved task slice as appropriate

#### Scenario: Progress history is preserved

- GIVEN existing useful progress, memory, handoff, or verification history
- WHEN new status or evidence is recorded
- THEN generated guidance requires integrating the update without replacing prior useful content
- AND MCP is the persistence target for operational memory when available

#### Scenario: Direct fix avoids unnecessary SDD

- GIVEN a small, punctual, low-risk change with clear acceptance criteria
- WHEN the orchestrator selects the workflow
- THEN it may coordinate only a narrowly defined small mechanical task instead of forcing all SDD phases
- AND direct work excludes phase artifacts and implementation code

#### Scenario: Large change triggers review budget decision

- GIVEN preflight established review budget and delivery preference
- WHEN the `sdd-tasks` forecast exceeds budget, reports High risk, recommends chaining, or needs a decision
- THEN the orchestrator stops after tasks and before apply and presents `stacked-to-main`, `feature-branch-chain`, or explicit maintainer-approved `size:exception`
- AND it never chooses silently
- AND apply returns blocked before writing without a resolved strategy and one authorized slice

#### Scenario: Apply progress is tracked

- GIVEN an approved implementation slice
- WHEN apply work starts or completes
- THEN generated guidance records current work, completed work, changed files, evidence, risks, blockers, and next action in `docs/pegasus/apply-progress.md`
- AND MCP task progress is updated when available

#### Scenario: Verification uses fresh context when possible

- GIVEN implementation is ready for verification
- WHEN generated verification guidance is followed
- THEN the verifier re-reads PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion
- AND the guidance treats fresh-context verification as an operational rule rather than a guaranteed runtime capability

## REMOVED Requirements

### Requirement: Project-local memory templates

(Reason: `docs/pegasus/memory/` is deprecated after MCP integration and must not remain an operational memory backend, fallback, or co-source.)
(Migration: None required; Pegasus Bootstrap has not been used operationally with the old Markdown memory backend.)
