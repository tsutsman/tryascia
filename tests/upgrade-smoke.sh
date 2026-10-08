#!/usr/bin/env bash
# End-to-end upgrade: v1.0.0 -> v1.1.0 -> reinstall -> uninstall.

set -euo pipefail

FROM_REF="${FROM_REF:-v1.0.0}"
TO_REF="${TO_REF:-v1.1.0}"
REPO_RAW="https://raw.githubusercontent.com/tsutsman/tryascia"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT

OLD="$WORK_DIR/old"
NEW="$WORK_DIR/new"
CODEX="$WORK_DIR/codex"
CLAUDE="$WORK_DIR/claude"
HERMES="$WORK_DIR/hermes/skills/tryascia"
OPENCLAW="$WORK_DIR/openclaw/skills/tryascia"
mkdir -p "$OLD" "$NEW" "$CODEX/tryascia/references" "$CLAUDE/skills/tryascia/references" "$HERMES/references" "$OPENCLAW/references"

printf '# Local Codex rules\n' > "$CODEX/AGENTS.md"
printf '# custom codex\n' > "$CODEX/tryascia/references/custom.md"
printf '# custom claude\n' > "$CLAUDE/skills/tryascia/references/custom.md"
printf '# custom hermes\n' > "$HERMES/references/custom.md"
printf '# custom openclaw\n' > "$OPENCLAW/references/custom.md"

fetch_installers() {
  local ref="$1" dir="$2" installer
  for installer in install-codex.sh install.sh install-hermes.sh install-openclaw.sh; do
    curl --connect-timeout 15 --retry 3 --retry-all-errors -fsSL "$REPO_RAW/$ref/$installer" -o "$dir/$installer"
  done
}

install_all() {
  local ref="$1" dir="$2"
  local raw="$REPO_RAW/$ref"
  TARGET_CODEX_DIR="$CODEX" TRYASCIA_REF="$ref" RAW_BASE="$raw" bash "$dir/install-codex.sh"
  TARGET_CLAUDE_DIR="$CLAUDE" TRYASCIA_REF="$ref" RAW_BASE="$raw" bash "$dir/install.sh"
  TARGET_HERMES_SKILL_DIR="$HERMES" TRYASCIA_REF="$ref" RAW_BASE="$raw" bash "$dir/install-hermes.sh"
  TARGET_OPENCLAW_SKILL_DIR="$OPENCLAW" TRYASCIA_REF="$ref" RAW_BASE="$raw" bash "$dir/install-openclaw.sh"
}

fetch_installers "$FROM_REF" "$OLD"
fetch_installers "$TO_REF" "$NEW"
install_all "$FROM_REF" "$OLD"
install_all "$TO_REF" "$NEW"
install_all "$TO_REF" "$NEW"

# v1.1.0 payload має бути саме 95 runtime records.
node - "$CODEX/tryascia/references/korpus.json" <<'NODE'
const fs = require('fs');
const data = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
if (!Array.isArray(data.runtime_records) || data.runtime_records.length !== 95) {
  throw new Error(`expected 95 runtime_records after upgrade, got ${data.runtime_records?.length}`);
}
NODE

# Unmanaged state survives upgrade/reinstall.
grep -Fq '# Local Codex rules' "$CODEX/AGENTS.md"
grep -Fq '# custom codex' "$CODEX/tryascia/references/custom.md"
grep -Fq '# custom claude' "$CLAUDE/skills/tryascia/references/custom.md"
grep -Fq '# custom hermes' "$HERMES/references/custom.md"
grep -Fq '# custom openclaw' "$OPENCLAW/references/custom.md"

TARGET_CODEX_DIR="$CODEX" bash "$NEW/install-codex.sh" --uninstall
TARGET_CLAUDE_DIR="$CLAUDE" bash "$NEW/install.sh" --uninstall
TARGET_HERMES_SKILL_DIR="$HERMES" bash "$NEW/install-hermes.sh" --uninstall
TARGET_OPENCLAW_SKILL_DIR="$OPENCLAW" bash "$NEW/install-openclaw.sh" --uninstall

# Managed files removed; unmanaged files preserved.
! grep -Fq '<!-- tryascia:start -->' "$CODEX/AGENTS.md"
test ! -e "$CODEX/tryascia/references/korpus.json"
test ! -e "$CLAUDE/skills/tryascia/SKILL.md"
test ! -e "$HERMES/SKILL.md"
test ! -e "$OPENCLAW/SKILL.md"
grep -Fq '# Local Codex rules' "$CODEX/AGENTS.md"
grep -Fq '# custom codex' "$CODEX/tryascia/references/custom.md"
grep -Fq '# custom claude' "$CLAUDE/skills/tryascia/references/custom.md"
grep -Fq '# custom hermes' "$HERMES/references/custom.md"
grep -Fq '# custom openclaw' "$OPENCLAW/references/custom.md"

echo "OK: upgrade $FROM_REF -> $TO_REF, reinstall і uninstall пройшли для 4 integrations без втрати unmanaged files."
