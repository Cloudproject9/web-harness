#!/usr/bin/env bash
set -euo pipefail

# Liest das JSON, das Claude Code vor jedem Write/Edit auf stdin schickt
input=$(cat)

# Zielpfad aus dem JSON holen; fehlt das Feld, gibt jq nichts zurueck
path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Kein Pfad im Aufruf -> geht diesen Hook nichts an -> durchlassen
[ -z "$path" ] && exit 0

# Projektverzeichnis; $PWD nur als Notnagel fuer Tests von Hand
root="${CLAUDE_PROJECT_DIR:-$PWD}"

# Immer absolut vergleichen, sonst kaeme "../../woanders" durch
case "$path" in
  /*) abs="$path" ;;
   *) abs="$root/$path" ;;
esac

# Erlaubnisliste: nur diese Bereiche darf der Agent beschreiben
for allowed in "$root/src" "$root/public" "$root/tests"; do
  case "$abs" in
    "$allowed"/*) exit 0 ;;
  esac
done

# Nichts hat gepasst -> blockieren. stderr geht als Begruendung ans Modell.
echo "BLOCKIERT: Schreibzugriff auf $abs. Erlaubt sind nur src/, public/ und tests/." >&2
exit 2 
