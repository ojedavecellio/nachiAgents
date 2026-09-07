# nachiAgents

Configuration for Cursor Agent. Skills, playbooks, and a base `AGENTS.md`
template — installable in any project via `npx`.

```bash
npx github:ojedavecellio/nachiAgents
```

---

## What it does

nachiAgents structures AI-assisted development through configuration files
(`.md`, `.sh`, `.mdc`) that live in each project. Cursor loads `AGENTS.md`
and `.cursor/rules/nachiagents.mdc` every session, and loads skills from
`.cursor/skills/` on demand.

The core principle: **Cursor executes.** Read the matching skill and do
the work. No prompt-to-paste ritual.

---

## Repo structure

```
nachiAgents/
├── AGENTS.md                     ← always-on context (web variant)
├── install.sh                    ← copies everything to .cursor/ in the target
├── templates/
│   ├── PROJECT_MEMORY.md         ← live project memory
│   ├── AGENTS-mobile.md          ← Expo / React Native variant
│   ├── AGENTS-automation.md      ← Python / FastAPI variant
│   └── cursor-rules/
│       └── nachiagents.mdc       ← skill map (alwaysApply: true)
├── agents/                       ← playbooks (installed as .cursor/skills/<name>/SKILL.md)
├── skills/                       ← playbooks loaded on demand
├── commands/                     ← /audit, /ship, /memory, /og (installed as skills)
└── .cursor/skills/               ← design skills (emil-design-eng, taste-skill)
```

---

## Core files

### `AGENTS.md`

Always-on context Cursor loads without being asked. Stack conventions
(TypeScript strict, React 19, Tailwind v4, Supabase, Vercel), animation
choices, design dispatch, testing policy. Cursor is the only agent —
it executes. Not `CLAUDE.md` (that's Claude Code).

Three variants: `web` (default), `mobile` (Expo/RN), `automation`
(Python/FastAPI). `PROJECT_MEMORY.md` is the live project state —
the agent reads it at the start of each session.

### `templates/PROJECT_MEMORY.md`

Live, project-specific memory: current state, architecture decisions,
pending tasks, known gotchas. Copied to each project root and updated as
the project evolves.

### `templates/cursor-rules/nachiagents.mdc`

Context map (`alwaysApply: true`). Points to skills in `.cursor/skills/`
with per-resource triggers so Cursor loads them on demand. Also enforces
the resource announcement pattern: before executing any task, announce
which skill will be used.

---

## Playbooks (installed as skills)

Source lives in `agents/`. `install.sh` copies each file to
`.cursor/skills/<name>/SKILL.md`.

| Skill | When to use |
|---|---|
| `project-auditor` | General project audit, state of the app |
| `deploy-checker` | Pre-deploy verification, before merging to main |
| `supabase-setup` | Schema, RLS, migrations |
| `vercel-deploy` | Env vars, Vercel build errors |
| `performance-auditor` | Lighthouse, Speed Index, WebGL/canvas performance |
| `product-discovery` | Structure a raw idea into vision, persona, JTBD, falsifiable hypotheses |
| `feature-spec` | Turn a validated idea into a lightweight PRD |

---

## Skills

Playbooks in `skills/`, copied to `.cursor/skills/`. Cursor loads the
matching `SKILL.md` when the task matches the trigger.

| Skill | Trigger |
|---|---|
| `glass-patterns/` | Glassmorphism CSS, Liquid Glass |
| `security-review/` | RLS, zod, pagination, security headers |
| `git-commits/` | Conventional Commits format |
| `hallmark/` | Visual redesign, 4-axis anti-AI-slop checklist |
| `nextjs-audit/` | Next.js security and scalability audit |
| `vercel-ui/` | Geist design system tokens |
| `lean-experiments/` | Design the cheapest experiment that can falsify a product hypothesis |
| `rapid-prototype/` | Disposable HTML prototype of a screen/flow before building it for real |
| `og-images/` | Open Graph / social cards: design, `next/og`, render the PNG, iterate |

No se copian recetas locales de GSAP ni de Three.js — se pudren.

**Oficiales** (el `install.sh` las agrega en proyectos web; se actualizan con `npx skills update`):

- [greensock/gsap-skills](https://github.com/greensock/gsap-skills) — `gsap-react`, `gsap-scrolltrigger`, `gsap-timeline`, …
- [vercel/next.js](https://github.com/vercel/next.js/tree/canary/skills) — Cache Components, prefetch, dev-loop

Three.js / R3F: no hay skill oficial que valga. Sin receta local; docs actuales. v9 estable, v10 alpha.

Optional: official Hallmark (`npx skills add nutlope/hallmark`) is
separate — this repo ships the 4-axis checklist.

### Design skills

Una skill de look por tarea, no las cuatro juntas. Viven en
`.cursor/skills/`.

| Skill | Trigger |
|---|---|
| `hallmark/` | Punch list anti-slop en una página que ya existe |
| `taste-skill/` | Landing / portfolio / redesign greenfield (dials) |
| `vercel-ui/` | UI de producto Geist / Vercel |
| `emil-design-eng/` | Motion de un componente |
| Impeccable | Pase de polish (`/polish`, `/critique`, `/bolder`...) — aparte: `npx impeccable install` |

### Product & prototyping

Work that starts before any product code: `product-discovery` (structure
the idea, flag the biggest unvalidated risk) → `lean-experiments` (cheapest
test for that risk) → `feature-spec` (lightweight PRD) → optionally
`rapid-prototype` (disposable HTML). No product code until there is a spec.

---

## Commands (installed as skills)

- `/audit` — `project-auditor`; si el proyecto es Next, también `nextjs-audit`. Actualiza `PROJECT_MEMORY.md`
- `/ship` — runs `deploy-checker` (+ `vercel-deploy` if needed), summarizes in three lists, asks before auto-fixing. Large React changes: `npx react-doctor@latest`
- `/memory` — reads `PROJECT_MEMORY.md`, summarizes current state and pending tasks by impact, suggests what to tackle next
- `/og` — designs or iterates the project's Open Graph / social card (`og-images` skill)

---

## Installation

```bash
./install.sh /path/to/project              # web variant (default)
./install.sh /path/to/project mobile       # Expo / React Native
./install.sh /path/to/project automation   # Python / FastAPI
```

Copies playbooks to `.cursor/skills/` and the context map to
`.cursor/rules/`. On the **web** variant, also installs official
GSAP + Next skills (`npx skills add`). Copies `AGENTS.md` and
`PROJECT_MEMORY.md` only if they don't already exist. If the target
still has `CLAUDE.md` and no `AGENTS.md`, it gets renamed. Does not
gitignore `.cursor/` — skills travel with the repo.

---

## Design decisions

**Deliberate rejections:**

- **gstack / VoltAgent** — covered by `project-auditor` + `deploy-checker` for this stack. Style conflicts with the rest of the repo.
- **Agent Teams / Conductor** — parallel execution doesn't match the step-by-step confirmation workflow.
- **Global skills in `~/.cursor/skills/`** — project-level skills are sufficient; global scope adds unnecessary complexity.

---

## Stack

Built for: Next.js 16 · Supabase · Vercel · TypeScript · React 19 · Tailwind v4
Mobile variant: Expo SDK 57 · React Native 0.86

---

## Inspiration

- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
- [hesreallyhim/a-list-of-claude-code-agents](https://github.com/hesreallyhim/a-list-of-claude-code-agents)
