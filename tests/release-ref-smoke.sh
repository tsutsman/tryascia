#!/usr/bin/env bash
# Перевірка інсталяторів через віддалений branch/tag/commit ref.

set -euo pipefail

REF="${TRYASCIA_REF:-${GITHUB_HEAD_REF:-${GITHUB_REF_NAME:-main}}}"
RAW_ROOT="${RAW_BASE:-https://raw.githubusercontent.com/tsutsman/tryascia/${REF}}"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT

CODEX_DIR="$WORK_DIR/codex"
CLAUDE_DIR="$WORK_DIR/claude"
HERMES_SKILL_DIR="$WORK_DIR/hermes/skills/tryascia"
OPENCLAW_SKILL_DIR="$WORK_DIR/openclaw/skills/tryascia"
INSTALLER_DIR="$WORK_DIR/installers"

mkdir -p \
  "$CODEX_DIR" \
  "$CLAUDE_DIR/skills/tryascia/references" \
  "$HERMES_SKILL_DIR/references" \
  "$OPENCLAW_SKILL_DIR/references" \
  "$INSTALLER_DIR"
printf '# Існуючі правила\n' > "$CODEX_DIR/AGENTS.md"
printf '# Чужий файл\n' > "$CLAUDE_DIR/skills/tryascia/references/custom.md"
printf '# Чужий Hermes-файл\n' > "$HERMES_SKILL_DIR/references/custom.md"
printf '# Чужий OpenClaw-файл\n' > "$OPENCLAW_SKILL_DIR/references/custom.md"

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

for installer in install-codex.sh install.sh install-hermes.sh install-openclaw.sh; do
  download_file "$RAW_ROOT/$installer" "$INSTALLER_DIR/$installer"
done
chmod +x "$INSTALLER_DIR"/*.sh

TARGET_CODEX_DIR="$CODEX_DIR" TRYASCIA_REF="$REF" RAW_BASE="$RAW_ROOT" \
  bash "$INSTALLER_DIR/install-codex.sh"
grep -Fq "<!-- tryascia:start -->" "$CODEX_DIR/AGENTS.md"
test -s "$CODEX_DIR/tryascia/references/korpus.json"
test -s "$CODEX_DIR/tryascia/references/polityka-korpusu.md"

TARGET_CODEX_DIR="$CODEX_DIR" TRYASCIA_REF="$REF" RAW_BASE="$RAW_ROOT" \
  bash "$INSTALLER_DIR/install-codex.sh" --uninstall
grep -Fq "# Існуючі правила" "$CODEX_DIR/AGENTS.md"
if grep -Fq "<!-- tryascia:start -->" "$CODEX_DIR/AGENTS.md"; then
  echo "Помилка: Codex-блок не видалено." >&2
  exit 1
fi

TARGET_CLAUDE_DIR="$CLAUDE_DIR" TRYASCIA_REF="$REF" RAW_BASE="$RAW_ROOT" \
  bash "$INSTALLER_DIR/install.sh"
test -s "$CLAUDE_DIR/output-styles/tryascia.md"
test -s "$CLAUDE_DIR/skills/tryascia/SKILL.md"
test -s "$CLAUDE_DIR/skills/tryascia/references/korpus.json"
test -s "$CLAUDE_DIR/skills/tryascia/references/polityka-korpusu.md"

TARGET_CLAUDE_DIR="$CLAUDE_DIR" TRYASCIA_REF="$REF" RAW_BASE="$RAW_ROOT" \
  bash "$INSTALLER_DIR/install.sh" --uninstall
test ! -e "$CLAUDE_DIR/output-styles/tryascia.md"
test ! -e "$CLAUDE_DIR/skills/tryascia/SKILL.md"
grep -Fq "# Чужий файл" "$CLAUDE_DIR/skills/tryascia/references/custom.md"

TARGET_HERMES_SKILL_DIR="$HERMES_SKILL_DIR" TRYASCIA_REF="$REF" RAW_BASE="$RAW_ROOT" \
  bash "$INSTALLER_DIR/install-hermes.sh"
test -s "$HERMES_SKILL_DIR/SKILL.md"
test -s "$HERMES_SKILL_DIR/references/korpus.json"
grep -Fq "name: tryascia" "$HERMES_SKILL_DIR/SKILL.md"
TARGET_HERMES_SKILL_DIR="$HERMES_SKILL_DIR" TRYASCIA_REF="$REF" RAW_BASE="$RAW_ROOT" \
  bash "$INSTALLER_DIR/install-hermes.sh" --uninstall
grep -Fq "# Чужий Hermes-файл" "$HERMES_SKILL_DIR/references/custom.md"

TARGET_OPENCLAW_SKILL_DIR="$OPENCLAW_SKILL_DIR" TRYASCIA_REF="$REF" RAW_BASE="$RAW_ROOT" \
  bash "$INSTALLER_DIR/install-openclaw.sh"
test -s "$OPENCLAW_SKILL_DIR/SKILL.md"
test -s "$OPENCLAW_SKILL_DIR/references/korpus.json"
grep -Fq "name: tryascia" "$OPENCLAW_SKILL_DIR/SKILL.md"
TARGET_OPENCLAW_SKILL_DIR="$OPENCLAW_SKILL_DIR" TRYASCIA_REF="$REF" RAW_BASE="$RAW_ROOT" \
  bash "$INSTALLER_DIR/install-openclaw.sh" --uninstall
grep -Fq "# Чужий OpenClaw-файл" "$OPENCLAW_SKILL_DIR/references/custom.md"

echo "OK: віддалені інсталятори Codex/Claude Code/Hermes/OpenClaw пройшли smoke-перевірку для ref $REF."
