#!/usr/bin/env bash
# Інсталяція skill ТРЯСЦЯ для OpenClaw.
# За замовчуванням ставить shared managed skill у ~/.openclaw/skills/tryascia.
# Для workspace-рівня передай OPENCLAW_SKILLS_DIR=/path/to/workspace/skills.
#
#   TRYASCIA_REF=v1.0.0 bash install-openclaw.sh
#   bash install-openclaw.sh --uninstall

set -euo pipefail

OPENCLAW_SKILLS_DIR="${OPENCLAW_SKILLS_DIR:-${OPENCLAW_STATE_DIR:-${HOME}/.openclaw}/skills}"
TARGET_SKILL_DIR="${TARGET_OPENCLAW_SKILL_DIR:-${OPENCLAW_SKILLS_DIR}/tryascia}"
TRYASCIA_REF="${TRYASCIA_REF:-main}"
RAW_BASE="${RAW_BASE:-https://raw.githubusercontent.com/tsutsman/tryascia/${TRYASCIA_REF}}"
MODE="${1:-install}"

REFERENCE_FILES=(
  slovar.md
  sceny.md
  ontologia.md
  dzherela.md
  korpus-100.md
  verifikatsiya.md
  polityka-korpusu.md
  korpus.json
)

remove_managed_files() {
  rm -f "$TARGET_SKILL_DIR/SKILL.md"
  for reference_name in "${REFERENCE_FILES[@]}"; do
    rm -f "$TARGET_SKILL_DIR/references/$reference_name"
  done
  rmdir "$TARGET_SKILL_DIR/references" 2>/dev/null || true
  rmdir "$TARGET_SKILL_DIR" 2>/dev/null || true
}

case "$MODE" in
  install)
    ;;
  --uninstall)
    remove_managed_files
    echo "ТРЯСЦЮ видалено з OpenClaw. Почни нову сесію агента."
    exit 0
    ;;
  *)
    echo "Використання: $0 [--uninstall]" >&2
    exit 2
    ;;
esac

mkdir -p "$TARGET_SKILL_DIR/references"

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
if [ -f "$SCRIPT_DIR/skills/tryascia/SKILL.md" ]; then
  cp "$SCRIPT_DIR/skills/tryascia/SKILL.md" "$TARGET_SKILL_DIR/SKILL.md"
  for reference_name in "${REFERENCE_FILES[@]}"; do
    cp "$SCRIPT_DIR/skills/tryascia/references/$reference_name" "$TARGET_SKILL_DIR/references/$reference_name"
  done
else
  command -v curl >/dev/null 2>&1 || { echo "Потрібен curl" >&2; exit 1; }
  download_file "$RAW_BASE/skills/tryascia/SKILL.md" "$TARGET_SKILL_DIR/SKILL.md"
  for reference_name in "${REFERENCE_FILES[@]}"; do
    download_file "$RAW_BASE/skills/tryascia/references/$reference_name" "$TARGET_SKILL_DIR/references/$reference_name"
  done
fi

echo "Готово. ТРЯСЦЯ встановлена як OpenClaw skill у $TARGET_SKILL_DIR."
