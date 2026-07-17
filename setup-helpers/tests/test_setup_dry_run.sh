#!/usr/bin/env bash
set -euo pipefail

# Verifies setup.sh --dry-run prints its steps and writes nothing into VIBE_HOME.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMPVH="$(mktemp -d)"

out="$(VIBE_HOME="$TMPVH" bash "$ROOT/setup.sh" --dry-run)"

echo "$out" | grep -q "Vibe step done" || { echo "FAIL: missing vibe step"; exit 1; }

if [ -f "$TMPVH/.env" ] || [ -f "$TMPVH/config.toml" ]; then
  echo "FAIL: dry-run wrote into VIBE_HOME"; exit 1
fi

echo "DRY-RUN OK"
