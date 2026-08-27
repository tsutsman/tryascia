#!/usr/bin/env bash
# Формальний smoke compatibility contract для 4 stable інтеграцій.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT

assert_skill_tree() {
  local target="$1"
  test -s "$target/SKILL.md"
  test -s "$target/references/korpus.json"
  test -s "$target/references/polityka-korpusu.md"
  grep -Fq "name: tryascia" "$target/SKILL.md"
}

# Codex: explicit target override + reinstall + uninstall preserves unrelated content.
CODEX_DIR="$WORK_DIR/codex"
mkdir -p "$CODEX_DIR"
printf '# Existing AGENTS rules\n' > "$CODEX_DIR/AGENTS.md"
TARGET_CODEX_DIR="$CODEX_DIR" bash "$ROOT_DIR/install-codex.sh"
test -s "$CODEX_DIR/tryascia/references/korpus.json"
grep -Fq '<!-- tryascia:start -->' "$CODEX_DIR/AGENTS.md"
TARGET_CODEX_DIR="$CODEX_DIR" bash "$ROOT_DIR/install-codex.sh"
TARGET_CODEX_DIR="$CODEX_DIR" bash "$ROOT_DIR/install-codex.sh" --uninstall
grep -Fq '# Existing AGENTS rules' "$CODEX_DIR/AGENTS.md"
! grep -Fq '<!-- tryascia:start -->' "$CODEX_DIR/AGENTS.md"

# Claude Code: explicit target override + canonical shared skill.
CLAUDE_DIR="$WORK_DIR/claude"
TARGET_CLAUDE_DIR="$CLAUDE_DIR" bash "$ROOT_DIR/install.sh"
assert_skill_tree "$CLAUDE_DIR/skills/tryascia"
test -s "$CLAUDE_DIR/output-styles/tryascia.md"
TARGET_CLAUDE_DIR="$CLAUDE_DIR" bash "$ROOT_DIR/install.sh"
TARGET_CLAUDE_DIR="$CLAUDE_DIR" bash "$ROOT_DIR/install.sh" --uninstall
test ! -e "$CLAUDE_DIR/skills/tryascia/SKILL.md"

# Hermes: HERMES_HOME contract.
HERMES_HOME_DIR="$WORK_DIR/hermes-home"
HERMES_HOME="$HERMES_HOME_DIR" bash "$ROOT_DIR/install-hermes.sh"
assert_skill_tree "$HERMES_HOME_DIR/skills/tryascia"
HERMES_HOME="$HERMES_HOME_DIR" bash "$ROOT_DIR/install-hermes.sh"
HERMES_HOME="$HERMES_HOME_DIR" bash "$ROOT_DIR/install-hermes.sh" --uninstall
test ! -e "$HERMES_HOME_DIR/skills/tryascia/SKILL.md"

# Hermes: HERMES_SKILLS_DIR takes an explicit shared-skills root.
HERMES_SKILLS_ROOT="$WORK_DIR/hermes-skills"
HERMES_SKILLS_DIR="$HERMES_SKILLS_ROOT" bash "$ROOT_DIR/install-hermes.sh"
assert_skill_tree "$HERMES_SKILLS_ROOT/tryascia"
HERMES_SKILLS_DIR="$HERMES_SKILLS_ROOT" bash "$ROOT_DIR/install-hermes.sh" --uninstall

# OpenClaw managed mode via state dir.
OPENCLAW_STATE="$WORK_DIR/openclaw-state"
OPENCLAW_STATE_DIR="$OPENCLAW_STATE" bash "$ROOT_DIR/install-openclaw.sh"
assert_skill_tree "$OPENCLAW_STATE/skills/tryascia"
OPENCLAW_STATE_DIR="$OPENCLAW_STATE" bash "$ROOT_DIR/install-openclaw.sh"
OPENCLAW_STATE_DIR="$OPENCLAW_STATE" bash "$ROOT_DIR/install-openclaw.sh" --uninstall

# OpenClaw workspace mode via workspace skills root.
OPENCLAW_WORKSPACE_SKILLS="$WORK_DIR/workspace/skills"
OPENCLAW_SKILLS_DIR="$OPENCLAW_WORKSPACE_SKILLS" bash "$ROOT_DIR/install-openclaw.sh"
assert_skill_tree "$OPENCLAW_WORKSPACE_SKILLS/tryascia"
OPENCLAW_SKILLS_DIR="$OPENCLAW_WORKSPACE_SKILLS" bash "$ROOT_DIR/install-openclaw.sh"
OPENCLAW_SKILLS_DIR="$OPENCLAW_WORKSPACE_SKILLS" bash "$ROOT_DIR/install-openclaw.sh" --uninstall
test ! -e "$OPENCLAW_WORKSPACE_SKILLS/tryascia/SKILL.md"

echo "OK: compatibility smoke пройдено для Codex, Claude Code, Hermes Agent і OpenClaw managed/workspace."
