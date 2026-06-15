# commands/

Slash commands custom (`.claude/commands/`) — fase 2, todavía vacío.

Candidatos cuando los necesitemos:

- `/audit` — invoca `project-auditor` y vuelca el resultado directo a
  `PROJECT_MEMORY.md` (hoy es manual: el agente reporta, la sesión
  principal actualiza el archivo).
- `/ship` — corre `deploy-checker` (y `vercel-deploy` si hay algo
  bloqueante de env vars).
- `/scaffold` — el árbol de decisión de `flujo-inicio-proyecto.md`
  ("qué tipo de proyecto → qué stack"), para arrancar un proyecto
  nuevo sin pasar por AI Craft 2.

Se agregan a partir de fricción real, no a priori.
