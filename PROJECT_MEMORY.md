# Memoria del proyecto — nachiAgents

_Esto es la memoria del framework mismo (este repo), no la plantilla
que se copia a proyectos cliente. Esa vive en `templates/PROJECT_MEMORY.md`.
Se carga vía `.claude/CLAUDE.md` y `.cursor/rules/self.mdc` — no vía
el `CLAUDE.md` de la raíz, que `install.sh` copia tal cual a cada cliente._

## Estado actual

Framework de configuración para Claude Code + Cursor: agentes, skills,
slash commands y plantillas `CLAUDE.md` (web / mobile / automation).
Instalable con `npx github:ojedavecellio/nachiAgents` → `install.sh`.

**Agentes** (`agents/`):
- `project-auditor` (haiku) — auditoría read-only
- `deploy-checker` (haiku) — pre-deploy
- `supabase-setup` (sonnet) — schema, RLS, migraciones
- `vercel-deploy` (sonnet) — env vars / builds Vercel
- `performance-auditor` (sonnet) — Lighthouse / WebGL
- `product-discovery` (opus) — idea cruda → hipótesis falsables
- `feature-spec` (sonnet) — idea validada → PRD liviano

**Skills** (`skills/`): gsap-motion, three-js, glass-patterns,
security-review, git-commits, hallmark, nextjs-audit, vercel-ui,
lean-experiments, rapid-prototype.

**Design skills** (`.claude/skills/` + `.cursor/skills/`):
emil-design-eng, taste-skill. Impeccable se instala aparte
(`npx impeccable install`).

**Commands**: `/audit`, `/ship`, `/memory`.

**Flag:** `audit-reviewer` (agente haiku maker-checker) **no está**
en `agents/` de este repo. Si se vuelve a mencionar, hay que crearlo
o confirmar que vive en otro lado.

## Decisiones de este proyecto

- El `CLAUDE.md` de la raíz es la plantilla de cliente. No poner
  contexto propio del framework ahí — se filtraría al instalar.
- Memoria propia del framework: `PROJECT_MEMORY.md` (esta) +
  `.claude/CLAUDE.md` + `.cursor/rules/self.mdc`.
- `templates/PROJECT_MEMORY.md` es el template vacío que reciben los
  proyectos cliente vía `install.sh`.
- Flujo: Claude Code lee y arma prompts; Cursor ejecuta. Sin
  ejecución autónoma sin confirmación explícita.
- Modelos: checklists read-only → haiku; discovery → opus; resto →
  sonnet.
- Rechazados a propósito: gstack/VoltAgent, Agent Teams/Conductor,
  skills globales en `~/.claude/skills/`, `cursor-delegate` con
  `agent -p` (preferimos copy-paste manual al Agents Window).

## Pendiente

- Confirmar / crear `audit-reviewer` si sigue haciendo falta.
- Mantener README, `templates/cursor-rules/nachiagents.mdc` y
  `CLAUDE.md` sincronizados cuando se agreguen agentes o skills.
- Revisar si conviene versionar o documentar dependencias externas
  (hallmark clone en install, impeccable aparte).

## Gotchas descubiertos

- `install.sh` agrega `.claude/` y `.cursor/` al `.gitignore` del
  **proyecto destino**. En este repo sí se trackean (skills de
  diseño, y ahora memoria propia).
- Hallmark se clona en install si no existe; puede fallar offline —
  es opcional.
- `nachiAgents` (este repo) no es una app Next.js: los agentes de
  deploy/auditoría de producto no aplican acá salvo para auditar el
  framework mismo.
