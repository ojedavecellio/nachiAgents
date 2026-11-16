---
name: nachi-style
description: Look default de Nacho. Tokens dark/light, tipo, una escala de radios y sombras, receta de vidrio (permitido cuando es chrome), componentes shadcn tematizados, y la lista de prohibiciones. Usala al armar o retocar UI, landings, nav, cards, botones, diálogos, o cuando el resultado "parece hecho por IA". Reemplaza a hallmark.
---

# nachi-style

Sitios y apps tipo Apple. Vidrio solo donde flota. Plata o neutros.
Mucho aire. Tipografía clara. Movimiento suave. La base sale de
sladstudio.com (el look, no la marca). Apple HIG (materiales) y
Linear aportan el criterio: el vidrio es una capa que flota, la
estructura se siente y no se grita, en un producto el movimiento es
corto.

Esta skill absorbe el checklist que antes estaba en `hallmark`.
No hay un segundo pase de look. Si el proyecto ya escribió otra
paleta en `PROJECT_MEMORY.md`, esa manda.

Los primitivos están en `components/ui/` (shadcn sobre Radix, con
estos tokens). No instales el Vercel UI SDK. No uses MUI, Chakra
ni Ant Design.

## Tokens

Default oscuro. La plata es la misma en las dos paletas.

| Rol | Oscuro | Claro |
| --- | --- | --- |
| Fondo | `#07080a` | `#f4f4f2` |
| Superficie | `#0e1014` | `#ffffff` |
| Tinta | `#f2f2f0` | `#0c0d10` |
| Texto secundario | tinta al 55% | tinta al 58% |
| Texto suave | tinta al 28% | tinta al 30% |
| Vidrio de fondo | blanco al 7% | blanco al 42% |
| Vidrio más sólido | blanco al 10% | blanco al 62% |
| Borde del vidrio | blanco al 12% | blanco al 70% |

Plata: profundo `#626b74`, medio `#9aa4ae`, plata `#d7dee4`,
brillante `#f7f8f9`. El brillo del borde es blanco semitransparente.
El resplandor de fondo es plata, nunca violeta.

Clases y variables: `styles/nachi.css`. El tema claro es
`data-theme="light"` en `<html>`.

Overrides que sí se pueden, si el brief lo pide y queda en
`PROJECT_MEMORY.md`:

- App tipo iPhone: fondo `#f5f5f7`, tinta `#1d1d1f`, acento `#0071e3`.
- Landing editorial: crema y Manrope.
- Marca de un cliente: esos colores mandan. No fuerces la plata de slad.

## Tipo

Default: Geist, vía `next/font`, en el scope del módulo, una familia
precargada, aplicada en `<html>`. Geist Mono solo para código o un
easter egg. Máximo dos familias. Otra fuente (Manrope, Inter, el
sistema) solo si quedó escrita.

| Uso | Detalle |
| --- | --- |
| Etiqueta | 15 px, tracking abierto, color plata |
| Links de nav | 14 px, tracking abierto, tinta al 65%, más sólida en hover |
| Cuerpo de carta | 1.7 rem, 2.15 rem en pantallas grandes, interlineado 1.28, tracking -0.03 em |
| Título grande | 2 rem a 3.25 rem, interlineado 1.15, tracking -0.03 em, peso medio |

Salto de tamaño de verdad, no de 2 px. Títulos alineados a la
izquierda. En textos chicos, no uses pesos muy finos.

## Radios y sombras

Una sola escala. No el mismo radio en todo.

- Pastillas (nav, player, botones redondos): `9999px`.
- Barras grandes (footer de vidrio): `rounded-3xl` (1.5 rem).
- Cards de contenido: `1rem`.
- Inputs: `0.75rem`.
- Imágenes: no heredan el radio de la card.

Sombras chicas, o un brillo fino arriba (`inset 0 1px 0`). Nunca
una sombra más grande que el objeto. Foco de teclado: borde de 2 px,
tinta al 45%, un poco separado.

Aire: un site de estudio queda en `max-w-5xl`. Una landing más ancha
puede ir hasta 1400 px. Padding horizontal 20 px, 32 px en pantallas
grandes. Respetá el área segura del celular.

## Vidrio

Permitido cuando es chrome. Prohibido cuando decora el contenido.
La misma regla que slad y que Apple con Liquid Glass.

Sí:

- Nav flotante.
- Pastillas (player, interruptores).
- Overlays, menús y popovers.
- Una barra de contacto o de compra que flota.
- Controles sobre una foto o un video.

No:

- Cards de contenido, artículos, dashboards, secciones enteras.
- El fondo de la página.
- Tres capas de vidrio una arriba de la otra.
- Vidrio en toda la interfaz, borde violeta, resplandor de neón.
- `feDisplacementMap` y "liquid glass" de demo. No es esta receta.

Receta: `glass-nav` o `glass-chrome`, más `silver-rim`, más `pill`
si es una pastilla. Brillo fino arriba. Desenfoque de 16 a 18 px.
Un poco más de saturación. Fondo bajo. En claro, subí la opacidad
para que se pueda leer. La carta, el artículo o el panel van sobre
superficie sólida.

Si el proyecto tiene marca de cliente, el vidrio (si aparece) se
pinta con esos colores.

No copies al kit la marca de SLAD: logo, wordmark, etimología,
franjas del logo, slider de fotos, easter egg, ni textos de esa casa.

## Componentes

Se copia el patrón. Cada proyecto pone su logo, sus links y su
contenido.

| Pieza | Dónde | Nota |
| --- | --- | --- |
| `Button` | `components/ui/button.tsx` | Píldora, tinta sólida, sin degradé |
| `Card` | `components/ui/card.tsx` | Sólida, radio 1 rem, sombra chica, sin raya a la izquierda |
| `Input` | `components/ui/input.tsx` | Radio de control, no el de la card |
| `Dialog` | `components/ui/dialog.tsx` | Overlay puede ser vidrio. El panel es sólido |
| `GlassNav` | `components/glass-nav.tsx` | Pastilla centrada |
| `SiteFooter` | `components/site-footer.tsx` | Sólido por default. `glass` solo si flota |
| `MailtoLink` | `components/mailto-link.tsx` | Brillo plateado en hover |
| `ThemeToggle` | `components/theme-toggle.tsx` | Claro / oscuro. El botón con tirón de slad no es obligatorio |
| `Atmosphere` | `components/atmosphere.tsx` | Luz suave y grano muy bajo. No es un adorno |
| `SmoothScroll` | `components/smooth-scroll.tsx` | Lenis, 1.1. Se apaga con reduced motion |
| `Reveal` | `components/reveal.tsx` | `useGSAP`. El hero no arranca en opacity 0 |
| `useReducedMotion` | `hooks/use-reduced-motion.ts` | |
| `siteMetadata` | `lib/site-metadata.ts` | `metadataBase` + OG |
| `OgImage` | `lib/og.tsx` | 1200x630, plata sobre negro, sin degradé |

`components.json` está en la raíz para el CLI de shadcn. Los
componentes nuevos de shadcn se copian y se tematizan con estos
tokens. No se dejan con el zinc de fábrica.

## Movimiento

| Caso | Valor |
| --- | --- |
| Hover, color, botón | 180 ms |
| Tema, asentamiento | 280 ms |
| Algo que llega con calma | 520 ms |
| Toque | 140 a 200 ms, escala 0.97 o 0.95 |
| Scroll largo o menú a pantalla completa | GSAP con `useGSAP` |
| Scroll de la página | Lenis, duración 1.1 |

No el mismo fade hacia arriba en cada bloque. No rebotes. No mezclar
GSAP, Motion y Lenis sin una razón. Reduced motion: tiempos a cero,
sin scroll suave, sin grano animado.

El hero es visible en el primer frame. `Reveal` con `priority` solo
mueve unos píxeles. Nunca `opacity: 0` en el LCP.

## Prohibido

- Em dash y en dash en copy visible.
- `border-l` de color en una card común.
- Degradés violeta, indigo o celeste. `bg-clip-text` arcoíris.
  Halos. Neón sobre negro.
- Elegir Inter, Geist o Space Grotesk sin decisión. Geist sí, como
  default de esta skill. Inter solo si está en la memoria.
- Hero plantilla: badge, título centrado enorme, "Get Started", orbe.
- Tres cards iguales con ícono. La secuencia hero, logos, tres
  cards, testimonios, precios, FAQ, como plantilla fija.
- Un solo radio grande para cards, inputs, botones e imágenes.
- Vidrio en el contenido o en todas las cards.
- Ventana falsa de Mac, métricas inventadas, badges "New" o
  "Popular" falsos, slogans vacíos, "no es solo X, es Y".
- Emojis en headings. "Unlock", "Elevate", "Seamless", "Effortless".
  Testimonios inventados.
- Franjas violeta y celeste del logo de slad.

Para cazarlos en el repo: `/slop`.
