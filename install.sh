#!/usr/bin/env bash
# Інсталяція output style ТРЯСЦЯ для Claude Code.
#
#   TRYASCIA_REF=v0.1.0-beta.1 bash install.sh
#   bash install.sh --uninstall

set -euo pipefail

TARGET_CLAUDE_DIR="${TARGET_CLAUDE_DIR:-${HOME}/.claude}"
TRYASCIA_REF="${TRYASCIA_REF:-main}"
RAW_BASE="${RAW_BASE:-https://raw.githubusercontent.com/tsutsman/tryascia/${TRYASCIA_REF}}"
MODE="${1:-install}"

case "$MODE" in
  install)
    ;;
  --uninstall)
    rm -f \
      "$TARGET_CLAUDE_DIR/output-styles/tryascia.md" \
      "$TARGET_CLAUDE_DIR/skills/tryascia/SKILL.md" \
      "$TARGET_CLAUDE_DIR/skills/tryascia/references/"*.md \
      "$TARGET_CLAUDE_DIR/skills/tryascia/references/korpus.json"
    rmdir "$TARGET_CLAUDE_DIR/skills/tryascia/references" 2>/dev/null || true
    rmdir "$TARGET_CLAUDE_DIR/skills/tryascia" 2>/dev/null || true
    echo "ТРЯСЦЮ видалено з Claude Code. Перезапусти Claude Code."
    exit 0
    ;;
  *)
    echo "Використання: $0 [--uninstall]" >&2
    exit 2
    ;;
esac

mkdir -p "$TARGET_CLAUDE_DIR/output-styles" "$TARGET_CLAUDE_DIR/skills/tryascia/references"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/output-styles/tryascia.md" ]; then
  cp "$SCRIPT_DIR/output-styles/tryascia.md" "$TARGET_CLAUDE_DIR/output-styles/tryascia.md"
  cp "$SCRIPT_DIR/skills/tryascia/SKILL.md" "$TARGET_CLAUDE_DIR/skills/tryascia/SKILL.md"
  cp "$SCRIPT_DIR/skills/tryascia/references/"*.md "$TARGET_CLAUDE_DIR/skills/tryascia/references/"
  cp "$SCRIPT_DIR/skills/tryascia/references/korpus.json" "$TARGET_CLAUDE_DIR/skills/tryascia/references/korpus.json"
else
  curl -fsSL "$RAW_BASE/output-styles/tryascia.md" -o "$TARGET_CLAUDE_DIR/output-styles/tryascia.md"
  curl -fsSL "$RAW_BASE/skills/tryascia/SKILL.md" -o "$TARGET_CLAUDE_DIR/skills/tryascia/SKILL.md"
  for reference_name in slovar.md sceny.md ontologia.md dzherela.md korpus-100.md verifikatsiya.md; do
    curl -fsSL "$RAW_BASE/skills/tryascia/references/$reference_name" -o "$TARGET_CLAUDE_DIR/skills/tryascia/references/$reference_name"
  done
  curl -fsSL "$RAW_BASE/skills/tryascia/references/korpus.json" -o "$TARGET_CLAUDE_DIR/skills/tryascia/references/korpus.json"
fi

echo "Готово. Обери output style ТРЯСЦЯ або перезапусти Claude Code."
