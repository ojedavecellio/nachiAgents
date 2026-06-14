#!/bin/bash
# Instala agents/ y skills/ de nachiAgents en .claude/ de un proyecto destino.
#
# Uso: ./install.sh /ruta/al/proyecto

set -e

TARGET="${1:?Uso: ./install.sh /ruta/al/proyecto}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$TARGET" ]; then
  echo "No existe el directorio: $TARGET"
  exit 1
fi

mkdir -p "$TARGET/.claude/agents" "$TARGET/.claude/skills"

cp "$SRC"/agents/*.md "$TARGET/.claude/agents/"
cp -r "$SRC"/skills/* "$TARGET/.claude/skills/"

if [ ! -f "$TARGET/CLAUDE.md" ]; then
  cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "CLAUDE.md copiado a la raíz — completar con lo específico del proyecto."
else
  echo "CLAUDE.md ya existe en el proyecto — no se sobreescribió."
  echo "Comparar manualmente con $SRC/CLAUDE.md para ver si falta algo nuevo."
fi

if [ ! -f "$TARGET/PROJECT_MEMORY.md" ]; then
  cp "$SRC/templates/PROJECT_MEMORY.md" "$TARGET/PROJECT_MEMORY.md"
  echo "PROJECT_MEMORY.md copiado — completar a medida que el proyecto avanza."
else
  echo "PROJECT_MEMORY.md ya existe — no se sobreescribió."
fi

echo "Listo. Agentes y skills instalados en $TARGET/.claude/"
