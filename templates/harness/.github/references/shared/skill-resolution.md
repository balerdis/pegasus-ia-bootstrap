# Pegasus Skill Resolution Contract

## Scope And Authority

This manually loaded reference owns how a Pegasus specialist handles exact skill paths supplied in its invocation context. It does not claim a registry, discovery tool, or skill loader exists.

Before phase work, inspect the invocation for injected exact skill paths and their required/optional status. For each supplied path, read that exact file before using its instructions; do not search for renamed, backup, neighboring, or guessed alternatives.

- Required path missing or unreadable: block before phase work and report the exact path and failure.
- Optional path missing or unreadable: report `failed: <reason>` and use only an explicitly supplied fallback; otherwise continue with canonical Pegasus references and workspace instructions.
- No matching path supplied: report `no-match`; use canonical Pegasus references and workspace instructions without inventing a skill match.

Report `skill_resolution` with each supplied path, required/optional status, load outcome, and fallback outcome. A loaded skill remains subordinate to the current macro and canonical Pegasus references and cannot expand the authorized slice.
