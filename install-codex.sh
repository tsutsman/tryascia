#!/usr/bin/env bash
# Інсталяція стилю ТРЯСЦЯ для Codex.
#
#   TRYASCIA_REF=v0.1.0-rc.1 bash install-codex.sh
#   bash install-codex.sh --uninstall

set -euo pipefail

TARGET_CODEX_DIR="${TARGET_CODEX_DIR:-${HOME}/.codex}"
TRYASCIA_REF="${TRYASCIA_REF:-main}"
RAW_BASE="${RAW_BASE:-https://raw.githubusercontent.com/tsutsman/tryascia/${TRYASCIA_REF}}"
MODE="${1:-install}"

case "$MODE" in
  install|--uninstall)
    ;;
  *)
    echo "Використання: $0 [--uninstall]" >&2
    exit 2
    ;;
esac

command -v python3 >/dev/null 2>&1 || { echo "Потрібен python3" >&2; exit 1; }

if [ "$MODE" = "--uninstall" ]; then
  python3 - "$TARGET_CODEX_DIR" <<'PY'
import os, re, sys

target_dir = sys.argv[1]
agents_path = os.path.join(target_dir, "AGENTS.md")
if os.path.exists(agents_path):
    with open(agents_path, encoding="utf-8") as handle:
        text = handle.read()
    text = re.sub(r"\n?<!-- tryascia:start -->.*?<!-- tryascia:end -->\n?", "\n", text, flags=re.S)
    with open(agents_path, "w", encoding="utf-8") as handle:
        handle.write(text)
print("ТРЯСЦЮ видалено з Codex. Перезапусти Codex.")
PY
  exit 0
fi

mkdir -p "$TARGET_CODEX_DIR/tryascia/references"

TMP_SECTION="$(mktemp)"
cleanup() { rm -f "$TMP_SECTION"; }
trap cleanup EXIT

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
if [ -f "$SCRIPT_DIR/codex/AGENTS-tryascia.md" ]; then
  cp "$SCRIPT_DIR/codex/AGENTS-tryascia.md" "$TMP_SECTION"
  cp "$SCRIPT_DIR/skills/tryascia/references/"*.md "$TARGET_CODEX_DIR/tryascia/references/"
  cp "$SCRIPT_DIR/skills/tryascia/references/korpus.json" "$TARGET_CODEX_DIR/tryascia/references/korpus.json"
else
  command -v curl >/dev/null 2>&1 || { echo "Потрібен curl" >&2; exit 1; }
  download_file "$RAW_BASE/codex/AGENTS-tryascia.md" "$TMP_SECTION"
  for reference_name in slovar.md sceny.md ontologia.md dzherela.md korpus-100.md verifikatsiya.md polityka-korpusu.md; do
    download_file "$RAW_BASE/skills/tryascia/references/$reference_name" "$TARGET_CODEX_DIR/tryascia/references/$reference_name"
  done
  download_file "$RAW_BASE/skills/tryascia/references/korpus.json" "$TARGET_CODEX_DIR/tryascia/references/korpus.json"
fi

python3 - "$TARGET_CODEX_DIR" "$TMP_SECTION" <<'PY'
import os, re, sys

target_dir, section_path = sys.argv[1:]
agents_path = os.path.join(target_dir, "AGENTS.md")
with open(section_path, encoding="utf-8") as handle:
    section = handle.read().strip()
text = ""
if os.path.exists(agents_path):
    with open(agents_path, encoding="utf-8") as handle:
        text = handle.read()
if "<!-- tryascia:start -->" in text:
    text = re.sub(r"<!-- tryascia:start -->.*?<!-- tryascia:end -->", section, text, flags=re.S)
else:
    text = (text.rstrip() + "\n\n" if text.strip() else "") + section + "\n"
with open(agents_path, "w", encoding="utf-8") as handle:
    handle.write(text)
PY

echo "Готово. ТРЯСЦЯ підключена до Codex. Перезапусти Codex."
