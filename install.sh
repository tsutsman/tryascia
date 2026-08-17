#!/usr/bin/env bash
# Інсталяція output style ТРЯСЦЯ для Claude Code.
#
#   curl -fsSL https://raw.githubusercontent.com/tsutsman/tryascia/main/install.sh | bash

set -euo pipefail

TARGET_CLAUDE_DIR="${TARGET_CLAUDE_DIR:-${HOME}/.claude}"
RAW_BASE="${RAW_BASE:-https://raw.githubusercontent.com/tsutsman/tryascia/main}"

mkdir -p "$TARGET_CLAUDE_DIR/output-styles" "$TARGET_CLAUDE_DIR/skills/tryascia/references"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/output-styles/tryascia.md" ]; then
  cp "$SCRIPT_DIR/output-styles/tryascia.md" "$TARGET_CLAUDE_DIR/output-styles/tryascia.md"
  cp "$SCRIPT_DIR/skills/tryascia/SKILL.md" "$TARGET_CLAUDE_DIR/skills/tryascia/SKILL.md"
  cp "$SCRIPT_DIR/skills/tryascia/references/"*.md "$TARGET_CLAUDE_DIR/skills/tryascia/references/"
else
  curl -fsSL "$RAW_BASE/output-styles/tryascia.md" -o "$TARGET_CLAUDE_DIR/output-styles/tryascia.md"
  curl -fsSL "$RAW_BASE/skills/tryascia/SKILL.md" -o "$TARGET_CLAUDE_DIR/skills/tryascia/SKILL.md"
  for reference_name in slovar.md sceny.md ontologia.md dzherela.md korpus-100.md; do
    curl -fsSL "$RAW_BASE/skills/tryascia/references/$reference_name" -o "$TARGET_CLAUDE_DIR/skills/tryascia/references/$reference_name"
  done
fi

echo "Готово. Обери output style ТРЯСЦЯ або перезапусти Claude Code."
