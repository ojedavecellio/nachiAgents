---
name: lean-experiments
description: Use this skill para diseñar el experimento más barato posible que pueda refutar una hipótesis de producto, antes de construir nada. Trigger cuando `product-discovery` señala un riesgo sin validar, cuando Nacho dice "cómo valido esto sin construirlo", "necesito saber si esto vale la pena antes de meterle tiempo", o cuando hay que priorizar qué asunción testear primero entre varias.
---

# Lean experiments — validar antes de construir

Playbook para diseñar el experimento más barato que puede matar una
idea mala rápido, en vez de construir el producto completo para
descubrir que nadie lo quiere. Complementa a `product-discovery`
(que identifica las hipótesis) — esta skill decide cómo testearlas.

## Principio

El costo de estar equivocado sobre una hipótesis debería ser mucho
menor que el costo de construir la feature completa. Si el
experimento cuesta casi lo mismo que construir la cosa real, no es un
experimento — es solo construir despacio.

## Priorizar qué testear primero: matriz Impacto × Riesgo

Antes de diseñar el experimento, ordenar las hipótesis:

- **Alto impacto + alto riesgo** (no sabés si es cierto, y si es falso
  mata el proyecto) → testear primero, siempre.
- **Alto impacto + bajo riesgo** (ya tenés evidencia razonable) →
  seguir de largo, no hace falta experimento.
- **Bajo impacto** (aunque falle, no cambia la decisión de construir
  o no) → no vale la pena diseñar un experimento, es ruido.

## Tipos de experimento (de más barato a más caro)

### 1. Entrevistas tipo Mom Test
Antes de cualquier experimento con código: hablar con 3-5 personas del
perfil objetivo. Reglas del Mom Test — evitar que confirmen por
cortesía:

- Preguntar sobre su vida y comportamiento pasado, no sobre la idea.
  ("¿Cómo resolvés esto hoy?" en vez de "¿Usarías algo que haga X?")
- Nunca describir la solución antes de entender el problema.
- Cualquier pregunta que se pueda responder con un cumplido en vez de
  un hecho, está mal formulada.
- Buscar compromisos reales (tiempo, dinero, intro a otra persona), no
  "me encantaría" — eso no cuesta nada decirlo.

### 2. Landing page / explainer
Una página que describe el producto terminado (aunque no exista) con
un CTA real (waitlist, "avisame cuando salga", precio). Mide interés
real por conversión, no por opinión. Costo: horas, no días.

### 3. Pre-orden / paga antes de que exista
El experimento más fuerte de intención de compra: pedir el pago (o un
depósito reembolsable) antes de construir. Si nadie paga, nadie lo
quería lo suficiente.

### 4. Wizard of Oz
El usuario interactúa con algo que parece automatizado pero atrás hay
un humano haciendo el trabajo manualmente (Nacho respondiendo a mano,
un Google Sheet en vez de un backend real). Válido para testear si el
resultado tiene valor antes de invertir en automatizarlo.

### 5. Prototipo real pero acotado
Cuando ninguno de los anteriores alcanza porque la hipótesis es sobre
la experiencia de uso en sí (no sobre si la gente la quiere) — ver
skill `rapid-prototype` para esto, es el escalón antes de construir
la versión de producción.

## Diseñar el experimento

Para cada hipótesis a testear, definir antes de arrancar:

1. **Qué vas a medir** — un número o comportamiento concreto, no una
   sensación ("3 de 5 personas se anotan en la waitlist", no "la
   gente parece interesada").
2. **Umbral de éxito y de fracaso** — antes de correr el experimento,
   no después. Si no definiste el umbral de fracaso, cualquier
   resultado se puede racionalizar como éxito.
3. **Tiempo/costo máximo** — cuánto tiempo o plata estás dispuesto a
   gastar en el experimento antes de cortarlo, corra bien o mal.

## Qué NO hacer

- No diseñar un experimento para una hipótesis de bajo impacto — es
  desperdiciar tiempo en algo que no cambia la decisión.
- No arrancar el experimento sin el umbral de fracaso definido.
- No confundir "la gente dijo que le gustaba" con validación — buscar
  siempre el compromiso real (tiempo, plata, intro) sobre la opinión.
