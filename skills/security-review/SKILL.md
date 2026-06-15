---
name: security-review
description: Use this skill whenever the task involves secrets/API keys, environment variables, making a repo or deploy public, Supabase Auth or RLS policies, validating user input, rate limiting, or any "es seguro esto", "revisá la seguridad", "podemos hacer público este repo", "vamos a lanzar esto" type request. Always consult before exposing a project publicly, before adding auth or new tables with user data, before writing Route Handlers that touch the database, and before any production deploy — covers the security checklist by exposure level, RLS patterns, input validation with zod, and the most common Supabase/Vercel/Expo security mistakes.
---

# Seguridad — checklist por nivel de exposición

Lo que un indie developer tiene que tener resuelto antes de que algo
sea público. No es una guía de seguridad empresarial — está organizado
por nivel para no sobre-ingenierizar proyectos personales.

## Niveles

- **Nivel 1 — Personal/interno**: un solo usuario, sin datos de
  terceros, no indexado.
- **Nivel 2 — Beta/usuarios reales**: hay cuentas, datos que no son
  tuyos, URL pública.
- **Nivel 3 — Producto público**: múltiples usuarios, datos
  sensibles, tráfico real.

Todo lo de Nivel 1 aplica al 2, todo lo del 2 aplica al 3.

## Nivel 1 — Lo que nunca puede faltar

**Secrets**: nunca hardcodeados, ni siquiera como "fallback temporal".

```
.env          ← valores reales, en .gitignore
.env.example  ← variables sin valores, en el repo
```

`.gitignore` con `.env`, `.env.local`, `*.pem`, `credentials.json`,
`token.json` desde el primer commit. Si una key llegó al repo por
accidente: revocarla en el proveedor ya — el git history no se limpia
fácil y la key queda comprometida.

**Antes de hacer público un repo privado**:

```bash
git log --all --full-history -- "*.env"
```

Si aparece algo, el repo está comprometido aunque el archivo ya no
exista en `main`.

`robots: { index: false }` en proyectos no listos para ser públicos —
Lovable lo pone por defecto, sacarlo al lanzar.

## Nivel 2 — Usuarios reales

**Auth**: Supabase Auth para todo lo que tiene usuarios reales. RLS
activado en toda tabla con datos de usuarios — NO es automático.

```sql
alter table items enable row level security;

create policy "users can only access own items"
on items for all
using (auth.uid() = user_id);
```

Sin RLS, cualquier usuario autenticado lee los datos de cualquier
otro. `service_role` bypasea RLS completamente — solo en el servidor,
nunca en el cliente ni en variables `NEXT_PUBLIC_*`.

**Inputs**: nunca confiar en datos del cliente. Validar en el servidor
antes de persistir o procesar.

```typescript
const schema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().max(10000),
})

const result = schema.safeParse(await request.json())
if (!result.success) return Response.json({ error: 'Invalid input' }, { status: 400 })
```

Nunca `SELECT *` en queries al cliente — siempre columnas explícitas,
y filtrar la respuesta con zod antes de devolverla (así si mañana
alguien agrega una columna sensible, no viaja sola al browser).

Ningún endpoint que devuelve listas sin paginar — `PAGE_SIZE = 20`
como default. `count: 'exact'` para que el cliente calcule el total
de páginas:

```typescript
const PAGE_SIZE = 20

const { data, count } = await supabase
  .from('tabla')
  .select('col1, col2, col3', { count: 'exact' })
  .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1)
  .order('created_at', { ascending: false })
```

Nunca columna `password` en tablas propias — solo Supabase Auth.

Sin concatenación de strings para SQL crudo — siempre parámetros. El
cliente de Supabase y la mayoría de ORMs lo manejan solo; el riesgo
es en SQL directo.

**Headers de seguridad** en `next.config.js`:

```javascript
const securityHeaders = [
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
]
```

CORS manual no hace falta si frontend y backend están en el mismo
dominio de Vercel — solo si hay un backend separado (FastAPI)
consumido desde otro origen.

**Rate limiting** en endpoints que consumen LLM o pueden ser
abusados. `@upstash/ratelimit` + Redis de Upstash en Vercel. No
inventar rate limiting in-memory en serverless — no funciona entre
instancias. En FastAPI: `slowapi`.

## Nivel 3 — Producto público

Variables de entorno distintas por ambiente (dev/preview/prod) — APIs
keys de test vs producción, URLs de DB que nunca deben apuntar a
producción desde dev.

Mínimo privilegio: el backend solo pide y guarda lo que necesita. No
loguear emails ni datos de usuarios en texto plano — los logs de
Vercel son visibles para cualquiera con acceso al proyecto.

Tokens OAuth de terceros (Gmail, Google) encriptados en DB — patrón
`enc:v1:` + valor encriptado, para identificar tokens en formato
legacy y migrarlos.

`npm audit` / `pip-audit` antes de cada deploy a algo nuevo o después
de actualizar dependencias — no en cada commit, pero sí antes de
lanzar. Distinguir severidad alta/crítica de media/baja, y código
servidor vs cliente.

Backups automáticos activados en Supabase (plan pago) antes de tener
usuarios reales. Point-in-time recovery en Neon si aplica.

## Por plataforma — gotchas específicos

**Next.js + Vercel**: `NEXT_PUBLIC_*` solo para lo que puede ser
público. Service role nunca con ese prefijo. Preview deployments son
públicos por defecto — password protection si tienen datos reales.

**Supabase**: RLS no se activa automáticamente por tabla nueva.
Políticas testeadas manualmente en el inspector del dashboard antes
de producción. Auth emails con dominio propio en producción.

**Expo/React Native**: todo lo que está en el bundle JS es extraíble
del APK/IPA — `process.env.ANTHROPIC_API_KEY` en el cliente NO es
seguro aunque venga de env vars de Expo. EAS Secrets + proxy
server-side para producción. Si hay datos sensibles en SQLite local,
considerar `expo-sqlite-encrypted`.

**Python/FastAPI**: `.env` con `python-dotenv`, nunca hardcodeado.
`credentials.json`/`token.json` de OAuth en `.gitignore` desde el
inicio. En producción, variables de entorno del sistema, no archivo
`.env`. Endpoints de admin con al menos un secret en header.

## Checklist final antes de hacer público

- [ ] `.env` en `.gitignore` y sin secrets en el historial de git
- [ ] `.env.example` completo y actualizado
- [ ] RLS activado en Supabase si hay datos de usuarios
- [ ] `service_role` no expuesta al cliente
- [ ] `robots.txt`/metadata de indexación configurada según corresponda
- [ ] Variables de entorno de producción distintas de las de dev
- [ ] Rate limiting en endpoints que consumen LLM o APIs de terceros
- [ ] Validación de inputs en el servidor antes de persistir
- [ ] Sin `console.log` con datos sensibles en producción
- [ ] `npm audit` sin vulnerabilidades high/critical

Esta misma lista es la que corre `deploy-checker` antes de un deploy —
este skill es el "por qué" detrás de cada ítem, para cuando hay que
diseñar algo nuevo, no solo verificarlo al final.
