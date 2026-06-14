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
├── CLAUDE.md              ← contexto base, siempre activo
├── templates/
│   └── PROJECT_MEMORY.md  ← memoria viva del proyecto (importada por CLAUDE.md)
├── agents/                ← subagentes (instancias con tarea/tools propios)
├── skills/                ← playbooks que se cargan según la tarea
├── commands/              ← slash commands (vacío por ahora)
└── install.sh             ← copia todo a .claude/ + raíz de un proyecto
```

**CLAUDE.md** — equivalente a `base-stack.md`. Contexto que Claude Code
carga siempre, en cada sesión, sin que lo pidas. Va en la raíz de cada
proyecto (se adapta, no se symlinkea — cada proyecto tiene secciones
propias: paletas, fuentes, dominios, etc.). Importa `PROJECT_MEMORY.md`
con `@PROJECT_MEMORY.md`.

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

**commands/** — slash commands custom (`.claude/commands/`). Fase 2.

---

## Cómo deployar en un proyecto

```bash
./install.sh /ruta/al/proyecto
```

Esto copia `agents/` y `skills/` a `.claude/` del proyecto destino, y
copia `CLAUDE.md` a la raíz **solo si no existe ya uno** (para no pisar
contexto específico del proyecto). Revisar y completar `CLAUDE.md` con
lo propio del proyecto antes de commitear.

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
- [ ] `skills/three-js` (de `three-js-patterns.md`)
- [ ] `commands/` — slash commands para flujos repetitivos
- [ ] Evaluar agentes de VoltAgent/awesome-claude-code-subagents y
      VoltAgent/awesome-agent-skills (incluye la colección de Garry
      Tan tipo "equipo de ingeniería") para roles que no cubren los
      docs propios — adaptados al estilo directo, no copiados tal cual
- [ ] Evaluar Agent Teams / Dynamic Workflows para tareas verticales
      grandes (no como modo default)

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
