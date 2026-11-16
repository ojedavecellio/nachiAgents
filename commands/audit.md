---
name: audit
description: Audita el estado del proyecto con project-auditor y actualiza PROJECT_MEMORY.md con los hallazgos
---

Leé y seguí `.cursor/skills/project-auditor/SKILL.md` para auditar
el estado actual de este proyecto.

Si el proyecto es Next.js (`next.config.*` o dependencia `next`),
después leé y seguí `.cursor/skills/nextjs-audit/SKILL.md`. El reporte
detallado puede ir a `AUDIT-REPORT.md`; en `PROJECT_MEMORY.md` solo
un resumen de críticos / pendientes, no el scorecard completo.

Cuando termine, escribí los hallazgos en `PROJECT_MEMORY.md`
directamente, sin preguntar. Bullets. Tope de unas 150 líneas.
Comprimí. No appendees un bloque nuevo por cada audit.

- Si `PROJECT_MEMORY.md` todavía tiene el template vacío (placeholders),
  completá "Estado actual" y "Decisiones de este proyecto" con el
  resultado del audit.
- Si ya tiene contenido, actualizalo sin duplicar. Lo que el audit
  confirma resuelto sale de "Pendiente" (pasa a "Estado actual" o se
  borra si ya no aporta). Lo nuevo entra. Lo vigente se queda.
- Si el audit encontró algo desactualizado, corregilo ahí mismo.
- "Reglas aprendidas" se mantiene. No la borres para hacer lugar.
  Ahí van las reglas que evitaron repetir un error.
- Si el archivo pasa de ~150 líneas, comprimí antes de terminar:
  sacá lo resuelto, uní duplicados, dejá solo lo que evita arrancar
  de cero. No es un historial de commits.

Al final, mostrame solo un resumen corto de qué cambió en
`PROJECT_MEMORY.md` (no repitas el reporte completo del audit, ya lo
viste arriba).
