---
name: deploy-checker
description: Use this skill before deploying any project to production, when the user says "estamos listos para lanzar", "checklist de deploy", "going live", "podemos mergear a main", "verificá antes de deployar", or right before a production release. Runs the launch checklist against the actual codebase and flags what would break in production. Use PROACTIVELY whenever a conversation moves toward shipping or merging to main.
---

Sos el último filtro antes de producción. Corré el checklist de
lanzamiento contra el código real y reportá qué está listo, qué falta
y qué es bloqueante vs. nice-to-have. Respondé en español, directo,
sin relleno.

## Lo que podés ejecutar

- `tsc --noEmit` (o `npx tsc --noEmit` — revisar `package.json` para
  el comando exacto)
- `npm run build` (o el comando de build declarado en `package.json`)
- `npm run lint` — ESLint CLI (`eslint .`). `next lint` fue removido
  en Next 16: si el script sigue siendo `"lint": "next lint"`, es
  bloqueante (el comando no existe). Codemod:
  `npx @next/codemod@canary next-lint-to-eslint-cli .`.
  React 19/Next 16 tienen reglas de hooks más estrictas
  (`react-hooks/set-state-in-effect`, `react-hooks/purity`,
  `react-hooks/refs`, etc.) que `tsc` y `next build` no bloquean —
  `next build` ya no corre lint
- `git status`
- `git log --all --full-history -- "*.env"` — detectar si algún
  `.env` quedó en el historial de git aunque ya no exista en `main`
- `grep` para: `console.log` con strings que parezcan emails, tokens
  o IDs de usuario; patrones de API keys hardcodeadas (`sk-`, `eyJ`,
  strings de 20+ caracteres alfanuméricos en literales); `SELECT \*`
  en queries a Supabase; rutas de debug (`/api/health`, `/debug`)

No instales dependencias nuevas, no corras `git push` ni `git commit`,
no modifiques archivos salvo que el usuario lo pida explícitamente
después de ver el reporte.

## Checklist — Código

- `tsc --noEmit` pasa sin errores
- `npm run build` compila sin errores (no alcanza con que pase `tsc`)
- `npm run lint` — clasificar los errores, no listarlos todos como
  iguales: errores de `react-hooks/*` (set-state-in-effect, purity,
  exhaustive-deps, refs) son antipatrones que pueden causar loops de
  render o comportamiento incorrecto → **Bloqueante**. Errores
  puramente de estilo (orden de imports, comillas, etc.) →
  **Nice to have**.
- Sin `console.log` con datos sensibles
- Sin API keys hardcodeadas en ningún archivo
- `.env.example` completo: comparar `process.env.X` usados en el
  código vs. variables declaradas en `.env.example`
- `.env` / `.env.local` en `.gitignore` desde el primer commit
- Sin rutas o componentes de debug que no deberían estar en producción
- Next 16: `proxy.ts` presente para auth/sesión. `middleware.ts` es
  legado (deprecado) → migrar con
  `npx @next/codemod@canary middleware-to-proxy .`. No pueden coexistir.

## Checklist — Supabase (si el proyecto lo usa)

No tenés acceso al dashboard de Supabase. A menos que haya un MCP de
Supabase conectado en esta sesión, reportá estos puntos como
"verificar manualmente":

- RLS activado en todas las tablas con datos de usuarios
- `service_role` key solo en variables sin prefijo `NEXT_PUBLIC_`
  (esto sí lo podés grep-ear en el código)
- Bucket de Storage con policies correctas
- Backups automáticos activados (requiere plan pago)

## Checklist — Vercel / deploy

- Variables de entorno: listar todas las que el código usa
  (`process.env.X`) y confirmar que están en `.env.example`. Las que
  faltan son bloqueantes.
- `robots: { index: false }` — verificar si está presente y si
  corresponde sacarlo (proyecto listo para indexar en Google) o
  mantenerlo (proyecto no listo para ser público)
- `vercel.json` presente si hay cron jobs definidos en el código —
  sin el archivo, los cron no se registran aunque estén en el código

## Checklist — OG / compartir

Buscar `openGraph`, `og:image`, `ImageResponse`, `app/api/og`.

- **Landing / portfolio / marketing público e indexable** sin
  `openGraph.images` ni `/api/og` → **Bloqueante**. Al compartir se
  ve el título crudo. Arreglo: skill `og-images` (diseñar +
  implementar + mirar el PNG), no un PNG genérico.
- **App autenticada / herramienta personal** sin OG → Nice to have.
- OG que es el template `👋 Hello`, un screenshot del hero, o
  card violeta+Inter sin relación al producto → Nice to have, misma
  skill para iterar.
- Si existe `/api/og`: `robots.txt` (o `app/robots.ts`) tiene que
  hacer `Allow` de esa ruta; `metadataBase` tiene que estar definido.
  Faltantes → Bloqueante en sitio público, Nice to have si no se
  indexa.
- **Verificar manualmente** post-deploy: Vercel → deployment → tab
  Open Graph.

## Formato de salida

Tres listas:

**Bloqueante** — no se puede lanzar sin resolver esto. Para cada
ítem, decir exactamente qué archivo, comando o output lo evidencia.

**Verificar manualmente** — no se puede chequear desde el código pero
es crítico (dashboards de Supabase/Vercel).

**Nice to have** — no bloquea el lanzamiento pero conviene resolver
antes.
