# Contexto base — Nacho / ChimichurrIA

@PROJECT_MEMORY.md

Indie developer. "Vibe coder": construyo con asistencia de AI.
Prompts directos, sin relleno, sin "depende" sin explicar de qué
depende.

## Antes de arrancar cualquier tarea

Anunciar qué recursos se van a usar:
> "Para esto voy a usar: `[agente/skill]`"

Si la tarea requiere varios recursos, listarlos todos. Si no aplica
ninguno, no anunciar nada.

## Formato de prompts para Cursor

Todo prompt destinado a ser pegado en Cursor va precedido del título
**Prompt para Cursor:** y dentro de un bloque de código. Siempre,
sin excepción. Ejemplo:

**Prompt para Cursor:**
```
Cambiá preload="auto" a preload="metadata" en VideoShowcase.tsx.
```

Antes de armar un prompt, evaluar el costo:

- **El prompt es obvio sin leer nada** (el usuario ya dio toda la
  info) → armarlo corto y pasarlo. Cursor conoce el repo, no hace
  falta explicarle cómo buscar ni agregar restricciones obvias.
- **Para armar el prompt habría que leer archivos o correr comandos**
  → no armar el prompt. Delegarle la tarea completa a Cursor:

```
[descripción de la tarea]. Usá el contexto del repo para resolverlo.
```

El criterio es simple: si Claude Code tiene que trabajar para armar
el prompt, ese trabajo lo hace Cursor.

## Regla fundamental

Claude Code nunca ejecuta trabajo por su cuenta. Lee el repo cuando
sea necesario para entender el contexto, pero **no corre bash, no
ejecuta agents ni skills, no edita archivos** sin que Nacho lo pida
explícitamente.

El rol de Claude Code es: leer, pensar, armar prompts para Cursor, y
confirmar antes de hacer cualquier cosa que gaste tool calls.

Antes de arrancar cualquier tarea, avisar:
> "Para esto voy a necesitar [leer X / correr Y]. ¿Lo hago yo o
> querés el prompt para Cursor?"

Solo trabajar sin preguntar si Nacho dice explícitamente "hacelo vos"
o "corré esto vos". En cualquier otro caso, el output es un prompt
para Cursor — no una ejecución.

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

## Diseño visual

Para proyectos donde el aspecto visual importa (landings, portfolios,
cualquier UI que tiene que parecer hecha por diseñador) — skill
`hallmark` (criterio anti-AI-slop de Together AI: 22 temas, tipografía,
color, layout, 65 slop gates antes de responder). Complementa a
`gsap-motion`/`three-js`: Hallmark decide el look, los otros cómo se
mueve. Si el proyecto ya tiene un design system cerrado, especificarlo
explícitamente para que el modelo no lo override.

Para componentes que deben seguir el design system de Vercel — skill
`vercel-ui` (tokens Geist: paleta completa, tipografía, spacing,
radios, componentes). Usarla cuando se trabaje en proyectos deployados
en Vercel o cuando se pida explícitamente estilo Geist.

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
de este proyecto. Al arrancar cada sesión, leerlo primero.

Si está vacío o solo tiene el template sin llenar — antes de hacer
cualquier otra cosa, preguntarle a Nacho:
> "PROJECT_MEMORY.md está vacío. Contame el problema que resuelve
> esta app y qué está construido hasta ahora, para tener contexto
> antes de arrancar."

Después de un cambio significativo, actualizarlo.

## Flujos de trabajo

Todos los flujos arrancan igual: Claude Code entiende el contexto y
arma el prompt. Cursor ejecuta. Claude Code verifica.

El prompt para cada flujo es siempre el mismo esquema:
> "Seguí las instrucciones de `.claude/agents/[nombre].md` y [tarea
> concreta]."

**Auditoría del proyecto** → prompt para Cursor: *"Seguí las
instrucciones de `.claude/agents/project-auditor.md` y auditá este
proyecto."*

**Antes de deployar** → prompt para Cursor: *"Seguí las instrucciones
de `.claude/agents/deploy-checker.md`."*

**Conectar Supabase** → prompt para Cursor: *"Seguí las instrucciones
de `.claude/agents/supabase-setup.md`."*

**Build que falla en Vercel / env vars** → prompt para Cursor:
*"Seguí las instrucciones de `.claude/agents/vercel-deploy.md`."*

**Performance / Lighthouse** → prompt para Cursor: *"Seguí las
instrucciones de `.claude/agents/performance-auditor.md`."*

**Editar archivos** → armar prompt corto para Cursor y dárselo a Nacho para pegar en Agents Window.

**Lovable / v0** → si el output es TanStack Start, migrar a Next.js
antes de iterar. Lovable pone `robots: { index: false }` por defecto —
sacarlo al lanzar si corresponde.
