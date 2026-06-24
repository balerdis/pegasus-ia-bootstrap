# Design: Create Cursor Harness Bootstrap

## Technical Approach

Create a small Python CLI in `/home/serg/ia-scripts/pegasus-ia-bootstrap` that renders a fixed Cursor/Pegasus IA harness into a target workspace. The implementation must use Python 3 standard-library modules only, remain deterministic and offline-capable, and be limited to documentation/rule/memory files. It must not scaffold business/domain application source, CI, deployment, databases, remotes, or commits.

## Architecture Decisions

| Decision | Choice | Alternatives considered | Rationale |
|---|---|---|---|
| Runtime | Python 3 CLI at `bin/pegasus-harness-bootstrap` plus static Markdown templates | Shell CLI; Node package | User approved Python over shell for readability, safer path/file handling, argparse ergonomics, and future growth without introducing third-party dependencies. |
| Python scope | Standard library only (`argparse`, `pathlib`, `datetime`, `re`, `sys`) | External CLI/template libraries | Keeps the bootstrap local-first and dependency-light while still more maintainable than shell for validation, planning, rendering, and writes. |
| Template model | Store files as templates under `templates/harness/` mirroring the initialized harness tree | Inline heredocs in script | Mirrored templates make review safer and reduce accidental business/domain app-code generation. |
| Rendering | Python string replacement for `{{PROJECT_NAME}}`, `{{TARGET_PATH}}`, `{{DATE}}` | Full template engine; shell `sed` | Only a few values are needed; avoiding a template dependency and shell quoting edge cases supports local-first operation. |
| Writes | Build a Python file plan, detect conflicts, then create directories/files with `pathlib` | Write as discovered; shell `cp`/redirection | A plan enables dry-run output, exact conflict reports, and no-overwrite defaults with clearer control flow. |
| Git | Do not initialize Git by default; optional `--init-git` MAY be added later | Always `git init` | Proposal excludes GitHub/remotes/commits; leaving Git optional avoids side effects in existing projects. |

## Data Flow

```txt
Python argparse ──→ validate project/target ──→ build file plan ──→ conflict check
                                                          │
                         dry-run output ◄────────────────┤
                                                          ▼
                         render templates ──→ pathlib writes ──→ completion summary
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
| `tests/` | Create | Minimal CLI tests using temporary directories. |

## Interfaces / Contracts

CLI contract:

```txt
pegasus-harness-bootstrap --project-name <name> [--target-path <path>] [--dry-run] [--force]

Defaults:
  --target-path /var/www/html/personal/<project-name>
  --dry-run false
  --force false
```

Behavior:
- Without `--force`, any existing generated-path file is preserved and reported as a conflict; no partial overwrite should occur.
- With `--force`, only known harness paths may be replaced, and overwritten paths must be listed.
- `--dry-run` prints planned creates/overwrites/conflicts and writes nothing.
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
| Policy | No business/domain app code and no banned public references | Search generated tree for unexpected paths/terms. |

Shell remains acceptable only as a smoke-test wrapper around the Python CLI, such as `tests/smoke.sh`; product bootstrap behavior belongs in Python.

## Migration / Rollout

No migration required. Rollout is local: run the CLI against a target path. Rollback is deleting generated harness files or restoring pre-existing files that were explicitly overwritten.

## Risks and Tradeoffs

- Python requires a local Python 3 runtime; mitigate with a `#!/usr/bin/env python3` entrypoint and allowing smoke tests to invoke `PYTHON_BIN`.
- Python is more verbose than shell for tiny scripts, but improves readability and safety as validation, planning, and rendering grow.
- Standard-library-only templating is intentionally limited; acceptable because templates are static and token count is small.
- `--force` can destroy user edits; mitigate with explicit reporting and limiting writes to known harness paths.

## Open Questions

None.
