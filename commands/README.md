# commands/

Skills invocables como `/audit`, `/ship`, `/memory`, `/og`.
`install.sh` las copia a `.cursor/skills/<nombre>/SKILL.md`.

- `/audit` — `project-auditor`; si el proyecto es Next (`next.config.*`
  o dependencia `next`), también `nextjs-audit`. Actualiza
  `PROJECT_MEMORY.md` (el reporte largo puede ir a `AUDIT-REPORT.md`).
- `/ship` — corre `deploy-checker` (y `vercel-deploy` si hay algo
  bloqueante de env vars/build), resume en las tres listas, y ofrece
  arreglar lo automatizable. Si hubo cambios grandes de componentes:
  `npx react-doctor@latest`.
- `/memory` — lee `PROJECT_MEMORY.md`, resume estado actual y
  pendientes ordenados por impacto, y sugiere qué atacar primero. Si
  el archivo está vacío, pide contexto en vez de inventarlo.
- `/og` — diseña o itera la Open Graph / social card (skill
  `og-images`): implementar, renderizar el PNG, mirarlo, iterar.
  Post-deploy, tab Open Graph de Vercel.
