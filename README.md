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
├── CLAUDE.md                     ← base context, always active (web variant)
├── install.sh                    ← copies everything to .claude/ in the target project
├── templates/
│   ├── PROJECT_MEMORY.md         ← live project memory (imported by CLAUDE.md)
│   ├── CLAUDE-mobile.md          ← Expo / React Native variant
│   ├── CLAUDE-automation.md      ← Python / FastAPI variant
│   └── cursor-rules/
│       └── nachiagents.mdc       ← context map for Cursor Agent (alwaysApply: true)
├── agents/                       ← subagents with specific tasks and tools
├── skills/                       ← playbooks loaded on demand per task
└── commands/                     ← slash commands (/audit, /ship)
```

---

## Core files

### `CLAUDE.md`

Base context that Claude Code loads on every session without being asked. Covers stack conventions (TypeScript strict, React 19, Tailwind v4, Supabase, Vercel), animation patterns, design system references, testing policy, and the fundamental rule: Claude Code never executes work autonomously — it reads context and produces prompts for Cursor.

Three variants exist for different project types: `web` (default), `mobile` (Expo/RN), `automation` (Python/FastAPI). Each imports `PROJECT_MEMORY.md` via `@PROJECT_MEMORY.md`.

### `templates/PROJECT_MEMORY.md`

Live, project-specific memory: current state, architecture decisions, pending tasks, known gotchas. Copied to each project root and updated as the project evolves.

### `templates/cursor-rules/nachiagents.mdc`

Context map for Cursor Agent (`alwaysApply: true`). Points to all available agents, skills, and commands with per-resource triggers so Cursor loads them on demand rather than all at once. Also enforces the resource announcement pattern: before executing any task, announce which agent or skill will be used.

---

## Agents

Subagents in `.claude/agents/`. Each is a focused Claude instance with its own system prompt and allowed tools.

| Agent | When to use |
|---|---|
| `project-auditor.md` | General project audit, state of the app |
| `deploy-checker.md` | Pre-deploy verification, before merging to main |
| `supabase-setup.md` | Schema, RLS, migrations |
| `vercel-deploy.md` | Env vars, Vercel build errors |
| `performance-auditor.md` | Lighthouse, Speed Index, WebGL/canvas performance |

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

---

## Commands

Slash commands in `.claude/commands/`.

- `/audit` — runs `project-auditor` and updates `PROJECT_MEMORY.md`
- `/ship` — runs `deploy-checker` (+ `vercel-deploy` if needed), summarizes in three lists, asks before auto-fixing

---

## Installation

```bash
./install.sh /path/to/project              # web variant (default)
./install.sh /path/to/project mobile       # Expo / React Native
./install.sh /path/to/project automation   # Python / FastAPI
```

Copies `agents/` and `skills/` to `.claude/` in the target project. Copies `CLAUDE.md` and `PROJECT_MEMORY.md` only if they don't already exist. Adds `.claude/` and `.cursor/` to `.gitignore` automatically.

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
