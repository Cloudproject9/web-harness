#!/usr/bin/env bash
set -euo pipefail

# Beim Bash-Werkzeug heisst das Feld "command" statt "file_path"
cmd=$(cat | jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

# Harte Verbote zuerst - sie muessen VOR der Erlaubnisliste stehen,
# sonst wuerde "git" das "git push" durchwinken
if echo "$cmd" | grep -Eq 'rm -rf /|curl .*\| *(ba)?sh|git push|sudo|:\(\)\{'; then
  echo "BLOCKIERT: Verbotenes Kommandomuster." >&2
  exit 2
fi

# Erstes Wort = der eigentliche Befehlsname
first=$(echo "$cmd" | awk '{print $1}')

# Erlaubnisliste
case "$first" in
  npm|npx|node|git|ls|cat|grep|find|mkdir|cp|mv|echo|test) exit 0 ;;
esac

echo "BLOCKIERT: '$first' steht nicht auf der Erlaubnisliste." >&2
exit 2
