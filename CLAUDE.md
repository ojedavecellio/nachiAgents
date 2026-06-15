# Contexto base — Nacho / ChimichurrIA

@PROJECT_MEMORY.md

Indie developer + estudio chico (ChimichurrIA, 2 personas: Nacho diseña
y construye, FABS es technical/AI lead). "Vibe coder": construyo con
asistencia de AI. Prompts directos, sin relleno, sin "depende" sin
explicar de qué depende.

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

React Query para datos remotos cuando hay fetching real. No cachear a
mano con `useState` + `useEffect`.

## Animación

GSAP para scroll narrativo, timelines, pin de secciones. Framer Motion
para transiciones de componentes/gestos. Lenis para smooth scroll. No
mezclar los tres sin razón — uno principal, el otro solo donde el
primero no alcanza. Ver skill `gsap-motion` para setup y patrones
completos.

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
requieren redeploy (se embeben en build time).

## Convenciones de proyecto

Feature-based, no MVC (`components/dominio/`, no `views/` + `controllers/`).
Un archivo = una responsabilidad — más de 400 líneas es señal de separar.
`.env.example` siempre presente con todas las variables sin valores
reales. Sin comentarios obvios — los comentarios explican el por qué, no
el qué.

## Testing

Mínimo, no cero. Auth, pagos, lógica de negocio core, decisiones
irreversibles: sí. UI y componentes visuales: no.

## Lo que se evita siempre

Redux, ORMs como primera opción, librerías UI completas, API keys en el
cliente, TanStack Start como framework base (si Lovable lo genera,
migrar a Next.js antes de iterar en Cursor o Claude Code), `any`,
dependencias para cosas que la plataforma ya resuelve.

## Memoria del proyecto

`PROJECT_MEMORY.md` (importado arriba) es el estado vivo y específico
de este proyecto. Después de un cambio significativo (feature
terminada, fix con causa no obvia, decisión de arquitectura),
actualizarlo: mover de "Pendiente" a "Estado actual", anotar
decisiones y gotchas nuevos. No hace falta para cambios chicos.

Si `PROJECT_MEMORY.md` todavía tiene el template vacío (primera vez en
este proyecto), correr `project-auditor` y completar "Estado actual" y
"Decisiones de este proyecto" con el resultado antes de seguir — no
dejarlo vacío más de una sesión.

## Flujos de trabajo

**Proyecto existente sin contexto reciente en esta sesión** → usar el
subagente `project-auditor` antes de proponer cambios, features o
arquitectura. No asumir stack ni estructura.

**Antes de deployar a producción** → usar el subagente `deploy-checker`.

**Conectando o configurando Supabase** (schema, RLS, storage, errores
de conexión) → usar el subagente `supabase-setup`.

**Deploy a Vercel, configurar variables de entorno, o build que falla
en Vercel** → usar el subagente `vercel-deploy`.

**Página lenta, Lighthouse con Speed Index alto, o antes/después de
agregar Three.js, canvas o motion pesado** → usar el subagente
`performance-auditor`.

**Lovable / v0** → si el output es TanStack Start, migrar a Next.js
antes de iterar. Lovable pone `robots: { index: false }` por defecto —
sacarlo al lanzar si corresponde.
