# Contexto base (automatización) — Nacho

@PROJECT_MEMORY.md

Indie developer. Vibe coder:
construyo con asistencia de AI. Prompts directos, sin relleno.

## Cuándo este stack

Python para procesamiento de datos, clasificación, automatización de
tareas, o agentes. FastAPI solo si el output es una API consumida por
un frontend Next.js, o si necesita UI propia consumible. Si el output
es directamente una UI para usuarios finales, eso es un proyecto Next.js
separado (`stack-web`/`CLAUDE.md` web) — proyectos que combinan web +
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

LLM: Anthropic SDK (`anthropic`) como primera opción,
`claude-sonnet-4-6` como default. OpenAI SDK solo si el proyecto ya
está integrado o hay una razón específica.

Integraciones comunes: Gmail (`google-auth`, `google-auth-oauthlib`,
`google-api-python-client`), adapters MCP propios si aplica.

## Arquitectura — capas + puertos/adaptadores, no MVC

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

El dominio no importa de `infra/` — los adapters se inyectan en
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

**Fallback conservador en LLM** — si falla la llamada al modelo o
falta la API key, el workflow clasifica como `Review` (o equivalente).
No fallar silenciosamente con una clasificación incorrecta.

**Logging de acciones en JSONL** — cada acción que muta estado se
loguea con timestamp, tipo de acción y metadata relevante. El schema
de `actions.jsonl` tiene que estar definido ANTES de construir
cualquier UI que lo consuma — si el schema cambia, la UI se rompe
silenciosamente. Es el bug más común en estos proyectos.

**Estado mínimo en archivos locales** para proyectos personales/v1:
JSON para estado persistido, JSONL para logs. Sin DB salvo que la
escala lo justifique.

## UI opcional

NiceGUI para prototipo rápido (Python puro, sin build step) si hace
falta un dashboard de observabilidad local — módulo separado (`web/`),
con estado independiente del backend, sin mezclar lógica de dominio
con la UI. Next.js si la UI es para usuarios finales (proyecto
separado).

## Variables de entorno

`requirements.txt` con todas las dependencias — NiceGUI no está ahí
por defecto en proyectos generados con AI, verificar antes de
compartir o deployar. `.env.example` con todas las variables sin
valores. `python-dotenv` cargado en el `__init__.py` del módulo
principal — no sobreescribe variables ya definidas en el sistema (en
producción/CI, las del entorno del sistema tienen precedencia).

Nunca al repo: `ANTHROPIC_API_KEY`/`OPENAI_API_KEY`,
`GOOGLE_CLIENT_SECRET`/`GOOGLE_CLIENT_ID`, cualquier token OAuth.
`credentials.json`/`token.json` en `.gitignore` desde el inicio.

## Convenciones

TypeScript strict no aplica acá, pero el equivalente sí: sin `dict`
crudo como input de endpoints FastAPI — Pydantic tipado hace la
validación automáticamente. Un archivo = una responsabilidad. pytest
para lógica de dominio y workflows — los adapters in-memory existen
precisamente para poder testear sin dependencias externas. Sin
comentarios obvios.

OAuth con Google en callbacks separados (login/callback en distintas
instancias del Flow) puede requerir deshabilitar PKCE explícitamente.

## Formato de prompts para Cursor

Todo prompt destinado a ser pegado en Cursor va precedido del título
**Prompt para Cursor:** y dentro de un bloque de código. Siempre,
sin excepción.

Antes de armar un prompt, evaluar el costo:

- **El prompt es obvio sin leer nada** → armarlo corto y pasarlo.
- **Para armar el prompt habría que leer archivos o correr comandos**
  → delegarle la tarea completa a Cursor directamente.

## Regla fundamental

Claude Code nunca ejecuta trabajo por su cuenta. Lee el repo cuando
sea necesario para entender el contexto, pero **no corre bash, no
ejecuta agents ni skills, no edita archivos** sin que Nacho lo pida
explícitamente.

Antes de arrancar cualquier tarea, avisar:
> "Para esto voy a necesitar [leer X / correr Y]. ¿Lo hago yo o
> querés el prompt para Cursor?"

Solo trabajar sin preguntar si Nacho dice explícitamente "hacelo vos".

## Memoria del proyecto

`PROJECT_MEMORY.md` (importado arriba) es el estado vivo de este
proyecto. Al arrancar cada sesión, leerlo primero. Prestar especial
atención al schema de `actions.jsonl` y qué adapters están activos
(memory vs real) — es lo más fácil de perder de vista entre sesiones.

Si está vacío — antes de hacer cualquier otra cosa, preguntarle a Nacho:
> "PROJECT_MEMORY.md está vacío. Contame el problema que resuelve
> esta automatización y qué está construido hasta ahora."

Después de un cambio significativo, actualizarlo.

## Flujos de trabajo

Todos los flujos arrancan igual: Claude Code entiende el contexto y
arma el prompt. Cursor ejecuta. Claude Code verifica.

**Auditoría del proyecto** → prompt para Cursor: *"Seguí las
instrucciones de `.claude/agents/project-auditor.md` y auditá este
proyecto."*

**Antes de hacer público o deployar** → prompt para Cursor: *"Seguí
las instrucciones de `.claude/agents/deploy-checker.md`."*

**Editar archivos** → armar prompt corto para Cursor y dárselo a Nacho
para pegar en Agents Window.
