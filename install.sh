#!/bin/bash
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

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SRC="$(cd -P "$(dirname "$SOURCE")" && pwd)"

if [ ! -d "$TARGET" ]; then
  echo "No existe el directorio: $TARGET"
  exit 1
fi

mkdir -p "$TARGET/.claude/agents" "$TARGET/.claude/skills" "$TARGET/.claude/commands" "$TARGET/.cursor/rules"

cp "$SRC"/agents/*.md "$TARGET/.claude/agents/"
cp -r "$SRC"/skills/* "$TARGET/.claude/skills/"

# Cursor rules — mapa de contexto para Cursor Agent
cp "$SRC/templates/cursor-rules/nachiagents.mdc" "$TARGET/.cursor/rules/nachiagents.mdc"

for f in "$SRC"/commands/*.md; do
  base="$(basename "$f")"
  [ "$base" = "README.md" ] && continue
  cp "$f" "$TARGET/.claude/commands/"
done

if [ ! -d "$TARGET/.claude/skills/hallmark" ]; then
  TMP_HALLMARK="$(mktemp -d)"
  if git clone --depth 1 -q https://github.com/nutlope/hallmark.git "$TMP_HALLMARK" 2>/dev/null \
     && [ -d "$TMP_HALLMARK/skills/hallmark" ]; then
    cp -r "$TMP_HALLMARK/skills/hallmark" "$TARGET/.claude/skills/hallmark"
    echo "Hallmark instalado en .claude/skills/hallmark/"
  else
    echo "No se pudo instalar Hallmark — opcional, instalar a mano si hace falta."
  fi
  rm -rf "$TMP_HALLMARK"
fi

case "$VARIANT" in
  web)        CLAUDE_SRC="$SRC/CLAUDE.md" ;;
  mobile)     CLAUDE_SRC="$SRC/templates/CLAUDE-mobile.md" ;;
  automation) CLAUDE_SRC="$SRC/templates/CLAUDE-automation.md" ;;
  *)
    echo "Variante desconocida: '$VARIANT' (usar web | mobile | automation)"
    exit 1
    ;;
esac

if [ ! -f "$TARGET/CLAUDE.md" ]; then
  cp "$CLAUDE_SRC" "$TARGET/CLAUDE.md"
  echo "CLAUDE.md ($VARIANT) copiado a la raíz."
else
  echo "CLAUDE.md ya existe — no se sobreescribió."
fi

if [ ! -f "$TARGET/PROJECT_MEMORY.md" ]; then
  cp "$SRC/templates/PROJECT_MEMORY.md" "$TARGET/PROJECT_MEMORY.md"
  echo "PROJECT_MEMORY.md copiado."
else
  echo "PROJECT_MEMORY.md ya existe — no se sobreescribió."
fi

# Agregar .claude/ y .cursor/ al .gitignore si no están ya
GITIGNORE="$TARGET/.gitignore"
for entry in ".claude/" ".cursor/"; do
  if [ -f "$GITIGNORE" ]; then
    grep -qF "$entry" "$GITIGNORE" || echo "$entry" >> "$GITIGNORE"
  else
    echo "$entry" >> "$GITIGNORE"
  fi
done
echo ".claude/ y .cursor/ agregados al .gitignore"

echo "Listo. Agentes y skills instalados en $TARGET/.claude/"
