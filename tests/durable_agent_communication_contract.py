#!/usr/bin/env python3
"""Dependency-free semantic contract probes for durable agent communication."""

from __future__ import annotations

import argparse
import hashlib
import tempfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath


FIELDS = {"status", "executive_summary", "artifacts", "durable_state_written", "next_recommended", "risks"}


def valid_handle(workspace: Path, relative: str, digest: str) -> bool:
    path = PurePosixPath(relative)
    if path.is_absolute() or ".." in path.parts or not relative or len(digest) != 64:
        return False
    candidate = workspace.joinpath(*path.parts)
    return candidate.is_file() and hashlib.sha256(candidate.read_bytes()).hexdigest() == digest


def valid_response(value: dict[str, object]) -> bool:
    return (
        set(value) == FIELDS
        and value["status"] in {"success", "partial", "blocked"}
        and value["durable_state_written"] in {"complete", "partial", "not-written", "not-required"}
        and bool(value["executive_summary"])
    )


def advancement_allowed(response: dict[str, object], current_evidence: bool) -> bool:
    return valid_response(response) and current_evidence and response["durable_state_written"] in {"complete", "not-required"}


@dataclass(frozen=True)
class Observation:
    identity: str
    topic: str
    conclusion: str
    evidence_digest: str
    revision: int
    supersedes: int | None = None


def persist_observation(history: list[Observation], candidate: Observation) -> list[Observation]:
    active = next((item for item in reversed(history) if item.identity == candidate.identity and item.topic == candidate.topic), None)
    if active and active.evidence_digest == candidate.evidence_digest and active.conclusion == candidate.conclusion:
        return history
    if active:
        candidate = Observation(candidate.identity, candidate.topic, candidate.conclusion,
                                candidate.evidence_digest, active.revision + 1, active.revision)
    return [*history, candidate]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--phase", default="prd")
    args = parser.parse_args()
    if args.phase != "prd":
        raise SystemExit(f"phase not migrated yet: {args.phase}")

    with tempfile.TemporaryDirectory(prefix="durable-state-") as name:
        first = Path(name) / "one"
        second = Path(name) / "elsewhere" / "two"
        relative = "docs/pegasus/prd.md"
        first.joinpath(relative).parent.mkdir(parents=True)
        first.joinpath(relative).write_text("durable PRD\n")
        digest = hashlib.sha256(first.joinpath(relative).read_bytes()).hexdigest()
        assert valid_handle(first, relative, digest)
        assert not valid_handle(first, str(first / relative), digest)
        assert not valid_handle(first, "../prd.md", digest)
        assert not valid_handle(first, relative, "0" * 64)
        second.joinpath(relative).parent.mkdir(parents=True)
        second.joinpath(relative).write_bytes(first.joinpath(relative).read_bytes())
        assert valid_handle(second, relative, digest)

    response = {
        "risks": [], "next_recommended": "human PRD review", "artifacts": [relative],
        "executive_summary": "PRD updated and durable evidence accepted.",
        "durable_state_written": "complete", "status": "success",
    }
    assert valid_response(response)  # Ordering and Markdown presentation are irrelevant.
    assert not valid_response(response | {"status": "completed"})
    partial = response | {"status": "partial", "durable_state_written": "not-written", "risks": ["event write failed"]}
    assert valid_response(partial) and not advancement_allowed(partial, True)
    assert not advancement_allowed(response, False)  # A response is never continuation evidence.
    assert advancement_allowed(response, True)

    history: list[Observation] = []
    original = Observation("project:prd:root", "product-decision", "guided", "a" * 64, 1)
    history = persist_observation(history, original)
    assert persist_observation(history, original) == history
    history = persist_observation(history, Observation(original.identity, original.topic, "free", "b" * 64, 1))
    assert len(history) == 2 and history[-1].revision == 2 and history[-1].supersedes == 1

    print("Durable PRD semantic probes passed: handles, response, failures, relocation, lineage.")


if __name__ == "__main__":
    main()
