---
name: slop
description: Revisa el look contra las prohibiciones de nachi-style. Em dash, borde izquierdo en cards, degradés violeta, vidrio mal usado, emojis en headings, slogans vacíos, testimonios inventados.
---

Leé `nachi-style` si todavía no lo leíste en esta sesión. Después
corrés estos greps en el repo, fuera de `node_modules`, `.git` y
`.next`. Reportá archivo y línea. No arregles sin que Nacho lo pida.

El vidrio no es slop por existir. Es slop si rompe las reglas:
card de contenido, fondo de página, tres capas, borde violeta, neón,
o `opacity: 0` en el hero. `glass-nav`, `glass-chrome`, `silver-rim`
y `pill` en nav, pastilla, overlay o barra flotante están bien.

```bash
rg -n -e $'\u2014' -e $'\u2013' -g '!node_modules/**' -g '!.git/**' -g '!.next/**'

rg -n 'border-l(-[0-9]|-[a-z]+)?' -g '*.tsx' -g '*.css' -g '!node_modules/**'

rg -n 'bg-clip-text|from-(purple|violet|indigo|fuchsia|sky|blue|cyan)-|to-(purple|violet|indigo|fuchsia|sky|blue|cyan)-' -g '*.tsx' -g '*.css' -g '!node_modules/**'

rg -n 'backdrop-blur|glass-nav|glass-chrome|feDisplacementMap' -g '*.tsx' -g '*.css' -g '!node_modules/**'

rg -n 'opacity-0|autoAlpha:\s*0' -g '*.tsx' -g '!node_modules/**'

rg -ni '\b(Unlock|Elevate|Seamless|Effortless|Get Started)\b|no es solo|not just' -g '*.tsx' -g '*.md' -g '!node_modules/**'
```

Además, a ojo en headings (`h1`, `h2`, `h3`, títulos de página):

- Emojis.
- Badges "New" o "Popular" que el producto no tiene.
- Testimonios, estrellas o cifras sin una fuente en el repo.
- La plantilla hero + logos + tres cards con ícono + testimonios +
  precios + FAQ, repetida sin decisión.
- Ventana falsa de Mac (los tres puntitos de tráfico).
- "Unlock", "Elevate", "Seamless", "Effortless".

Salida, corta:

**Slop:** cada hallazgo, con archivo y por qué cae en la lista.

**Vidrio ok:** piezas que sí cumplen la receta, en una línea. Si no
hay, no inventes la sección.

**No toqué:** dejá claro que no editaste nada.
