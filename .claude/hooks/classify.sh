#!/usr/bin/env bash
set -euo pipefail

# Vergleichspunkt: ohne Argument gegen den letzten Commit
BASE="${1:-HEAD}"

# Liste der geaenderten Dateien, eine pro Zeile
files=$(git diff --name-only "$BASE")

if [ -z "$files" ]; then
  echo "R1"
  exit 0
fi

# Startklasse; wird nur nach oben korrigiert, nie nach unten
class=1

bump() {
  [ "$1" -gt "$class" ] && class="$1"
  return 0
}

while IFS= read -r f; do
  case "$f" in
    .claude/*|.github/*|netlify.toml|_redirects|_headers|*.env*)
      bump 3 ;;
    package.json|package-lock.json|*.config.js|*.config.ts|src/*.js|src/*.ts)
      bump 2 ;;
    src/*.html|src/*.css|public/*|content/*.md|tests/*)
      bump 1 ;;
    *)
      bump 2 ;;   # Unbekanntes ist im Zweifel nicht harmlos
  esac
done <<< "$files"

# Umfang: sehr grosse Aenderungen sind auch in src/ nie R1
lines=$(git diff --numstat "$BASE" | awk '{added+=$1; removed+=$2} END {print added+removed+0}')
if [ "$lines" -gt 300 ]; then
  bump 2
fi

echo "R$class"
