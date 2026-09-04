# nachiAgents

Configuration framework for Claude Code. Agents, skills, slash commands, and a base `CLAUDE.md` template — installable in any project via `npx`.

```bash
npx github:ojedavecellio/nachiAgents
```

---

## What it does

nachiAgents structures AI-assisted development through configuration files (`.md`, `.sh`, `.mdc`) that live directly in each project. Claude Code loads them automatically per session, and Cursor Agent uses them as a context map to load resources on demand.

The core principle: **Claude Code reads and generates prompts. Cursor Agent executes.** Nothing runs autonomously without explicit confirmation.

---

## Repo structure

```
nachiAgents/
├── CLAUDE.md                     ← base context, always active (web variant) — CLIENT TEMPLATE
├── PROJECT_MEMORY.md             ← live memory of THIS framework (not copied to clients)
├── install.sh                    ← copies everything to .claude/ in the target project
├── templates/
│   ├── PROJECT_MEMORY.md         ← empty template copied to client projects
│   ├── CLAUDE-mobile.md          ← Expo / React Native variant
│   ├── CLAUDE-automation.md      ← Python / FastAPI variant
│   └── cursor-rules/
│       └── nachiagents.mdc       ← context map for Cursor Agent (alwaysApply: true)
├── agents/                       ← subagents with specific tasks and tools
├── skills/                       ← playbooks loaded on demand per task
├── commands/                     ← slash commands (/audit, /ship, /memory)
├── .claude/
│   ├── CLAUDE.md                 ← framework self-context (imports PROJECT_MEMORY.md)
│   └── skills/                   ← design skills (emil-design-eng, taste-skill)
└── .cursor/
    ├── rules/self.mdc            ← framework self-context for Cursor
    └── skills/                   ← design skills mirror
```

---

## Core files

### `CLAUDE.md`

Base context that Claude Code loads on every session without being asked. Covers stack conventions (TypeScript strict, React 19, Tailwind v4, Supabase, Vercel), animation patterns, design system references, testing policy, and the fundamental rule: Claude Code never executes work autonomously — it reads context and produces prompts for Cursor.

Three variants exist for different project types: `web` (default), `mobile` (Expo/RN), `automation` (Python/FastAPI). Each imports `PROJECT_MEMORY.md` via `@PROJECT_MEMORY.md`.

### `templates/PROJECT_MEMORY.md`

Empty template copied to each **client** project root. There it becomes the live, project-specific memory (state, decisions, pending, gotchas). This repo's own memory is the root `PROJECT_MEMORY.md` — see [Framework self-memory](#framework-self-memory).

### `templates/cursor-rules/nachiagents.mdc`

Context map for Cursor Agent (`alwaysApply: true`). Points to all available agents, skills, and commands with per-resource triggers so Cursor loads them on demand rather than all at once. Also enforces the resource announcement pattern: before executing any task, announce which agent or skill will be used.

---

## Agents

Subagents in `.claude/agents/`. Each is a focused Claude instance with its own system prompt and allowed tools.

| Agent | When to use |
|---|---|
| `project-auditor.md` | General project audit, state of the app *(model: haiku)* |
| `deploy-checker.md` | Pre-deploy verification, before merging to main *(model: haiku)* |
| `supabase-setup.md` | Schema, RLS, migrations |
| `vercel-deploy.md` | Env vars, Vercel build errors |
| `performance-auditor.md` | Lighthouse, Speed Index, WebGL/canvas performance |
| `product-discovery.md` | Structure a raw idea into vision, persona, JTBD, falsifiable hypotheses *(model: opus)* |
| `feature-spec.md` | Turn a validated idea into a lightweight PRD Cursor can build from |

`project-auditor` and `deploy-checker` run read-only checklists against files — no deep reasoning needed, routed to haiku to cut cost. `product-discovery` benefits from opus for hypothesis framing.

---

## Skills

Playbooks in `.claude/skills/`. Claude Code loads the relevant `SKILL.md` when the task matches the trigger.

| Skill | Trigger |
|---|---|
| `gsap-motion/` | GSAP animations, ScrollTrigger, parallax |
| `three-js/` | Three.js / R3F, shaders, particles |
| `glass-patterns/` | Glassmorphism CSS, Liquid Glass |
| `security-review/` | RLS, zod, pagination, security headers |
| `git-commits/` | Conventional Commits format |
| `hallmark/` | Visual redesign, aesthetic review, anti-AI-slop |
| `nextjs-audit/` | Next.js security and scalability audit |
| `vercel-ui/` | Geist design system tokens: colors, typography, spacing, components |
| `lean-experiments/` | Design the cheapest experiment that can falsify a product hypothesis |
| `rapid-prototype/` | Disposable HTML prototype of a screen/flow before building it for real |

### Design skills

Three complementary skills for frontend/UI work — used together, not as alternatives. Live in `.claude/skills/` and `.cursor/skills/`.

| Skill | Trigger |
|---|---|
| `emil-design-eng/` | Animation decisions, UI micro-polish, interaction craft |
| `taste-skill/` | Anti-slop full frontend pass: layout, typography, motion, spacing, pre-flight check |
| Impeccable | 23 slash commands (`/polish`, `/audit`, `/critique`, `/bolder`, `/quieter`, `/animate`...) — installed separately, not copied as a static file: `npx impeccable install` |

### Product & prototyping

For work that starts before any code — validating an idea, spec'ing a feature, testing a UX flow — the flow is: `product-discovery` (structure the idea, flag the biggest unvalidated risk) → skill `lean-experiments` (design the cheapest test for that risk) → `feature-spec` (once validated, turn it into a lightweight PRD) → optionally skill `rapid-prototype` (disposable HTML mockup to resolve UX uncertainty before writing the spec's user stories). All read-only / research — no code is written until a spec goes to Cursor.

---

## Commands

Slash commands in `.claude/commands/`.

- `/audit` — runs `project-auditor` and updates `PROJECT_MEMORY.md`
- `/ship` — runs `deploy-checker` (+ `vercel-deploy` if needed), summarizes in three lists, asks before auto-fixing
- `/memory` — reads `PROJECT_MEMORY.md`, summarizes current state and pending tasks by impact, suggests what to tackle next

---

## Installation

```bash
./install.sh /path/to/project              # web variant (default)
./install.sh /path/to/project mobile       # Expo / React Native
./install.sh /path/to/project automation   # Python / FastAPI
```

Copies `agents/` and `skills/` to `.claude/` in the target project. Copies `CLAUDE.md` and `PROJECT_MEMORY.md` only if they don't already exist. Adds `.claude/` and `.cursor/` to `.gitignore` automatically.

---

## Framework self-memory

This repo distributes `CLAUDE.md` + `templates/PROJECT_MEMORY.md` to
client projects. Those files must stay client-agnostic — anything put
in the root `CLAUDE.md` gets copied by `install.sh` to every install.

The framework's **own** memory lives elsewhere so it never leaks:

| File | Role |
|---|---|
| `PROJECT_MEMORY.md` (root) | Live memory of nachiAgents itself |
| `.claude/CLAUDE.md` | Claude Code project memory (imports `@../PROJECT_MEMORY.md`) |
| `.cursor/rules/self.mdc` | Same idea for Cursor (`alwaysApply: true`) |
| `templates/PROJECT_MEMORY.md` | Empty template copied to client projects |

Come back to this repo and ask "anything to update?" — Cursor / Claude
Code read `PROJECT_MEMORY.md` without needing a handoff first.

---

## Design decisions

**Deliberate rejections:**

- **gstack / VoltAgent** — covered by `project-auditor` + `deploy-checker` for this stack. Style conflicts with the rest of the repo.
- **Agent Teams / Conductor** — parallel execution doesn't match the step-by-step confirmation workflow.
- **Global skills in `~/.claude/skills/`** — project-level skills are sufficient; global scope adds unnecessary complexity.
- **`cursor-delegate` with `agent -p`** — manual copy-paste of prompts into Cursor's Agents Window is intentional and preferred.

---

## Stack

Built for: Next.js · Supabase · Vercel · TypeScript · React 19 · Tailwind v4

---

## Inspiration

- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
- [hesreallyhim/a-list-of-claude-code-agents](https://github.com/hesreallyhim/a-list-of-claude-code-agents)
