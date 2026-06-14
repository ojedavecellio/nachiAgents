---
name: gsap-motion
description: Use this skill whenever the task involves GSAP, ScrollTrigger, scroll-driven or scroll-narrative animation, parallax, pinned sections, text reveals, horizontal scroll, counter animations, Flip transitions, or Lenis smooth scroll integration in a Next.js + React 19 project. Always consult before writing, reviewing, or debugging GSAP code, even if the request just says "animate this" or "make this scroll nicer" — covers setup in lib/gsap.ts, the useGSAP pattern, ease curves, performance rules, and accessibility with prefers-reduced-motion. For Apple/Linear-style scroll-cinematic patterns (parallax layers, pin + transform sequences, draw-on-scroll, horizontal galleries, zoom-on-scroll), also read references/scroll-parallax.md.
---

# GSAP en Next.js + React 19

Patrones fijos para este stack. No es documentación de la librería —
son las decisiones ya tomadas, aplicar directo.

## Cuándo GSAP vs Framer Motion

Framer Motion: transiciones de componentes React, gestos, animaciones
de UI (entradas/salidas de modales, tabs, hover states).

GSAP: scroll narrativo, timelines coordinadas, parallax, pin de
secciones, text reveals, cualquier animación que necesite control
preciso de timing o que múltiples elementos se muevan en relación
entre sí.

Si el proyecto tiene los dos: Framer Motion maneja componentes
interactivos, GSAP maneja scroll y animaciones de página. No mezclar
los dos en el mismo elemento.

## Setup — lib/gsap.ts

Registro de plugins en un solo lugar:

```typescript
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
import { SplitText } from 'gsap/SplitText'
import { Flip } from 'gsap/Flip'

gsap.registerPlugin(ScrollTrigger, SplitText, Flip)

ScrollTrigger.defaults({
  toggleActions: 'play none none none',
})

export { gsap, ScrollTrigger, SplitText, Flip }
```

Importar siempre desde `lib/gsap.ts`, nunca directo de `gsap`. Esto
garantiza que los plugins estén registrados antes de usarse.

## Patrón base — useGSAP

`useGSAP` del paquete `@gsap/react` para todo. No `useEffect` ni
`useLayoutEffect` directo para animaciones.

```typescript
import { useGSAP } from '@gsap/react'
import { gsap, ScrollTrigger } from '@/lib/gsap'

export function HeroSection() {
  const container = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    gsap.from('.hero-title', {
      y: 60,
      opacity: 0,
      duration: 1,
      ease: 'power3.out',
    })
  }, { scope: container })

  return <div ref={container}>...</div>
}
```

`scope: container` es obligatorio — limita las queries de GSAP al
componente y evita colisiones entre animaciones de distintos
componentes. El cleanup es automático con `useGSAP`. No hace falta
`ctx.revert()` manual salvo casos muy específicos con ScrollTrigger.

## Reveal al entrar en viewport

```typescript
useGSAP(() => {
  gsap.from('.reveal', {
    y: 40,
    opacity: 0,
    duration: 0.8,
    ease: 'power2.out',
    stagger: 0.1,
    scrollTrigger: {
      trigger: '.reveal',
      start: 'top 85%',
    },
  })
}, { scope: container })
```

## Sección con pin + scrub

```typescript
useGSAP(() => {
  const tl = gsap.timeline({
    scrollTrigger: {
      trigger: sectionRef.current,
      start: 'top top',
      end: '+=100%',
      pin: true,
      scrub: 1,
    },
  })

  tl.from('.panel', { opacity: 0, y: 30 })
    .to('.panel', { opacity: 0, y: -30 }, '+=0.5')
}, { scope: container })
```

## Integración con Lenis

Cuando el proyecto usa Lenis para smooth scroll, ScrollTrigger
necesita sincronizarse o los triggers se desfasan. Configuración en
`app/providers/LenisProvider.tsx`:

```typescript
import Lenis from 'lenis'
import { ScrollTrigger } from '@/lib/gsap'

const lenis = new Lenis()

lenis.on('scroll', ScrollTrigger.update)

gsap.ticker.add((time) => {
  lenis.raf(time * 1000)
})

gsap.ticker.lagSmoothing(0)
```

Sin esta configuración, Lenis y ScrollTrigger compiten por el scroll y
los triggers se activan en posiciones incorrectas.

## Ease curves

Los defaults de GSAP (`power1`, `power2`) son correctos para la
mayoría de los casos. Las únicas personalizadas que vale la pena
memorizar:

- `power3.out` — entradas de hero y títulos principales.
- `power2.inOut` — transiciones de estado (cards que se expanden,
  paneles que cambian).
- `none` — animaciones con scrub. Con scrub el ease lo controla el
  scroll, no GSAP.

Sin `elastic`, sin `bounce` en proyectos de producto. Solo en
contextos muy específicos donde el diseño lo pide explícitamente.

## Performance

Solo `transform` y `opacity`. Nunca animar `width`, `height`, `top`,
`left`, `margin` o `padding` directamente: causan reflow y bajan el
FPS. Para mover un elemento, `x`/`y` (GSAP los traduce a
`translateX`/`translateY`), no `left`/`top`.

`will-change: transform` solo en elementos que van a animarse durante
scroll. No aplicarlo globalmente ni como default.

Cleanup al desmontar en animaciones con ScrollTrigger que NO usan
`useGSAP`:

```typescript
return () => {
  ScrollTrigger.getAll().forEach(trigger => trigger.kill())
}
```

## Accesibilidad

`gsap.matchMedia()` para respetar `prefers-reduced-motion`:

```typescript
useGSAP(() => {
  const mm = gsap.matchMedia()

  mm.add('(prefers-reduced-motion: no-preference)', () => {
    gsap.from('.hero-title', { y: 60, opacity: 0, duration: 1 })
  })

  mm.add('(prefers-reduced-motion: reduce)', () => {
    gsap.set('.hero-title', { opacity: 1 })
  })
}, { scope: container })
```

El fallback de `reduced-motion` tiene que dejar los elementos
visibles con `gsap.set`. Si no, los elementos que empiezan con
`opacity: 0` o fuera del viewport quedan invisibles para usuarios con
motion reducido.

## Plugins: cuándo usar cada uno

- **ScrollTrigger** — siempre que haya scroll. Plugin base.
- **SplitText** — titulares que se revelan palabra por palabra o
  letra por letra. Solo si el diseño lo justifica. Rompe
  accesibilidad si se aplica a texto con roles ARIA o labels de
  formularios — solo en elementos decorativos o titulares.
- **Flip** — transiciones de layout donde un elemento cambia de
  posición o tamaño (grid a lista, card que se expande). Alternativa
  a Framer Motion Layout Animations cuando el elemento no es un
  componente React.
- **ScrollToPlugin** — navegación suave a una sección al hacer click
  en un link del navbar (`gsap.to(window, { scrollTo })`).
- **Draggable / Observer** — solo si hay interacción táctil o drag
  explícita en el diseño. No instalar por defecto.

## Gotchas

- `useEffect` para GSAP en Next.js causa hydration mismatches.
  Siempre `useGSAP` de `@gsap/react`.
- `ScrollTrigger.refresh()` tiene que llamarse después de que el DOM
  termine de renderizar contenido dinámico (imágenes cargadas, fonts
  aplicadas).
- Lenis y ScrollTrigger sin sincronizar causan que los triggers se
  activen antes o después de lo esperado (ver integración arriba).
- En desarrollo con React StrictMode, los efectos se ejecutan dos
  veces. `useGSAP` maneja esto correctamente. Si se usa
  `gsap.context()` directo, necesita `ctx.revert()` en el cleanup.

## Patrones de scroll-cinematic avanzados

Para parallax de capas, pin + secuencias de transformación,
draw-on-scroll (SVG/clip-path), texto que se ilumina con scroll,
scroll horizontal y zoom estilo Apple/Linear: ver
`references/scroll-parallax.md`.
