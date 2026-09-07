#!/usr/bin/env bash
set -uo pipefail

BASE="${1:-HEAD}"
TASK="${2:-unbenannt}"

mkdir -p .claude/logs

start=$(date +%s)
class=$(.claude/hooks/classify.sh "$BASE")

if npm test --silent >/dev/null 2>&1; then
  tests="gruen"
else
  tests="rot"
fi

.claude/hooks/gate.sh "$BASE" >/dev/null 2>&1
gate_exit=$?

case "$gate_exit" in
  0)  decision="auto-merge" ;;
  10) decision="review" ;;
  11) decision="review+preview" ;;
  *)  decision="blockiert" ;;
esac

files=$(git diff --cached --name-only | wc -l | tr -d ' ')
lines=$(git diff --cached --numstat | awk '{s+=$1+$2} END {print s+0}')
dauer=$(( $(date +%s) - start ))
id=$(date +%Y%m%d-%H%M%S)

jq -n \
  --arg id "$id" \
  --arg task "$TASK" \
  --arg class "$class" \
  --arg tests "$tests" \
  --arg decision "$decision" \
  --argjson files "$files" \
  --argjson lines "$lines" \
  --argjson dauer "$dauer" \
  '{run_id:$id, task:$task, risk_class:$class, tests:$tests,
    decision:$decision, files_changed:$files, lines_changed:$lines,
    duration_s:$dauer}' > ".claude/logs/$id.json"

echo "Protokoll: .claude/logs/$id.json"
cat ".claude/logs/$id.json"
