#!/usr/bin/env bash
# Перевіряє опублікований stable tag незалежно від поточного branch head.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STABLE_REF="${STABLE_REF:-v1.1.0}"

TRYASCIA_REF="$STABLE_REF" bash "$ROOT_DIR/tests/release-ref-smoke.sh"

echo "OK: stable release tag $STABLE_REF пройшов 4-agent remote install/uninstall smoke."
