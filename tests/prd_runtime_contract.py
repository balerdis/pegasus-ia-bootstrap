#!/usr/bin/env python3
"""Runtime contract probe for the vertically migrated PRD slice."""

from __future__ import annotations

import os
import subprocess
import sys
import tempfile
from pathlib import Path


def require(content: str, *needles: str) -> None:
    for needle in needles:
        assert needle in content, needle


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="pegasus-prd-runtime-") as temporary:
        temp = Path(temporary)
        target = temp / "relocated" / "workspace"
        env = os.environ | {
            "PEGASUS_MEMORY_MCP_SKIP_INSTALL": "1",
            "PEGASUS_MEMORY_MCP_ROOT": str(temp / "memory"),
        }
        result = subprocess.run(
            [sys.executable, str(root / "bin/pegasus-harness-bootstrap"),
             "--project-name", "runtime-project", "--target-path", str(target)],
            input="yes\n", text=True, capture_output=True, cwd=root, env=env,
        )
        assert result.returncode == 0, result.stderr

        github = target / ".github"
        agent = (github / "agents/doc-designer.agent.md").read_text()
        phase = (github / "references/phases/prd.md").read_text()
        semantic = (github / "references/shared/semantic-response.md").read_text()
        durable = (github / "references/shared/durable-state.md").read_text()

        require(agent, "execution-specific compact launch brief", "phases/prd.md", "Do not reconstruct architecture")
        assert "prd-result-v1.md" not in agent
        assert "PEGASUS_PRD_RESULT_V1" not in agent
        assert not (github / "references/results/prd-result-v1.md").exists()

        require(phase, "relative path", "SHA-256", "event-time", "closure-time",
                "one concise grouped round of product questions", "zero artifact edits")
        require(semantic, "`status`", "`executive_summary`", "`artifacts`",
                "`durable_state_written`", "`next_recommended`", "`risks`")
        require(durable, "append-only lineage", "supersedes", "evidence digest",
                "Required Memory writes block advancement")

        audit = subprocess.run(
            [sys.executable, str(root / "tests/audit_instruction_architecture.py"),
             "--root", str(root), "--static-only"],
            text=True, capture_output=True, cwd=root,
        )
        assert audit.returncode == 0, audit.stdout + audit.stderr

    print("PRD runtime contract probes passed: bootstrap relocation and generated equivalence.")


if __name__ == "__main__":
    main()
