# Contexto base: Nacho

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
encaje, y ejecutá. Al arrancar, leé también `PROJECT_MEMORY.md`.

## Stack fijo

En la web, todos los proyectos nuevos usan esto, salvo que Nacho
pida otra cosa y quede anotado en `PROJECT_MEMORY.md`.

- Next.js 16, App Router
- React 19
- TypeScript estricto (`"strict": true`), sin `any`. Si el tipo es
  desconocido: `unknown` y manejo explícito.
- Tailwind v4
- GSAP vía `useGSAP` de `@gsap/react`. Scroll y timelines: skills
  oficiales (`npx skills add greensock/gsap-skills`).
- Supabase (Auth, Postgres, Storage, RLS)
- Resend para mail transaccional, siempre en el servidor
- Vercel, GitHub conectado, auto-deploy al pushear a `main`
- shadcn/ui es la base real de componentes. Se copian al repo, sobre
  Radix, y se tematizan con nachi-style. No es un paquete cerrado.
  Nada de MUI, Chakra, Ant Design, ni del Vercel UI SDK.

Estado: `useState` hasta que no alcance. Después Context. Zustand
solo si hace falta de verdad. Nunca Redux.

Datos remotos: el servidor pinta primero. TanStack Query
(`@tanstack/react-query`) solo cuando el cliente necesita recargar,
scroll infinito o actualizaciones al toque. Prefetch +
`HydrationBoundary`. No `useState` + `useEffect` para la primera
pintura.

Movimiento: GSAP para scroll largo y timelines. Motion (`motion`,
no `framer-motion`) para botones, transiciones y gestos. Lenis para
el scroll suave (duración 1.1). No mezclar los tres sin motivo.

Celular: variante Expo / React Native. Automatización: variante
Python / FastAPI.

APIs, cache y proxy de Next: skills oficiales
(`npx skills add vercel/next.js`). `proxy.ts`, no `middleware.ts`.

Three.js / R3F solo si el brief lo pide. Docs actuales. V9 es
estable. V10 (WebGPU) sigue en alpha: no en producción.

## nachi-style

En una frase: sitios y apps tipo Apple, con vidrio solo donde flota,
plata o neutros, mucho aire, tipografía clara y movimiento suave. La
base sale de sladstudio.com. El detalle (tokens, tipo, una sola
escala de radios y sombras, receta de vidrio, prohibiciones) está
en la skill `nachi-style`.

El vidrio está permitido cuando está bien hecho: chrome que flota
(nav, pastilla, overlay, barra de contacto, control sobre foto o
video). No decora cards ni el fondo de la página.

La paleta de un proyecto se puede pisar en `PROJECT_MEMORY.md` si
el brief lo pide (crema editorial, colores de app iOS, marca de un
cliente). No se improvisa.

`emil-design-eng` es solo el motion de un componente, y no pisa
estos tokens. `taste-skill` no redefine la paleta. `vercel-ui` no
es el look default y no es el Vercel UI SDK.

## Prohibiciones

No van como default. Huelen a página hecha por IA. El vidrio sí,
solo como chrome, con la receta de `nachi-style`.

- Em dash o en dash en los textos que se ven.
- Borde o raya de color en el canto izquierdo de una card común.
  Eso es para alertas, no para decorar.
- Degradés violeta, indigo o celeste. Texto con degradé. Halos de
  color. Neón sobre negro.
- Inter, Geist o Space Grotesk sin haberlo pensado. Geist es el
  default nachi-style. Inter solo si el proyecto lo elige y queda
  escrito.
- El hero de siempre: pastillita arriba, título enorme al centro,
  botón "Get Started", orbe de color atrás.
- Tres cards iguales con un ícono arriba, o la plantilla fija de
  hero, logos, tres cards, testimonios, precios y preguntas.
- El mismo radio grande en cards, inputs, botones e imágenes.
- Vidrio en el contenido, en el fondo, o en todas las cards.
- Ventana falsa de Mac, números inventados, badges "New" o
  "Popular" que no son verdad, slogans vacíos, o la fórmula "no es
  solo esto, es aquello".
- Emojis en headings. "Unlock", "Elevate", "Seamless", "Effortless".
  Testimonios inventados.
- Las franjas violeta y celeste del logo de slad. Son de esa marca.

## Animaciones

Curva: `cubic-bezier(0.22, 1, 0.36, 1)`. Rápido 180 ms. Normal
280 ms. Lento 520 ms. Toque de un botón: 140 a 200 ms, escala 0.97
o 0.95.

GSAP se escribe con `useGSAP` de `@gsap/react`. No uses
`useLayoutEffect` + `gsap.context`.

El hero se ve en el primer frame. Nada de `opacity: 0` en el
candidato a LCP, ni en CSS ni con `gsap.set` antes de pintar.
Animá el transform. No escondas el texto para "revelarlo" después
de hidratar.

Si la persona pidió menos movimiento (`prefers-reduced-motion`),
se apaga todo: tiempos a cero, sin Lenis, sin grano animado.

No el mismo fade hacia arriba en cada bloque. No rebotes elásticos.

## Gotchas de Next 16

- **GSAP y LCP.** `useGSAP` corre después del primer paint. Si el
  CSS del hero arranca en `opacity: 0`, el LCP queda escondido o
  se atrasa. El candidato a LCP nace visible.
- **`next/font`.** La fuente (Geist por default, u otra si quedó
  escrita) se carga con `next/font` en el scope del módulo, una
  familia, aplicada en `<html>`. No un `<link>` a Google Fonts. No
  llames al loader adentro de un componente. No precargues un
  montón de pesos.
- **`connection()` y Cache Components.** Con `cacheComponents`, la
  página se prerenderiza. `cookies()`, `headers()` y cualquier
  dato del request necesitan `connection()` de `next/server`, o
  tiran en el prerender. No metas `cookies()` adentro de
  `"use cache"`. No uses `export const dynamic = "force-dynamic"`
  ni `unstable_cache` como default. Pasá el dato del request como
  argumento a la función cacheada.

## Flujo de trabajo

- El trabajo corre en un agente de Cursor en la Mac de Nacho. No
  en la nube, salvo que él pida lo contrario.
- Modelo: el Grok más nuevo que haya. No una versión fija, salvo
  que Nacho pida otro.
- `/no-test` por default. Tests sí en login, pagos, lógica
  importante y cosas irreversibles. No en la interfaz visual, salvo
  que el tema sea sensible.
- Cambio chico: directo a `main`, después de que pasen lint y build.
- Cambio grande: branch, PR, y el ok de Nacho antes de mergear.
- Antes de tocar producción, preguntar. Base de datos, deploy,
  variables de entorno, dominios, cualquier borrado. Si Nacho lo
  pidió explícito, eso cuenta como sí.
- `cyp` = commit y push. Mensajes en inglés, Conventional Commits.
  Skill `git-commits`.

## IA / LLM en el producto

El modelo default de una feature es el Grok más nuevo. OpenAI solo
con una razón específica. La API key nunca va al cliente. Tipá o
validá con zod las respuestas, sin `any`.

## Base de datos / Auth

Supabase como primera opción (Auth + Postgres + Storage + RLS). Sin
ORM por defecto: SQL directo o el cliente de Supabase. Prisma o
Drizzle solo si el esquema lo justifica y queda escrito. RLS
activado en toda tabla con datos de más de un usuario. No es
automático.

Supabase Auth para cualquier proyecto con usuarios reales. Una
solución casera (HMAC, secreto en cookie) solo para una herramienta
personal de un solo usuario.

## Deploy

Vercel para la web. `NEXT_PUBLIC_*` solo para lo que puede ser
público. Nunca `service_role` ni la key de Resend con ese prefijo.
Cambiar una `NEXT_PUBLIC_*` pide redeploy (se embebe en el build).

Sitio público: `metadataBase` + OG 1200x630 (`next/og`), con la
pieza de `lib/og.tsx` y la skill `og-images`. Después del deploy,
mirá la card en el tab Open Graph del deployment.

## Convenciones de proyecto

Feature-based, no MVC (`components/dominio/`, no `views/` +
`controllers/`). Un archivo = una responsabilidad. Más de 400
líneas es señal de separar. `.env.example` siempre presente, sin
valores reales. Los comentarios explican el por qué, no el qué.

Los primitivos viven en `components/ui/` (shadcn, tematizados).
Las piezas compartidas (`Reveal`, `SmoothScroll`, `SiteFooter`,
`GlassNav`, `site-metadata`, `og`) las copia el instalador. El
CSS de tokens es `styles/nachi.css`, importado desde
`app/globals.css`.

## Testing

Mínimo, no cero. Auth, pagos, lógica de negocio core, decisiones
irreversibles: sí. UI y componentes visuales: no, salvo un tema
sensible.

## Recommended tools

- **`npx react-doctor@latest`**: anti-patterns de React. Correr
  antes de un `/ship` si hubo cambios grandes de componentes.
- **Figma**: si hay un MCP de Figma conectado, usalo para specs.
  Si no está, no inventes el diseño desde una URL.

## Lo que se evita siempre

Redux, ORMs como primera opción, librerías UI completas, el Vercel
UI SDK, API keys en el cliente, TanStack Start como framework base
(si una herramienta lo genera, migrar a Next.js antes de seguir),
`any`, dependencias para cosas que la plataforma ya resuelve.

## Memoria del proyecto

`PROJECT_MEMORY.md` es el estado vivo de este repo: qué hay hoy,
qué se decidió acá (por ejemplo una paleta distinta), qué falta,
qué ya se rompió, y reglas aprendidas. No es un historial de
commits.

Tope: unas 150 líneas, en bullets. Si se pasa, se comprime: se
recorta lo viejo y se deja lo que evita arrancar de cero. `/audit`
comprime. No appendea una sección nueva cada vez.

Si está vacío o es el template sin llenar, antes de hacer cualquier
otra cosa preguntale a Nacho:
> "PROJECT_MEMORY.md está vacío. Contame el problema que resuelve
> esta app y qué está construido hasta ahora, para tener contexto
> antes de arrancar."

Después de un cambio importante, actualizalo.

## Flujos de trabajo

Leé y seguí `.cursor/skills/<nombre>/SKILL.md`, y ejecutá.

**Look, vidrio, componentes** → skill `nachi-style`. Chequeo de
slop → `/slop`.

**Auditoría** → skill `project-auditor`. Si es Next.js, después
`nextjs-audit`. `/audit` escribe la memoria y la comprime.

**Antes de deployar** → skill `deploy-checker`, que incluye el
pase de `/slop`.

**Conectar Supabase** → skill `supabase-setup`.

**Build que falla en Vercel / env vars** → skill `vercel-deploy`.

**Performance / Lighthouse** → skill `performance-auditor`.

**Idea cruda** → skill `product-discovery` (research, no código de
producto). Si señala un riesgo sin validar, `lean-experiments`.

**Idea validada a algo construible** → skill `feature-spec`. No
construir hasta que haya spec.

**Validar un flujo de UX** → skill `rapid-prototype`. HTML
desechable. No toca el proyecto real.

**OG** → skill `og-images` (o `/og`).

**Lovable / v0** → si el output es TanStack Start, migrar a Next.js
antes de iterar. Si dejan `robots: { index: false }`, sacarlo al
lanzar cuando corresponda.
