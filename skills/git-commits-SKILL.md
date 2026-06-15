---
name: git-commits
description: Use this skill whenever writing a git commit message — after staging changes that are ready to commit, when the user says "hacé el commit", "armá el mensaje de commit", "committeá esto", or right before running git commit. Covers Conventional Commits format, scope naming for this stack, splitting into atomic commits, and what should never appear in a commit message.
---

# Mensajes de commit

Conventional Commits, en inglés — el código y los nombres de archivo ya
están en inglés, el mensaje sigue la misma convención.

## Formato

```
<type>(<scope>): <description>

<body opcional>

<footer opcional>
```

## Types

- `feat` — feature nueva o cambio de comportamiento visible
- `fix` — corrección de un bug
- `refactor` — cambio de estructura sin cambiar comportamiento
- `perf` — mejora de performance
- `style` — cambios puramente visuales/CSS sin lógica
- `docs` — documentación (README, comentarios, CLAUDE.md, etc.)
- `chore` — config, dependencias, scripts, CI
- `test` — agregar o ajustar tests

## Scope

Módulo/dominio afectado, kebab-case, entre paréntesis — `(hero)`,
`(auth)`, `(gallery)`, `(ctd-export)`. Si el cambio es transversal
(config global, dependencias en todo el proyecto), omitir el scope.

## Description

Imperativo, minúscula, sin punto final, máximo ~72 caracteres.
"add", "fix", "remove" — no "added"/"fixes"/"removing".

## Body

Solo si el "por qué" no es obvio desde el diff. El diff ya muestra el
"qué" — el body explica motivación o contexto, no repite los cambios
línea por línea. Si la descripción del header alcanza, no hay body.

## Atomicidad

Un commit = un cambio lógico. Si el trabajo tocó dos cosas no
relacionadas (arreglaste una animación Y actualizaste una dependencia),
son dos commits, no uno. `git add -p` para staging parcial cuando los
cambios quedaron mezclados en los mismos archivos.

## Qué NO va en el mensaje

- Sin "Generated with Claude Code" ni co-author footers, salvo pedido
  explícito.
- Sin commits tipo "fix", "wip", "cambios varios", "update" sin más
  contexto — si no se puede describir en una línea qué cambió y por
  qué, probablemente sean dos commits.
- `BREAKING CHANGE:` en el footer solo si rompe algo de lo que otro
  código (o vos mismo en otro proyecto) depende.

## Ejemplos

```
feat(audit): add project-auditor subagent

fix(gallery): prevent panel remount delay on desktop

refactor(gsap): move ScrollTrigger setup to lib/gsap.ts

perf(hero): lazy-mount particle field with IntersectionObserver

docs: add PROJECT_MEMORY.md convention to CLAUDE.md

chore: bump gsap to 3.13
```
