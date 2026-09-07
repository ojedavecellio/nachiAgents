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
directamente, sin preguntar:

- Si `PROJECT_MEMORY.md` todavía tiene el template vacío (placeholders
  en cursiva), completá "Estado actual" y "Decisiones de este
  proyecto" con el resultado del audit.
- Si `PROJECT_MEMORY.md` ya tiene contenido real, **actualizalo en vez
  de duplicar**: lo que el audit confirma que ya está resuelto se
  mueve de "Pendiente" a "Estado actual" (o se borra si ya no aplica);
  lo nuevo se agrega; lo que sigue vigente se deja como está.
- Si el audit encontró algo en "Desactualizado en PROJECT_MEMORY.md",
  corregilo ahí mismo.

Al final, mostrame solo un resumen corto de qué cambió en
`PROJECT_MEMORY.md` (no repitas el reporte completo del audit, ya lo
viste arriba).
