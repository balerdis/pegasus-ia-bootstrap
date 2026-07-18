# SDD Apply Phase Contract

## Scope And Authority

This manually loaded phase reference owns the detailed `sdd-apply` workflow. It is subordinate to the current macro, authoritative over shared references for Apply-specific behavior, and does not authorize a slice or delivery strategy.

## Input Contract

Require approved `docs/pegasus/changes/<change-id>/spec.md` and `docs/pegasus/changes/<change-id>/design.md`, `docs/pegasus/changes/<change-id>/tasks.md` identifying the approved next slice, and existing or creatable `docs/pegasus/changes/<change-id>/apply-progress.md`. The macro's exactly-one-slice and resolved-strategy gates remain mandatory.

## Required Reads

Before implementation edits, read `.github/copilot-instructions.md`, `.github/instructions/pegasus-sdd-boundaries.instructions.md`, the four current-change files above, relevant recovered MCP task progress when memory is available, and implementation files for the authorized slice. If a required input, approval, identity, or gate is unclear, return blocked before writing.

## Duplicate And Execution Rules

Check MCP task progress and apply-progress before editing; when memory is unavailable, record that the MCP side of the check could not run. Record the approved slice source and duplicate-check result. If the slice is already in progress, stop and report recovery options. If complete, return control for Verify or the next approved slice. Otherwise implement no more than the single authorized slice.

Run focused checks appropriate to the slice and label all Apply evidence preliminary; preliminary apply evidence does not replace verification. Do not self-declare final acceptance, invoke Verify, or skip the verification handoff.

## Progress Updates

Merge, rather than replace, implementation progress. Update only the authorized implementation slice; its truthful task status; and apply-progress fields for slice source, duplicate check, current/completed work, changed files, preliminary commands/results, per-slice verification status, blockers, risks, and next action. Update MCP task progress when state changes and memory is healthy. Optional preliminary notes may be appended to `verify.md` without a final verdict.

## Stop And Return

Preserve prior changed files, blockers, deviations, progress, and verification notes unless explicitly superseded. Stop after the authorized slice and progress updates, then return control for distinct fresh-context `sdd-verify` or the next approved slice.
