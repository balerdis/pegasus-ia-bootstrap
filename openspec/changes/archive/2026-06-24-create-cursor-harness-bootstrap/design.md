# Design: Create Cursor Harness Bootstrap

## Technical Approach

Create a small Python CLI in `/home/serg/ia-scripts/pegasus-ia-bootstrap` that renders a fixed Cursor/Pegasus IA harness into a target workspace. The default path remains workspace-only: documentation/rule/memory files, no business app source, CI, deployment, databases, remotes, commits, or local Git initialization. Optional global Cursor user configuration is added only behind `--install-cursor-global`, with dry-run planning, existing-config backup, and version/checksum safety.

## Architecture Decisions

| Decision | Choice | Alternatives considered | Rationale |
|---|---|---|---|
| Runtime | Python 3 CLI at `bin/pegasus-harness-bootstrap` plus static Markdown templates | Shell CLI; Node package | User approved Python over shell for readability, safer path/file handling, argparse ergonomics, and future growth without introducing third-party dependencies. |
| Python scope | Standard library only (`argparse`, `pathlib`, `datetime`, `re`, `sys`) | External CLI/template libraries | Keeps the bootstrap local-first and dependency-light while still more maintainable than shell for validation, planning, rendering, and writes. |
| Template model | Store files as templates under `templates/harness/` mirroring the initialized harness tree | Inline heredocs in script | Mirrored templates make review safer and reduce accidental business/domain app-code generation. |
| Rendering | Python string replacement for `{{PROJECT_NAME}}`, `{{TARGET_PATH}}`, `{{DATE}}` | Full template engine; shell `sed` | Only a few values are needed; avoiding a template dependency and shell quoting edge cases supports local-first operation. |
| Writes | Build a Python file plan, detect conflicts, then create directories/files with `pathlib` | Write as discovered; shell `cp`/redirection | A plan enables dry-run output, exact conflict reports, and no-overwrite defaults with clearer control flow. |
| Global Cursor config | Add `--install-cursor-global`; default never touches global config | Always install global config | Explicit opt-in protects personal Cursor settings and keeps normal bootstrap scoped to the target workspace. |
| Global config safety | Detect Linux Cursor user rules path, write only known Pegasus files/blocks, and back up before update | Blind overwrite | User-level config is high blast-radius; backup plus marker/checksum supports safe update and rollback. |
| Git | Do not initialize Git at all in this bootstrap | Default or optional `git init` | Repo/business lifecycle is separate from harness configuration and must not be mixed into bootstrap scope. |

## Data Flow

```txt
Python argparse ──→ validate inputs ──→ workspace plan ──→ conflict check
                         │                     │
                         └─ if flag ─────────→ global Cursor plan + backup plan
                                               │
                         dry-run output ◄──────┤
                                               ▼
                         render/write known files ──→ completion summary
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `bin/pegasus-harness-bootstrap` | Create | Python 3 CLI entrypoint, validation, planning, safe writes, output. |
| `templates/harness/AGENTS.md` | Create | Portable agent contract; references local Markdown memory and Pegasus IA workflow only. |
| `templates/harness/.cursor/rules/pegasus-workflow.mdc` | Create | Cursor rule for SDD workflow, memory recovery, and harness-only boundaries. |
| `templates/harness/.cursor/rules/pegasus-memory.mdc` | Create | Cursor rule for reading/updating `docs/pegasus/memory/`. |
| `templates/harness/docs/pegasus/*.md` | Create | Proposal/spec/design/tasks/verify templates for future target work. |
| `templates/harness/docs/pegasus/memory/*.md` | Create | Context, decisions, tasks log, handoff, and learnings templates with read/write policy. |
| `templates/cursor-global/` | Create | Optional global Cursor guidance template with Pegasus marker/checksum metadata. |
| `tests/` | Create | Minimal CLI tests using temporary directories. |

## Interfaces / Contracts

CLI contract:

```txt
pegasus-harness-bootstrap --project-name <name> [--target-path <path>] [--dry-run] [--force] [--install-cursor-global]

Defaults:
  --target-path /var/www/html/personal/<project-name>
  --dry-run false
  --force false
  --install-cursor-global false
```

Behavior:
- Without `--force`, any existing generated-path file is preserved and reported as a conflict; no partial overwrite should occur.
- With `--force`, only known harness paths may be replaced, and overwritten paths must be listed.
- `--dry-run` prints planned creates/overwrites/conflicts and writes nothing.
- Without `--install-cursor-global`, no global Cursor config path is created, read, backed up, or modified.
- With `--install-cursor-global`, detect Linux Cursor user rules/config path in order: `$XDG_CONFIG_HOME/Cursor/User/rules` when `XDG_CONFIG_HOME` exists, otherwise `~/.config/Cursor/User/rules`; if an existing legacy `~/.cursor/rules` is present, report it and prefer the existing path unless an explicit override is introduced later.
- Before changing an existing global config file, create a sibling timestamped `.bak` file. Include a Pegasus-owned marker plus template checksum/version in generated content so updates can distinguish owned content from user content.
- Completion output lists initialized harness paths and tells the user to open the target workspace in Cursor and start from `AGENTS.md`.

Generated public files must avoid references to private tooling or external memory services.

Runtime contract:

```txt
#!/usr/bin/env python3
No third-party Python packages.
Shell is not part of the product implementation.
```

## Template Content Strategy

`AGENTS.md` should define a portable contract: read `docs/pegasus/memory/context.md` first, follow SDD docs in `docs/pegasus/`, update decisions/tasks/learnings/handoff as work progresses, and never assume external services. Cursor rules should be split by concern (`pegasus-workflow.mdc`, `pegasus-memory.mdc`) so Cursor can apply stable, focused guidance. Memory templates must state: when to read, when to write, append/update format, and compacted-session recovery steps.

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit | Path derivation, project name validation, file plan, token rendering | Python functions exercised through CLI behavior or future Python unit tests. |
| Integration | Successful bootstrap, dry-run no writes, conflict blocking, force overwrite reporting | Execute CLI against temp targets; inspect exact tree and content. |
| Integration | Optional global Cursor config planning, backup, update, and dry-run no writes | Use temporary HOME/XDG_CONFIG_HOME to avoid touching real user config. |
| Policy | No business/domain app code, no Git init, and no banned public references | Search generated tree for unexpected paths/terms and assert no `.git/`. |

Shell remains acceptable only as a smoke-test wrapper around the Python CLI, such as `tests/smoke.sh`; product bootstrap behavior belongs in Python.

## Migration / Rollout

No migration required. Rollout is local: run the CLI against a target path. Rollback is deleting generated harness files or restoring pre-existing files that were explicitly overwritten.

## Risks and Tradeoffs

- Python requires a local Python 3 runtime; mitigate with a `#!/usr/bin/env python3` entrypoint and allowing smoke tests to invoke `PYTHON_BIN`.
- Python is more verbose than shell for tiny scripts, but improves readability and safety as validation, planning, and rendering grow.
- Standard-library-only templating is intentionally limited; acceptable because templates are static and token count is small.
- `--force` can destroy user edits; mitigate with explicit reporting and limiting writes to known harness paths.
- Global Cursor path conventions may differ across Cursor versions; mitigate by isolating detection, reporting the chosen path, and testing with temporary Linux HOME/XDG config roots.

## Open Questions

None.
