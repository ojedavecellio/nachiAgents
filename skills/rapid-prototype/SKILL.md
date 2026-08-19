---
name: rapid-prototype
description: Use this skill para generar un prototipo de UI rápido y desechable — HTML autocontenido con mock data — antes de comprometer código real en el stack del proyecto. Trigger cuando Nacho dice "quiero ver cómo se sentiría esto antes de construirlo posta", "hazme un prototipo rápido de esta pantalla", "necesito mostrarle esto a alguien antes de invertir tiempo real", o cuando `feature-spec` tiene una story con incertidumbre de UX que conviene resolver visualmente antes de especificarla del todo.
---

# Rapid prototype — prototipos desechables de UI

Playbook para generar un prototipo de una pantalla o flujo en HTML
autocontenido, rápido y desechable, antes de escribirle el spec final
o pedirle a Cursor que lo construya en el stack real. El objetivo es
testear el *flujo y la sensación*, no shippear el prototipo — se tira
después de que cumplió su función.

## Cuándo usarla (y cuándo no)

Sirve para: validar un flujo antes de comprometer tiempo real,
mostrarle algo tangible a alguien para juntar feedback, o resolver
una duda de UX que un texto en el spec no puede resolver.

No sirve para: features donde el riesgo es de lógica de negocio, no
de UX (ahí el prototipo no aporta nada — construir directo). Tampoco
reemplaza a las skills de diseño del stack real (`hallmark`,
`vercel-ui`, `taste-skill`) — esas se aplican al producto final, acá
la prioridad es velocidad, no pulido.

## Reglas del prototipo

- **HTML + CSS + JS vanilla en un solo archivo**, sin build step, sin
  dependencias del proyecto real — tiene que abrirse con doble click
  en el browser.
- **Mock data determinística**, no random — si alguien lo mira dos
  veces tiene que ver lo mismo, para poder discutirlo.
- **Cubrir todos los estados relevantes** de la pantalla: vacío,
  cargando, con datos, error — no solo el happy path. El estado vacío
  y el de error son los que más se olvidan y los que más definen si
  el flujo funciona.
- **Sin lógica real** — los botones pueden simular una acción
  (cambiar de estado visual) pero no hay backend, fetch real, ni
  persistencia.
- **Rápido primero, lindo después** — arrancar con estructura y
  contenido real (no Lorem Ipsum) en blanco y negro o estilo mínimo.
  Si el flujo funciona, recién ahí vale la pena invertir en verse
  bien — para eso, aplicar `hallmark` o `vercel-ui` sobre el mismo
  archivo.

## Proceso

1. **Confirmar qué se está testeando** — el flujo completo, una
   pantalla puntual, o una interacción específica. No prototipar más
   de lo necesario para responder la duda.
2. **Listar los estados** a cubrir (vacío/cargando/con datos/error) y
   las variantes si hay más de un camino posible.
3. **Generar el HTML** con navegación entre estados via JS simple
   (mostrar/ocultar secciones, no rutas reales).
4. **Entregarlo como artifact o archivo** para que Nacho lo abra
   directo — no requiere deploy ni instalación.

## Después del prototipo

Si el flujo valida — pasar a `feature-spec` con las decisiones de UX
ya resueltas (menos ambigüedad en las user stories). El prototipo en
sí no se lleva al proyecto real — Cursor construye la versión real en
el stack del proyecto (React/Tailwind), usando el prototipo como
referencia visual, no como código a reutilizar.

## Qué NO hacer

- No usar componentes o convenciones del proyecto real en el
  prototipo — mezclar rompe la velocidad que es el punto de esto.
- No prototipar toda la app de una — una pantalla o un flujo puntual
  por vez.
- No dejar el prototipo como si fuera código de producción — si
  Cursor lo termina copiando tal cual al proyecto real, se pierde el
  propósito (era desechable, no una primera versión del código real).
