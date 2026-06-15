---
name: glass-patterns
description: Use this skill whenever the task involves glassmorphism, backdrop-blur, frosted glass UI, a "liquid glass" or Apple-style glass effect, glass navbars/cards/modals, or any switch/slider/toggle where the glass itself moves over live content. Always consult before writing backdrop-filter CSS or a glass component — covers the two levels (CSS glassmorphism vs feDisplacementMap "Liquid Glass"), when each applies, dark/light/tinted variants, and cross-browser gotchas (especially Safari). For the full feDisplacementMap implementation (Glass component, displacement map generation, Switch/Slider/Toggle patterns, WebGL fallback for video/canvas), also read references/liquid-glass-implementation.md.
---

# Glass — dos niveles

Referencia técnica central: [Building Glass for the Web — Aave Labs](https://aave.com/design/building-glass-for-the-web)

## Cuándo usar cada nivel

¿El glass es decorativo — fondo de navbar, card, modal? → **Nivel 1**:
CSS glassmorphism (`backdrop-filter` + `rgba`). Listo, cubre el 80% de
los casos.

¿El glass ES el componente — switch thumb, slider handle, selection
indicator, algo que se mueve sobre contenido vivo? → **Nivel 2**:
`feDisplacementMap` (la técnica de Aave) — ver
`references/liquid-glass-implementation.md`.

¿El contenido debajo es un `<video>` en Safari o está en `<canvas>`?
→ Nivel 2 con fallback WebGL — ver referencia.

No mezclar los dos niveles en el mismo elemento.

## Nivel 1 — Glassmorphism CSS

Para navbar sticky, cards sobre imagen, modales, tooltips. Estático o
cambia solo en hover/open.

```css
.glass {
  background: rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(12px) saturate(180%);
  -webkit-backdrop-filter: blur(12px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 16px;
}
```

`-webkit-backdrop-filter` es obligatorio para Safari — sin él, el
blur no aparece en iOS ni macOS.

Con Tailwind v4:

```tsx
<div className="bg-white/8 backdrop-blur-xl backdrop-saturate-180 border border-white/12 rounded-2xl">
  {children}
</div>
```

### Variantes por paleta

**Dark** (la más común en proyectos actuales):
```css
background: rgba(255, 255, 255, 0.06);
backdrop-filter: blur(16px) saturate(150%) brightness(1.1);
border: 1px solid rgba(255, 255, 255, 0.10);
```

**Light**:
```css
background: rgba(255, 255, 255, 0.55);
backdrop-filter: blur(20px) saturate(180%);
border: 1px solid rgba(255, 255, 255, 0.60);
box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
```

**Tinted** (glass con color de marca):
```css
background: rgba(var(--color-accent-rgb), 0.12);
backdrop-filter: blur(12px) saturate(200%);
border: 1px solid rgba(var(--color-accent-rgb), 0.20);
```

### Navbar sticky activado al scrollear

```tsx
'use client'

import { useEffect, useState } from 'react'

export function Navbar() {
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <header
      className={`fixed top-0 w-full z-50 transition-all duration-300
        ${scrolled ? 'bg-black/30 backdrop-blur-xl border-b border-white/8' : 'bg-transparent'}`}
    >
      {/* contenido */}
    </header>
  )
}
```

## Nivel 2 — Liquid Glass (feDisplacementMap)

Conceptualmente distinto al Nivel 1: acá el glass **dobla los pixels
del contenido debajo** en vez de desenfocarlos desde afuera. Por eso
el texto debajo del glass sigue siendo seleccionable y los links
clickeables.

### Por qué esta técnica

Los demos post-WWDC 2025 usan SVG `backdrop-filter` (solo Chromium) o
HTML-in-Canvas (experimental, detrás de flag). `feDisplacementMap`
funciona en Chromium, Safari y Firefox sin flags ni fallbacks — el
SVG filter opera directamente sobre el contenido renderizado.

Idea general: se genera un PNG chico (el displacement map) según la
forma del lente, con simetría cuatro-fold (solo se calcula 1/4 y se
refleja). Los canales R/G del mapa codifican desplazamiento
horizontal/vertical. Un SVG filter con `feDisplacementMap` aplica el
mapa, y `feSpecularLighting` agrega el highlight que hace el glass
legible.

La implementación completa (componente `Glass`, generación del mapa,
patrones de Switch/Slider/Toggle, fallback WebGL para video/canvas)
está en `references/liquid-glass-implementation.md` — es código
extenso, no entra acá.

## Cross-browser gotchas (aplica a los dos niveles)

- **Safari cachea el filter output por ID** — si el displacement map
  cambia pero el ID del filter no, Safari sirve el output viejo y el
  glass se congela. Forzar nuevo ID en cada update (`useId()` + un
  contador en estado).
- **Safari tiene límite de tamaño en el source graphic del filter** —
  pasado el límite, rompe en bloques desalineados. Mantenerse
  conservador con tamaño y complejidad del DOM refractado.
- **`feImage` con `href` dinámico en Firefox** — necesita `width`/
  `height` explícitos como atributos SVG (no CSS) para renderizar el
  mapa correctamente.
- **`backdrop-filter` (Nivel 1) también necesita `-webkit-`** en
  Safari. No mezclar Nivel 1 y Nivel 2 en el mismo elemento — combinados
  dan resultados impredecibles.

## Performance

**Nivel 1**: `backdrop-filter` es caro con muchos elementos apilados o
área grande. Máximo 3-4 elementos glass visibles a la vez. Animar
`opacity` del elemento, nunca `backdrop-filter` directamente.

**Nivel 2**: el mapa se regenera solo cuando cambia la forma del lente
(border-radius, tamaño) — mover el glass (drag de un slider) solo
actualiza posicionamiento CSS, no recalcula el mapa. `will-change: filter`
solo en elementos que se mueven. No anidar glass effects — además del
costo de compositing, el `feDisplacementMap` anidado produce
artefactos en todos los browsers.

## Cuándo NO usar Liquid Glass

El Nivel 2 no vale la complejidad si: el glass es puramente decorativo
(Nivel 1), mobile es el canal principal con dispositivos mid-range o
bajos (WebGL + SVG filters en GPU limitada es riesgo real), no hay
contenido visual interesante debajo del lente, o el proyecto está en
v1 con features críticas sin implementar todavía.

## Gotchas generales

No usar glass sobre texto denso sin chequear contraste — la
refracción puede hacer el texto ilegible aunque se vea bien en
screenshots. El glass necesita algo detrás para funcionar — sobre
fondo negro plano parece solo un borde redondeado semitransparente.
Safari iOS tiene restricciones de compositing adicionales que no
aparecen en desktop — testear en dispositivo real. Para Nivel 1,
`backdrop-filter: blur` no funciona si el padre tiene
`overflow: hidden` en algunos browsers — si el blur desaparece sin
razón, ese es el culpable.
