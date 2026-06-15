# Shaders, modelos GLB y scroll con GSAP

Patrones menos frecuentes que el campo de partículas del SKILL.md
principal, pero que aparecen cuando el brief pide algo más específico:
fondo generativo, producto en 3D, o cámara que reacciona al scroll.

## Fondo generativo con shader

Más performante que partículas para efectos de fondo abstracto: un
plano que cubre toda la pantalla con un fragment shader que anima
colores y formas. Sin geometría compleja, sin loops en CPU.

```typescript
// components/hero/ShaderBackground.tsx
'use client'

import { useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'

const vertexShader = `
  varying vec2 vUv;
  void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  }
`

const fragmentShader = `
  uniform float uTime;
  uniform vec2 uMouse;
  varying vec2 vUv;

  float noise(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
  }

  float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
  }

  void main() {
    vec2 uv = vUv;

    float n = smoothNoise(uv * 3.0 + uTime * 0.1);
    n += smoothNoise(uv * 6.0 - uTime * 0.15) * 0.5;

    float mouseInfluence = length(uv - uMouse) * 2.0;
    n += (1.0 - smoothstep(0.0, 1.0, mouseInfluence)) * 0.3;

    // Paleta — ajustar según el proyecto
    vec3 colorA = vec3(0.05, 0.05, 0.1);
    vec3 colorB = vec3(0.1, 0.05, 0.2);
    vec3 color = mix(colorA, colorB, n);

    gl_FragColor = vec4(color, 1.0);
  }
`

export function ShaderBackground() {
  const materialRef = useRef<THREE.ShaderMaterial>(null)

  useFrame(({ clock, mouse }) => {
    if (!materialRef.current) return
    materialRef.current.uniforms.uTime.value = clock.elapsedTime
    materialRef.current.uniforms.uMouse.value.set(mouse.x * 0.5 + 0.5, mouse.y * 0.5 + 0.5)
  })

  return (
    <mesh>
      <planeGeometry args={[2, 2]} />
      <shaderMaterial
        ref={materialRef}
        vertexShader={vertexShader}
        fragmentShader={fragmentShader}
        uniforms={{ uTime: { value: 0 }, uMouse: { value: new THREE.Vector2(0.5, 0.5) } }}
      />
    </mesh>
  )
}
```

Para que el plano cubra todo el viewport sin importar el tamaño de la
cámara: `<Canvas orthographic>` con `camera={{ zoom: 1 }}`, o ajustar
el plano al frustum de la cámara por defecto.

## Modelo 3D de producto (GLB/GLTF)

Para cuando el producto es físico o hay un modelo disponible. Drei
tiene los helpers para no escribir todo desde cero.

```typescript
// components/hero/ProductModel.tsx
'use client'

import { useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import { useGLTF, Environment, ContactShadows } from '@react-three/drei'
import * as THREE from 'three'

export function ProductModel() {
  const groupRef = useRef<THREE.Group>(null)
  const { scene } = useGLTF('/models/product.glb')

  useFrame((state) => {
    if (!groupRef.current) return
    groupRef.current.rotation.y += (state.mouse.x * 0.5 - groupRef.current.rotation.y) * 0.05
    groupRef.current.rotation.x += (state.mouse.y * 0.2 - groupRef.current.rotation.x) * 0.05
  })

  return (
    <>
      <Environment preset="city" />
      <group ref={groupRef}>
        <primitive object={scene} scale={1.5} />
      </group>
      <ContactShadows position={[0, -1.5, 0]} opacity={0.4} scale={4} blur={2} />
    </>
  )
}

// fuera del componente, para que el modelo empiece a cargar antes de montar
useGLTF.preload('/models/product.glb')
```

Los modelos GLB van en `/public/models/` — Next.js los sirve estático.

## Scroll de GSAP controlando la escena 3D

El patrón para que el scroll mueva la cámara o los objetos 3D. GSAP
anima un objeto mutable que Three.js lee en cada frame — requiere el
setup de `lib/gsap.ts` del skill `gsap-motion`.

```typescript
// components/hero/ScrollCamera.tsx
'use client'

import { useRef } from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import { useGSAP } from '@gsap/react'
import { gsap, ScrollTrigger } from '@/lib/gsap'

export function ScrollCamera() {
  const { camera } = useThree()
  const cameraTarget = useRef({ z: 5, y: 0 })

  useGSAP(() => {
    gsap.to(cameraTarget.current, {
      z: 8,
      y: -2,
      ease: 'none',
      scrollTrigger: {
        trigger: 'body',
        start: 'top top',
        end: '+=100%',
        scrub: 1,
      },
    })
  }, [])

  useFrame(() => {
    camera.position.z += (cameraTarget.current.z - camera.position.z) * 0.05
    camera.position.y += (cameraTarget.current.y - camera.position.y) * 0.05
  })

  return null
}
```

El lerp manual en `useFrame` (`+= (target - current) * 0.05`) suaviza
el movimiento aunque `scrub` ya tenga su propio lag — mismo principio
que un cursor custom con lerp.

## Gotcha de transparencia

`alpha: true` activa la transparencia del canvas, pero por defecto el
canvas tiene `background: transparent`. Si el fondo CSS detrás tiene
color o imagen, se ve a través del canvas en las zonas sin geometría
— es lo que se busca en el patrón base. Si no se quiere transparencia,
`alpha: false` + definir `scene.background = new THREE.Color(...)`.
