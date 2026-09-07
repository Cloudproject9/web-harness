#!/usr/bin/env bash
set -uo pipefail

BASE="${1:-HEAD}"

echo "== Tests =="
if npm test; then
  tests="gruen"
else
  tests="rot"
fi

echo "== Risikoklasse =="
class=$(.claude/hooks/classify.sh "$BASE")
echo "$class"

echo "== Entscheidung =="
if [ "$tests" = "rot" ]; then
  echo "BLOCKIERT: Tests rot. Risikoklasse spielt keine Rolle."
  exit 1
fi

case "$class" in
  R1) echo "AUTO-MERGE: harmlos und gruen."; exit 0 ;;
  R2) echo "REVIEW: Diff pruefen."; exit 10 ;;
  R3) echo "REVIEW + PREVIEW: Diff pruefen und Deploy-Preview abwarten."; exit 11 ;;
   *) echo "BLOCKIERT: unbekannte Klasse '$class'."; exit 1 ;;
esac
