# Prompt para Cursor: integrar design skills en nachiAgents

Prompt para Cursor:

```
Leé install.sh y .cursor/rules/nachiagents.mdc antes de hacer cualquier cambio.

Tarea 1 — Actualizar install.sh
Agregá al final de la sección de copia de skills (después de donde se copian nextjs-audit o vercel-ui) el siguiente bloque:

  # Design skills
  copy_skill ".claude/skills/emil-design-eng" "$TARGET/.claude/skills/emil-design-eng"
  copy_skill ".cursor/skills/emil-design-eng" "$TARGET/.cursor/skills/emil-design-eng"
  copy_skill ".claude/skills/taste-skill" "$TARGET/.claude/skills/taste-skill"
  copy_skill ".cursor/skills/taste-skill" "$TARGET/.cursor/skills/taste-skill"

  echo ""
  echo "📐 Design skills installed: emil-design-eng, taste-skill"
  echo "   For impeccable (23 commands + CLI detector), run separately: npx impeccable install"

Si install.sh no tiene una función copy_skill, adaptá la lógica al patrón que ya use el script para copiar directorios.

Tarea 2 — Actualizar .cursor/rules/nachiagents.mdc
En la sección de skills o tools del archivo, agregá referencia a las tres design skills:

  ## Design Skills (for frontend/UI work)
  - `.claude/skills/emil-design-eng/SKILL.md` — animation decisions, UI micro-polish (Emil Kowalski)
  - `.claude/skills/taste-skill/SKILL.md` — anti-slop full frontend, dials, pre-flight check (taste-skill)
  - Impeccable: install separately via `npx impeccable install` — 23 commands (/polish, /audit, /critique, /bolder, /quieter, /animate...)

Tarea 3 — Si existe un CLAUDE.md template para web (ej: templates/web/CLAUDE.md o similar)
Agregá una sección `## Design Skills` que mencione las tres, cuándo usarlas, y el comando para impeccable.

Hacé los cambios, mostrámelos con diff, y esperá confirmación antes de commitear.
```
