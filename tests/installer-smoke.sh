#!/usr/bin/env bash
# Димова перевірка інсталяторів у чистих тимчасових каталогах.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT

CODEX_DIR="$WORK_DIR/codex"
CLAUDE_DIR="$WORK_DIR/claude"

mkdir -p "$CODEX_DIR"
printf '# Існуючі правила\n' > "$CODEX_DIR/AGENTS.md"

TARGET_CODEX_DIR="$CODEX_DIR" bash "$ROOT_DIR/install-codex.sh"
grep -Fq "<!-- tryascia:start -->" "$CODEX_DIR/AGENTS.md"
test -s "$CODEX_DIR/tryascia/references/korpus.json"

TARGET_CODEX_DIR="$CODEX_DIR" bash "$ROOT_DIR/install-codex.sh"
grep -Fq "# Існуючі правила" "$CODEX_DIR/AGENTS.md"
TARGET_CODEX_DIR="$CODEX_DIR" bash "$ROOT_DIR/install-codex.sh" --uninstall
grep -Fq "# Існуючі правила" "$CODEX_DIR/AGENTS.md"
if grep -Fq "<!-- tryascia:start -->" "$CODEX_DIR/AGENTS.md"; then
  echo "Помилка: Codex-блок не видалено." >&2
  exit 1
fi

mkdir -p "$CLAUDE_DIR/skills/tryascia/references"
printf '# Чужий файл\n' > "$CLAUDE_DIR/skills/tryascia/references/custom.md"
TARGET_CLAUDE_DIR="$CLAUDE_DIR" bash "$ROOT_DIR/install.sh"
test -s "$CLAUDE_DIR/output-styles/tryascia.md"
test -s "$CLAUDE_DIR/skills/tryascia/SKILL.md"
test -s "$CLAUDE_DIR/skills/tryascia/references/korpus.json"
TARGET_CLAUDE_DIR="$CLAUDE_DIR" bash "$ROOT_DIR/install.sh" --uninstall
test ! -e "$CLAUDE_DIR/output-styles/tryascia.md"
test ! -e "$CLAUDE_DIR/skills/tryascia/SKILL.md"
grep -Fq "# Чужий файл" "$CLAUDE_DIR/skills/tryascia/references/custom.md"

echo "OK: Codex і Claude Code інсталятори пройшли smoke-перевірку."
