---
name: three-js
description: Use this skill whenever the task involves Three.js, React Three Fiber (R3F), WebGL, a 3D hero background, particle fields, generative shader backgrounds, GLB/GLTF product models, or any "fondo 3D", "partículas", "hero inmersivo" request in a Next.js App Router project. Always consult before adding Three.js to a project, even just to evaluate if it's worth it — covers when NOT to use it, the mandatory dynamic + ssr:false setup, the canvas-as-background pattern, and mobile/WebGL-tier fallbacks. For shader backgrounds, GLB product models, or GSAP-driven camera/scroll integration, also read references/shaders-and-models.md.
---

# Three.js en Next.js App Router

Three.js (vía React Three Fiber) como capa visual del hero. El canvas
vive detrás del contenido DOM. GSAP y Framer Motion siguen manejando
todo lo que no es 3D — ver skill `gsap-motion` para esa parte.

## Cuándo usarlo (y cuándo no)

Tiene sentido cuando: el fondo generativo o las partículas son parte
del diseño (no un adorno), el producto se muestra en 3D, o el brief
apunta explícitamente a referencias tipo Lusion/Activetheory que GSAP
solo no puede replicar.

**No usarlo cuando**: un gradiente animado con CSS o un video loop
hacen lo mismo, el cliente no tiene diseño 3D definido (Three.js sin
dirección visual clara siempre queda genérico), o mobile es el canal
principal (WebGL en dispositivos medios-bajos es un riesgo real de
performance).

Si la respuesta es "no estoy seguro", es que no.

## Dependencias

```bash
npm install three @react-three/fiber @react-three/drei
npm install -D @types/three
```

```
three: ^0.176.x
@react-three/fiber: ^9.x
@react-three/drei: ^10.x
```

R3F v9 requiere React 19. Si el proyecto está en React 18, usar R3F v8.

## Setup — obligatorio: dynamic + ssr: false

Three.js referencia `window` al importar — no existe en el servidor,
y sin esto el build explota con un error poco descriptivo
("window is not defined").

```typescript
// app/page.tsx — Server Component
import dynamic from 'next/dynamic'

const HeroCanvas = dynamic(
  () => import('@/components/hero/HeroCanvas'),
  { ssr: false }
)

export default function Page() {
  return (
    <main>
      <HeroCanvas />
      {/* resto del contenido */}
    </main>
  )
}
```

El componente que usa R3F siempre lleva `'use client'` arriba.

## Patrón base — canvas de fondo + DOM encima

La estructura que se repite en todas las landings: el canvas en
`absolute inset-0 z-0`, el contenido DOM (copy, CTAs, nav) encima con
`z-index` mayor.

```typescript
// components/hero/HeroSection.tsx
'use client'

import dynamic from 'next/dynamic'

const HeroCanvas = dynamic(() => import('./HeroCanvas'), { ssr: false, loading: () => null })

export function HeroSection() {
  return (
    <section className="relative h-screen w-full overflow-hidden">
      <div className="absolute inset-0 z-0">
        <HeroCanvas />
      </div>

      <div className="relative z-10 flex h-full flex-col items-center justify-center px-6 text-center">
        <h1 className="text-7xl font-bold text-white">Título principal</h1>
        <p className="mt-4 text-xl text-white/70">Subtítulo acá</p>
        <button className="mt-8 rounded-full bg-white px-8 py-3 text-black font-medium">CTA</button>
      </div>
    </section>
  )
}
```

```typescript
// components/hero/HeroCanvas.tsx
'use client'

import { Canvas } from '@react-three/fiber'
import { ParticleField } from './ParticleField'

export default function HeroCanvas() {
  return (
    <Canvas
      camera={{ position: [0, 0, 5], fov: 75 }}
      gl={{ antialias: false, alpha: true }} // alpha: true → fondo CSS visible detrás del canvas
      dpr={[1, 1.5]} // limitar device pixel ratio para performance
    >
      <ParticleField />
    </Canvas>
  )
}
```

`alpha: true` es lo que permite ver el fondo CSS detrás del canvas
(sin esto el canvas es negro). `dpr={[1, 1.5]}` limita el DPR — en
retina el default es 2+ y dobla los píxeles que WebGL procesa.
`antialias: false` mejora performance y para partículas/efectos
abstractos no se nota.

## Patrón — partículas reactivas al mouse

El más versátil para landings. Miles de puntos que responden al
movimiento del cursor.

```typescript
// components/hero/ParticleField.tsx
'use client'

import { useRef, useMemo } from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import * as THREE from 'three'

const PARTICLE_COUNT = 2000

export function ParticleField() {
  const meshRef = useRef<THREE.Points>(null)
  const { mouse } = useThree()

  const { positions, originalPositions } = useMemo(() => {
    const positions = new Float32Array(PARTICLE_COUNT * 3)
    const originalPositions = new Float32Array(PARTICLE_COUNT * 3)

    for (let i = 0; i < PARTICLE_COUNT; i++) {
      const x = (Math.random() - 0.5) * 10
      const y = (Math.random() - 0.5) * 10
      const z = (Math.random() - 0.5) * 5

      positions[i * 3] = x
      positions[i * 3 + 1] = y
      positions[i * 3 + 2] = z
      originalPositions[i * 3] = x
      originalPositions[i * 3 + 1] = y
      originalPositions[i * 3 + 2] = z
    }

    return { positions, originalPositions }
  }, [])

  useFrame((state) => {
    if (!meshRef.current) return
    const time = state.clock.elapsedTime
    const pos = meshRef.current.geometry.attributes.position

    for (let i = 0; i < PARTICLE_COUNT; i++) {
      const i3 = i * 3
      pos.array[i3 + 1] = originalPositions[i3 + 1] + Math.sin(time * 0.5 + i * 0.1) * 0.1

      const dx = pos.array[i3] - mouse.x * 3
      const dy = pos.array[i3 + 1] - mouse.y * 3
      const dist = Math.sqrt(dx * dx + dy * dy)

      if (dist < 1.5) {
        pos.array[i3] += dx * 0.01
        pos.array[i3 + 1] += dy * 0.01
      }
    }

    pos.needsUpdate = true
    meshRef.current.rotation.y = time * 0.03
  })

  return (
    <points ref={meshRef}>
      <bufferGeometry>
        <bufferAttribute attach="attributes-position" count={PARTICLE_COUNT} array={positions} itemSize={3} />
      </bufferGeometry>
      <pointsMaterial size={0.015} color="#ffffff" transparent opacity={0.6} sizeAttenuation />
    </points>
  )
}
```

`pos.needsUpdate = true` es obligatorio cada frame si mutás el array
de posiciones — sin esto Three.js no re-renderiza. Para 2000
partículas este loop en `useFrame` es aceptable; para más de 5000,
mover la lógica a un vertex shader.

## Performance y fallback mobile

Detección de capacidad del dispositivo:

```typescript
// lib/webgl.ts
export function getWebGLTier(): 'high' | 'low' | 'unsupported' {
  if (typeof window === 'undefined') return 'unsupported'

  const canvas = document.createElement('canvas')
  const gl = canvas.getContext('webgl2') || canvas.getContext('webgl')
  if (!gl) return 'unsupported'

  const renderer = gl.getParameter((gl as WebGLRenderingContext).RENDERER)
  if (/Mali|Adreno 3|PowerVR/.test(renderer)) return 'low'
  return 'high'
}
```

Fallback en `HeroCanvas`:

```typescript
'use client'

import { useEffect, useState } from 'react'
import { Canvas } from '@react-three/fiber'
import { ParticleField } from './ParticleField'
import { getWebGLTier } from '@/lib/webgl'

export default function HeroCanvas() {
  const [tier, setTier] = useState<'high' | 'low' | 'unsupported' | null>(null)

  useEffect(() => { setTier(getWebGLTier()) }, [])

  if (tier === null) return null // evita flash antes de detectar

  if (tier === 'unsupported') {
    return <div className="absolute inset-0 bg-gradient-to-br from-black to-zinc-900" />
  }

  return (
    <Canvas camera={{ position: [0, 0, 5], fov: 75 }} gl={{ antialias: false, alpha: true }} dpr={tier === 'low' ? [1, 1] : [1, 1.5]}>
      <ParticleField count={tier === 'low' ? 500 : 2000} />
    </Canvas>
  )
}
```

Reglas para `useFrame` (corre 60/seg): sin `new THREE.Vector3()` dentro
(crea garbage, activa el GC — crear con `useRef` fuera y reutilizar),
sin lógica condicional pesada (va en `useMemo`), pausar si el
componente no está visible.

```typescript
// Mal — objeto nuevo 60 veces por segundo
useFrame(() => {
  mesh.current.position.lerp(new THREE.Vector3(target.x, target.y, 0), 0.05)
})

// Bien — reutiliza el vector
const targetVec = useRef(new THREE.Vector3())
useFrame(() => {
  targetVec.current.set(target.x, target.y, 0)
  mesh.current.position.lerp(targetVec.current, 0.05)
})
```

## Estructura de carpetas

```
components/
  hero/
    HeroSection.tsx      ← layout: canvas + DOM encima
    HeroCanvas.tsx       ← Canvas de R3F + detección de tier
    ParticleField.tsx    ← geometría de partículas
    ShaderBackground.tsx ← plano con shader (ver references/)
    ProductModel.tsx     ← modelo GLB (ver references/)
    ScrollCamera.tsx     ← integración GSAP + Three.js (ver references/)
lib/
  gsap.ts
  webgl.ts              ← detección de tier
public/
  models/               ← archivos .glb/.gltf
```

## Gotchas

- **`ssr: false` no es opcional** — sin `dynamic` + `ssr: false`,
  build roto con error poco claro.
- **El canvas bloquea pointer events por defecto** — si hay
  elementos interactivos sobre el canvas, `style={{ pointerEvents: 'none' }}`
  en el `<Canvas>` y `position: relative`/`z-index` mayor en el DOM.
- **`useFrame` en componentes desmontados** — R3F limpia solo, pero
  hacer `if (!meshRef.current) return` antes de acceder a refs.
- **Fonts/geometrías pesadas bloquean el hilo principal** — `Suspense`
  con `fallback={null}` alrededor de modelos GLB.
- **`@react-three/drei` es pesado** — importar solo lo que se usa
  (`import { useGLTF } from '@react-three/drei'`, nunca `import * as drei`).
- **Lenis + Three.js**: el mouse-move para interacción 3D sigue
  funcionando (no es scroll, no hay conflicto). Lo que puede fallar
  es ScrollTrigger afectando el canvas — ver integración en skill
  `gsap-motion`.

## Shaders, modelos GLB y scroll con GSAP

Para fondo generativo con shader (más performante que partículas para
efectos abstractos), modelo 3D de producto (GLB/GLTF), o integrar
scroll de GSAP con la cámara/escena: ver
`references/shaders-and-models.md`.
