# commands/

Slash commands custom (`.claude/commands/`).

- `/audit` — corre `project-auditor` y vuelca/actualiza
  `PROJECT_MEMORY.md` automáticamente (antes era manual: el agente
  reportaba, la sesión principal preguntaba si completar la memoria).
- `/ship` — corre `deploy-checker` (y `vercel-deploy` si hay algo
  bloqueante de env vars/build), resume en las tres listas, y ofrece
  arreglar lo automatizable.

Pendiente, sin urgencia:

- `/scaffold` — el árbol de decisión de `flujo-inicio-proyecto.md`
  ("qué tipo de proyecto → qué stack"). Baja prioridad: `install.sh`
  ya asume que el repo existe; esto serviría para el paso anterior
  (crear el repo), que sigue siendo manual.
