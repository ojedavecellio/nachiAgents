# OG images — templates

Satori details: [satori](https://github.com/vercel/satori). Vercel:
[OG Image Generation](https://vercel.com/docs/og-image-generation).
Playground: [og-playground.vercel.app](https://og-playground.vercel.app/).

## Ruta (`app/api/og/route.tsx`)

```tsx
import { ImageResponse } from 'next/og'
import { readFile } from 'node:fs/promises'
import { join } from 'node:path'

export async function GET(request: Request) {
  const title =
    new URL(request.url).searchParams.get('title')?.slice(0, 80) ??
    'Default product claim'

  const font = await readFile(
    join(process.cwd(), 'public/fonts/Brand-Regular.otf'),
  )
  const logo = await readFile(
    join(process.cwd(), 'public/logo.png'),
  )

  return new ImageResponse(
    (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between',
          width: '100%',
          height: '100%',
          padding: 80,
          background: '#0a0a0a',
          color: '#fafafa',
        }}
      >
        <img
          src={`data:image/png;base64,${logo.toString('base64')}`}
          width={48}
          height={48}
          alt=""
        />
        <div
          style={{
            display: 'flex',
            fontSize: 72,
            lineHeight: 1.05,
            letterSpacing: '-0.03em',
            maxWidth: 960,
          }}
        >
          {title}
        </div>
      </div>
    ),
    {
      width: 1200,
      height: 630,
      fonts: [{ name: 'Brand', data: font, style: 'normal' }],
    },
  )
}
```

Colores, font, logo y titular salen **del proyecto**, no de este
snippet. Cada `div` lleva `display: 'flex'`.

## Font si no hay archivo local

Subset desde Google Fonts (texto real, no la familia entera):

```ts
async function loadGoogleFont(family: string, text: string) {
  const cssUrl = `https://fonts.googleapis.com/css2?family=${encodeURIComponent(family)}&text=${encodeURIComponent(text)}`
  const css = await (await fetch(cssUrl)).text()
  const match = css.match(
    /src: url\((.+)\) format\('(opentype|truetype)'\)/,
  )
  if (!match?.[1]) throw new Error(`Font not found: ${family}`)
  const res = await fetch(match[1])
  if (!res.ok) throw new Error(`Font fetch failed: ${family}`)
  return res.arrayBuffer()
}
```

Formatos: `ttf`, `otf`, `woff`. Preferir `ttf`/`otf`. No `woff2`.
`next/font` **no** funciona dentro de `ImageResponse` — hay que
pasar `ArrayBuffer` en `fonts`.

## Metadata

Sin `metadataBase`, `og:image` relativa se rompe en varios crawlers.

```ts
// app/layout.tsx (o la página)
export const metadata = {
  metadataBase: new URL('https://example.com'),
  openGraph: {
    title: 'Product',
    description: 'One-line claim',
    images: [{ url: '/api/og', width: 1200, height: 630 }],
  },
  twitter: {
    card: 'summary_large_image',
    images: ['/api/og'],
  },
}
```

Página con título propio:

```ts
images: [
  {
    url: `/api/og?title=${encodeURIComponent(title)}`,
    width: 1200,
    height: 630,
  },
]
```

## robots.txt

```
Allow: /api/og
```

Si `robots.txt` se genera en Next (`app/robots.ts`), incluir esa
regla ahí.

## Satori — lo que no va

- `display: grid`, `gap` inconsistente, selectores CSS, media queries
- Web fonts por `link` / `next/font` (solo `fonts` en options)
- Bundle de la ruta > 500KB (JSX + CSS + fonts + imágenes). Si se
  pasa, subset de font o fetch de assets en runtime — no embeber
  fotos enormes.

## Preview

```bash
curl -sS "http://localhost:3000/api/og" -o /tmp/og-preview.png
curl -sS -G "http://localhost:3000/api/og" --data-urlencode "title=Your claim here" -o /tmp/og-preview.png
```

Después del deploy: Vercel → deployment → tab **Open Graph**.
