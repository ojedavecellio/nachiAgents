# Scroll-parallax y patrones cinematográficos

Patrones para webs estilo Apple/Linear donde el scroll controla la
narrativa visual. Todo sobre Next.js App Router + React 19, usando el
setup de `lib/gsap.ts` (ver SKILL.md principal).

## El concepto central: scrub

La diferencia entre una animación normal y parallax/scroll-cinematic
es `scrub`. En vez de reproducirse al entrar al viewport, la
animación queda atada al scroll: el progreso del scroll = el progreso
de la animación.

```typescript
scrollTrigger: {
  trigger: element,
  start: 'top top',
  end: '+=500',   // px de scroll = duración total
  scrub: 1,       // 1 = 1s de lag suave. true = sin lag
}
```

`scrub: 1` es el default para casi todo — da la sensación de "peso"
de las animaciones de Apple. `scrub: true` es inmediato, útil para
cosas muy pequeñas. Con `scrub` activo, el ease no importa para el
movimiento general (lo controla el scroll), pero sí para
transiciones internas de un timeline.

## Patrón 1 — Parallax simple (capas a distinta velocidad)

```typescript
// components/hero/ParallaxHero.tsx
'use client'

import { useRef } from 'react'
import { useGSAP } from '@gsap/react'
import { gsap, ScrollTrigger } from '@/lib/gsap'

export function ParallaxHero() {
  const container = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    gsap.to('.parallax-bg', {
      y: '40%',
      ease: 'none',
      scrollTrigger: {
        trigger: container.current,
        start: 'top top',
        end: 'bottom top',
        scrub: true,
      },
    })

    gsap.to('.parallax-content', {
      y: '20%',
      opacity: 0,
      ease: 'none',
      scrollTrigger: {
        trigger: container.current,
        start: 'top top',
        end: '60% top',
        scrub: true,
      },
    })
  }, { scope: container })

  return (
    <div ref={container} className="relative h-screen overflow-hidden">
      <div
        className="parallax-bg absolute inset-0 -top-[20%] scale-110 bg-cover bg-center"
        style={{ backgroundImage: 'url(/hero-bg.jpg)' }}
      />
      <div className="parallax-content relative z-10 flex h-full items-center justify-center">
        <h1 className="text-7xl font-bold">Título</h1>
      </div>
    </div>
  )
}
```

Regla de velocidades: `y: '40-60%'` para el fondo (más lento, más
lejos), `y: '15-25%'` para elementos medios, sin animación o
`y: '-10%'` para el primer plano (más rápido).

## Patrón 2 — Sección pinneada con transformaciones

El patrón Apple por excelencia: la sección queda fija mientras
scrolleás y en ese espacio "estático" pasan cosas.

```typescript
// components/sections/PinnedSection.tsx
'use client'

import { useRef } from 'react'
import { useGSAP } from '@gsap/react'
import { gsap, ScrollTrigger } from '@/lib/gsap'

export function PinnedSection() {
  const container = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    const tl = gsap.timeline({
      scrollTrigger: {
        trigger: container.current,
        start: 'top top',
        end: '+=300%',   // 3x viewport = 3 "escenas"
        pin: true,
        scrub: 1,
        anticipatePin: 1, // evita el flash al pinnear
      },
    })

    tl.to('.pin-title', { scale: 0.4, y: '-40vh', opacity: 0.3, duration: 1 })

    tl.from('.pin-image', { scale: 1.2, opacity: 0, duration: 1 }, '<0.3')

    tl.to('.pin-image', { x: '-30vw', scale: 0.8, duration: 1 }, '+=0.5')

    tl.from('.pin-details', { x: '30vw', opacity: 0, duration: 1 }, '<')
  }, { scope: container })

  return (
    <div className="relative h-screen w-full overflow-hidden bg-black">
      <h2 className="pin-title absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 text-6xl font-bold text-white">
        Título
      </h2>
      <img className="pin-image absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-64" src="/product.png" alt="" />
      <div className="pin-details absolute right-16 top-1/2 -translate-y-1/2 max-w-xs text-white">
        <p className="text-xl">Detalle del producto acá.</p>
      </div>
    </div>
  )
}
```

`anticipatePin: 1` es casi siempre necesario — sin él hay un salto
visual al pinnear, especialmente con smooth scroll.

## Patrón 3 — Objeto que se "arma" al scrollear

### Variante A: SVG path que se dibuja (strokeDashoffset)

```typescript
useGSAP(() => {
  const path = pathRef.current
  if (!path) return

  const length = path.getTotalLength()

  gsap.set(path, { strokeDasharray: length, strokeDashoffset: length })

  gsap.to(path, {
    strokeDashoffset: 0,
    ease: 'none',
    scrollTrigger: {
      trigger: container.current,
      start: 'top 80%',
      end: 'bottom 20%',
      scrub: 1,
    },
  })
}, { scope: container })
```

### Variante B: imagen/div que se revela con clip-path

```typescript
useGSAP(() => {
  gsap.from('.reveal-image', {
    clipPath: 'inset(100% 0% 0% 0%)',
    ease: 'none',
    scrollTrigger: {
      trigger: '.reveal-image',
      start: 'top 80%',
      end: 'top 20%',
      scrub: 1,
    },
  })
}, { scope: container })
```

## Patrón 4 — Texto palabra por palabra con scroll

Distinto al text reveal por tiempo del SKILL.md principal — acá cada
palabra tiene su propio punto de activación según el scroll.

```typescript
useGSAP(() => {
  const split = new SplitText('.scroll-text', { type: 'words' })

  gsap.from(split.words, {
    opacity: 0.1,
    ease: 'none',
    stagger: { each: 0.1, from: 'start' },
    scrollTrigger: {
      trigger: container.current,
      start: 'top 70%',
      end: 'bottom 30%',
      scrub: 1,
    },
  })

  return () => split.revert()
}, { scope: container })
```

`opacity: 0.1` en vez de `0` da el efecto "iluminado" que usa Apple
en páginas de producto — las palabras no desaparecen del todo.

## Patrón 5 — Parallax horizontal (scroll vertical → movimiento horizontal)

```typescript
useGSAP(() => {
  const panels = track.current?.querySelectorAll('.h-panel')
  if (!panels?.length) return

  const totalWidth = (panels.length - 1) * window.innerWidth

  gsap.to(track.current, {
    x: -totalWidth,
    ease: 'none',
    scrollTrigger: {
      trigger: container.current,
      start: 'top top',
      end: `+=${totalWidth}`,
      pin: true,
      scrub: 1,
      anticipatePin: 1,
      invalidateOnRefresh: true, // recalcula en resize
    },
  })
}, { scope: container })
```

`invalidateOnRefresh: true` es crítico en scroll horizontal — sin él,
un resize deja el cálculo mal.

## Patrón 6 — Zoom de imagen al scrollear (estilo Apple hero)

```typescript
// empieza chica centrada, se expande a fullscreen
useGSAP(() => {
  gsap.from('.zoom-image', {
    scale: 0.6,
    borderRadius: '24px',
    ease: 'none',
    scrollTrigger: {
      trigger: container.current,
      start: 'top top',
      end: '+=80%',
      scrub: 1,
    },
  })
}, { scope: container })
```

Efecto inverso (fullscreen → se achica):

```typescript
gsap.to('.zoom-image', {
  scale: 0.7,
  borderRadius: '16px',
  ease: 'none',
  scrollTrigger: { trigger: container.current, start: 'top top', end: '+=60%', scrub: 1 },
})
```

## Composición

En una landing real estos patrones se encadenan sección por sección,
cada una con su propio ScrollTrigger — no hay un contexto global para
toda la página. Cada componente maneja su propio `useGSAP` con
`scope: container`. Si dos secciones interactúan entre sí,
encapsularlas en un componente padre común.

## Performance específico de scroll animations

- `will-change: transform` solo en los elementos que se mueven
  durante scroll.
- Imágenes con `next/image` y `priority` en el hero — ScrollTrigger
  necesita que estén cargadas para calcular posiciones. Llamar
  `ScrollTrigger.refresh()` después de que carguen imágenes
  dinámicas.
- `invalidateOnRefresh: true` en cualquier ScrollTrigger que calcule
  dimensiones del DOM (scroll horizontal, parallax con medidas
  exactas).
- Máximo 3-4 capas de parallax por sección — más y el costo de
  compositing baja el FPS en mobile.
- Mobile: reducir intensidad de parallax con `gsap.matchMedia()`:

```typescript
const mm = gsap.matchMedia()

mm.add('(min-width: 768px)', () => {
  gsap.to('.parallax-bg', { y: '40%', /* ... */ })
})

mm.add('(max-width: 767px)', () => {
  gsap.to('.parallax-bg', { y: '15%', /* ... */ }) // más suave
})
```

## Gotchas específicos

- **Overflow hidden en el padre**: si el contenedor tiene
  `overflow: hidden`, el pin de ScrollTrigger no funciona bien. El
  elemento pinneable tiene que estar fuera del overflow hidden, o el
  trigger tiene que ser un ancestro.
- **Lenis + ScrollTrigger**: si hay smooth scroll, la integración del
  SKILL.md principal es obligatoria — sin ella los triggers se activan
  200-300px antes o después de lo esperado.
- **`anticipatePin: 1`**: siempre en secciones pinneadas. Sin él hay
  un flash de 1-2 frames al pinnear.
- **Heights dinámicos**: si el contenido cambia de altura (texto que
  cambia, imágenes que cargan tarde), llamar `ScrollTrigger.refresh()`
  después del cambio.
- **SplitText y resize**: el split se hace una vez al montar. Si el
  usuario hace resize y el texto rompe en líneas distintas, el split
  queda incorrecto. Si esto importa, escuchar resize y re-hacer el
  split con `ScrollTrigger.refresh()`.
- **Timelines con scrub son reversibles**: con scrub el usuario puede
  scrollear hacia atrás. Evitar side effects no-reversibles en
  callbacks `onUpdate`.
