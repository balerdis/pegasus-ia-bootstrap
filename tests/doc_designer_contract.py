#!/usr/bin/env python3
"""Direct contract probes for the doc-designer PRD specialist boundary."""

from __future__ import annotations

from pathlib import Path


def require(content: str, *needles: str) -> None:
    for needle in needles:
        assert needle in content, needle


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    agent = (root / "templates/harness/.github/agents/doc-designer.agent.md").read_text()
    phase = (root / "templates/harness/.github/references/phases/prd.md").read_text()

    require(
        agent,
        "execution-specific compact launch brief",
        ".github/references/phases/prd.md",
        "Do not reconstruct architecture",
    )
    assert "references/orchestration/routing.md" not in agent
    assert "references manually in exact order" not in agent

    gate = phase.index("## Material-Gap Gate")
    persistence = phase.index("## Durable Drafting And Return")
    assert gate < persistence
    gap_section = phase[gate:persistence]
    require(
        gap_section,
        "one concise grouped round of product questions",
        "`blocked`",
        "zero artifact edits",
        "zero `ensure_project`",
        "zero artifact, observation, handoff, or task-progress records",
        "zero approval request or advancement",
        "fresh launch",
    )
    assert "Pegasus Memory `health`" not in gap_section

    # This is a direct-specialist contract. Router behavior belongs to R6/R7.
    assert "router" not in phase.lower()
    print("Doc-designer contract probes passed: direct material-gap block and compact boundary.")


if __name__ == "__main__":
    main()
