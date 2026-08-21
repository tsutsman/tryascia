#!/usr/bin/env bash
# Інсталяція output style ТРЯСЦЯ для Claude Code.
#
#   TRYASCIA_REF=v1.0.0 bash install.sh
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
      "$TARGET_CLAUDE_DIR/skills/tryascia/references/korpus.json"
    for reference_name in slovar.md sceny.md ontologia.md dzherela.md korpus-100.md verifikatsiya.md polityka-korpusu.md; do
      rm -f "$TARGET_CLAUDE_DIR/skills/tryascia/references/$reference_name"
    done
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

download_file() {
  local url="$1"
  local output="$2"
  local attempt
  for attempt in 1 2 3 4; do
    if curl --connect-timeout 15 -fsSL "$url" -o "$output"; then
      return 0
    fi
    if [ "$attempt" -lt 4 ]; then
      sleep $((attempt * 2))
    fi
  done
  echo "Не вдалося завантажити $url після 4 спроб." >&2
  return 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/output-styles/tryascia.md" ]; then
  cp "$SCRIPT_DIR/output-styles/tryascia.md" "$TARGET_CLAUDE_DIR/output-styles/tryascia.md"
  cp "$SCRIPT_DIR/skills/tryascia/SKILL.md" "$TARGET_CLAUDE_DIR/skills/tryascia/SKILL.md"
  cp "$SCRIPT_DIR/skills/tryascia/references/"*.md "$TARGET_CLAUDE_DIR/skills/tryascia/references/"
  cp "$SCRIPT_DIR/skills/tryascia/references/korpus.json" "$TARGET_CLAUDE_DIR/skills/tryascia/references/korpus.json"
else
  command -v curl >/dev/null 2>&1 || { echo "Потрібен curl" >&2; exit 1; }
  download_file "$RAW_BASE/output-styles/tryascia.md" "$TARGET_CLAUDE_DIR/output-styles/tryascia.md"
  download_file "$RAW_BASE/skills/tryascia/SKILL.md" "$TARGET_CLAUDE_DIR/skills/tryascia/SKILL.md"
  for reference_name in slovar.md sceny.md ontologia.md dzherela.md korpus-100.md verifikatsiya.md polityka-korpusu.md; do
    download_file "$RAW_BASE/skills/tryascia/references/$reference_name" "$TARGET_CLAUDE_DIR/skills/tryascia/references/$reference_name"
  done
  download_file "$RAW_BASE/skills/tryascia/references/korpus.json" "$TARGET_CLAUDE_DIR/skills/tryascia/references/korpus.json"
fi

echo "Готово. Обери output style ТРЯСЦЯ або перезапусти Claude Code."
