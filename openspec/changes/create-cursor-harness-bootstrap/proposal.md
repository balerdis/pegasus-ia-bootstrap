# Proposal: Create Cursor Harness Bootstrap

## Intent

Create a local-first Pegasus IA bootstrap tool that configures a target workspace harness for building a business MVP later inside Cursor using Pegasus IA rules. The bootstrap initializes the Cursor harness and context files only; it does not generate business/domain MVP code.

## Scope

### In Scope
- Configure/initialize target workspace harness files only; no business/domain app scaffold.
- Accept project name plus optional target path; default `/var/www/html/personal/<project-name>`.
- Create portable agent instructions in `AGENTS.md` and Cursor rules under `.cursor/rules/`.
- Optionally install/update general Cursor user configuration only when an explicit `--install-cursor-global` flag is provided, with backup and version/safety checks.
- Create Pegasus SDD docs under `docs/pegasus/`: `proposal.md`, `spec.md`, `design.md`, `tasks.md`, and `verify.md`.
- Create project-local Markdown memory under `docs/pegasus/memory/`: `context.md`, `decisions.md`, `tasks-log.md`, `handoff.md`, and `learnings.md`.
- Ensure Markdown memory is usable by future or compacted Cursor sessions to recover context, decisions, task status, handoff notes, and learnings.

### Out of Scope / Non-Goals
- Generating framework, domain, UI, API, database, or other business MVP application code.
- Creating a remote GitHub repo, first commit, CI, or deployment setup.
- Initializing a local Git repository; repo lifecycle is intentionally separate from harness configuration.
- Installing MCP servers or requiring persistent external services.
- Replacing future persistent operational memory; Markdown memory is the initial project-local substitute.

## Target Workspace Output Structure

```txt
<target-workspace>/
├── AGENTS.md
├── .cursor/
│   └── rules/
└── docs/
    └── pegasus/
        ├── proposal.md
        ├── spec.md
        ├── design.md
        ├── tasks.md
        ├── verify.md
        └── memory/
            ├── context.md
            ├── decisions.md
            ├── tasks-log.md
            ├── handoff.md
            └── learnings.md
```

## Users and First Slice

Primary user: a developer starting Pegasus IA exercises/demos. First later target: `/var/www/html/personal/gestor-solicitudes-mvp`.

## Capabilities

### New Capabilities
- `pegasus-harness-bootstrap`: CLI behavior, inputs, outputs, initialized harness files, no-business-MVP-code guarantee, and local-first recovery model.

### Modified Capabilities
- None.

## Approach

Provide a small bootstrap entrypoint that validates target path safety, initializes the selected option C harness structure, writes deterministic templates, and avoids overwrites unless confirmed or backed up. By default it touches only the target workspace. If `--install-cursor-global` is provided, it also plans and applies guarded global Cursor configuration updates with backup/version checks. Generated content teaches Cursor how to use Pegasus IA rules and points sessions to project-local Markdown memory before the user/team builds the business MVP inside Cursor.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `openspec/changes/create-cursor-harness-bootstrap/` | Modified | Clarified SDD proposal scope |
| future bootstrap entrypoint | New | Initializes target workspace harness only |
| target workspace harness | New | Agent, Cursor rules, SDD docs, Markdown memory |
| optional Cursor user config | New | Installed/updated only behind explicit flag with backup/version safety |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Overwriting user files | Med | Default to no-overwrite; require explicit force/backup behavior |
| Overwriting Cursor user configuration | Med | Never touch global config by default; require explicit flag and create backups before changes |
| Harness overreach | Med | Enforce config-only output and acceptance checks for no business/domain app code |
| Context loss after compaction | Med | Make memory files explicit, structured, and referenced from `AGENTS.md` and Cursor rules |

## Rollback Plan

Delete generated harness files/directories, or restore backups. If global Cursor config was installed, restore the generated backup. No remote resources, app code, or local Git repository are created.

## Dependencies

- Local filesystem access to target path.
- Bootstrap runtime/tooling, to be decided in design.

## Acceptance Criteria

- [ ] Running the bootstrap initializes exactly the option C harness structure in a target workspace.
- [ ] No business MVP application source code, framework scaffold, database schema, or deployment setup is generated.
- [ ] `AGENTS.md` and Cursor rules instruct future Cursor sessions to follow Pegasus IA rules.
- [ ] A default run does not read/write global Cursor user configuration; global Cursor config is changed only with `--install-cursor-global` and backup protection.
- [ ] Project-local Markdown memory files are created and documented as the recovery source for context, decisions, tasks, handoff, and learnings.
- [ ] Existing files are protected by default.
- [ ] The bootstrap does not run `git init` or create local Git metadata.
