---
name: og-images
description: Designs, implements, and iterates Open Graph / social cards with next/og (ImageResponse) so shares on iMessage, X, LinkedIn, and Slack look designed—not like a screenshot or the default 👋 Hello template. Use when building a public landing or portfolio, adding metadata/og:image/twitter:card, when the user says "OG", "open graph", "social card", "imagen al compartir", "armame el OG", "iterá el OG", or before shipping a public site.
---

# OG images — diseñar, renderizar, iterar

El trabajo no es pegar el snippet de Vercel. Es **hacer una card de
1200×630 que se sienta del producto**, mirar el PNG, y iterar hasta
que no parezca slop. Misma barra que `hallmark` / `taste-skill`, recorte
de social card.

## Cuándo (proactivo)

Landings, portfolios, marketing, cualquier página pública que se
vaya a compartir. Cargar esta skill **sin que la pidan** cuando se
construye o se shipea algo indexable.

No aplica a dashboards internos ni herramientas de un solo usuario.

## Qué es una buena OG

Una pieza gráfica. No un screenshot del hero. No la home en miniatura.

Cabe en un thumbnail de ~400px (Slack, iMessage) y sigue leyéndose.

Inventario máximo:

- wordmark o logo
- **un** titular (≤ ~7 palabras, el claim del producto)
- kicker opcional (dominio, categoría) — un solo elemento chico

Nada más. Sin nav, sin tres feature cards, sin párrafo, sin CTA,
sin mockup del site.

**Design Read** (una línea, antes de codear), mismo espíritu que
`taste-skill`:

> "Card editorial, wordmark arriba-izquierda, titular 72px a la
> izquierda, acento de la marca en una barra, fondo del sitio no
> un mesh violeta."

Si el proyecto tiene design system (`vercel-ui` / Geist, o tokens
propios), usarlo. Hallmark no overridea un sistema cerrado.

## Anti-slop (gates de card)

Rompe la card — rehacer, no “ajustes”:

- Template `👋 Hello` / fondo blanco / texto centrado default
- Screenshot o recorte del hero
- Gradiente violeta/indigo + Inter “porque sí”
- Todo centrado en columna, padding uniforme, cara de template
- Texto < 32px (desaparece en el feed)
- Más de un bloque de copy además del titular
- Emoji decorativo (👋✨🚀) salvo que la marca lo use de verdad
- `display: grid` (Satori no lo soporta — la imagen sale mal o falla)

La card tiene que **reconocerse como el mismo producto** que la web:
misma familia tipográfica, misma paleta, mismo logo. Si la web es
oscura y editorial, la OG no es una card blanca de SaaS genérico.

Tipografía: la del proyecto, cargada como `ttf`/`otf`/`woff`. Nunca
dejar la default de Satori. Ver [reference.md](reference.md).

Layout: flexbox, asimetría leve (wordmark vs titular), padding
generoso (~80px). Contraste alto — la card vive sobre chrome blanco
o oscuro del feed, no sobre tu landing.

## Implementación

App Router: `import { ImageResponse } from 'next/og'`. **No instalar
`@vercel/og`** — ya viene. Ruta: `app/api/og/route.tsx`.

Node.js runtime (default). `fs.readFile` para fonts/logo locales.
No forzar `runtime = 'edge'` salvo razón concreta.

Tamaño: **1200×630**. Parámetro `title` (y los mínimos que cambien
por página). Una sola ruta, no una por post.

Templates, fonts, `metadataBase`, `robots.txt`: [reference.md](reference.md).

CSS: solo flexbox y el subset de Satori. Cada contenedor con
`display: 'flex'`. Si el JSX pelea con CSS, iterar en
[og-playground.vercel.app](https://og-playground.vercel.app/) y
traer el resultado a la ruta.

## Loop (obligatorio — no dar por hecha una card sin verla)

```
Diseñar → implementar → renderizar PNG → mirarlo → iterar
```

1. **Leer el producto** — color, font, logo (`public/`), headline
   real (no lorem). Una línea de Design Read.
2. **Implementar** `app/api/og/route.tsx` + metadata (`openGraph` +
   `twitter.card: 'summary_large_image'`) + `metadataBase` +
   `Allow: /api/og` en `robots.txt` si la ruta existe.
3. **Renderizar y mirar.** Con el dev server arriba:

   ```bash
   curl -sS "http://localhost:3000/api/og" -o /tmp/og-preview.png
   ```

   Leer `/tmp/og-preview.png` como imagen. Criticar contra los gates.
   Si el server no está, pedirlo (`pnpm dev`) — no inventar cómo se
   ve. Query params: `/api/og?title=...` (URL-encoded).
4. **Iterar el JSX** hasta pasar los gates. Un cambio por pase
   cuando Nacho da feedback (abajo). Volver a curl + mirar.
5. **Post-deploy, Vercel.** Deployment → tab **Open Graph**: card +
   el resto de metadata, antes de promover a production. Si el MCP
   de Vercel está autenticado, usarlo para ubicar el deployment;
   el tab sigue siendo el preview visual.
6. **Crawlers** (si Nacho está debuggeando un share que no
   actualiza): Facebook Sharing Debugger / LinkedIn Post Inspector /
   Twitter Card Validator. Cachean — hay que re-scrape.

No exportar un PNG de Figma y servir ese archivo, salvo que el
contenido **nunca** cambie (marca única, un solo título). Default:
`ImageResponse` dinámico.

## Vocabulario de iteración

Cuando Nacho pide cambios, mapear a JSX — no rediseñar de cero:

| Dice | Hacer |
|---|---|
| más bold | titular más grande, más contraste, menos padding, acento más presente |
| más quiet / más quieto | más aire, titular más chico, sacar barra/acento |
| se ve IA / genérico | matar centro + gradient + Inter + emoji; traer type/color/logo del sitio |
| cambiá el copy | `title` param / default string — no tocar layout |
| más marca | logo más grande o wordmark, color de acento del producto |
| no se lee | subir peso/tamaño, subir contraste, cortar el titular |
| iterá en Vercel | deploy preview → tab Open Graph; volver con lo que se ve ahí |

Si pide direcciones distintas (no un ajuste): **máximo 2**.
Implementar la que elija, no las dos.

## Checklist rápido

- [ ] Design Read dicho antes de codear
- [ ] 1200×630, flexbox, font del proyecto cargada
- [ ] Logo + un titular (+ kicker opcional)
- [ ] PNG renderizado y **visto**, no asumido
- [ ] `metadataBase` + `openGraph.images` + `twitter: summary_large_image`
- [ ] `robots.txt` Allow de `/api/og`
- [ ] Después del deploy: tab Open Graph de Vercel
