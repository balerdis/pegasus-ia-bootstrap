---
name: pegasus-memory-update
description: Record Pegasus operational memory through MCP
tools:
  - read
  - search
  - agent
---

# Memory maintenance router

Launch exactly one fresh `memory-maintainer` specialist for the user's explicit maintenance request. Pass the request, project identity, active change identity when applicable, exact operation, exact source facts or record identities, and restrictions without adding maintenance instructions.

This prompt is launch-only. It MUST NOT recover context, write records or artifacts, edit, execute commands, run tests/builds/installs, persist state, validate maintenance internals, or perform Memory Maintenance itself.

If agent delegation, `memory-maintainer`, or `PEGASUS_MEMORY_MAINTENANCE_RESULT_V1` is unavailable, failed, missing, or invalid, stop and report the blocker. Do not search for another specialist and do not absorb, reconstruct, or fall back to its work.
