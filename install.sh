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

# Resolver symlinks: npx ejecuta esto vía node_modules/.bin/nachi-agents,
# que es un symlink al install.sh real dentro de node_modules/nachi-agents/.
# Sin esto, SRC apuntaría a .bin/ (que no tiene agents/, skills/, etc.)
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

mkdir -p "$TARGET/.claude/agents" "$TARGET/.claude/skills" "$TARGET/.claude/commands"

cp "$SRC"/agents/*.md "$TARGET/.claude/agents/"

# skills/ — todos al proyecto excepto nextjs-audit (va global)
for d in "$SRC"/skills/*/; do
  name="$(basename "$d")"
  [ "$name" = "nextjs-audit" ] && continue
  cp -r "$d" "$TARGET/.claude/skills/$name"
done

# nextjs-audit va en ~/.claude/skills/ (global) — disponible en todos
# los proyectos sin estar versionado en cada uno.
mkdir -p ~/.claude/skills/nextjs-audit
cp "$SRC/skills/nextjs-audit/SKILL.md" ~/.claude/skills/nextjs-audit/SKILL.md
echo "nextjs-audit instalado globalmente en ~/.claude/skills/"

# commands/README.md es documentación de nachiAgents, no un slash
# command — todo lo demás en commands/*.md sí se copia.
for f in "$SRC"/commands/*.md; do
  base="$(basename "$f")"
  [ "$base" = "README.md" ] && continue
  cp "$f" "$TARGET/.claude/commands/"
done

# Hallmark (anti-AI-slop, ~106 archivos) — se clona el repo y se copia
# solo la carpeta del skill (skills/hallmark/), mismo patrón que los
# nuestros. No usamos "npx skills add": es interactivo (pide elegir
# agentes con un menú) y se cuelga en un script no interactivo.
# No fatal si git/red falla: el resto de nachiAgents queda instalado igual.
if [ ! -d "$TARGET/.claude/skills/hallmark" ]; then
  TMP_HALLMARK="$(mktemp -d)"
  if git clone --depth 1 -q https://github.com/nutlope/hallmark.git "$TMP_HALLMARK" 2>/dev/null \
     && [ -d "$TMP_HALLMARK/skills/hallmark" ]; then
    cp -r "$TMP_HALLMARK/skills/hallmark" "$TARGET/.claude/skills/hallmark"
    echo "Hallmark instalado en .claude/skills/hallmark/"
  else
    echo "No se pudo instalar Hallmark (github.com/nutlope/hallmark) — opcional, copiar 'skills/hallmark/' del repo a mano si hace falta."
  fi
  rm -rf "$TMP_HALLMARK"
fi

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
