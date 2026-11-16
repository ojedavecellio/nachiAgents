# Design Skills

El look default es `nachi-style`. No se mezcla con otra paleta.

## Cuál cargar

- **Cualquier UI** → `nachi-style` (tokens, vidrio, prohibiciones)
- **Motion de un componente** (modal, botón, gesture) → `emil-design-eng`,
  sin pisar los tokens
- **Card al compartir** → `og-images`
- `taste-skill` no redefine la paleta. `vercel-ui` solo si el proyecto
  pidió Geist. No es el Vercel UI SDK.

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
