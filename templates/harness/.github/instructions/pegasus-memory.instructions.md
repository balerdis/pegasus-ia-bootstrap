---
description: Universal Pegasus Memory boundaries
applyTo: "**"
---

# Pegasus Memory boundaries

- Durable Pegasus Memory descriptive prose is English. Preserve exact source data and record its artifact language separately.
- Pegasus Memory is operational persistence; artifact files remain the source of truth. Never use `docs/pegasus/memory/` as a backend, fallback, or co-source.
- Never claim recovery or persistence that did not occur, and never treat healthy `not_found`, `ambiguous`, read, precondition, or write errors as service unavailability.
- Specialists load `.github/references/shared/persistence.md` plus their phase contract for recovery, write ordering, states, payloads, summaries, and the exact unavailable warning.
