# cursor-delegate

Delega ediciones de código a Cursor CLI (`agent -p`) en vez de editarlas
directamente. Claude Code actúa como cerebro (lee, decide, arma el prompt),
Cursor CLI actúa como manos (edita, crea archivos). Resultado: Claude Code
gasta mínimos tokens en la parte cara (generar y aplicar diffs); Cursor
usa su propia cuota.

## Cuándo usar esta skill

Usar siempre que la tarea implique editar o crear archivos y el usuario
no haya pedido explícitamente que Claude Code lo haga él mismo.

Excepciones donde Claude Code edita directo (sin delegar):
- El usuario lo pide explícitamente ("editalo vos", "hacelo acá")
- Es un cambio de una sola línea trivial (una constante, un typo)
- `agent` no está disponible en el PATH (`which agent` falla)

## Criterio: directo vs con confirmación

**Directo** (manda sin preguntar):
- Un solo archivo afectado
- Fix con causa clara y acotada (lint error, typo, variable sin usar)
- Resultado predecible — el diff esperado es obvio

**Con confirmación** (muestra el prompt, espera OK antes de mandar):
- Múltiples archivos
- Feature nueva o refactor
- Cambio arquitectónico (mover código entre capas, cambiar patrones)
- Cualquier cosa que toque lógica de negocio, auth, o DB

## Cómo armar el prompt para Cursor

El prompt que va a `agent -p` tiene que ser autocontenido — Cursor conoce
el repo pero no esta conversación. Incluir siempre:

1. **Qué hacer** — acción concreta, sin contexto de por qué llegamos acá
2. **Dónde** — paths exactos de los archivos a tocar
3. **Restricciones** — qué NO tocar, convenciones a respetar
4. **Criterio de éxito** — cómo sabe Cursor que terminó bien

Ejemplo de prompt bien armado:
```
En hooks/useTimer.ts, corregí el error de react-hooks/exhaustive-deps
en la línea 47: agregá `intervalRef` al array de dependencias del
useEffect. No toques ningún otro archivo. El fix es correcto cuando
`npm run lint` no reporta errores en ese archivo.
```

Ejemplo de prompt mal armado (sin contexto suficiente):
```
Arreglá el bug del timer.
```

## Ejecución

```bash
agent -p "<prompt autocontenido>" --output-format text
```

El `--trust` no es necesario si el proyecto ya fue aprobado antes
(se persiste por directorio). Si falla con "Workspace Trust Required",
agregar `--trust` al comando.

Timeout recomendado para cambios grandes (evita que se cuelgue
indefinidamente en casos edge):
```bash
timeout 120 agent -p "<prompt>" --output-format text
```

## Después de la ejecución

1. Leer los archivos modificados con Read/Glob para verificar que el
   cambio es correcto — no asumir que Cursor hizo exactamente lo pedido
2. Reportar al usuario: qué cambió, en qué archivos, resultado de la
   verificación
3. Si el resultado no es correcto: armar un prompt de corrección más
   específico y volver a delegar (no intentar arreglar el output de
   Cursor editando directo, salvo que sea un caso de excepción arriba)

## Gotchas

- `agent -p` es bloqueante — Claude Code espera a que termine antes de
  seguir. Para cambios que tardan (refactors grandes), avisarle al
  usuario que puede tardar.
- El output de `agent -p` es la respuesta en texto del agente, no un
  diff. Para saber qué cambió exactamente, leer los archivos después
  con Read o correr `git diff`.
- Si Cursor no tiene el modelo correcto configurado, puede usar uno más
  lento o menos capaz. El modelo se elige en la UI de Cursor — esta
  skill no lo controla.
- No anidar delegaciones: si el prompt a Cursor genera una pregunta de
  vuelta ("¿querés que también toque X?"), no hay forma de responderle
  en modo `-p`. El prompt tiene que ser lo suficientemente específico
  para que Cursor lo resuelva sin preguntar.
