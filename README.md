# Pegasus Harness Bootstrap 0.6.2

Herramienta local de inicialización para configurar un harness de Pegasus orientado a VS Code/Copilot en un workspace de destino. El workspace generado contiene guías, plantillas SDD, recursos de Copilot y archivos secundarios de compatibilidad heredada con Cursor; no genera código de aplicación, metadatos de Git, CI, despliegues ni recursos remotos.

## Inicio rápido

```sh
python -m venv .venv
source .venv/bin/activate
pip install -e .
pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp --dry-run
pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp
```

Para consultar en cualquier momento la versión instalada del producto:

```sh
pegasus-harness-bootstrap --version
# Pegasus Harness Bootstrap 0.6.2
```

Para el uso cotidiano fuera de este checkout, instale la CLI con `pipx`:

```sh
pipx install /path/to/pegasus-ia-bootstrap
pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp --dry-run
```

De forma predeterminada, la ruta del workspace de destino es `/var/www/html/personal/<project-name>`.
Use `--target-path <path>` para indicar un destino explícito. En un workspace de Pegasus existente (con `.pegasus-bootstrap-ia/manifest.json`), la inicialización normal se niega a reemplazar su manifiesto de ciclo de vida. Actualice los archivos administrados de forma segura ejecutando primero `--sync-workspace --dry-run` y luego `--sync-workspace`; el proyecto se infiere del manifiesto. La sincronización informa la versión instalada de la CLI, la versión de la plantilla de origen y la versión del manifiesto del workspace. Use `--force` únicamente para un reemplazo completo, agresivo e intencional, ya que puede sobrescribir personalizaciones y conflictos de archivos administrados.

Si una inicialización interrumpida anteriormente dejó un manifiesto válido con registros de propiedad vacíos, la sincronización recupera únicamente los archivos de texto actuales administrados por el harness que tengan su marcador exacto de Pegasus (ruta y modo de propiedad). Nunca adopta `docs/pegasus/**`, artefactos de cambios, `.vscode/mcp.json` ni archivos sin marcador.

Después de una ejecución correcta, abra el workspace de destino en VS Code con GitHub Copilot y comience desde el agente personalizado del orquestador de Pegasus ubicado en `.github/agents/pegasus-orchestrator.agent.md`.

La versión 0.6.2 preserva la delegación obligatoria y refuerza el límite del coordinador: `sdd-design` escribe, valida y persiste el diseño, mientras el orquestador reproduce completo el sobre de resultados devuelto antes de solicitar aprobación. Además, cada riesgo aprobado de la propuesta debe quedar cubierto por el diseño y por una prueba o medición aplicable. El diseño sigue usando inglés salvo que el usuario nombre explícitamente otro idioma para ese artefacto.

## Idioma del producto y de los artefactos

La conversación con el usuario, este README y los mensajes públicos localizados pueden estar en español. En cambio, los prompts, las instrucciones, la comunicación interna entre agentes, la prosa descriptiva persistente de Pegasus Memory y los artefactos generados usan inglés de forma predeterminada. El idioma de un artefacto generado cambia únicamente cuando el usuario indica de manera explícita el idioma para ese artefacto; no se infiere del idioma del chat, la persona, el código fuente dominante ni artefactos anteriores.

## Estructura del workspace generado

```txt
.github/copilot-instructions.md
.github/instructions/pegasus-workflow.instructions.md
.github/instructions/pegasus-memory.instructions.md
.github/instructions/pegasus-sdd-boundaries.instructions.md
.github/instructions/pegasus-local-first.instructions.md
.github/instructions/pegasus-legacy-compatibility.instructions.md
.github/prompts/sdd-phases.prompt.md
.github/prompts/handoff.prompt.md
.github/prompts/memory-update.prompt.md
.github/agents/pegasus-orchestrator.agent.md
.github/agents/sdd-proposal.agent.md
.github/agents/sdd-spec.agent.md
.github/agents/sdd-design.agent.md
.github/agents/sdd-tasks.agent.md
.github/agents/sdd-apply.agent.md
.github/agents/sdd-verify.agent.md
.github/agents/session-handoff.agent.md
.github/agents/memory-maintainer.agent.md
.github/agents/doc-designer.agent.md
.vscode/mcp.json
AGENTS.md
docs/pegasus/prd.md
docs/pegasus/proposal.md
docs/pegasus/spec.md
docs/pegasus/design.md
docs/pegasus/tasks.md
docs/pegasus/apply-progress.md
docs/pegasus/verify.md
.cursor/rules/pegasus-workflow.mdc
.cursor/rules/pegasus-memory.mdc
```

El árbol `.github/` es la superficie de control principal y nativa de Copilot. `.vscode/mcp.json` configura Pegasus Memory MCP como servidor stdio del workspace. `AGENTS.md` conserva una guía portable para los agentes que no leen archivos específicos de Copilot. `.cursor/` se mantiene únicamente como compatibilidad heredada secundaria y remite a los recursos de VS Code/Copilot. La memoria operativa prioriza MCP; la inicialización no genera un backend de memoria en Markdown.

## Configuración predeterminada de Pegasus Memory MCP

La configuración de memoria del workspace está activada de forma predeterminada. Una ejecución normal de la inicialización resuelve `pegasus-memory-mcp`, genera `.vscode/mcp.json` e indica a VS Code que inicie el servidor MCP desde la raíz MCP resuelta con:

```json
{"servers":{"pegasus-memory-mcp":{"command":"node","cwd":"/absolute/path","args":["/absolute/path/dist/bin/pegasus-memory-mcp.js"]}}}
```

Use `--install-memory-mcp` cuando desee que el plan identifique explícitamente la misma configuración predeterminada de memoria del workspace. La CLI resuelve el script MCP compilado en este orden:

1. `pegasus-memory-mcp` o `pegasus-memory-mcp.js` en `PATH`.
2. `/home/serg/ia-scripts/pegasus-memory-mcp/dist/bin/pegasus-memory-mcp.js`.
3. Alternativa de clonación y compilación desde la rama `stable/0.1.1` de `https://github.com/balerdis/pegasus-memory-mcp.git`.

Si no se puede preparar MCP, la inicialización mantiene disponible la configuración del harness basada únicamente en archivos e imprime exactamente:

```txt
El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente
```

La guía generada exige que los agentes invoquen `health` de MCP antes de la primera recuperación o persistencia y usen `health.capabilities.parent_bootstrap` cuando esté disponible. Si la recuperación devuelve `not_found` con `project_not_found`, los agentes invocan `ensure_project` antes de registrar observaciones, artefactos, progreso de tareas o handoffs. Al crear un cambio o PRD nuevo en `docs/pegasus/changes/<change-id>/`, los agentes invocan `ensure_change` antes de `record_artifact` o de observaciones asociadas al cambio. De forma predeterminada, la guía generada usa el payload mínimo compatible de `ensure_change`: `project_id` y `change_id`; agregue los campos planos opcionales `key`, `title`, `status` o `description` solo cuando sean necesarios. Para clasificar, use `kind` únicamente cuando sea necesario; nunca envíe `type` ni envíe `kind` y `type` juntos, aunque sus valores coincidan. Las decisiones y preguntas del PRD, así como los resúmenes de artefactos, se registran con `record_observation` o `record_artifact`, no como metadatos arbitrarios de `ensure_change`. Si MCP no está disponible, los agentes no deben afirmar que la persistencia en memoria fue correcta ni recurrir a `docs/pegasus/memory/`.

De forma predeterminada, Pegasus Memory MCP almacena su base de datos en `~/.local/share/pegasus-memory-mcp/memory.db`. La sincronización del workspace puede actualizar el `.vscode/mcp.json` generado y las referencias al binario o la configuración de Pegasus Memory cuando los checksums del manifiesto demuestran que es seguro, pero no elimina, vuelve a crear, restablece ni sobrescribe la base de datos MCP. Solo Pegasus Memory puede modificar esa base de datos para una migración explícita de esquema cuando detecta o incluye una versión de esquema más reciente. Si la instalación o compilación local falla después de `npm ci` y `npm config get ignore-scripts` devuelve `true`, vuelva a compilar la dependencia nativa de SQLite con:

```sh
npm_config_ignore_scripts=false npm rebuild better-sqlite3 --foreground-scripts
```

## Desinstalación segura y limpieza de memoria

Use la desinstalación del workspace para eliminar únicamente los recursos del harness administrados por Pegasus que figuran en el manifiesto de instalación:

```sh
pegasus-harness-bootstrap --uninstall --target-path /path/to/workspace --dry-run
pegasus-harness-bootstrap --uninstall --target-path /path/to/workspace
```

La desinstalación conserva los artefactos de `docs/pegasus/**`, como PRD, propuestas, especificaciones, diseños, tareas, notas de apply, notas de verificación y carpetas de cambios. También conserva los archivos creados por el usuario que no son propiedad del manifiesto o que no contienen marcadores de propiedad de Pegasus.

La limpieza de memoria es explícita y se delega a la CLI oficial de Pegasus Memory; una desinstalación simple nunca elimina datos de Pegasus Memory:

```sh
pegasus-harness-bootstrap --uninstall --target-path /path/to/workspace --reset-memory-project
pegasus-harness-bootstrap --uninstall --target-path /path/to/workspace --purge-memory
```

`--reset-memory-project` ejecuta `pegasus-memory-mcp reset --project <project-name> --yes`; `--purge-memory` ejecuta `pegasus-memory-mcp purge --all --yes-i-understand-this-deletes-data`. Con `--dry-run`, Pegasus IA imprime el comando delegado con `--dry-run` y no invoca la CLI externa. Las dos opciones de memoria son mutuamente excluyentes. Si `pegasus-memory-mcp` no está disponible para una solicitud real de limpieza, Pegasus IA falla de forma explícita y no elimina directamente las rutas de memoria.

De forma predeterminada, la delegación de limpieza de memoria se resuelve en este orden:

1. `pegasus-memory-mcp` en `PATH`.
2. El servidor `pegasus-memory-mcp` definido en `.vscode/mcp.json` del workspace de destino, cuando describe de forma segura la estructura generada para VS Code (`command: "node"`, `args: [".../dist/bin/pegasus-memory-mcp.js"]`, `cwd` opcional).

Use `--memory-cli-command <command-or-js-entrypoint>` para reemplazar explícitamente el descubrimiento. Las rutas o nombres ejecutables se invocan directamente; las rutas `.js` se invocan como `node <path>`.

Esto permite usar workspaces donde VS Code inicia Pegasus Memory MCP mediante `node` y la ruta de un script compilado, en lugar de una CLI global. La salida de dry-run incluye el comando delegado resuelto y el cwd cuando se utiliza uno.

Si falta el manifiesto del workspace, la desinstalación simple del workspace falla porque Pegasus IA no puede demostrar cuáles archivos le pertenecen. `--uninstall --purge-memory` es la única ruta de limpieza sin manifiesto: omite la eliminación de archivos del workspace, informa que los recursos administrados no pueden planificarse de forma segura y delega únicamente el comando de purga global de Pegasus Memory.

## Instalación global opcional de VS Code/Copilot

La configuración global o a nivel de usuario de Copilot es opcional y nunca se ejecuta de forma predeterminada:

```sh
pegasus-harness-bootstrap \
  --project-name gestor-solicitudes-mvp \
  --install-copilot-global \
  --vscode-target stable
```

Use `--vscode-target insiders` para seleccionar VS Code Insiders en lugar de Stable. En Linux, la CLI respeta `XDG_CONFIG_HOME`; de lo contrario, usa `~/.config`.

| Destino | Ruta de configuración |
|---|---|
| Stable | `$XDG_CONFIG_HOME/Code/User/settings.json` o `~/.config/Code/User/settings.json` |
| Insiders | `$XDG_CONFIG_HOME/Code - Insiders/User/settings.json` o `~/.config/Code - Insiders/User/settings.json` |

El comando copia los recursos de Copilot administrados por Pegasus en `$XDG_CONFIG_HOME/pegasus-ia/copilot/{agents,instructions,prompts}/` o `~/.config/pegasus-ia/copilot/{agents,instructions,prompts}/` y luego integra esas ubicaciones en:

- `chat.agentFilesLocations`
- `chat.instructionsFilesLocations`
- `chat.promptFilesLocations`

La configuración existente se conserva. Si existe el `settings.json` seleccionado, primero se crea a su lado una copia de seguridad `.bak` con marca de tiempo. Un JSON de configuración no válido provoca un fallo antes de escribir en el workspace, los recursos administrados, la copia de seguridad o la configuración.

Agregue `--dry-run` para obtener una vista previa de los archivos del workspace, los recursos globales, las rutas de configuración de VS Code y los planes de copia de seguridad sin escribir nada.

## Compatibilidad heredada con Cursor

La compatibilidad con Cursor se mantiene como opción heredada:

```sh
pegasus-harness-bootstrap --project-name gestor-solicitudes-mvp --install-cursor-global
```

Una ejecución predeterminada no crea, lee, respalda ni modifica la configuración global de Cursor. Use `--install-cursor-global` solo cuando necesite la regla global heredada de Cursor. En Linux, la CLI escribe en `$XDG_CONFIG_HOME/Cursor/User/rules` cuando `XDG_CONFIG_HOME` está definido; de lo contrario, escribe en `~/.config/Cursor/User/rules`. Si existe el directorio heredado `~/.cursor/rules`, se informa y se le da prioridad. Antes de actualizar, se crea junto a cada archivo de reglas globales existente una copia de seguridad `.bak` con marca de tiempo.

## Verificación

Ejecute la verificación smoke con:

```sh
bash tests/smoke.sh
```

El wrapper smoke ejecuta la CLI de Python con destinos temporales aislados y verifica la salida de ayuda, que dry-run no escriba archivos, la generación de una estructura orientada a Copilot, la generación de la configuración stdio de MCP, la guía de recuperación y persistencia condicionada por `health`, la ausencia de una alternativa de memoria en Markdown, el orquestador y los agentes secundarios, la exclusión de agentes revisores, el manejo seguro de conflictos, el informe de sobrescrituras forzadas, las referencias públicas prohibidas, la redacción condicional de compatibilidad heredada con Cursor, la ausencia de creación de `.git` y la validación del nombre del proyecto.

También verifica el comportamiento opcional de dry-run, instalación y actualización global de Copilot para Stable e Insiders con valores temporales de `HOME` y `XDG_CONFIG_HOME`, incluidas las copias de seguridad de configuración y su integración no destructiva. La planificación, instalación y actualización global heredada de Cursor se cubren con rutas temporales aisladas para no modificar la configuración real del usuario.
