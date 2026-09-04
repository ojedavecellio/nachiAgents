# Contexto — nachiAgents (el framework)

@../PROJECT_MEMORY.md

Este archivo es la memoria **propia** de este repo (nachiAgents), no
la plantilla de cliente. Claude Code lo carga desde `.claude/CLAUDE.md`
sin tocar el `CLAUDE.md` de la raíz — ese se copia tal cual a cada
proyecto vía `install.sh`.

## Qué es este repo

Framework de agentes, skills, commands y plantillas para Claude Code
+ Cursor. No es una app de producto. Cuando Nacho viene acá a
preguntar "¿hay algo para actualizar?", el contexto es el framework
mismo: agentes, skills, install, docs.

## Cómo trabajar acá

1. Leer `PROJECT_MEMORY.md` (importado arriba) antes de proponer
   cambios.
2. Si la pregunta es sobre actualizar librerías / agentes / skills:
   comparar lo documentado con lo que hay en `agents/`, `skills/`,
   `commands/`, `install.sh` y el README.
3. No editar el `CLAUDE.md` de la raíz con contexto del framework —
   contaminaría a todos los clientes.
4. Después de un cambio significativo al framework, actualizar
   `PROJECT_MEMORY.md`.
