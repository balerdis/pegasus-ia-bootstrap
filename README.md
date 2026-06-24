# Pegasus IA Bootstrap

Local bootstrap tooling for configuring a Pegasus/Cursor harness in a target workspace.

## Usage

The product CLI is implemented in Python for readability and future growth around flags, validation, and templates. It remains executable directly:

```sh
bin/pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp --dry-run
bin/pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp
bin/pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp --install-cursor-global
```

By default, the target workspace path is `/var/www/html/personal/<project-name>`.
Use `--target-path <path>` for an explicit target and `--force` only when replacing known harness files is intended.

Global Cursor user rules are opt-in. A default run only writes the target workspace harness and does not create, read, back up, or modify global Cursor configuration. Use `--install-cursor-global` to install the Pegasus global Cursor rule. On Linux, the CLI writes to `$XDG_CONFIG_HOME/Cursor/User/rules` when `XDG_CONFIG_HOME` is set, otherwise `~/.config/Cursor/User/rules`; an existing legacy `~/.cursor/rules` directory is reported and preferred. Existing global rule files are backed up with a timestamped `.bak` sibling before update. Combine the flag with `--dry-run` to preview global creates, updates, and backups without writing anything.

Run slice verification with:

```sh
bash tests/smoke.sh
```

The initialized target workspace contains only harness files. Pegasus IA does not generate the business/domain MVP; the user or team builds that MVP later inside Cursor using this harness:

```txt
AGENTS.md
.cursor/rules/pegasus-workflow.mdc
.cursor/rules/pegasus-memory.mdc
docs/pegasus/proposal.md
docs/pegasus/spec.md
docs/pegasus/design.md
docs/pegasus/tasks.md
docs/pegasus/verify.md
docs/pegasus/memory/context.md
docs/pegasus/memory/decisions.md
docs/pegasus/memory/tasks-log.md
docs/pegasus/memory/handoff.md
docs/pegasus/memory/learnings.md
```

The smoke wrapper runs the Python CLI with isolated temporary targets and verifies help output, dry-run no-write behavior, full harness structure generation, safe conflict handling, force overwrite reporting, banned public references, and project-name validation.
It also verifies optional global Cursor rule planning/install/update behavior with temporary `HOME` and `XDG_CONFIG_HOME` values so real Cursor configuration is not touched.
