#!/usr/bin/env python3
"""Deterministic contract probes for the root PRD lifecycle runtime boundary."""

from __future__ import annotations

import json
import os
import secrets
import subprocess
import sys
import tempfile
from pathlib import Path


def require(content: str, *needles: str) -> None:
    for needle in needles:
        assert needle in content, needle


DISPATCHABLE = {"not-started", "awaiting-input", "draft-refinement"}


def dispatch_allowed(
    project: str | None,
    launch: str | None,
    duplicate: str | None,
    evidence: str | None,
) -> bool:
    return bool(
        project and launch == f"{project}:prd:root"
        and duplicate in DISPATCHABLE and evidence
    )


def specialist_actions(
    manifest_project: str,
    payload_project: str | None,
    payload_launch: str | None,
    lifecycle: str,
    material_gaps: list[str],
    mutation: bool = True,
) -> tuple[str, list[str], list[str]]:
    identity_matches = (
        payload_project == manifest_project
        and payload_launch == f"{manifest_project}:prd:root"
    )
    if not identity_matches:
        return "blocked-identity", [], []
    if lifecycle not in DISPATCHABLE:
        return "blocked-duplicate", [], []
    if material_gaps:
        return "awaiting-input", [], material_gaps
    if not mutation:
        return "read-only", ["persistence:not-needed:zero-mutation"], []
    return "drafted", [
        "edit:docs/pegasus/prd.md",
        f"ensure_project:{manifest_project}",
        f"record_artifact:{manifest_project}:refresh",
        f"record_observation:{manifest_project}:merge",
    ], []


def valid_prd_result(
    payload_project: str,
    payload_launch: str,
    result_project: str,
    result_launch: str,
    duplicate_state: str | None,
    duplicate_evidence: str | None,
    mutated: bool,
    persistence: str,
) -> bool:
    identity_ok = (
        result_project == payload_project
        and result_launch == payload_launch
        and result_launch != "root PRD"
    )
    duplicate_ok = duplicate_state in DISPATCHABLE and bool(duplicate_evidence)
    persistence_ok = (
        "record_artifact:succeeded" in persistence
        and "record_observation:succeeded" in persistence
    ) if mutated else "not-needed:zero-mutation" in persistence
    return identity_ok and duplicate_ok and persistence_ok


def valid_orchestrator_output(output: str) -> bool:
    return output.count("PEGASUS_ORCHESTRATOR_RESULT_V1") == 1 and all(
        field in output for field in (
            "Status:", "Launch identity:", "Duplicate launch gate:",
            "Specialist result validation:", "Coordinator fallback work: none",
            "Next action:",
        )
    )


def contains_material_decision(value: object, key: str = "") -> bool:
    if "material" in key.lower() and bool(value):
        return True
    if isinstance(value, dict):
        return any(contains_material_decision(item, str(name)) for name, item in value.items())
    if isinstance(value, list):
        return any(contains_material_decision(item) for item in value)
    return isinstance(value, str) and "material decision" in value.lower()


def semantically_valid_prd_envelope(result: dict[str, object]) -> bool:
    discovery = result["discovery_outcome"]
    assert isinstance(discovery, dict)
    if not contains_material_decision(result):
        return True
    persistence = result["persistence"]
    assert isinstance(persistence, dict)
    return (
        result["status"] == "blocked"
        and discovery.get("state") == "awaiting-input"
        and bool(discovery.get("questions"))
        and result["artifact_validation"] == "artifact edit not run: awaiting product input"
        and all(value == "not needed: awaiting product input" for value in persistence.values())
        and "product input" in str(result["next_action"]).lower()
        and "approval" not in str(result["next_action"]).lower()
    )


def orchestrator_prd_boundary(result: dict[str, object]) -> str:
    if not semantically_valid_prd_envelope(result):
        return "Status: blocked\nSpecialist result validation: blocked: contradictory PRD envelope\nNext action: correct or replace the invalid specialist result"
    return "Status: completed-boundary\nSpecialist result validation: passed\nNext action: human PRD review"


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    token = secrets.token_hex(8)
    project = f"fixture-{token}"
    product = f"Atlas-{secrets.token_hex(7)}"
    assert project not in product and product not in project

    with tempfile.TemporaryDirectory(prefix="pegasus-prd-contract-") as temp_name:
        target = Path(temp_name) / "workspace-unrelated-to-identities"
        env = os.environ | {
            "PEGASUS_MEMORY_MCP_SKIP_INSTALL": "1",
            "PEGASUS_MEMORY_MCP_ROOT": str(Path(temp_name) / "memory"),
        }
        result = subprocess.run(
            [sys.executable, str(root / "bin/pegasus-harness-bootstrap"),
             "--project-name", project, "--target-path", str(target)],
            input="yes\n", text=True, capture_output=True, env=env, cwd=root,
        )
        assert result.returncode == 0, result.stderr

        manifest = json.loads((target / ".pegasus-bootstrap-ia/manifest.json").read_text())
        canonical = manifest["workspace"]["project_name"]
        assert canonical == project
        launch = f"{canonical}:prd:root"

        routing = (target / ".github/references/orchestration/routing.md").read_text()
        specialist = (target / ".github/agents/doc-designer.agent.md").read_text()
        phase = (target / ".github/references/phases/prd.md").read_text()
        prd_result = (target / ".github/references/results/prd-result-v1.md").read_text()
        orchestrator_result = (target / ".github/references/results/orchestrator-result-v1.md").read_text()

        persistence = (target / ".github/references/shared/persistence.md").read_text()

        require(routing, "`workspace.project_name` as the canonical project key",
                "Every root PRD launch uses `<canonical-project-key>:prd:root`",
                "explicit `project_key` and `launch_identity` payload fields",
                "`awaiting-input`", "`draft-refinement`", "`approved/completed`",
                "`ambiguous/stale/contradictory`", "do not authorize Proposal")
        require(specialist, "explicit payload fields `project_key` and `launch_identity`",
                "aliased identity/authorization blocks")
        require(phase, "Before any artifact edit or persistence",
                "return a blocked awaiting-input result",
                "NEVER call `ensure_change` for root PRD",
                "creation or material refinement",
                "do not invent questions and proceed")
        require(persistence, "durable mutation to a previously recorded artifact invalidates",
                "Edit size and file-only scope do not make persistence unnecessary")
        require(prd_result, "compatible blocked-state specialization",
                 "artifact edit not run: awaiting product input",
                 "explicit `project_key`", "refresh after mutation",
                 "Cross-field invariant", "unresolved material decision",
                 "envelope containing either side of that contradiction is invalid")
        require(routing, "cross-field invariant, not field presence alone",
                "Any invalid PRD result makes the orchestrator outcome `blocked`",
                "never request approval")
        require(orchestrator_result, "Launch identity: <project:prd:root|change:phase[:slice]|not established>",
                "valid PRD awaiting-input result is surfaced as `blocked`",
                "prose-only output is invalid")
        assert "git diff" not in phase.lower()

        assert not dispatch_allowed(None, None, None, None)
        assert not dispatch_allowed(canonical, None, "not-started", "template")
        assert not dispatch_allowed(canonical, launch, None, "template")
        assert not dispatch_allowed(canonical, launch, "not-started", None)
        for blocked in ("in-progress", "approved/completed", "ambiguous/stale/contradictory"):
            assert not dispatch_allowed(canonical, launch, blocked, "observed")
        for allowed in DISPATCHABLE:
            assert dispatch_allowed(canonical, launch, allowed, f"observed:{allowed}")

        invented = product.lower()
        state, writes, questions = specialist_actions(
            canonical, invented, f"{invented}:prd:root", "not-started", []
        )
        assert (state, writes, questions) == ("blocked-identity", [], [])
        state, writes, questions = specialist_actions(
            canonical, canonical, None, "not-started", []
        )
        assert (state, writes, questions) == ("blocked-identity", [], [])
        state, writes, questions = specialist_actions(
            canonical, canonical, "root PRD", "draft-refinement", []
        )
        assert (state, writes, questions) == ("blocked-identity", [], [])

        gaps = ["Which moons are included?", "Guided or free default?", "What reading level?"]
        state, writes, questions = specialist_actions(
            canonical, canonical, launch, "not-started", gaps
        )
        assert state == "awaiting-input" and writes == [] and questions == gaps

        state, writes, questions = specialist_actions(
            canonical, canonical, launch, "awaiting-input", []
        )
        assert state == "drafted" and not questions
        assert writes == ["edit:docs/pegasus/prd.md", f"ensure_project:{canonical}",
                          f"record_artifact:{canonical}:refresh",
                          f"record_observation:{canonical}:merge"]
        assert all(product.lower() not in write for write in writes)
        assert not any("ensure_change" in write for write in writes)

        state, writes, _ = specialist_actions(
            canonical, canonical, launch, "draft-refinement", []
        )
        assert state == "drafted" and writes[-2:] == [
            f"record_artifact:{canonical}:refresh",
            f"record_observation:{canonical}:merge",
        ]
        state, writes, _ = specialist_actions(
            canonical, canonical, launch, "awaiting-input", [], mutation=False
        )
        assert (state, writes) == ("read-only", ["persistence:not-needed:zero-mutation"])

        succeeded = "record_artifact:succeeded record_observation:succeeded"
        assert valid_prd_result(canonical, launch, canonical, launch,
                                "draft-refinement", "draft plus user request", True, succeeded)
        assert not valid_prd_result(canonical, launch, canonical, "root PRD",
                                    "draft-refinement", "draft plus user request", True, succeeded)
        assert not valid_prd_result(canonical, launch, canonical, f"{canonical}:prd:other",
                                    "draft-refinement", "draft plus user request", True, succeeded)
        assert not valid_prd_result(canonical, launch, canonical, launch,
                                    None, None, True, succeeded)
        assert not valid_prd_result(canonical, launch, canonical, launch,
                                    "draft-refinement", "draft plus user request", True,
                                    "persistence:not-needed:file-only edit")
        assert valid_prd_result(canonical, launch, canonical, launch,
                                "awaiting-input", "unresolved questions", False,
                                "persistence:not-needed:zero-mutation")

        unresolved = [
            "Which celestial bodies are included in the first release?",
            "Is the default experience guided or freely explorable?",
            "What reading level should explanatory content target?",
            "Which facts require citations or editorial review?",
            "What measurable outcome determines launch success?",
        ]
        contradictory_result = {
            "status": "completed",
            "specialist": "doc-designer",
            "request_and_artifact": {
                "project_key": canonical,
                "launch_identity": launch,
                "path": "docs/pegasus/prd.md",
            },
            "discovery_outcome": {
                "state": "drafted",
                "material_ambiguities": unresolved,
                "questions": [],
            },
            "artifact_validation": "artifact edited and readback passed",
            "approval_state": "Draft; ready for human review",
            "persistence": {
                "ensure_project": "succeeded",
                "ensure_change": "not needed: root PRD",
                "record_artifact": "succeeded",
                "record_observation": "succeeded",
            },
            "skill_resolution": "no-match",
            "blockers_risks": unresolved,
            "next_action": "Approve the Draft PRD",
        }
        assert not semantically_valid_prd_envelope(contradictory_result)
        blocked_boundary = orchestrator_prd_boundary(contradictory_result)
        assert "Status: blocked" in blocked_boundary
        assert "Specialist result validation: blocked" in blocked_boundary
        assert "approval" not in blocked_boundary.lower()

        awaiting_input_result = contradictory_result | {
            "status": "blocked",
            "discovery_outcome": {
                "state": "awaiting-input",
                "material_ambiguities": unresolved,
                "questions": unresolved,
            },
            "artifact_validation": "artifact edit not run: awaiting product input",
            "approval_state": "not evaluated: awaiting product input",
            "persistence": {
                operation: "not needed: awaiting product input"
                for operation in contradictory_result["persistence"]
            },
            "next_action": "Provide the requested product input",
        }
        assert semantically_valid_prd_envelope(awaiting_input_result)

        completed_result = contradictory_result | {
            "discovery_outcome": {
                "state": "drafted",
                "material_ambiguities": [],
                "questions": [],
            },
            "blockers_risks": "none",
        }
        assert semantically_valid_prd_envelope(completed_result)

        material_risk_result = completed_result | {
            "blockers_risks": {
                "material_decisions": ["Which launch outcome is required?"]
            },
        }
        assert not semantically_valid_prd_envelope(material_risk_result)
        assert "Status: blocked" in orchestrator_prd_boundary(material_risk_result)

        non_material_blocked_result = completed_result | {
            "status": "blocked",
            "blockers_risks": ["Editorial review service is temporarily unavailable"],
            "next_action": "Retry editorial validation",
        }
        assert semantically_valid_prd_envelope(non_material_blocked_result)

        prose_only = "The PRD was updated and remains Draft."
        assert not valid_orchestrator_output(prose_only)
        envelope = "\n".join((
            "PEGASUS_ORCHESTRATOR_RESULT_V1", "Status: completed-boundary",
            f"Launch identity: {launch}",
            "Duplicate launch gate: passed: draft-refinement; draft plus user request",
            "Specialist result validation: passed", "Coordinator fallback work: none",
            "Next action: human PRD review",
        ))
        assert valid_orchestrator_output(envelope)
        assert "Proposal" not in envelope

    print("PRD runtime contract probes passed.")


if __name__ == "__main__":
    main()
