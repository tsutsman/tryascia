#!/usr/bin/env bash
# Інсталяція skill ТРЯСЦЯ для Hermes Agent.
#
#   TRYASCIA_REF=v0.1.0-rc.2 bash install-hermes.sh
#   bash install-hermes.sh --uninstall

set -euo pipefail

HERMES_SKILLS_DIR="${HERMES_SKILLS_DIR:-${HERMES_HOME:-${HOME}/.hermes}/skills}"
TARGET_SKILL_DIR="${TARGET_HERMES_SKILL_DIR:-${HERMES_SKILLS_DIR}/tryascia}"
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
    echo "ТРЯСЦЮ видалено з Hermes Agent. Почни нову сесію Hermes."
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

echo "Готово. ТРЯСЦЯ встановлена як Hermes skill. Почни нову сесію або онови skill cache."
