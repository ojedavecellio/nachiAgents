# Design Skills

Three complementary design skills for anti-slop frontend work.
Use them together — they are not alternatives.

## Skills

### `emil-design-eng`
- **Author:** Emil Kowalski (Linear, ex-Vercel)
- **Focus:** Animation decisions, UI polish, component micro-interactions, the invisible details
- **When to use:** Any time you're building or reviewing animation/interaction code
- **Source:** github.com/emilkowalski/skill

### `design-taste-frontend` (taste-skill)
- **Author:** Leonxlnx
- **Focus:** Anti-slop full frontend: layout, typography, motion, spacing, pre-flight checks
- **When to use:** Greenfield landing pages, portfolios, redesigns — not dashboards or data tables
- **Dials:** DESIGN_VARIANCE / MOTION_INTENSITY / VISUAL_DENSITY (1-10 each)
- **Source:** github.com/Leonxlnx/taste-skill

### `impeccable`
- **Author:** Paul Bakaus (backed by a16z)
- **Focus:** 23 slash commands (`/polish`, `/audit`, `/critique`, `/bolder`, `/quieter`, `/animate`...) + 7 reference files + CLI detector
- **When to use:** Polish and audit passes — it gives you vocabulary to steer the AI, not prescribe it
- **Install:** `npx impeccable install` (do NOT store static copies — actively maintained, 666+ commits)
- **Source:** github.com/pbakaus/impeccable

## How they layer

```
impeccable         → sets vocabulary + anti-patterns baseline
taste-skill        → briefs, dials, layout discipline, pre-flight check
emil-design-eng    → animation framework, component micro-detail
```

## Install in a new project

`install.sh` copies `emil-design-eng` and `taste-skill` automatically.
For `impeccable`, run separately in the project:

```bash
npx impeccable install
```
