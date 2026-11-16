# Contexto base (automatización): Nacho

Indie developer. Vibe coder:
construyo con asistencia de AI. Prompts directos, sin relleno.

## Cuándo este stack

Python para procesamiento de datos, clasificación, automatización de
tareas, o agentes. FastAPI solo si el output es una API consumida por
un frontend Next.js, o si necesita UI propia consumible. Si el output
es directamente una UI para usuarios finales, eso es un proyecto Next.js
separado (`stack-web` / `AGENTS.md` web). Proyectos que combinan web +
backend de procesamiento son DOS repos separados desde el inicio, no
un monorepo.

## Stack base

```
python >= 3.10
fastapi >= 0.111
uvicorn >= 0.30
pydantic          ← validación y tipado de datos
python-dotenv     ← variables de entorno
pytest            ← tests
```

LLM: el modelo default es el Grok más nuevo. No pines una versión
fija, salvo que Nacho pida otra. OpenAI solo si el proyecto ya está
integrado o hay una razón específica. La API key nunca va al cliente.

Flujo: agente de Cursor en la Mac de Nacho, con el Grok más nuevo.
`/no-test` salvo lógica sensible. Cambio chico a `main` después de
lint. Cambio grande en branch, con PR y el ok de Nacho. Confirmar
antes de tocar producción. `cyp` es commit y push.

Integraciones comunes: Gmail (`google-auth`, `google-auth-oauthlib`,
`google-api-python-client`), adapters MCP propios si aplica.

## Arquitectura: capas + puertos/adaptadores, no MVC

```
proyecto/
  api/              ← HTTP layer (FastAPI endpoints, OAuth, schemas)
  dominio/          ← lógica de negocio pura (sin dependencias externas)
    models.py       ← dataclasses/pydantic models
    workflows/      ← orquestación de casos de uso
    agents/         ← integración con LLM
  infra/            ← adapters concretos
    gmail/
      base.py       ← interfaz abstracta (GmailClient)
      memory.py     ← adapter in-memory (tests, dry-run)
      api.py        ← adapter real (Gmail API OAuth)
      mcp.py        ← adapter MCP si aplica
  prompts/          ← archivos .txt con prompts del LLM
  tests/
  scripts/          ← mantenimiento/migración
```

El dominio no importa de `infra/`. Los adapters se inyectan en
runtime. Interfaces abstractas para todo lo externo (Gmail, LLM,
storage), con al menos un adapter in-memory para tests.

## Patrones fijos

**Dry-run mode siempre** en cualquier automatización que escribe o
muta datos:

```python
def assert_live_mode():
    if current_mode == RuntimeMode.DRY_RUN:
        raise RuntimeError("Operación bloqueada en dry-run")
```

**Fallback conservador en LLM**: si falla la llamada al modelo o
falta la API key, el workflow clasifica como `Review` (o equivalente).
No fallar silenciosamente con una clasificación incorrecta.

**Logging de acciones en JSONL**: cada acción que muta estado se
loguea con timestamp, tipo de acción y metadata relevante. El schema
de `actions.jsonl` tiene que estar definido ANTES de construir
cualquier UI que lo consuma. Si el schema cambia, la UI se rompe
silenciosamente. Es el bug más común en estos proyectos.

**Estado mínimo en archivos locales** para proyectos personales/v1:
JSON para estado persistido, JSONL para logs. Sin DB salvo que la
escala lo justifique.

## UI opcional

NiceGUI para prototipo rápido (Python puro, sin build step) si hace
falta un dashboard de observabilidad local. Módulo separado (`web/`),
con estado independiente del backend, sin mezclar lógica de dominio
con la UI. Next.js si la UI es para usuarios finales (proyecto
separado).

## Variables de entorno

`requirements.txt` con todas las dependencias. NiceGUI no está ahí
por defecto en proyectos generados con AI, verificar antes de
compartir o deployar. `.env.example` con todas las variables sin
valores. `python-dotenv` cargado en el `__init__.py` del módulo
principal. No sobreescribe variables ya definidas en el sistema (en
producción/CI, las del entorno del sistema tienen precedencia).

Nunca al repo: `ANTHROPIC_API_KEY`/`OPENAI_API_KEY`,
`GOOGLE_CLIENT_SECRET`/`GOOGLE_CLIENT_ID`, cualquier token OAuth.
`credentials.json`/`token.json` en `.gitignore` desde el inicio.

## Convenciones

TypeScript strict no aplica acá, pero el equivalente sí: sin `dict`
crudo como input de endpoints FastAPI. Pydantic tipado hace la
validación automáticamente. Un archivo = una responsabilidad. Pytest
para lógica de dominio y workflows. Los adapters in-memory existen
precisamente para poder testear sin dependencias externas. Sin
comentarios obvios.

OAuth con Google en callbacks separados (login/callback en distintas
instancias del Flow) puede requerir deshabilitar PKCE explícitamente.

## Antes de arrancar cualquier tarea

Anunciar qué recursos se van a usar:
> "Para esto voy a usar: `[skill]`"

Cursor es el único agente. Ejecuta: lee el repo, sigue las skills
en `.cursor/skills/`, edita archivos. No armes prompts para pegar
en otro lado.

## Memoria del proyecto

`PROJECT_MEMORY.md` es el estado vivo de este
proyecto. Al arrancar cada sesión, leerlo primero. Prestar especial
atención al schema de `actions.jsonl` y qué adapters están activos
(memory vs real). Es lo más fácil de perder de vista entre sesiones.

Si está vacío. Antes de hacer cualquier otra cosa, preguntarle a Nacho:
> "PROJECT_MEMORY.md está vacío. Contame el problema que resuelve
> esta automatización y qué está construido hasta ahora."

Después de un cambio significativo, actualizarlo.

## Recommended tools

`react-doctor` y el MCP de Figma no aplican a este stack (sin capa
de React ni UI que implementar desde diseño).

## Flujos de trabajo

Leé y seguí `.cursor/skills/<nombre>/SKILL.md`, y ejecutá.

**Auditoría del proyecto** → skill `project-auditor`.

**Antes de hacer público o deployar** → skill `deploy-checker`.

**Idea cruda / spec** → `product-discovery` y `feature-spec`. No
código de producto hasta que haya spec.
