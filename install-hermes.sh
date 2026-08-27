#!/usr/bin/env bash
# Інсталяція skill ТРЯСЦЯ для Hermes Agent.
#
#   TRYASCIA_REF=v1.0.0 bash install-hermes.sh
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(mktemp -d)"
PAYLOAD_DIR="$WORK_DIR/payload"
trap 'rm -rf -- "$WORK_DIR"' EXIT

bootstrap_hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "Потрібен sha256sum або shasum для перевірки payload." >&2
    return 1
  fi
}

bootstrap_download() {
  local url="$1" output="$2" attempt
  command -v curl >/dev/null 2>&1 || { echo "Потрібен curl" >&2; return 1; }
  mkdir -p "$(dirname "$output")"
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

if [ -f "$SCRIPT_DIR/scripts/install-common.sh" ] && [ -f "$SCRIPT_DIR/install-manifest.sha256" ]; then
  SOURCE_MODE="local"
  MANIFEST_PATH="$SCRIPT_DIR/install-manifest.sha256"
  COMMON_PATH="$SCRIPT_DIR/scripts/install-common.sh"
else
  SOURCE_MODE="remote"
  MANIFEST_PATH="$WORK_DIR/install-manifest.sha256"
  COMMON_PATH="$WORK_DIR/scripts/install-common.sh"
  bootstrap_download "$RAW_BASE/install-manifest.sha256" "$MANIFEST_PATH"
  bootstrap_download "$RAW_BASE/scripts/install-common.sh" "$COMMON_PATH"
  expected="$(awk '$2 == "scripts/install-common.sh" { print $1; found = 1; exit } END { if (!found) exit 1 }' "$MANIFEST_PATH")" || {
    echo "Маніфест не містить checksum для scripts/install-common.sh." >&2
    exit 1
  }
  actual="$(bootstrap_hash_file "$COMMON_PATH")"
  if [ "$actual" != "$expected" ]; then
    echo "Checksum mismatch для scripts/install-common.sh." >&2
    exit 1
  fi
fi

# shellcheck source=scripts/install-common.sh
source "$COMMON_PATH"

PAYLOAD_FILES=("skills/tryascia/SKILL.md")
TARGET_FILES=("SKILL.md")
for reference_name in "${REFERENCE_FILES[@]}"; do
  PAYLOAD_FILES+=("skills/tryascia/references/$reference_name")
  TARGET_FILES+=("references/$reference_name")
done

tryascia_stage_payload \
  "$SOURCE_MODE" "$SCRIPT_DIR" "$RAW_BASE" "$MANIFEST_PATH" "$PAYLOAD_DIR" \
  "${PAYLOAD_FILES[@]}"

tryascia_atomic_overlay_dir \
  "$TARGET_SKILL_DIR" "$PAYLOAD_DIR" "skills/tryascia" \
  "${TARGET_FILES[@]}"

echo "Готово. ТРЯСЦЯ встановлена як Hermes skill. Почни нову сесію або онови skill cache."
