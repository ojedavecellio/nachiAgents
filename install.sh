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

mkdir -p "$TARGET/.cursor/rules" "$TARGET/.cursor/skills"

copy_skill() {
  local src="$1"
  local dest="$2"
  if [ -d "$SRC/$src" ]; then
    mkdir -p "$(dirname "$dest")"
    cp -r "$SRC/$src" "$dest"
  fi
}

install_playbook() {
  local src_file="$1"
  local name
  name="$(basename "$src_file" .md)"
  mkdir -p "$TARGET/.cursor/skills/$name"
  cp "$src_file" "$TARGET/.cursor/skills/$name/SKILL.md"
}

cp -r "$SRC"/skills/* "$TARGET/.cursor/skills/"

for f in "$SRC"/agents/*.md; do
  [ -f "$f" ] || continue
  install_playbook "$f"
done

for f in "$SRC"/commands/*.md; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  case "$base" in
    README.md|commands-README.md) continue ;;
  esac
  install_playbook "$f"
done

cp "$SRC/templates/cursor-rules/nachiagents.mdc" "$TARGET/.cursor/rules/nachiagents.mdc"

copy_skill ".cursor/skills/emil-design-eng" "$TARGET/.cursor/skills/emil-design-eng"
copy_skill ".cursor/skills/taste-skill" "$TARGET/.cursor/skills/taste-skill"

if [ -f "$SRC/.cursor/skills/design-README.md" ]; then
  cp "$SRC/.cursor/skills/design-README.md" "$TARGET/.cursor/skills/design-README.md"
fi

echo ""
echo "Skills installed in $TARGET/.cursor/skills/"

if [ "$VARIANT" = "web" ]; then
  echo "Installing official skills (authors keep them current)..."
  (
    cd "$TARGET"
    npx --yes skills add greensock/gsap-skills -a cursor -s '*' -y \
      || echo "WARN: no se pudieron instalar greensock/gsap-skills"
    npx --yes skills add vercel/next.js -a cursor -s '*' -y \
      || echo "WARN: no se pudieron instalar vercel/next.js skills"
  )
  echo "Refresh later: npx skills update -y"
fi

echo "For impeccable, run separately: npx impeccable install"
echo "Optional official Hallmark: npx skills add nutlope/hallmark"

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

echo "Listo. Skills y rules instalados en $TARGET/.cursor/"
