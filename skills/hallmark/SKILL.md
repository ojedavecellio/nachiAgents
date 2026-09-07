---
name: hallmark
description: Use this skill for visual redesigns, aesthetic reviews, or any UI that needs to look like it was made by a designer — landings, portfolios, marketing pages. Runs an anti-AI-slop pass over layout, typography, color, and spacing before shipping. Trigger on "rediseño visual", "no se ve profesional", "parece hecho por IA", "revisá el diseño", or before shipping any public-facing page.
---

# Hallmark — criterio anti-AI-slop

Checklist de diseño para que una UI no tenga "olor a IA": layouts
genéricos, tipografía por default, paleta sin intención, spacing
inconsistente. Se aplica como pase final antes de dar por terminada
una pantalla visual — no reemplaza a GSAP / R3F (el movimiento va
por las skills oficiales de GSAP o las docs actuales de R3F; esta
skill define el look).

## Cuándo usarla

Landings, portfolios, páginas de marketing, cualquier UI donde el
aspecto visual es parte del producto. **No aplica** a dashboards
internos, tablas de datos, o herramientas de un solo usuario donde lo
único que importa es que funcione.

Si el proyecto ya tiene un design system cerrado (ej. Geist vía
`vercel-ui`), especificarlo explícitamente antes de correr el pase —
Hallmark no debe overridear un sistema ya definido, solo rellenar
donde no hay uno.

## Los 4 ejes

### 1. Tipografía
- Nunca la fuente default del framework sin decisión consciente
  (evitar Inter/system-ui "porque sí" — elegir por qué esa fuente).
- Jerarquía real: mínimo 3 tamaños con salto perceptible, no
  incrementos de 2px.
- Line-height y letter-spacing ajustados por tamaño, no un valor único
  para todo el sitio.
- Máximo 2 familias tipográficas por proyecto.

### 2. Color
- Paleta con intención: un color dominante, uno de acento, neutros
  bien definidos — no "gradiente violeta-celeste" por default.
- Contraste verificado (WCAG AA mínimo) en texto sobre fondo, no solo
  que "se vea bien" a ojo.
- Evitar paletas que se repiten en el 80% de landings generadas por
  IA (violeta/indigo sobre fondo oscuro, gradientes diagonales sin
  motivo).

### 3. Layout
- Grid con propósito, no todo centrado en columna única de 600px.
- Densidad de información variable — no todo el contenido con el
  mismo padding gigante tipo "hero section" repetido.
- Asimetría intencional cuando aporta (no todo simétrico por default).
- Whitespace como herramienta de jerarquía, no relleno uniforme.

### 4. Micro-detalle
- Bordes, sombras y radios consistentes entre componentes (mismo
  sistema de tokens, no valores sueltos por componente).
- Estados (hover, focus, active, disabled) diseñados, no dejados en
  default del navegador.
- Iconografía de una sola librería/estilo, nunca mezclada.

## Proceso

1. **Leer el brief** — qué tipo de proyecto es, quién lo va a ver,
   qué tono busca (corporate, playful, editorial, brutalist...). Sin
   esto, el pase es genérico.
2. **Pase por eje** — recorrer tipografía → color → layout →
   micro-detalle, señalando qué es "slop" (default sin decisión) y
   qué está bien.
3. **Priorizar** — no todos los hallazgos son iguales. Separar en
   "rompe la percepción de calidad" vs "detalle menor".
4. **Aplicar** — los cambios van como edits concretos en el código.
   No listar un checklist genérico: traducir a cambios puntuales.

## Qué NO hacer

- No proponer un rediseño completo cuando el pedido es puntual (ej.
  "revisá el hero") — quedarse en el scope pedido.
- No mezclar esta skill con decisiones de stack o performance — eso
  es `nextjs-audit`/`performance-auditor`.
- No aplicar sobre proyectos con design system cerrado sin
  confirmarlo antes (ver arriba).
