# Contexto base — Nacho

@PROJECT_MEMORY.md

Indie developer. "Vibe coder": construyo con asistencia de AI.
Prompts directos, sin relleno, sin "depende" sin explicar de qué
depende.

Cursor es el único agente. Ejecuta: lee el repo, sigue las skills
en `.cursor/skills/`, edita archivos. No armes prompts para pegar
en otro lado.

## Antes de arrancar cualquier tarea

Anunciar qué recursos se van a usar:
> "Para esto voy a usar: `[skill]`"

Si la tarea requiere varios, listarlos todos. Si no aplica ninguno,
no anunciar nada.

Leé y seguí `.cursor/skills/<nombre>/SKILL.md` cuando la tarea
encaje, y ejecutá.

## Lenguaje y tipado

TypeScript strict en todo, sin excepciones (`"strict": true`). Sin `any`
implícito — si el tipo es genuinamente desconocido, `unknown` + manejo
explícito.

## Frontend

React 19. Tailwind v4. Sin librerías UI completas como base (no MUI, no
Chakra, no Ant Design). Radix UI para primitivos accesibles cuando se
necesitan (dropdowns, dialogs, tooltips). shadcn como referencia de
implementación, no como dependencia.

Estado: local con `useState` hasta que duela. Context si el estado cruza
2-3 niveles de componentes con frecuencia. Zustand solo si Context no
alcanza y el estado es complejo. Nunca Redux.

Datos remotos: Server Components (`fetch` / cliente Supabase server)
para la primera pintura. TanStack Query (`@tanstack/react-query`) solo
cuando el cliente necesita polling, infinite scroll, cache cruzando
rutas u optimistic updates — prefetch + `HydrationBoundary`, no
`useState` + `useEffect`. Import desde `@tanstack/react-query`, no
"React Query" como paquete.

## Next.js

App Router. APIs, cache y proxy: skills oficiales de Next
(`npx skills add vercel/next.js`). No hay receta local — ellos las
actualizan. `npx skills update` cuando haga falta.

## Animación

GSAP para scroll narrativo, timelines, pin de secciones — skills
oficiales (`npx skills add greensock/gsap-skills`: `gsap-react`,
`gsap-scrolltrigger`, `gsap-timeline`, etc.). Motion (`motion/react`)
para transiciones de componentes/gestos. Lenis para smooth scroll.
No mezclar los tres sin razón. No instalar `framer-motion`; el paquete
es `motion`.

Three.js / R3F: sin receta local (no hay skill oficial que valga la
pena copiar). Docs actuales de R3F. v9 es estable; v10 (WebGPU) sigue
en alpha — no en producción. Solo si el brief lo pide; CSS o un video
loop si alcanza.

## Diseño visual

Despacho — una skill de look por tarea, no las cuatro juntas:

- **Página existente que "parece IA" / punch list** → `hallmark`
  (checklist de 4 ejes). No overridear un design system cerrado.
- **Landing / portfolio / redesign greenfield** → `taste-skill`
  (dials + pre-flight). No dashboards ni tablas.
- **UI de producto con look Geist / deployada en Vercel** → `vercel-ui`.
- **Motion de un componente** (modal, botón, gesture) → `emil-design-eng`.
- **Card al compartir** → `og-images`.

`gsap` / R3F definen cómo se mueve, no el look — GSAP via skills
oficiales, Three.js via docs actuales. Sin receta local.
Impeccable (`npx impeccable install`) es un pase de polish aparte,
no se copia en el install.

## IA / LLM

Claude (`claude-sonnet-4-6` como referencia actual — verificar si cambió)
como modelo default para features de producto. OpenAI solo con razón
específica. La API key NUNCA va al cliente — siempre server-side. Tipar
o validar con zod las respuestas del LLM, sin `any`.

## Base de datos / Auth

Supabase como primera opción (Auth + Postgres + Storage + RLS). Sin ORM
por defecto — SQL directo o cliente Supabase. Prisma/Drizzle solo si la
complejidad del schema lo justifica explícitamente. RLS activado en toda
tabla con datos de múltiples usuarios — no es automático, hay que
activarlo explícitamente por tabla.

Supabase Auth para cualquier proyecto con usuarios reales, sin
excepciones. Solución casera (HMAC, secreto en cookie) solo para
herramientas personales de un solo usuario.

## Deploy

Vercel para todo lo web, GitHub conectado para auto-deploy en push a
`main`. Variables `NEXT_PUBLIC_*` solo para lo que puede ser público —
nunca `service_role` con ese prefijo. Cambios en variables `NEXT_PUBLIC_*`
requieren redeploy (se embeben en build time). Sitio público:
`metadataBase` + OG 1200×630 (`next/og`). Después del deploy, revisar
la card en el tab Open Graph del deployment. Skill `og-images` para
diseñarla e iterarla — no inventar un PNG genérico.

## Git

`cyp` = commit + push. Cuando Nacho dice `cyp`, seguí `git-commits`
(Conventional Commits en inglés), commit, y push a origin.

## Convenciones de proyecto

Feature-based, no MVC (`components/dominio/`, no `views/` + `controllers/`).
Un archivo = una responsabilidad — más de 400 líneas es señal de separar.
`.env.example` siempre presente con todas las variables sin valores
reales. Sin comentarios obvios — los comentarios explican el por qué, no
el qué.

## Testing

Mínimo, no cero. Auth, pagos, lógica de negocio core, decisiones
irreversibles: sí. UI y componentes visuales: no.

## Recommended tools

Herramientas externas para usar en momentos puntuales, no como parte
del flujo default:

- **`npx react-doctor@latest`** — anti-patterns en la capa de React
  (re-renders, hooks mal usados, memoization faltante). Complementa a
  `nextjs-audit`, que cubre el stack completo (seguridad, routing,
  data fetching) pero no entra tan profundo en React puro. Correr
  antes de un `/ship` si hubo cambios grandes de componentes.
- **Figma** — si hay un MCP de Figma conectado en esta sesión, usalo
  para traer specs (tokens, medidas, assets) cuando hay que implementar
  1:1. Si no está conectado, no inventes el diseño desde una URL.

## Lo que se evita siempre

Redux, ORMs como primera opción, librerías UI completas, API keys en el
cliente, TanStack Start como framework base (si Lovable lo genera,
migrar a Next.js antes de iterar), `any`, dependencias para cosas que
la plataforma ya resuelve.

## Memoria del proyecto

`PROJECT_MEMORY.md` (importado arriba) es el estado vivo y específico
de este proyecto. Al arrancar cada sesión, leerlo primero.

Si está vacío o solo tiene el template sin llenar — antes de hacer
cualquier otra cosa, preguntarle a Nacho:
> "PROJECT_MEMORY.md está vacío. Contame el problema que resuelve
> esta app y qué está construido hasta ahora, para tener contexto
> antes de arrancar."

Después de un cambio significativo, actualizarlo.

## Flujos de trabajo

Leé y seguí `.cursor/skills/<nombre>/SKILL.md`, y ejecutá.

**Auditoría del proyecto** → skill `project-auditor`. Si el proyecto
es Next.js + Supabase, después correr `nextjs-audit` (deep-dive).

**Antes de deployar** → skill `deploy-checker`.

**Conectar Supabase** → skill `supabase-setup`.

**Build que falla en Vercel / env vars** → skill `vercel-deploy`.

**Performance / Lighthouse** → skill `performance-auditor`.

**Idea cruda de producto/feature** → skill `product-discovery`
(research, no código de producto). Si señala un riesgo sin validar,
usar `lean-experiments` antes de seguir.

**Convertir una idea validada en algo construible** → skill
`feature-spec`. El spec se pega en `PROJECT_MEMORY.md` o se usa como
contexto para construir la feature — no construir hasta que haya spec.

**Validar un flujo de UX antes de construirlo posta** → skill
`rapid-prototype` — genera un HTML desechable, no toca el proyecto
real.

**OG / card al compartir** → skill `og-images` (o `/og`). Diseñar,
implementar `/api/og`, curl del PNG, mirarlo, iterar. En Vercel: tab
Open Graph del deployment.

**Lovable / v0** → si el output es TanStack Start, migrar a Next.js
antes de iterar. Lovable pone `robots: { index: false }` por defecto —
sacarlo al lanzar si corresponde.
