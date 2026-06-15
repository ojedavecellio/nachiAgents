# nachiAgents

Biblioteca personal de agentes, skills y contexto base para Claude Code.
Es la evolución de **AI Craft 2 / Lab**: en vez de documentos que se
pegan a mano en una conversación de Claude para armar un prompt que
después se pega en Cursor, esto vive directo en cada repo y Claude Code
lo carga o invoca solo, sin el ping-pong.

AI Craft 2 sigue siendo el lugar donde se discuten y prueban estos
agentes antes de que terminen acá.

---

## Qué hay en este repo

```
nachiAgents/
├── CLAUDE.md              ← contexto base WEB, siempre activo (variante default)
├── templates/
│   ├── PROJECT_MEMORY.md       ← memoria viva del proyecto (importada por CLAUDE.md)
│   ├── CLAUDE-mobile.md         ← variante Expo/React Native (Cal Buddies)
│   └── CLAUDE-automation.md     ← variante Python/FastAPI (ctdApp, automatizaciones)
├── agents/                ← subagentes (instancias con tarea/tools propios)
├── skills/                ← playbooks que se cargan según la tarea
├── commands/              ← slash commands (/audit, /ship)
└── install.sh             ← copia todo a .claude/ + raíz de un proyecto
```

**CLAUDE.md / templates/CLAUDE-\*.md** — equivalente a `base-stack.md` +
`stack-web.md`/`stack-mobile.md`/`stack-automatizacion.md`. Contexto que
Claude Code carga siempre, en cada sesión, sin que lo pidas. `install.sh`
copia la variante que corresponda a la raíz del proyecto (se adapta, no
se symlinkea — cada proyecto tiene secciones propias: paletas, fuentes,
dominios, etc.). Las tres importan `PROJECT_MEMORY.md` con
`@PROJECT_MEMORY.md`.

**templates/PROJECT_MEMORY.md** — memoria viva y específica de cada
proyecto (estado actual, decisiones, pendientes, gotchas). Se copia a
la raíz del proyecto y se actualiza a medida que se avanza —
equivalente a las secciones "Estado actual / On the horizon" de AI
Craft 2, pero en el repo.

**agents/** — subagentes en `.claude/agents/`. Cada uno es una instancia
de Claude con su propio system prompt, tools permitidas y, opcionalmente,
modelo. Reemplazan los "flujos" manuales de AI Craft 2 (auditoría,
checklist de lanzamiento).

**skills/** — playbooks en `.claude/skills/`. Equivalente a los docs de
patrones (gsap-patterns, glass-patterns, etc.) pero con un `description`
que hace que Claude Code los cargue solo cuando la tarea matchea.

**commands/** — slash commands custom (`.claude/commands/`). `/audit`
encadena `project-auditor` con la actualización de `PROJECT_MEMORY.md`
(antes era manual). `/ship` encadena `deploy-checker` +
`vercel-deploy` si hace falta.

---

## Cómo deployar en un proyecto

```bash
./install.sh /ruta/al/proyecto              # variante web (default)
./install.sh /ruta/a/CalBuddies mobile      # variante Expo/React Native
./install.sh /ruta/a/ctdApp automation      # variante Python/FastAPI
```

Esto copia `agents/` y `skills/` a `.claude/` del proyecto destino, y
copia el `CLAUDE.md` de la variante elegida a la raíz **solo si no
existe ya uno** (para no pisar contexto específico del proyecto).
También copia `PROJECT_MEMORY.md` si no existe. Revisar y completar
`CLAUDE.md` con lo propio del proyecto antes de commitear.

---

## Estado

- [x] `CLAUDE.md` base
- [x] `templates/PROJECT_MEMORY.md` — memoria de proyecto importada por `CLAUDE.md`
- [x] `agents/project-auditor` — reemplaza `flujo-auditoria.md`, lee `PROJECT_MEMORY.md`
- [x] `agents/deploy-checker` — reemplaza `checklist-lanzamiento.md`
- [x] `skills/gsap-motion` (+ `references/scroll-parallax.md`)
- [x] `skills/security-review` — de `cybersecurity.md`
- [x] `agents/supabase-setup` — de `setup-supabase.md`
- [x] `agents/vercel-deploy` — de `setup-vercel.md`
- [x] `skills/three-js` (+ `references/shaders-and-models.md`)
- [x] `skills/glass-patterns` (+ `references/liquid-glass-implementation.md`)
- [x] `skills/git-commits` — Conventional Commits, formato y atomicidad
- [x] `agents/performance-auditor` — de `performance-lazy-mount.md`
- [x] `templates/CLAUDE-mobile.md` — variante Expo/RN, de `stack-mobile.md`
- [x] `templates/CLAUDE-automation.md` — variante Python/FastAPI, de `stack-automatizacion.md`
- [x] `install.sh` — soporta variante `web|mobile|automation`, funciona
      vía `npx` (resuelve symlinks), copia `commands/`
- [x] `commands/audit.md` — corre `project-auditor` y actualiza
      `PROJECT_MEMORY.md` solo, sin preguntar
- [x] `commands/ship.md` — corre `deploy-checker` (+ `vercel-deploy` si
      hace falta), resume en 3 listas, pregunta antes de auto-fixear
- [x] `skills/security-review` — paginación agregada (de `stack-web.md`,
      ahora completamente absorbido)

**Evaluado y descartado** (no por falta de tiempo — son "no" deliberados):

- **gstack / VoltAgent** (colección "equipo de ingeniería" de Garry
  Tan): lo que más vale (`/review`, `/qa`) ya está cubierto por
  `project-auditor` + `deploy-checker` (a medida de este stack) y por
  `Skill(verify)` (built-in de Claude Code, gratis). Choque de voz/estilo
  con el resto del repo. El scoping pre-build (`/office-hours`,
  `/plan-eng-review`) ya pasa en el chat de Claude antes de Cursor —
  no es un hueco.
- **Agent Teams / Dynamic Workflows / Conductor** (paralelismo): no
  matchea el flujo de confirmación paso a paso. Revisar si ChimichurrIA
  escala a un punto donde haga falta correr cosas desatendidas.
- **nachiDesignSkill** (paletas/tipografía como doc separado):
  redundante — cuando hizo falta un componente visual nuevo (Aurora en
  sladstudio), lo que funcionó fue el registro `@react-bits` (componente
  real e instalable), no una referencia en markdown.

**Pendiente, sin urgencia:**

- `commands/scaffold.md` — árbol de decisión de `flujo-inicio-proyecto.md`
  (qué tipo de proyecto → qué stack), para el paso de crear el repo
  (anterior a `install.sh`)

---

## Iteración

Cuando algo de esto no funciona bien en la práctica — un agente que se
porta mal, un skill que no triggerea, un prompt que hay que ajustar —
se discute en el proyecto **agents** de Claude, se corrige acá, y se
re-deploya con `install.sh` a los proyectos que lo usan.

---

## Fuentes / inspiración

- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) —
  100+ subagentes, instalable como plugin marketplace.
- [hesreallyhim/a-list-of-claude-code-agents](https://github.com/hesreallyhim/a-list-of-claude-code-agents)
- Estructura y convenciones propias: AI Craft 2 / Lab (proyecto de Claude)
