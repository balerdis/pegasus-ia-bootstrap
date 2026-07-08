# Pegasus Memory MCP — Ready for Pegasus Bootstrap Integration

Use this file in the next `pegasus-ia-bootstrap` session.

## Context

`pegasus-memory-mcp` is now available and ready to be consumed by `pegasus-ia-bootstrap`.

Repository:

- Local: `/home/serg/ia-scripts/pegasus-memory-mcp`
- GitHub: `https://github.com/balerdis/pegasus-memory-mcp`
- Stable branch: `stable/0.1.0`
- Testing branch: `testing`
- Latest integration commit: `5b2aee8 feat: agrega contrato de disponibilidad mcp`

The change was implemented, verified, archived, committed, and pushed.

## What is now available

`pegasus-memory-mcp` now exposes a side-effect-free MCP tool:

- `health`

The `health` tool is intended for availability checks by installers/bootstrap flows.

It confirms the MCP server process is operational without writing memory or performing deep diagnostic side effects.

## Consumer state contract

Pegasus Bootstrap should distinguish these cases:

1. **MCP process/tool unavailable**
   - The MCP process cannot be launched, the tool cannot be called, or the MCP server is not configured.
   - This is detected out-of-band by the caller/bootstrap, not from a successful `health` response.
   - In this case Pegasus must show exactly:

   ```txt
   El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente
   ```

2. **MCP available but no recoverable context**
   - MCP is running, but recovery returns `not_found`.
   - This means memory is available, but there is no prior context for the requested project/change.

3. **MCP available but recovery is ambiguous**
   - MCP is running, but recovery returns `ambiguous` with candidate context choices.
   - The consuming agent/bootstrap may ask one concise clarification if needed.

4. **Real persistence/read error**
   - MCP is running, but a read operation fails with `read_error`.
   - Write failures are surfaced as `persistence_error`.
   - Validation/programmer errors should not be hidden as persistence/read errors.

## VS Code MCP stdio setup

`pegasus-memory-mcp` is a stdio MCP server.

The README in `/home/serg/ia-scripts/pegasus-memory-mcp/README.md` now documents VS Code `mcp.json` setup.

Expected runtime:

- command: `node`
- args: absolute path to built script, e.g. `/home/serg/ia-scripts/pegasus-memory-mcp/dist/bin/pegasus-memory-mcp.js`
- optional DB override via:
  - `PEGASUS_MEMORY_DB_PATH`
  - or CLI `--db <path>`

Default DB path:

```txt
~/.local/share/pegasus-memory-mcp/memory.db
```

## Important local environment gotcha

On this machine, npm may have:

```bash
npm config get ignore-scripts
```

returning:

```txt
true
```

If so, after `npm ci`, rebuild `better-sqlite3` with scripts enabled:

```bash
npm_config_ignore_scripts=false npm rebuild better-sqlite3 --foreground-scripts
```

Without that, SQLite-dependent tests/runtime may fail because native bindings were not built.

## What Pegasus Bootstrap should do next

In the next `pegasus-ia-bootstrap` session, start from this objective:

> Integrate Pegasus Bootstrap with the already-available `pegasus-memory-mcp` availability contract.

Suggested SDD prompt:

```txt
Quiero integrar `pegasus-ia-bootstrap` con el `pegasus-memory-mcp` ya disponible.

Contexto:
- `pegasus-memory-mcp` está implementado y publicado en `stable/0.1.0`.
- Último commit relevante: `5b2aee8 feat: agrega contrato de disponibilidad mcp`.
- Expone tool MCP side-effect-free `health`.
- README documenta VS Code `mcp.json` para stdio.
- Default DB path: `~/.local/share/pegasus-memory-mcp/memory.db`.
- Si MCP no está disponible, Pegasus debe mostrar exactamente:
  `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`

Objetivo:
Actualizar el bootstrap/installer de Pegasus IA para:
1. verificar disponibilidad de `pegasus-memory-mcp`;
2. instalarlo o indicar/configurar su instalación según el contrato ya definido;
3. generar/configurar `.vscode/mcp.json` para stdio auto-launch;
4. usar `health` como probe de disponibilidad;
5. distinguir MCP no disponible, memoria vacía, recuperación ambigua y errores reales;
6. actualizar guidance del orchestrator para chequear disponibilidad antes del primer recovery/save;
7. mantener el fallback exacto cuando MCP no esté disponible.

Usá SDD. Primero exploración/proposal. No implementes hasta aprobar proposal/spec/design/tasks.
```

## Source of truth

For the `pegasus-memory-mcp` side, source of truth is now:

- `README.md`
- `openspec/specs/context-recovery/spec.md`
- `openspec/specs/operational-memory-core/spec.md`
- archived change: `openspec/changes/archive/2026-07-08-availability-contract/`
