# nachiAgents

Configuración para Cursor. Skills, playbooks y un `AGENTS.md` base.
Se instala en cualquier proyecto con `npx`.

```bash
npx github:ojedavecellio/nachiAgents
```

Cursor ejecuta. Lee la skill que corresponde y hace el trabajo.

## v2

- Look `nachi-style`: tokens oscuro/claro, tipo, una escala de radios
  y sombras, vidrio permitido cuando es chrome.
- shadcn/ui copiado al repo (`templates/components/`), tematizado.
  No es el Vercel UI SDK.
- `/slop` entra en `/ship` y en `deploy-checker`.
- `/audit` comprime `PROJECT_MEMORY.md` (tope ~150 líneas, sección
  "Reglas aprendidas").
- `install.sh --update` refresca skills, commands, `AGENTS.md` y
  templates sin tocar `PROJECT_MEMORY.md`.
- Si `AGENTS.md` es solo el bloque que escribe Next, el kit se instala
  y ese bloque queda entre sus markers.
- `.cursor/` se versiona. `* 2.*` entra al `.gitignore`.
- Gotchas de Next 16: GSAP y LCP, `next/font`, `connection()` /
  Cache Components.

### Actualizar un repo que ya tiene el kit

Desde el proyecto:

```bash
npx github:ojedavecellio/nachiAgents --update
```

O, con el repo del kit clonado:

```bash
./install.sh /ruta/al/proyecto --update
./install.sh /ruta/al/proyecto mobile --update
```

No pisa `PROJECT_MEMORY.md`. Refresca `AGENTS.md` y conserva el bloque
`<!-- BEGIN:nextjs-agent-rules -->` (o el legacy `NEXT-AGENTS-MD`) si
Next lo había escrito. Los componentes del kit se vuelven a copiar.
La ruta `app/api/og` solo se copia si no existe.

Si quedó un `CLAUDE.md` del kit viejo, borrarlo. Cursor lee `AGENTS.md`.

## Estructura

```
nachiAgents/
├── AGENTS.md
├── install.sh
├── templates/
│   ├── PROJECT_MEMORY.md
│   ├── AGENTS-mobile.md
│   ├── AGENTS-automation.md
│   ├── components.json
│   ├── components/          ← Button, Card, Input, Dialog, Reveal, ...
│   ├── hooks/
│   ├── lib/                 ← utils, site-metadata, og
│   ├── styles/nachi.css
│   └── cursor-rules/nachiagents.mdc
├── agents/
├── skills/                  ← nachi-style, glass-patterns, ...
├── commands/                ← /audit, /ship, /memory, /og, /slop
└── .cursor/skills/          ← emil-design-eng, taste-skill
```

## Archivos base

`AGENTS.md` es el contexto que Cursor carga solo. Stack fijo (Next.js
16, React 19, TypeScript, Tailwind v4, GSAP con `useGSAP`, Supabase,
Resend, Vercel, shadcn/ui), nachi-style, prohibiciones, flujo de
trabajo y gotchas de Next 16.

Variantes: `web` (default), `mobile` (Expo/RN), `automation`
(Python/FastAPI). El modelo default es el Grok más nuevo.

`PROJECT_MEMORY.md` es el estado vivo del proyecto. Bullets, ~150
líneas, con "Reglas aprendidas".

`templates/cursor-rules/nachiagents.mdc` es el mapa (`alwaysApply`).
Apunta a `.cursor/skills/`.

## Playbooks

`install.sh` copia `agents/*.md` a `.cursor/skills/<nombre>/SKILL.md`.

| Skill | Cuándo |
| --- | --- |
| `project-auditor` | Auditoría general |
| `deploy-checker` | Antes de deployar. Incluye `/slop` |
| `supabase-setup` | Schema, RLS, migraciones |
| `vercel-deploy` | Env vars, errores de build |
| `performance-auditor` | Lighthouse, LCP, motion pesado |
| `product-discovery` | Idea cruda a hipótesis |
| `feature-spec` | Idea validada a PRD liviano |

## Skills

| Skill | Trigger |
| --- | --- |
| `nachi-style/` | Look default. Reemplaza a hallmark |
| `glass-patterns/` | Receta de vidrio y `useGSAP` |
| `security-review/` | RLS, zod, headers |
| `git-commits/` | Conventional Commits. `cyp` |
| `nextjs-audit/` | Audit Next + Supabase, lo despacha `/audit` |
| `vercel-ui/` | Tokens Geist, solo si el proyecto lo pidió |
| `lean-experiments/` | El experimento más barato |
| `rapid-prototype/` | HTML desechable |
| `og-images/` | Open Graph |

GSAP y Next oficiales se instalan en proyectos web y se actualizan
con `npx skills update`:

- [greensock/gsap-skills](https://github.com/greensock/gsap-skills)
- [vercel/next.js](https://github.com/vercel/next.js/tree/canary/skills)

Three.js / R3F: sin receta local. Docs actuales. V9 estable, v10 alpha.

Impeccable va aparte: `npx impeccable install`.

## Commands

- `/audit`: auditor + `nextjs-audit` si es Next. Comprime la memoria.
- `/ship`: `deploy-checker`, `/slop`, y `vercel-deploy` si hace falta.
- `/memory`: resume la memoria y propone una sola cosa.
- `/og`: diseña o itera la social card.
- `/slop`: grepea la lista de prohibiciones. No arregla solo.

## Instalación

```bash
./install.sh /ruta/al/proyecto
./install.sh /ruta/al/proyecto mobile
./install.sh /ruta/al/proyecto automation
./install.sh /ruta/al/proyecto --update
```

Copia skills a `.cursor/skills/` y la rule a `.cursor/rules/`. En
`web`, también los primitivos shadcn, `styles/nachi.css`, `components.json`,
y (si hay `package.json` con Next y el target no es este repo) las
deps: Radix dialog/slot, `clsx`, `tailwind-merge`, `cva`, `gsap`,
`@gsap/react`, `lenis`.

`AGENTS.md` se copia si no existe, si es solo el bloque de Next, o
si pasás `--update`. `PROJECT_MEMORY.md` solo si no existe.

`.cursor/` no va al gitignore. Sí va `* 2.*` (duplicados de Finder).

## Decisiones

- gstack / VoltAgent: lo cubren `project-auditor` y `deploy-checker`.
- Agent Teams / Conductor: no encaja con confirmar antes de producción.
- Skills globales en `~/.cursor/skills/`: alcanza con las del proyecto.
- Vercel UI SDK: fuera de scope.
- Hallmark oficial: no se clona. El criterio vive en `nachi-style`.

## Stack

Next.js 16, Supabase, Resend, Vercel, TypeScript, React 19, Tailwind v4.
Mobile: Expo SDK 57, React Native 0.86.
