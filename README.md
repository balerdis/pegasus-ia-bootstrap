# Pegasus Harness Bootstrap 0.4.1

Local bootstrap tooling for configuring a Pegasus VS Code/Copilot-first harness in a target workspace. The generated workspace contains guidance, SDD templates, Copilot assets, and secondary legacy Cursor compatibility files; it does not scaffold app code, Git metadata, CI, deployment, or remote resources.

## Quick path

```sh
python -m venv .venv
source .venv/bin/activate
pip install -e .
pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp --dry-run
pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp
```

Check the installed product release at any time:

```sh
pegasus-harness-bootstrap --version
# Pegasus Harness Bootstrap 0.4.1
```

For everyday use from outside this checkout, install the CLI with `pipx`:

```sh
pipx install /path/to/pegasus-ia-bootstrap
pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp --dry-run
```

By default, the target workspace path is `/var/www/html/personal/<project-name>`.
Use `--target-path <path>` for an explicit target. For an existing Pegasus workspace (one with `.pegasus-bootstrap-ia/manifest.json`), normal bootstrap refuses to replace its lifecycle manifest. Update managed files safely with `--sync-workspace --dry-run` first, then `--sync-workspace`; the project is inferred from the manifest. Sync reports the installed CLI version, source template version, and workspace manifest version. Use `--force` only for intentional aggressive full replacement because it may overwrite managed-file customizations and conflicts.

If a historical interrupted bootstrap left a valid manifest with empty ownership records, sync recovers only current managed harness text files with their exact Pegasus marker (path and ownership mode). It never adopts `docs/pegasus/**`, change artifacts, `.vscode/mcp.json`, or unmarked files.

After a successful run, open the target workspace in VS Code with GitHub Copilot and start from the Pegasus orchestrator custom agent at `.github/agents/pegasus-orchestrator.agent.md`.

## Generated workspace layout

```txt
.github/copilot-instructions.md
.github/instructions/pegasus-workflow.instructions.md
.github/instructions/pegasus-memory.instructions.md
.github/instructions/pegasus-sdd-boundaries.instructions.md
.github/instructions/pegasus-local-first.instructions.md
.github/instructions/pegasus-legacy-compatibility.instructions.md
.github/prompts/sdd-phases.prompt.md
.github/prompts/handoff.prompt.md
.github/prompts/memory-update.prompt.md
.github/agents/pegasus-orchestrator.agent.md
.github/agents/sdd-proposal.agent.md
.github/agents/sdd-spec.agent.md
.github/agents/sdd-design.agent.md
.github/agents/sdd-tasks.agent.md
.github/agents/sdd-apply.agent.md
.github/agents/sdd-verify.agent.md
.github/agents/session-handoff.agent.md
.github/agents/memory-maintainer.agent.md
.github/agents/doc-designer.agent.md
.vscode/mcp.json
AGENTS.md
docs/pegasus/prd.md
docs/pegasus/proposal.md
docs/pegasus/spec.md
docs/pegasus/design.md
docs/pegasus/tasks.md
docs/pegasus/apply-progress.md
docs/pegasus/verify.md
.cursor/rules/pegasus-workflow.mdc
.cursor/rules/pegasus-memory.mdc
```

The `.github/` tree is the primary Copilot-native control surface. `.vscode/mcp.json` configures Pegasus Memory MCP as a workspace stdio server. `AGENTS.md` remains portable guidance for agents that do not read Copilot-specific files. `.cursor/` is retained only as secondary legacy compatibility and points back to the VS Code/Copilot assets. Operational memory is MCP-first; the bootstrap does not generate a Markdown memory backend.

## Default Pegasus Memory MCP setup

Workspace memory setup is default-on. A normal bootstrap run resolves `pegasus-memory-mcp`, renders `.vscode/mcp.json`, and tells VS Code to launch the MCP server from the resolved MCP root with:

```json
{"servers":{"pegasus-memory-mcp":{"command":"node","cwd":"/absolute/path","args":["/absolute/path/dist/bin/pegasus-memory-mcp.js"]}}}
```

Use `--install-memory-mcp` when you want the plan to label the same default workspace memory setup explicitly. The CLI resolves the built MCP script in this order:

1. `pegasus-memory-mcp` or `pegasus-memory-mcp.js` on `PATH`.
2. `/home/serg/ia-scripts/pegasus-memory-mcp/dist/bin/pegasus-memory-mcp.js`.
3. Clone/build fallback from `https://github.com/balerdis/pegasus-memory-mcp.git` branch `stable/0.1.1`.

If MCP cannot be prepared, the bootstrap keeps file-only harness setup available and prints exactly:

```txt
El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente
```

Generated guidance requires agents to call MCP `health` before the first recovery or save and use `health.capabilities.parent_bootstrap` when available. If recovery returns `not_found` with `project_not_found`, agents call `ensure_project` before recording observations, artifacts, task progress, or handoffs. When creating a new change/PRD under `docs/pegasus/changes/<change-id>/`, agents call `ensure_change` before `record_artifact` or change-scoped observations. Generated guidance uses the minimal compatible `ensure_change` payload by default: `project_id` and `change_id`; add optional flat `key`, `title`, `status`, or `description` only when needed. For classification, use `kind` only when needed; never send `type`, and never send both `kind` and `type`, even if their values match. PRD decisions, questions, and artifact summaries are recorded with `record_observation` or `record_artifact`, not as arbitrary `ensure_change` metadata. If MCP is unavailable, agents must not claim persistent-memory saves succeeded and must not fall back to `docs/pegasus/memory/`.

Pegasus Memory MCP stores its database at `~/.local/share/pegasus-memory-mcp/memory.db` by default. Workspace sync may update the generated `.vscode/mcp.json` and Pegasus Memory binary/config references when manifest checksums prove it is safe, but it does not delete, recreate, reset, or overwrite the MCP database. Only Pegasus Memory itself may mutate that database for an explicit schema migration when it detects or ships a newer schema version. If local install/build fails after `npm ci` and `npm config get ignore-scripts` returns `true`, rebuild the native SQLite dependency with:

```sh
npm_config_ignore_scripts=false npm rebuild better-sqlite3 --foreground-scripts
```

## Safe uninstall and memory cleanup

Use workspace uninstall to remove only Pegasus-managed harness assets recorded in the install manifest:

```sh
pegasus-harness-bootstrap --uninstall --target-path /path/to/workspace --dry-run
pegasus-harness-bootstrap --uninstall --target-path /path/to/workspace
```

The uninstall preserves `docs/pegasus/**` artifacts such as PRDs, proposals, specs, designs, tasks, apply notes, verification notes, and change folders. It also preserves user-created files that are not manifest-owned or do not carry Pegasus ownership markers.

Memory cleanup is explicit and delegated to the official Pegasus Memory CLI; plain uninstall never deletes Pegasus Memory data:

```sh
pegasus-harness-bootstrap --uninstall --target-path /path/to/workspace --reset-memory-project
pegasus-harness-bootstrap --uninstall --target-path /path/to/workspace --purge-memory
```

`--reset-memory-project` runs `pegasus-memory-mcp reset --project <project-name> --yes`; `--purge-memory` runs `pegasus-memory-mcp purge --all --yes-i-understand-this-deletes-data`. With `--dry-run`, Pegasus IA prints the delegated command with `--dry-run` and does not call the external CLI. The two memory flags are mutually exclusive. If `pegasus-memory-mcp` is unavailable for a real cleanup request, Pegasus IA fails clearly and does not delete memory paths directly.

By default, memory cleanup delegation resolves in this order:

1. `pegasus-memory-mcp` on `PATH`.
2. The target workspace `.vscode/mcp.json` server named `pegasus-memory-mcp` when it safely describes the generated VS Code shape (`command: "node"`, `args: [".../dist/bin/pegasus-memory-mcp.js"]`, optional `cwd`).

Use `--memory-cli-command <command-or-js-entrypoint>` to override discovery explicitly. Executable paths/names are called directly; `.js` paths are called as `node <path>`.

This supports workspaces where VS Code launches Pegasus Memory MCP through `node` and a built script path rather than a global CLI. Dry-run output includes the resolved delegated command and cwd when one is used.

If the workspace manifest is missing, plain workspace uninstall still fails because Pegasus IA cannot prove which workspace files it owns. `--uninstall --purge-memory` is the only no-manifest cleanup path: it skips workspace file removal, reports that managed workspace assets cannot be planned safely, and delegates only the global Pegasus Memory purge command.

## Optional global VS Code/Copilot install

Global/user-level Copilot setup is opt-in and never runs by default:

```sh
pegasus-harness-bootstrap \
  --project-name gestor-solicitudes-mvp \
  --install-copilot-global \
  --vscode-target stable
```

Use `--vscode-target insiders` to target VS Code Insiders instead of Stable. On Linux, the CLI respects `XDG_CONFIG_HOME`; otherwise it uses `~/.config`.

| Target | Settings path |
|---|---|
| Stable | `$XDG_CONFIG_HOME/Code/User/settings.json` or `~/.config/Code/User/settings.json` |
| Insiders | `$XDG_CONFIG_HOME/Code - Insiders/User/settings.json` or `~/.config/Code - Insiders/User/settings.json` |

The command copies Pegasus-managed Copilot assets under `$XDG_CONFIG_HOME/pegasus-ia/copilot/{agents,instructions,prompts}/` or `~/.config/pegasus-ia/copilot/{agents,instructions,prompts}/`, then merges these locations into:

- `chat.agentFilesLocations`
- `chat.instructionsFilesLocations`
- `chat.promptFilesLocations`

Existing settings are preserved. If the selected `settings.json` exists, it is backed up first with a timestamped `.bak` sibling. Invalid settings JSON fails before workspace, managed asset, backup, or settings writes.

Add `--dry-run` to preview workspace files, global assets, VS Code settings paths, and backup plans without writing anything.

## Legacy Cursor support

Cursor support remains available as legacy compatibility:

```sh
pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp --install-cursor-global
```

A default run does not create, read, back up, or modify global Cursor configuration. Use `--install-cursor-global` only when you need the legacy Cursor global rule. On Linux, the CLI writes to `$XDG_CONFIG_HOME/Cursor/User/rules` when `XDG_CONFIG_HOME` is set, otherwise `~/.config/Cursor/User/rules`; an existing legacy `~/.cursor/rules` directory is reported and preferred. Existing global rule files are backed up with a timestamped `.bak` sibling before update.

## Verification

Run smoke verification with:

```sh
bash tests/smoke.sh
```

The smoke wrapper runs the Python CLI with isolated temporary targets and verifies help output, dry-run no-write behavior, Copilot-first structure generation, MCP stdio config rendering, `health`-gated recovery/save guidance, no Markdown memory fallback, orchestrator and secondary agents, excluded reviewer agents, safe conflict handling, force overwrite reporting, banned public references, conditional legacy Cursor wording, no `.git` creation, and project-name validation.

It also verifies optional global Copilot dry-run/install/update behavior for Stable and Insiders with temporary `HOME` and `XDG_CONFIG_HOME` values, including settings backups and non-destructive settings merge. Legacy Cursor global planning/install/update behavior is covered with isolated temporary paths so real user configuration is not touched.
