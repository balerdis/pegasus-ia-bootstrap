# PRD: Bootstrap CLI Lifecycle and Installability

Pegasus IA Bootstrap needs a safer and more usable CLI lifecycle so developers can install, update, apply, and remove the Pegasus harness in both new and existing projects without relying on absolute script paths or manual cleanup.

## Outcome

Developers can use Pegasus as an installable CLI, apply the harness to new or existing workspaces, remove workspace/global configuration safely, and understand both development and everyday usage flows.

## Problem

The current CLI works, but it is still shaped like an internal script:

- Users must run it by absolute path unless they create their own shell alias/symlink.
- The CLI is a single large Python script, making future lifecycle behavior harder to maintain.
- Existing projects can receive the harness through `--target-path`, but this scenario is not explicit enough.
- There is no supported uninstall path for workspace harness files.
- There is no supported uninstall path for global VS Code/Copilot configuration.
- When the explicit `--target-path` does not exist, the CLI must report that the target path will be created and require explicit confirmation before writing.

## Target Users and Situations

| User/Situation | Need |
|---|---|
| Pegasus maintainer | Develop and test the CLI from a local checkout using `.venv`. |
| Pegasus user on the same machine | Run `pegasus-harness-bootstrap` from any directory without remembering the repo path. |
| New project bootstrap | Create a Pegasus-guided workspace from scratch. |
| Existing project setup | Add the Pegasus harness to a project that already has source code. |
| Cleanup/removal | Remove Pegasus workspace files or global Copilot config without deleting unrelated user files. |

## Current Gap

Pegasus generates a production-ready harness, but the bootstrap CLI lifecycle is not yet production-grade. The product lacks installable entry points, explicit existing-project setup guidance, safe uninstall flows, and maintainable CLI structure.

## Product Scope

### In Scope

- Convert the current single-file CLI into a Python package split into maintainable modules.
- Add an installable Python entry point for `pegasus-harness-bootstrap`.
- Support development usage through a project `.venv`.
- Support everyday usage through an installed CLI command.
- Document both usage modes.
- Make existing-project setup an explicit supported scenario.
- Add safe workspace harness uninstall planning/application.
- Add safe global VS Code/Copilot uninstall planning/application.
- Preserve `--dry-run` behavior for install, setup, and uninstall flows.

### Out of Scope

- Publishing to PyPI.
- Adding `make install` or a custom installer script.
- Creating Git repositories or remotes for target projects.
- Creating application/business code in target projects.
- Building a heavy runtime dispatcher.
- Managing, modifying, or deleting non-Pegasus user files.

## Product and Safety Rules

- The CLI must never delete files unless the user explicitly requests uninstall behavior.
- Uninstall must remove the Pegasus-managed files that Pegasus installed.
- Uninstall must know its managed file inventory from an install manifest written during workspace setup.
- The install manifest must allow a project to uninstall the Pegasus files that were installed at that time, even if newer Pegasus versions change the template inventory later.
- Uninstall must support `--dry-run` and clearly show planned file removals, directory cleanup attempts, global asset removals, settings changes, and backups before writing.
- Existing project setup must not overwrite existing files unless the user opts in with an explicit overwrite option.
- Global VS Code/Copilot uninstall must back up `settings.json` before modifying it.
- Global uninstall must remove only Pegasus-managed paths from Copilot settings and must preserve unrelated user settings.
- Target paths are user-defined. The CLI should display the exact target path in dry-run and execution output.
- If the target path does not exist, the CLI must ask for explicit confirmation before creating it in non-dry-run mode.

## Required Usage Modes

### Development Mode

For contributors working from the Pegasus repo:

```sh
python -m venv .venv
source .venv/bin/activate
pip install -e .
pegasus-harness-bootstrap --project-name demo --dry-run
```

### Everyday Usage Mode

For using Pegasus as a CLI from any directory:

```sh
pipx install /path/to/pegasus-ia-bootstrap
pegasus-harness-bootstrap --project-name demo --dry-run
```

## Desired CLI Capabilities

| Capability | Expected Behavior |
|---|---|
| New workspace setup | Create Pegasus harness files in the default or explicit target path. |
| Existing project setup | Add Pegasus harness files to an existing project without touching app code. |
| Missing target path confirmation | If the requested target path does not exist, report it and require explicit confirmation before creating it. |
| Workspace uninstall | Remove Pegasus-managed workspace files, then attempt to remove directories that become empty. If a directory remains non-empty, leave it in place and report it. |
| Global Copilot install | Install/update managed global Copilot assets and settings entries with backup. |
| Global Copilot uninstall | Remove Pegasus-managed global assets and Copilot settings entries with backup. |
| Dry-run | Show creates, updates, conflicts, removals, settings changes, and backups without writing. |
| Target path display | Always show the exact target path before writes so the user can catch mistakes before execution. |

## Success Criteria

- A contributor can activate `.venv`, install the project editable, and run `pegasus-harness-bootstrap` without a path prefix.
- A user can install the CLI with `pipx` and run it from any directory.
- The CLI can add Pegasus to a new workspace.
- The CLI can add Pegasus to an existing workspace without touching unrelated code.
- The CLI asks for explicit confirmation before creating a missing target path in non-dry-run mode.
- Workspace setup writes an install manifest that records the Pegasus-managed files installed in that workspace.
- The CLI can dry-run and perform workspace uninstall by removing Pegasus-installed files, then removing empty Pegasus directories or reporting directories left non-empty.
- The CLI can dry-run and perform global VS Code/Copilot uninstall by removing Pegasus-managed global assets and Pegasus-managed settings entries while preserving unrelated settings.
- Tests cover install planning, existing-project setup, workspace uninstall, global uninstall, settings backup/merge/removal, target path reporting, and installable entry point usage.
- Documentation explains development mode and everyday usage mode.

## Edge Cases

- Target workspace already has `.github/` files unrelated to Pegasus.
- Target workspace already has older Pegasus-managed files.
- Target workspace has mixed Pegasus and user-managed files in the same directories.
- Target workspace path does not exist yet.
- A newer Pegasus version has a different template inventory than the version originally installed in the target workspace.
- `AGENTS.md` contains both Pegasus-managed content and user/other-tool content.
- VS Code `settings.json` does not exist.
- VS Code `settings.json` contains invalid JSON.
- Copilot settings keys contain both Pegasus and non-Pegasus paths.
- Pegasus global managed assets are missing but settings still reference them.
- User passes a target path outside the default root; Pegasus still respects the explicit path and prints it clearly before writing.

## Decisions

- Pegasus will write an install manifest during workspace setup and use it as the uninstall source of truth for that project.
- The workspace install manifest will live inside the target project at `.pegasus-bootstrap-ia/manifest.json`. The user decides whether to commit it, ignore it with `.gitignore`, or keep it local via `.git/info/exclude`.
- Shared files such as `AGENTS.md` should use Pegasus content markers, for example `<!-- pegasus-harness:start -->` and `<!-- pegasus-harness:end -->`, so uninstall removes only the Pegasus-managed block and leaves other tool/user content intact.
- Pegasus should support iterative PRD-to-verify work cycles as named changes, inspired by OpenSpec: active work lives under a change-specific path, and completed/approved work can be archived so it becomes part of the project knowledge history.
- Pegasus should prefer marker-managed writes for generated workspace files. For shared files, uninstall removes only the Pegasus marker block. For Pegasus-owned files, uninstall may remove the full file when the file contains only Pegasus-managed content; if content remains after marker removal, leave the file and report it.
- Generic generated agent/prompt filenames should be prefixed with `pegasus-` to reduce collisions and make ownership obvious.
- Change-cycle source templates should live inside the Pegasus package/template directory, not as `_template` files inside the user's project.
- The target project should receive real change artifacts only when a change is created.
- The Pegasus orchestrator may guide users in natural language and, when terminal execution tools are available, invoke the Pegasus CLI to create a new change cycle after the user agrees to use the Pegasus PRD/SDD flow for that request. The user should not need to understand or approve the internal CLI command separately.
- New change cycles will be created with `--new-change <change-id>` plus `--target-path <project>`.
- New change creation will infer project metadata from `.pegasus-bootstrap-ia/manifest.json`; `--project-name` is not required once the harness is installed in the target project.
- `--project-name` is required only for initial workspace setup when Pegasus does not yet have a workspace manifest. Once `.pegasus-bootstrap-ia/manifest.json` exists, change-cycle commands such as `--new-change <change-id> --target-path <project>` must infer project metadata from the manifest instead of asking for `--project-name` again.
- Pegasus allows multiple active changes. Each change owns its own PRD-to-verify lifecycle under `docs/pegasus/changes/<change-id>/`.
- During a VS Code/Copilot session, the orchestrator should preserve the current active `change-id` in its working context and continue that change without involving the user in internal organization.
- If the orchestrator truly cannot determine the active change after context loss, it should recover from local Pegasus state first. It should ask the user only as a last resort, and phrase it as resuming work, not as an internal storage question.
- `.pegasus-bootstrap-ia/manifest.json` is the workspace install/ownership manifest. It records installed file inventory, Pegasus ownership metadata, workspace metadata, and lifecycle data needed for safe uninstall and future CLI operations.
- `pegasus-memory-mcp` is the operational memory layer. It records active change context, summaries, decisions, status, handoffs, and recovery data when available.
- `docs/pegasus/changes/<change-id>/` contains the file artifacts that remain the source of truth for PRD, proposal, spec, design, tasks, apply-progress, and verify evidence.
- If `pegasus-memory-mcp` is unavailable, Pegasus must warn the user with the exact approved message: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`.
- When MCP memory is unavailable, Pegasus may continue creating or updating file artifacts under `docs/pegasus/changes/<change-id>/`, but it must not claim persistent memory was saved and must not fall back to generated Markdown memory files.

## Workspace File Ownership Review

Before SDD, classify generated workspace files as either full-file owned by Pegasus or marker-managed for coexistence.

| Path | Initial ownership hypothesis | Notes |
|---|---|---|
| `.github/copilot-instructions.md` | Marker-managed candidate | Existing projects may already have Copilot instructions. |
| `.github/instructions/pegasus-workflow.instructions.md` | Full-file owned candidate | Pegasus-specific filename. |
| `.github/instructions/pegasus-memory.instructions.md` | Full-file owned candidate | Pegasus-specific filename. |
| `.github/instructions/pegasus-sdd-boundaries.instructions.md` | Full-file owned candidate | Pegasus-specific filename. |
| `.github/instructions/pegasus-local-first.instructions.md` | Full-file owned candidate | Pegasus-specific filename. |
| `.github/instructions/pegasus-legacy-compatibility.instructions.md` | Full-file owned candidate | Pegasus-specific filename. |
| `.github/prompts/sdd-phases.prompt.md` | Full-file owned candidate | Generic-ish name, but under prompt file. Could be prefixed later if needed. |
| `.github/prompts/pegasus-handoff.prompt.md` | Full-file owned candidate | Prefixed Pegasus prompt. |
| `.github/prompts/pegasus-memory-update.prompt.md` | Full-file owned candidate | Prefixed Pegasus prompt. |
| `.github/agents/pegasus-orchestrator.agent.md` | Full-file owned candidate | Pegasus-specific filename. |
| `.github/agents/pegasus-doc-designer.agent.md` | Full-file owned candidate | Prefixed Pegasus agent. |
| `.github/agents/sdd-proposal.agent.md` | Full-file owned candidate | Pegasus SDD phase agent. |
| `.github/agents/sdd-spec.agent.md` | Full-file owned candidate | Pegasus SDD phase agent. |
| `.github/agents/sdd-design.agent.md` | Full-file owned candidate | Pegasus SDD phase agent. |
| `.github/agents/sdd-tasks.agent.md` | Full-file owned candidate | Pegasus SDD phase agent. |
| `.github/agents/sdd-apply.agent.md` | Full-file owned candidate | Pegasus SDD phase agent. |
| `.github/agents/sdd-verify.agent.md` | Full-file owned candidate | Pegasus SDD phase agent. |
| `.github/agents/pegasus-session-handoff.agent.md` | Full-file owned candidate | Prefixed Pegasus agent. |
| `.github/agents/pegasus-memory-maintainer.agent.md` | Full-file owned candidate | Prefixed Pegasus agent. |
| `AGENTS.md` | Marker-managed | Common shared agent instruction filename. |
| `docs/pegasus/prd.md` | Full-file owned candidate | Pegasus-specific docs tree. |
| `docs/pegasus/proposal.md` | Full-file owned candidate | Pegasus-specific docs tree. |
| `docs/pegasus/spec.md` | Full-file owned candidate | Pegasus-specific docs tree. |
| `docs/pegasus/design.md` | Full-file owned candidate | Pegasus-specific docs tree. |
| `docs/pegasus/tasks.md` | Full-file owned candidate | Pegasus-specific docs tree. |
| `docs/pegasus/apply-progress.md` | Full-file owned candidate | Pegasus-specific docs tree. |
| `docs/pegasus/verify.md` | Full-file owned candidate | Pegasus-specific docs tree. |
| `docs/pegasus/memory/*` | Historical/non-generated | Deprecated as an active generated backend. New Pegasus installs must not generate Markdown operational memory files. If old files exist, they may remain as historical project files but must not be treated as MCP fallback or co-source. |
| `.cursor/rules/pegasus-workflow.mdc` | Full-file owned candidate | Pegasus-specific filename, legacy compatibility. |
| `.cursor/rules/pegasus-memory.mdc` | Full-file owned candidate | Pegasus-specific filename, legacy compatibility. |
| `.pegasus-bootstrap-ia/manifest.json` | Full-file owned | Install/uninstall manifest. |

## Iterative Change Cycle Model

Pegasus should not force every project into one long-lived `docs/pegasus/prd.md → verify.md` chain. Real usage will have multiple product/change cycles. Each cycle should be separable and reviewable.

Recommended model:

```txt
docs/pegasus/
  changes/
    <change-id>/
      prd.md
      proposal.md
      spec.md
      design.md
      tasks.md
      apply-progress.md
      verify.md
    archive/
      <date>-<change-id>/
        prd.md
        proposal.md
        spec.md
        design.md
        tasks.md
        apply-progress.md
        verify.md
  specs/
    <capability>/
      spec.md
```

| Area | Purpose |
|---|---|
| `docs/pegasus/changes/<change-id>/` | Active PRD-to-verify cycle for one feature/change. |
| `docs/pegasus/changes/archive/<date>-<change-id>/` | Completed change history and evidence. |
| `docs/pegasus/specs/<capability>/spec.md` | Stable functional knowledge accepted from archived changes. |
| MCP operational memory | Cross-change context, active change recovery, decisions, status, task progress summaries, learnings, and handoff when `pegasus-memory-mcp` is available. |

Change files are created from Pegasus package templates when a new change is started. Pegasus should not install a project-local `_template` directory in this first lifecycle implementation.

Markdown files under `docs/pegasus/memory/` are not part of the new generated lifecycle. They are deprecated historical files only, not an active memory backend, not a fallback, and not a co-source of truth.

This keeps Pegasus aligned with the useful OpenSpec concept: changes are temporary workspaces, archives preserve completed work, and stable specs become the functional knowledge of the system.

## Orchestrator-Driven Change Creation

Users should not need to manually remember the CLI for normal workflow operations. The Pegasus orchestrator should recognize natural-language requests such as “start a new feature”, “this is a medium-sized change”, or “let's begin SDD for X”.

Expected flow:

1. The orchestrator determines whether the request is a direct fix or a change cycle.
2. For a change cycle, it asks whether to use the Pegasus PRD/SDD flow when the user has not already requested it.
3. Once the user agrees to the flow, the orchestrator derives or proposes a `change-id` and creates `docs/pegasus/changes/<change-id>/` from packaged templates.
4. If terminal execution is available, it runs the Pegasus CLI internally.
5. If terminal execution is unavailable, it gives the exact command for the user to run manually.
6. After creation, it tells the user which artifact was created first, usually `prd.md`, and asks for the product input/review needed for that phase.

The user-facing approval is approval of the Pegasus PRD/SDD workflow, not approval of an internal CLI implementation detail. The orchestrator should not expose CLI mechanics unless terminal execution is unavailable or troubleshooting is needed.

## Open Questions

- Should the manifest include a lightweight pointer to the last created change for CLI convenience, while keeping active operational recovery in `pegasus-memory-mcp` when available?

## Approval

- Status: Pending review
- Owner: Sergio
- Approval date: TBD
- Notes: Review this PRD before moving to SDD proposal/spec/design/tasks.
