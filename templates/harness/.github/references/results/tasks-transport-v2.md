# Tasks Result Transport V2

## Scope And Authority

This manually loaded transport reference exclusively owns Tasks v2 canonical JSON serialization bytes, slash encoding, digest calculation, decoded path validation, revision freeze, and transport rejection rules. It does not own field names/order/values, phase workflow, or orchestrator routing.

Serialize the result schema as exactly one UTF-8 JSON object line with no BOM and keys in schema order. Use no insignificant whitespace. Every value is a string and uses strict JSON escaping. Encode every literal `/` in every string as lowercase `\u002f`; raw `/` and `\/` are forbidden. Reject malformed escapes, lone surrogates, duplicate, unknown, missing, or reordered keys, and non-string values.

Compute `Specialist result block revision` as lowercase SHA-256 over the exact UTF-8 bytes of the single serialized JSON line plus exactly one final LF. Exclude both delimiters and the revision line from the digest. Insert that digest, then freeze the complete four-line block. Do not reconstruct, reserialize, normalize, summarize, or mutate any byte afterward.

Decode JSON strictly and require `schema` to equal `pegasus-specialist-result/v2`. Decode `artifact_path` and validate exact equality with the canonical path constructed as `docs/pegasus/changes/` + supplied current change ID + `/tasks.md` and with the separately supplied output path. Reject short, absolute, alternate-change, non-canonical, or tool-derived paths.

Reject an invalid digest, non-canonical reserialization, any raw slash, malformed Unicode/JSON, key-set/order/type violation, legacy or mixed delimiters, missing or extra lines, multiple blocks, any envelope field outside the block, narrative substitution, and any post-freeze or post-persistence mutation. The final revision is immutable: exact decoded `post_persistence_edits` value `none` is required for completion, and final/persistence task revisions MUST remain equal. On rejection, return a truthful blocked canonical v2 block when one can be safely formed; never emit a partially trusted block, ask for strategy, or authorize/launch Apply.
