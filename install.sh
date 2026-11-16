#!/bin/bash
set -euo pipefail

UPDATE=0
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --update) UPDATE=1 ;;
    *) POSITIONAL+=("$arg") ;;
  esac
done

ARG1="${POSITIONAL[0]:-}"
ARG2="${POSITIONAL[1]:-}"

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

case "$VARIANT" in
  web|mobile|automation) ;;
  *)
    echo "Variante desconocida: '$VARIANT' (usar web | mobile | automation)"
    exit 1
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

TARGET="$(cd "$TARGET" && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "Hace falta python3 para mezclar AGENTS.md y el .gitignore."
  exit 1
fi

mkdir -p "$TARGET/.cursor/rules" "$TARGET/.cursor/skills"

copy_skill() {
  local src="$1"
  local dest="$2"
  if [ -d "$SRC/$src" ]; then
    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    cp -R "$SRC/$src" "$dest"
  fi
}

install_playbook() {
  local src_file="$1"
  local name
  name="$(basename "$src_file" .md)"
  mkdir -p "$TARGET/.cursor/skills/$name"
  cp "$src_file" "$TARGET/.cursor/skills/$name/SKILL.md"
}

rm -rf "$TARGET/.cursor/skills/hallmark"
rm -f "$TARGET/.cursor/skills/glass-patterns/references/liquid-glass-implementation.md"
cp -R "$SRC"/skills/. "$TARGET/.cursor/skills/"

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
    if [ "$UPDATE" = 1 ]; then
      npx --yes skills update -y \
        || echo "WARN: npx skills update fallo. Sigo con skills add."
    fi
    npx --yes skills add greensock/gsap-skills -a cursor -s '*' -y \
      || echo "WARN: no se pudieron instalar greensock/gsap-skills"
    npx --yes skills add vercel/next.js -a cursor -s '*' -y \
      || echo "WARN: no se pudieron instalar vercel/next.js skills"
  )
  echo "Refresh later: npx skills update -y"
fi

echo "For impeccable, run separately: npx impeccable install"

sync_tree() {
  local from="$1"
  local to="$2"
  local mode="$3"
  [ -d "$from" ] || return 0
  local file rel dest
  while IFS= read -r -d '' file; do
    rel="${file#"$from"/}"
    dest="$to/$rel"
    if [ "$mode" = "missing" ] && [ -e "$dest" ]; then
      continue
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$file" "$dest"
  done < <(find "$from" -type f -print0)
}

if [ "$VARIANT" = "web" ]; then
  template_mode="missing"
  if [ "$UPDATE" = 1 ]; then
    template_mode="refresh"
  fi

  if [ "$template_mode" = "refresh" ] || [ ! -f "$TARGET/components.json" ]; then
    cp "$SRC/templates/components.json" "$TARGET/components.json"
  fi

  sync_tree "$SRC/templates/components" "$TARGET/components" "$template_mode"
  sync_tree "$SRC/templates/hooks" "$TARGET/hooks" "$template_mode"
  sync_tree "$SRC/templates/lib" "$TARGET/lib" "$template_mode"
  sync_tree "$SRC/templates/styles" "$TARGET/styles" "$template_mode"
  # La ruta de OG lleva el titulo del sitio. No se pisa en un update.
  sync_tree "$SRC/templates/app" "$TARGET/app" "missing"

  python3 - "$TARGET" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
candidates = [
    (root / "app" / "globals.css", "../styles/nachi.css"),
    (root / "src" / "app" / "globals.css", "../../styles/nachi.css"),
]
needles = ['@import "tailwindcss";', "@import 'tailwindcss';"]
for path, spec in candidates:
    if not path.is_file():
        continue
    text = path.read_text()
    if "nachi.css" in text:
        continue
    line = f'@import "{spec}";'
    updated = text
    for needle in needles:
        if needle in updated:
            updated = updated.replace(needle, needle + "\n" + line, 1)
            break
    else:
        updated = line + "\n\n" + text
    path.write_text(updated)
    print(f"Import de nachi.css agregado en {path}")
PY

  if [ -f "$TARGET/package.json" ] && [ "$TARGET" != "$SRC" ]; then
    if grep -q '"next"' "$TARGET/package.json"; then
      echo "Installing shadcn, GSAP and Lenis deps..."
      (
        cd "$TARGET"
        npm install --save \
          clsx \
          tailwind-merge \
          class-variance-authority \
          @radix-ui/react-slot \
          @radix-ui/react-dialog \
          gsap \
          @gsap/react \
          lenis \
          || echo "WARN: no se pudieron instalar las deps de componentes."
      )
    fi
  fi
fi

python3 - "$TARGET/.gitignore" <<'PY'
import pathlib, re, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text() if path.exists() else ""
drop = re.compile(
    r"\s*(/?\.cursor/?|\*\*/\.cursor/?|\.cursor/\*\*)\s*(#.*)?$"
)
kept = []
removed = False
for line in text.splitlines():
    if drop.fullmatch(line):
        removed = True
        continue
    kept.append(line)
body = "\n".join(kept).strip("\n")
if "* 2.*" not in {line.strip() for line in kept}:
    extra = "# Duplicados de Finder\n* 2.*"
    body = f"{body}\n\n{extra}" if body else extra
path.write_text(body + "\n")
if removed:
    print(".cursor/ se versiona: saque esa linea del .gitignore.")
print("gitignore: * 2.*")
PY

case "$VARIANT" in
  web)        AGENTS_SRC="$SRC/AGENTS.md" ;;
  mobile)     AGENTS_SRC="$SRC/templates/AGENTS-mobile.md" ;;
  automation) AGENTS_SRC="$SRC/templates/AGENTS-automation.md" ;;
esac

python3 - "$TARGET" "$AGENTS_SRC" "$UPDATE" <<'PY'
import pathlib, re, sys
target = pathlib.Path(sys.argv[1])
source = pathlib.Path(sys.argv[2]).read_text()
update = sys.argv[3] == "1"
dest = target / "AGENTS.md"
patterns = [
    r"<!-- BEGIN:nextjs-agent-rules -->.*?<!-- END:nextjs-agent-rules -->",
    r"<!-- NEXT-AGENTS-MD-START -->.*?<!-- NEXT-AGENTS-MD-END -->",
]
existing = dest.read_text() if dest.exists() else ""
blocks = []
for pattern in patterns:
    blocks.extend(re.findall(pattern, existing, flags=re.S))
stripped = existing
for pattern in patterns:
    stripped = re.sub(pattern, "", stripped, flags=re.S)
only_next = dest.exists() and stripped.strip() == ""
if (not dest.exists()) or only_next or update:
    text = source.rstrip() + "\n"
    if blocks:
        text += "\n" + "\n\n".join(block.rstrip() for block in blocks) + "\n"
    dest.write_text(text)
    if only_next:
        print("AGENTS.md era solo el bloque de Next. Instale el kit y deje ese bloque.")
    elif update and existing:
        print("AGENTS.md actualizado. El bloque de Next, si habia, se dejo.")
    else:
        print("AGENTS.md copiado a la raiz.")
else:
    print("AGENTS.md ya existe. No se sobreescribio. Para refrescarlo: install.sh --update")
if (target / "CLAUDE.md").exists():
    print("Sobra CLAUDE.md. Cursor lee AGENTS.md. Si es leftover del kit viejo, borralo.")
PY

if [ ! -f "$TARGET/PROJECT_MEMORY.md" ]; then
  cp "$SRC/templates/PROJECT_MEMORY.md" "$TARGET/PROJECT_MEMORY.md"
  echo "PROJECT_MEMORY.md copiado."
else
  echo "PROJECT_MEMORY.md ya existe. No se toco."
fi

echo "Listo. Skills y rules en $TARGET/.cursor/"
