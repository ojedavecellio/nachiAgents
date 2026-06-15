#!/bin/bash
# Instala agents/ y skills/ de nachiAgents en .claude/ de un proyecto
# destino, y copia el CLAUDE.md correspondiente al tipo de proyecto.
#
# Uso (parado en la carpeta del proyecto destino):
#   nachi-agents                # variante web, instala acá (.)
#   nachi-agents mobile         # variante mobile, instala acá (.)
#   nachi-agents automation     # variante automation, instala acá (.)
#
# Uso legacy (apuntando a otra carpeta):
#   nachi-agents /ruta/al/proyecto [web|mobile|automation]

set -e

ARG1="${1:-}"
ARG2="${2:-}"

case "$ARG1" in
  web|mobile|automation|"")
    TARGET="."
    VARIANT="${ARG1:-web}"
    ;;
  *)
    TARGET="$ARG1"
    VARIANT="${ARG2:-web}"
    ;;
esac

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$TARGET" ]; then
  echo "No existe el directorio: $TARGET"
  exit 1
fi

mkdir -p "$TARGET/.claude/agents" "$TARGET/.claude/skills"

cp "$SRC"/agents/*.md "$TARGET/.claude/agents/"
cp -r "$SRC"/skills/* "$TARGET/.claude/skills/"

case "$VARIANT" in
  web)
    CLAUDE_SRC="$SRC/CLAUDE.md"
    ;;
  mobile)
    CLAUDE_SRC="$SRC/templates/CLAUDE-mobile.md"
    ;;
  automation)
    CLAUDE_SRC="$SRC/templates/CLAUDE-automation.md"
    ;;
  *)
    echo "Variante desconocida: '$VARIANT' (usar web | mobile | automation)"
    exit 1
    ;;
esac

if [ ! -f "$TARGET/CLAUDE.md" ]; then
  cp "$CLAUDE_SRC" "$TARGET/CLAUDE.md"
  echo "CLAUDE.md ($VARIANT) copiado a la raíz — completar con lo específico del proyecto."
else
  echo "CLAUDE.md ya existe en el proyecto — no se sobreescribió."
  echo "Comparar manualmente con $CLAUDE_SRC para ver si falta algo nuevo."
fi

if [ ! -f "$TARGET/PROJECT_MEMORY.md" ]; then
  cp "$SRC/templates/PROJECT_MEMORY.md" "$TARGET/PROJECT_MEMORY.md"
  echo "PROJECT_MEMORY.md copiado — completar a medida que el proyecto avanza."
else
  echo "PROJECT_MEMORY.md ya existe — no se sobreescribió."
fi

echo "Listo. Agentes y skills instalados en $TARGET/.claude/"
