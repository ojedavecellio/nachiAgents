# Design Skills

Una skill de look por tarea, no las cuatro juntas.

## Cuál cargar

- **Página existente que "parece IA" / punch list** → `hallmark`
- **Landing / portfolio / redesign greenfield** → `taste-skill`
  (dials). No dashboards ni tablas.
- **UI de producto Geist / Vercel** → `vercel-ui`
- **Motion de un componente** (modal, botón, gesture) → `emil-design-eng`
- **Card al compartir** → `og-images`

`gsap` / R3F definen cómo se mueve, no el look. GSAP: skills oficiales.
Three.js: docs actuales, sin receta local.

## Skills

### `emil-design-eng`
- **Author:** Emil Kowalski (Linear, ex-Vercel)
- **Focus:** Animation decisions, UI polish, component micro-interactions
- **Source:** github.com/emilkowalski/skill

### `taste-skill`
- **Author:** Leonxlnx
- **Focus:** Anti-slop full frontend: layout, typography, motion, spacing, pre-flight
- **Dials:** DESIGN_VARIANCE / MOTION_INTENSITY / VISUAL_DENSITY (1-10)
- **Source:** github.com/Leonxlnx/taste-skill

### `impeccable`
- **Author:** Paul Bakaus
- **Focus:** Slash commands (`/polish`, `/critique`, `/bolder`, `/quieter`, `/animate`...) + CLI detector
- **Install:** `npx impeccable install` (do NOT store static copies)
- **Source:** github.com/pbakaus/impeccable

## Install in a new project

`install.sh` copies `emil-design-eng` and `taste-skill` to `.cursor/skills/`.
For `impeccable`, run separately:

```bash
npx impeccable install
```
