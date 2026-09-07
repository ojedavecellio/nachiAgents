---
name: og
description: Diseña, implementa o itera la Open Graph / social card del proyecto
---

Usá la skill `og-images` (`.cursor/skills/og-images/SKILL.md`).

1. Si no hay ruta `/api/og` ni `openGraph.images` — diseñá la card
   (Design Read → implementar → curl del PNG → mirarlo → iterar).
2. Si ya existe — renderizá el PNG, criticá contra los gates de la
   skill, y iterá. No reescribas de cero salvo que sea el template
   default o slop obvio.
3. Feedback de Nacho ("más bold", "se ve IA", "cambiá el copy"):
   mapearlo con la tabla de iteración de la skill. Un cambio por pase.
4. Si pide verlo en Vercel — deployment preview → tab Open Graph.

No instales `@vercel/og` en App Router. No des por hecha una card
sin haber visto el PNG.
