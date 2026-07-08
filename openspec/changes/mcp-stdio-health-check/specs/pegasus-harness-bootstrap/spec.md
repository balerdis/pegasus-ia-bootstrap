# Delta for Pegasus Harness Bootstrap

## MODIFIED Requirements

### Requirement: MCP-first operational memory

The generated harness MUST use the `pegasus-memory-mcp` MCP tool contract as the operational memory interface for recovery, search, persistence, and availability checks. It MUST configure memory by default, MUST support `--install-memory-mcp` as the explicit install/config flag, MUST resolve the executable from PATH first and then the default local install path, and MUST generate VS Code workspace stdio config that launches `node` with the absolute built script path. It MUST NOT require users or agents to write operational memory to `docs/pegasus/memory/`, and it MUST NOT depend on MCP server internals, SQLite details, database paths, or source modules.
(Previously: MCP-only guidance did not define default install/config, PATH fallback, or VS Code stdio launch wiring.)

#### Scenario: Session starts with memory available

- GIVEN `pegasus-memory-mcp` is available on PATH or at the default local path
- WHEN the bootstrap writes workspace harness files
- THEN it emits VS Code `.vscode/mcp.json` stdio config for `node` and the built script path
- AND it uses the resolved executable for memory availability checks

#### Scenario: Missing install falls back to clone/build

- GIVEN `pegasus-memory-mcp` is absent from PATH and the default local path
- WHEN bootstrap reaches memory setup
- THEN it warns and attempts GitHub clone/install/build into the default local location
- AND normal bootstrap flow remains default-on

### Requirement: Memory unavailable behavior

The generated harness MUST call `health` before the first recovery or save attempt and MUST detect unavailable memory before relying on persistence. If `pegasus-memory-mcp` is unavailable, the user-facing warning MUST be exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Pegasus MAY continue project/change artifact work, but it MUST NOT claim persistent memory was saved and MUST NOT fall back to Markdown memory. It MUST distinguish `not_found`, `ambiguous`, `read_error`, and `persistence_error` from true unavailability.
(Previously: unavailability handling did not require a health probe or distinguish consumer states.)

#### Scenario: MCP missing or unreachable

- GIVEN MCP memory is missing, not executable, not on PATH, or health fails
- WHEN Pegasus needs persistent memory
- THEN it shows the exact approved warning
- AND persistent memory saves are treated as unavailable

#### Scenario: Recoverable states stay distinct

- GIVEN MCP is running and recovery returns `not_found` or `ambiguous`
- WHEN the consumer handles context
- THEN it reports the recoverable state rather than unavailable memory
- AND it does not show the approved warning

#### Scenario: Read and persistence errors are not availability failures

- GIVEN MCP is running and a read or write fails
- WHEN the consumer handles persistence
- THEN it surfaces `read_error` or `persistence_error`
- AND it does not collapse the failure into unavailable memory

### Requirement: Manifest-owned lifecycle metadata

The manifest `.pegasus-bootstrap-ia/manifest.json` MUST record install, ownership, update, uninstall, and workspace metadata only. It MUST NOT store operational memory, active-change pointers, recovery state, or any Markdown-memory backend data.
(Previously: manifest metadata existed, but operational-memory exclusion was not explicit.)

#### Scenario: Manifest supports uninstall

- GIVEN a successful workspace setup
- WHEN the manifest is inspected
- THEN it records Pegasus-managed ownership for uninstall
- AND it contains no operational memory or active-change pointer
