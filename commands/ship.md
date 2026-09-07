---
name: ship
description: Corre el checklist de pre-deploy completo (deploy-checker) y resuelve bloqueantes de env vars/Vercel si aparecen
---

Leé y seguí `.cursor/skills/deploy-checker/SKILL.md` para correr el
checklist de pre-deploy completo contra el código real.

Si el reporte tiene bloqueantes relacionados con variables de entorno
faltantes, configuración de Vercel, o errores de build que necesiten
diagnóstico — leé también `.cursor/skills/vercel-deploy/SKILL.md` para
generar la lista exacta de qué configurar y por qué.

Al final:

1. Mostrame las tres listas (Bloqueante / Verificar manualmente / Nice
   to have).
2. Si hay bloqueantes que se pueden arreglar solos (lint, console.log
   con datos sensibles, `.env.example` incompleto), preguntame si
   querés que los arregle antes de seguir — no los arregles sin
   preguntar, a diferencia del audit esto puede tocar código que
   estabas editando.
3. Si falta OG en un sitio público, o la card es el template default /
   slop: no la inventes en el ship. Señalalo y usá la skill
   `og-images` (o `/og`) cuando Nacho pida arreglarla.
4. Si hubo cambios grandes de componentes React, corré
   `npx react-doctor@latest` y reportá antipatrones. No es bloqueante
   por sí solo.
