---
name: glass-patterns
description: Vidrio de nachi-style. Nav, pastillas, overlays y barras flotantes con backdrop-filter, silver-rim y useGSAP. No es liquid glass ni feDisplacementMap. Leé nachi-style para saber dónde el vidrio está permitido.
---

# Vidrio

El look y las reglas están en `nachi-style`. Esta skill es la receta
CSS y cómo se anima. El vidrio está permitido cuando es chrome. No
cuando decora una card, un artículo o el fondo de la página.

No uses `feDisplacementMap`, mapas de displacement, ni el demo de
"liquid glass". Eso quedó afuera: es un efecto de más, y se rompe
distinto en cada browser.

## Dónde

Sí: nav flotante, pastilla, overlay, menú, popover, barra de contacto
o de compra que flota, control sobre foto o video.

No: cards de contenido, dashboards, secciones enteras, el fondo de
la página, tres capas apiladas, borde violeta, neón.

La carta va sobre superficie sólida (`bg-elevated`).

## Receta

Clases en `styles/nachi.css`: `glass-nav` o `glass-chrome`, más
`silver-rim`, más `pill` si es una pastilla.

- Desenfoque 16 px en la nav, 18 px en el chrome.
- Saturación apenas arriba de 1.
- Brillo fino arriba: `inset 0 1px 0`.
- Fondo bajo (blanco al 7% en oscuro). En claro, subí la opacidad
  (el CSS ya lo hace con `data-theme="light"`) para que se lea.
- Siempre `-webkit-backdrop-filter` junto con `backdrop-filter`.
  Sin el prefijo, Safari no desenfoca.

No animes `backdrop-filter`. No apiles más de una capa de vidrio en
el mismo rincón. Máximo unas pocas piezas de vidrio en pantalla.

## Animación

`useGSAP` de `@gsap/react`. No `useLayoutEffect` ni `gsap.context`.

La pieza nace visible. No arranques en `opacity: 0`. Un desplazamiento
corto está bien. Si es el hero o el LCP, ni siquiera lo bajes de
opacidad en el CSS.

```tsx
"use client";

import { useRef } from "react";
import { gsap } from "gsap";
import { useGSAP } from "@gsap/react";
import { useReducedMotion } from "@/hooks/use-reduced-motion";

export function FloatingBar({ children }: { children: React.ReactNode }) {
  const ref = useRef<HTMLDivElement>(null);
  const reduced = useReducedMotion();

  useGSAP(
    () => {
      if (reduced || !ref.current) return;
      gsap.fromTo(
        ref.current,
        { y: 12 },
        { y: 0, duration: 0.28, ease: "power3.out" },
      );
    },
    { scope: ref, dependencies: [reduced] },
  );

  return (
    <div ref={ref} className="glass-chrome silver-rim pill">
      {children}
    </div>
  );
}
```

Con `prefers-reduced-motion`, no hay movimiento. `SmoothScroll` ya
no monta Lenis en ese caso.
