# Contexto base (automatización) — Nacho / ChimichurrIA

@PROJECT_MEMORY.md

Indie developer + estudio chico (ChimichurrIA, 2 personas). Vibe coder:
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

## Memoria del proyecto

`PROJECT_MEMORY.md` (importado arriba) es el estado vivo de este
proyecto. Prestar especial atención a documentar el schema de
`actions.jsonl` y qué adapters están activos (memory vs real) por
integración — es lo más fácil de perder de vista entre sesiones, y el
README puede decir "usa MCP" mientras el código inyecta OAuth (estado
válido de transición, pero hay que documentarlo acá).

## Flujos de trabajo

Proyecto existente sin contexto reciente en esta sesión → usar
`project-auditor` antes de proponer cambios. Antes de hacer público o
deployar → skill `security-review`, sección Python/FastAPI.
