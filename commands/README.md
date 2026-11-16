# commands/

Skills invocables como `/audit`, `/ship`, `/memory`, `/og`, `/slop`.
`install.sh` las copia a `.cursor/skills/<nombre>/SKILL.md`.

- `/audit`: `project-auditor`. Si el proyecto es Next (`next.config.*`
  o dependencia `next`), también `nextjs-audit`. Actualiza
  `PROJECT_MEMORY.md` y lo comprime a unas 150 líneas. El reporte
  largo puede ir a `AUDIT-REPORT.md`.
- `/ship`: corre `deploy-checker` (y `vercel-deploy` si hay algo
  bloqueante de env vars/build), corre `/slop`, resume en las tres
  listas, y ofrece arreglar lo automatizable. Si hubo cambios grandes
  de componentes: `npx react-doctor@latest`.
- `/memory`: lee `PROJECT_MEMORY.md`, resume estado actual y
  pendientes ordenados por impacto, y sugiere qué atacar primero. Si
  el archivo está vacío, pide contexto en vez de inventarlo.
- `/og`: diseña o itera la Open Graph / social card (skill
  `og-images`). Implementar, renderizar el PNG, mirarlo, iterar.
  Post-deploy, tab Open Graph de Vercel.
- `/slop`: grepea la lista de prohibiciones de `nachi-style` en código
  y copy. No arregla solo.
