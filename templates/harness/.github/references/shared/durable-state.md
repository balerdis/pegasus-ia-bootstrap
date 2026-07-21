# Pegasus Durable State Contract

## Scope And Authority

This manually loaded reference owns durable identity, artifact revision, observation lineage, persistence sequencing, and recovery for migrated phases. Authoritative artifacts own phase truth; Pegasus Memory indexes summaries, blockers, next action, and revisions without overriding artifacts.

## Identity And References

Use stable identity `{project, work_scope, phase?, slice?}` where work scope is `root`, `change:<id>`, or `point:<id>`. Session, attempt, retry, actor, and time are append-only metadata, never key dimensions.

Artifact handles MUST contain a normalized workspace-relative path or durable topic, algorithm `sha256`, and the full SHA-256 content digest. Never accept an absolute path, `..` traversal, a transcribed root, a timestamp, or model-generated root reconstruction as identity or revision. Validate the digest against current authoritative content; stale references block continuation.

For a multi-file revision, sort normalized relative paths lexicographically and encode each UTF-8 line as `<path>\t<sha256>\n`; SHA-256 of those bytes is the manifest revision. This remains stable after workspace relocation.

## Observations And Sequencing

Material discoveries, fixes, decisions, restrictions, and blockers are event-time writes. An observation records stable identity, semantic topic, category, conclusion, evidence digest, revision, and active state. Identical identity plus evidence digest deduplicates or merges without a second active conclusion. A changed conclusion appends a revision with explicit `supersedes`, `resolves`, `related_to`, or `caused_by` append-only lineage.

After artifact readback, write closure-time progress, handoff, phase status, next action, summary, and artifact references. Progress/index records upsert under stable identity while preserving attempt history. Required Memory writes block advancement. If an event-time or closure-time write fails, preserve current artifacts, surface the failure, set truthful `durable_state_written`, and prohibit advancement until explicit recovery succeeds under the same identity. Do not silently retry indefinitely or create Markdown fallback state.

Recovery receives current intent and exact required artifact/topic/status handles from the orchestrator. Read proportionally, reject stale or non-canonical handles, and never continue from a prior response envelope, a visual TODO, or a defensive full-store scan.
