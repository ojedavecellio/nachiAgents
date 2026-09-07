# Contexto base (mobile) — Nacho

@PROJECT_MEMORY.md

Indie developer. Vibe coder:
construyo con asistencia de AI. Prompts directos, sin relleno.

## Framework

Expo managed workflow + expo-router (routing file-based). Sin eject a
bare workflow salvo dependencia nativa que Expo no soporte (raro en la
práctica). iOS-first: diseño y decisiones de UX parten de iOS —
Android y web son targets secundarios que se verifican pero no
dictan decisiones.

## Stack

```
expo (~57.x)          ← npx expo install; no bajar de expo@57.0.9
                       (regresión de memoria Hermes V1 en 56 y 57 temprano)
react (19.2.x)
react-native (0.86.x)
typescript (~5.x)
Node 22.13+           ← mínimo del SDK 57
```

Dependencias de Expo (`expo-router`, `expo-sqlite`, etc.): siempre
`npx expo install`, nunca el latest suelto de npm.

New Architecture es obligatoria (SDK 55+). No hay opt-out.
React Compiler recomendado en proyectos nuevos:
`experiments.reactCompiler` en `app.json`.

UI: React Native Paper para componentes base si hace falta. Reanimated
para animaciones — requiere `react-native-worklets` y el plugin de
Babel; sin él las animaciones fallan en runtime sin error claro.
Gesture Handler para interacciones táctiles complejas. `ActionSheetIOS`
es iOS-only — si hay planes de soporte Android, abstraer desde el
principio. Audio/video: `expo-audio` / `expo-video` — `expo-av` ya no
existe en este SDK.

Sin Tailwind/NativeWind — StyleSheet de React Native o inline.

## Datos y arquitectura

Local-first: SQLite en el dispositivo (`expo-sqlite`), con
repositorios propios en `src/db/repositories/` — nunca acceder a la DB
directamente desde componentes. Migraciones numeradas
(`001_initial.sql`, `002_add_x.sql`...), corren en orden por nombre de
archivo. `@react-native-async-storage/async-storage` para
preferencias y estado de UI persistido. `expo-sqlite` tiene
diferencias de API entre versiones — usar siempre la del SDK de Expo
correspondiente, no la última de npm.

Sin backend propio en v1, sin auth en v1 (un solo usuario local). Si
el proyecto crece a multi-usuario o necesita sync, eso es v2 con
diseño explícito — Supabase como candidato natural (ver skill
`supabase-setup` cuando llegue ese momento).

Estado: `useState` para pantalla, Context + AsyncStorage para
preferencias globales (tema, modos). Sin Redux/Zustand/Jotai/MobX.

## IA remota

Anthropic API desde un service dedicado (`src/services/ai.ts`). La key
NUNCA va en el bundle para producción — EAS Secrets + proxy
server-side si hace falta. `process.env.ANTHROPIC_API_KEY` en el
cliente no es seguro aunque venga de env vars de Expo: todo lo que
está en el bundle JS es extraíble del APK/IPA.

## Archivos del usuario

`expo-file-system` para adjuntos y assets locales. `expo-image-picker`
y `expo-document-picker` para input del usuario.

## Estructura de carpetas

```
app/              ← rutas (expo-router, file-based)
src/
  components/     ← UI por dominio
  db/
    repositories/ ← acceso a SQLite
    migrations/   ← SQL de migraciones
  services/       ← integraciones externas (IA, etc.)
  hooks/
  context/        ← estado global chico (tema, modo, etc.)
  models/
  utils/
```

## Build y deploy

EAS Build para producción, perfiles `development`/`preview`/`production`
en `eas.json`. Sin EAS en desarrollo (Expo Go o simulador local). EAS
Secrets para API keys en builds de producción — sin excepciones. Sin
CI/CD automatizado en v1, builds manuales con `eas build`.

## Convenciones

TypeScript strict, sin `any` implícito. Un archivo = una
responsabilidad. Sin comentarios obvios. Testing mínimo: lógica de
negocio core si la hay, no UI.

## Antes de arrancar cualquier tarea

Anunciar qué recursos se van a usar:
> "Para esto voy a usar: `[skill]`"

Cursor es el único agente. Ejecuta: lee el repo, sigue las skills
en `.cursor/skills/`, edita archivos. No armes prompts para pegar
en otro lado.

## Memoria del proyecto

`PROJECT_MEMORY.md` (importado arriba) es el estado vivo de este
proyecto. Al arrancar cada sesión, leerlo primero.

Si está vacío — antes de hacer cualquier otra cosa, preguntarle a Nacho:
> "PROJECT_MEMORY.md está vacío. Contame el problema que resuelve
> esta app y qué está construido hasta ahora."

Después de un cambio significativo, actualizarlo.

## Recommended tools

- **`npx react-doctor@latest`** — anti-patterns en la capa de React
  (re-renders, hooks mal usados). Aplica igual en React Native. Correr
  antes de un build de producción si hubo cambios grandes de
  componentes.
- **Figma** — si hay un MCP de Figma conectado en esta sesión, usalo
  para traer specs cuando hay que implementar una pantalla 1:1.

## Flujos de trabajo

Leé y seguí `.cursor/skills/<nombre>/SKILL.md`, y ejecutá.

**Auditoría del proyecto** → skill `project-auditor`.

**Antes de un build de producción con `eas build`** → skill
`deploy-checker`. Confirmar que las API keys están en EAS Secrets,
nunca hardcodeadas.

**Idea cruda / spec** → `product-discovery` y `feature-spec`. No
código de producto hasta que haya spec.
