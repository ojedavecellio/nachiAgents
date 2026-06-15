# Liquid Glass — implementación completa (feDisplacementMap)

Implementación del Nivel 2 del skill `glass-patterns`. Código extenso
— usar cuando el glass es interactivo y central a la UX (switch,
slider, selection indicator), no para decoración.

## Componente base

```tsx
// components/ui/Glass.tsx
'use client'

import { useRef, useId, useEffect } from 'react'

interface GlensConfig {
  lensW: number
  lensH: number
  borderRadius: number
  scale?: number      // intensidad de la refracción (default: 0.1)
  depth?: number      // profundidad del efecto (default: 10)
  curvature?: number  // curvatura del lente (default: 40)
  chroma?: number     // aberración cromática (default: 0.2)
}

interface GlassProps {
  lens: GlensConfig
  x?: number           // posición horizontal (0-1 normalizado)
  children: React.ReactNode
  refractionTarget?: React.ReactNode  // contenido alternativo a doblar
}

export function Glass({ lens, x = 0, children, refractionTarget }: GlassProps) {
  const filterId = useId()
  const mapRef = useRef<string | null>(null)

  useEffect(() => {
    mapRef.current = generateDisplacementMap(lens)
  }, [lens.lensW, lens.lensH, lens.borderRadius, lens.scale, lens.depth, lens.curvature])

  return (
    <div className="relative overflow-hidden">
      {children}

      <div className="absolute inset-0 pointer-events-none" style={{ filter: `url(#${filterId})` }}>
        {refractionTarget ?? children}
      </div>

      <svg className="absolute w-0 h-0 overflow-hidden">
        <defs>
          <filter id={filterId}>
            <feImage href={mapRef.current ?? ''} result="map" x="0" y="0" width={lens.lensW} height={lens.lensH} />
            <feDisplacementMap
              in="SourceGraphic"
              in2="map"
              scale={lens.scale ?? 0.1 * lens.lensW}
              xChannelSelector="R"
              yChannelSelector="G"
            />
          </filter>
        </defs>
      </svg>
    </div>
  )
}
```

## Generación del displacement map

La parte crítica: calcular solo el cuadrante superior-izquierdo y
reflejarlo mantiene el costo dentro del frame budget cuando el mapa se
regenera.

```typescript
// lib/glass.ts
export function generateDisplacementMap(lens: GlensConfig): string {
  const { lensW, lensH, depth = 10, curvature = 40 } = lens

  const canvas = document.createElement('canvas')
  canvas.width = lensW
  canvas.height = lensH
  const ctx = canvas.getContext('2d')!

  const data = ctx.createImageData(lensW, lensH)
  const halfW = Math.ceil(lensW / 2)
  const halfH = Math.ceil(lensH / 2)

  for (let y = 0; y < halfH; y++) {
    for (let x = 0; x < halfW; x++) {
      const nx = x / halfW
      const ny = y / halfH

      const dx = (nx - 0.5) * 2
      const dy = (ny - 0.5) * 2
      const dist = Math.sqrt(dx * dx + dy * dy)

      const bend = Math.max(0, 1 - dist) * (curvature / 100)

      // Canal R = desplazamiento X, Canal G = desplazamiento Y. 128 = neutro.
      const rx = Math.round(128 + dx * bend * depth)
      const ry = Math.round(128 + dy * bend * depth)

      const writePixel = (px: number, py: number, r: number, g: number) => {
        const i = (py * lensW + px) * 4
        data.data[i] = r
        data.data[i + 1] = g
        data.data[i + 2] = 128
        data.data[i + 3] = 255
      }

      // Escribir los 4 cuadrantes con la simetría correspondiente
      writePixel(x, y, rx, ry)
      writePixel(lensW - 1 - x, y, 255 - rx, ry)
      writePixel(x, lensH - 1 - y, rx, 255 - ry)
      writePixel(lensW - 1 - x, lensH - 1 - y, 255 - rx, 255 - ry)
    }
  }

  ctx.putImageData(data, 0, 0)
  return canvas.toDataURL()
}
```

## Componentes que se construyen sobre este patrón

**Switch:**
```tsx
<Glass lens={{ lensW: 90, lensH: 60, borderRadius: 30 }} x={progress}>
  <SwitchTrack />
</Glass>
```

**Slider:**
```tsx
<Glass
  lens={{ lensW: 90, lensH: 60, borderRadius: 30 }}
  x={handlePosition}
  refractionTarget={<TrackFill progress={progress} />}
>
  <SliderTrack />
</Glass>
```

**Toggle group** (glass como selection indicator):
```tsx
<Glass
  lens={selectionLens}
  x={selectedOptionPosition}
  refractionTarget={<HighlightedOptions />}
>
  <ToggleGroup options={options} />
</Glass>
```

## Fallback WebGL (video y canvas en Safari)

Safari no aplica SVG filters a `<video>` vivos porque los composita en
GPU. Para esos casos, el mismo displacement map alimenta un shader
WebGL:

```tsx
// El mismo mapa de generateDisplacementMap() alimenta el renderer WebGL
const { map, scale, chromaAmount } = generateLensMap(lens)
videoRefractRenderer.setDisplacement({ map, scale, chromaAmount })
```

Para contenido pintado en canvas (QR codes, charts):

```tsx
const { map, scale, chromaAmount } = generateLensMap(lens)
qrCanvas.setDisplacement({ map, scale, chromaAmount })
```

La interfaz de los renderers es la misma — cambia el renderer, no el
mapa ni el pipeline de refracción.

## Forzar regeneración en Safari (caché por ID)

```tsx
const baseId = useId()
const [version, setVersion] = useState(0)
const filterId = `${baseId}-${version}`

// cuando el mapa cambia:
setVersion(v => v + 1)
```

Sin esto, Safari sirve el output viejo del filter y el glass queda
congelado aunque el mapa subyacente haya cambiado.

## El specular highlight

Cubre toda el área del filter, no solo el lente — su costo escala con
el área total. En Chromium, recortarlo al lente produce artefactos
sub-pixel en los bordes; en Safari no. El fix es aplicar esa
optimización solo en Safari, detectando con `CSS.supports`.
