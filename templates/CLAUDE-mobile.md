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
expo (~54.x)
expo-router (~6.x)
react (19.x)
react-native (0.81.x)
typescript (~5.x)
```

UI: React Native Paper para componentes base si hace falta. Reanimated
para animaciones (gestos, transiciones) — requiere el plugin de Babel;
sin él las animaciones fallan en runtime sin error claro. Gesture
Handler para interacciones táctiles complejas. `ActionSheetIOS` es
iOS-only — si hay planes de soporte Android, abstraer desde el
principio.

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

## Formato de prompts para Cursor

Todo prompt destinado a ser pegado en Cursor va precedido del título
**Prompt para Cursor:** y dentro de un bloque de código. Siempre,
sin excepción.

Antes de armar un prompt, evaluar el costo:

- **El prompt es obvio sin leer nada** → armarlo corto y pasarlo.
- **Para armar el prompt habría que leer archivos o correr comandos**
  → delegarle la tarea completa a Cursor directamente.

## Regla fundamental

Claude Code nunca ejecuta trabajo por su cuenta. Lee el repo cuando
sea necesario para entender el contexto, pero **no corre bash, no
ejecuta agents ni skills, no edita archivos** sin que Nacho lo pida
explícitamente.

Antes de arrancar cualquier tarea, avisar:
> "Para esto voy a necesitar [leer X / correr Y]. ¿Lo hago yo o
> querés el prompt para Cursor?"

Solo trabajar sin preguntar si Nacho dice explícitamente "hacelo vos".

## Memoria del proyecto

`PROJECT_MEMORY.md` (importado arriba) es el estado vivo de este
proyecto. Al arrancar cada sesión, leerlo primero.

Si está vacío — antes de hacer cualquier otra cosa, preguntarle a Nacho:
> "PROJECT_MEMORY.md está vacío. Contame el problema que resuelve
> esta app y qué está construido hasta ahora."

Después de un cambio significativo, actualizarlo.

## Flujos de trabajo

Todos los flujos arrancan igual: Claude Code entiende el contexto y
arma el prompt. Cursor ejecuta. Claude Code verifica.

**Auditoría del proyecto** → prompt para Cursor: *"Seguí las
instrucciones de `.claude/agents/project-auditor.md` y auditá este
proyecto."*

**Antes de un build de producción con `eas build`** → prompt para
Cursor: *"Seguí las instrucciones de `.claude/agents/deploy-checker.md`."*
Confirmar que las API keys están en EAS Secrets, nunca hardcodeadas.

**Editar archivos** → armar prompt corto para Cursor y dárselo a Nacho
para pegar en Agents Window.
