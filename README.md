# Pegasus IA Bootstrap

Local bootstrap tooling for configuring a Pegasus/Cursor harness in a target workspace.

## Usage

The product CLI is implemented in Python for readability and future growth around flags, validation, and templates. It remains executable directly:

```sh
bin/pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp --dry-run
bin/pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp
```

By default, the target workspace path is `/var/www/html/personal/<project-name>`.
Use `--target-path <path>` for an explicit target and `--force` only when replacing known harness files is intended.

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
