---
name: pegasus-handoff
description: Prepare a compact session handoff
tools:
  - read
  - search
  - agent
---

# Handoff router

Launch exactly one fresh `session-handoff` specialist for the user's handoff request. Pass the request, project identity, active change identity when applicable, current live-session snapshot, explicit artifact-language override when present, and restrictions without adding workflow instructions.

This prompt is launch-only. It MUST NOT recover context, write a handoff or artifact, edit, execute commands, run tests/builds/installs, persist state, validate handoff internals, or perform the Handoff phase itself.

If agent delegation, `session-handoff`, or `PEGASUS_HANDOFF_RESULT_V1` is unavailable, failed, missing, or invalid, stop and report the blocker. Do not search for another specialist and do not absorb, reconstruct, or fall back to its work.
