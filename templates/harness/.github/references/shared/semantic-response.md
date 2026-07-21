# Pegasus Semantic Response Contract

## Scope And Authority

This manually loaded reference owns the disposable specialist response semantics for migrated phases. It does not own phase workflow or durable authority.

Return these six fields once, in any order or presentation that preserves their meaning:

- `status`: exactly `success`, `partial`, or `blocked`; describes execution only.
- `executive_summary`: a concise outcome, including any persistence blocker.
- `artifacts`: relative artifact handles and observed SHA-256 revisions, or an empty collection.
- `durable_state_written`: independently `complete`, `partial`, `not-written`, or `not-required`.
- `next_recommended`: the next safe action, never advancement unsupported by durable evidence.
- `risks`: observed blockers and residual risks, or an empty collection.

Validation is semantic and evidence-based. Field order, Markdown layout, headings, and exact prose are not contractual. Missing fields, invalid state-domain values, status conflation, contradictory claims, absolute artifact paths, or unobserved success are invalid.

The response is ephemeral transport. Never persist or use it for continuation, recovery, duplicate detection, authorization, or durable authority. A truthful partial result MAY be delivered after a required persistence failure, but `status` alone never authorizes advancement.
