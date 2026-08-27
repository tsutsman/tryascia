#!/usr/bin/env bash
# Regression checks: remote download/checksum failures must not mutate an existing install.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
REAL_CURL="$(command -v curl)"
trap 'rm -rf -- "$WORK_DIR"' EXIT

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "Потрібен sha256sum або shasum." >&2
    return 1
  fi
}

payload_files() {
  cat <<'EOF'
codex/AGENTS-tryascia.md
output-styles/tryascia.md
skills/tryascia/SKILL.md
skills/tryascia/references/slovar.md
skills/tryascia/references/sceny.md
skills/tryascia/references/ontologia.md
skills/tryascia/references/dzherela.md
skills/tryascia/references/korpus-100.md
skills/tryascia/references/verifikatsiya.md
skills/tryascia/references/polityka-korpusu.md
skills/tryascia/references/korpus.json
EOF
  if [ -f "$ROOT_DIR/scripts/install-common.sh" ]; then
    printf '%s\n' 'scripts/install-common.sh'
  fi
}

prepare_raw_root() {
  local raw_root="$1"
  rm -rf -- "$raw_root"
  mkdir -p "$raw_root"
  : > "$raw_root/install-manifest.sha256"

  while IFS= read -r rel; do
    mkdir -p "$raw_root/$(dirname "$rel")"
    cp "$ROOT_DIR/$rel" "$raw_root/$rel"
    printf '%s  %s\n' "$(hash_file "$raw_root/$rel")" "$rel" >> "$raw_root/install-manifest.sha256"
  done < <(payload_files)
}

prepare_isolated_installers() {
  local dir="$1"
  mkdir -p "$dir"
  cp \
    "$ROOT_DIR/install-codex.sh" \
    "$ROOT_DIR/install.sh" \
    "$ROOT_DIR/install-hermes.sh" \
    "$ROOT_DIR/install-openclaw.sh" \
    "$dir/"
  chmod +x "$dir"/*.sh
}

prepare_target() {
  local platform="$1"
  local target="$2"

  case "$platform" in
    codex)
      mkdir -p "$target/tryascia/references"
      cat > "$target/AGENTS.md" <<'EOF'
# Існуючі правила

<!-- tryascia:start -->
# Стара ТРЯСЦЯ
<!-- tryascia:end -->
EOF
      printf '%s\n' 'OLD-CODEX-KORPUS' > "$target/tryascia/references/korpus.json"
      printf '%s\n' '# Чужий Codex-файл' > "$target/tryascia/references/custom.md"
      ;;
    claude)
      mkdir -p "$target/output-styles" "$target/skills/tryascia/references"
      printf '%s\n' '# OLD STYLE' > "$target/output-styles/tryascia.md"
      printf '%s\n' '# OLD SKILL' > "$target/skills/tryascia/SKILL.md"
      printf '%s\n' 'OLD-CLAUDE-KORPUS' > "$target/skills/tryascia/references/korpus.json"
      printf '%s\n' '# Чужий Claude-файл' > "$target/skills/tryascia/references/custom.md"
      ;;
    hermes|openclaw)
      mkdir -p "$target/references"
      printf '%s\n' '# OLD SKILL' > "$target/SKILL.md"
      printf '%s\n' "OLD-${platform}-KORPUS" > "$target/references/korpus.json"
      printf '%s\n' "# Чужий ${platform}-файл" > "$target/references/custom.md"
      ;;
    *)
      echo "Невідома платформа: $platform" >&2
      return 2
      ;;
  esac
}

snapshot_target() {
  local target="$1"
  local snapshot="$2"
  mkdir -p "$snapshot"
  cp -a "$target/." "$snapshot/"
}

assert_unchanged() {
  local snapshot="$1"
  local target="$2"
  local label="$3"
  if ! diff -ruN "$snapshot" "$target" >/dev/null; then
    echo "Помилка: $label змінив чинну інсталяцію після невдалої перевірки payload." >&2
    diff -ruN "$snapshot" "$target" >&2 || true
    return 1
  fi
}

run_installer() {
  local platform="$1"
  local installer_dir="$2"
  local raw_root="$3"
  local target="$4"
  local path_prefix="${5:-}"

  case "$platform" in
    codex)
      PATH="${path_prefix}${PATH}" TARGET_CODEX_DIR="$target" TRYASCIA_REF=test RAW_BASE="file://$raw_root" \
        bash "$installer_dir/install-codex.sh"
      ;;
    claude)
      PATH="${path_prefix}${PATH}" TARGET_CLAUDE_DIR="$target" TRYASCIA_REF=test RAW_BASE="file://$raw_root" \
        bash "$installer_dir/install.sh"
      ;;
    hermes)
      PATH="${path_prefix}${PATH}" TARGET_HERMES_SKILL_DIR="$target" TRYASCIA_REF=test RAW_BASE="file://$raw_root" \
        bash "$installer_dir/install-hermes.sh"
      ;;
    openclaw)
      PATH="${path_prefix}${PATH}" TARGET_OPENCLAW_SKILL_DIR="$target" TRYASCIA_REF=test RAW_BASE="file://$raw_root" \
        bash "$installer_dir/install-openclaw.sh"
      ;;
  esac
}

expect_failure_without_mutation() {
  local platform="$1"
  local installer_dir="$2"
  local raw_root="$3"
  local target="$4"
  local snapshot="$5"
  local label="$6"
  local path_prefix="${7:-}"

  set +e
  run_installer "$platform" "$installer_dir" "$raw_root" "$target" "$path_prefix"
  local status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    echo "Помилка: $label мав завершитися помилкою для $platform." >&2
    return 1
  fi
  assert_unchanged "$snapshot" "$target" "$label/$platform"
}

INSTALLER_DIR="$WORK_DIR/installers"
prepare_isolated_installers "$INSTALLER_DIR"

for platform in codex claude hermes openclaw; do
  CASE_DIR="$WORK_DIR/checksum-$platform"
  RAW_ROOT="$CASE_DIR/raw"
  TARGET="$CASE_DIR/target"
  SNAPSHOT="$CASE_DIR/before"
  prepare_raw_root "$RAW_ROOT"
  prepare_target "$platform" "$TARGET"
  snapshot_target "$TARGET" "$SNAPSHOT"
  printf '\nCORRUPTED\n' >> "$RAW_ROOT/skills/tryascia/references/korpus.json"
  expect_failure_without_mutation "$platform" "$INSTALLER_DIR" "$RAW_ROOT" "$TARGET" "$SNAPSHOT" "checksum mismatch"
done

SHIM_DIR="$WORK_DIR/shims"
mkdir -p "$SHIM_DIR"
cat > "$SHIM_DIR/curl" <<EOF
#!/usr/bin/env bash
for arg in "\$@"; do
  case "\$arg" in
    */skills/tryascia/references/korpus.json)
      exit 22
      ;;
  esac
done
exec "$REAL_CURL" "\$@"
EOF
cat > "$SHIM_DIR/sleep" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$SHIM_DIR/curl" "$SHIM_DIR/sleep"

for platform in codex claude hermes openclaw; do
  CASE_DIR="$WORK_DIR/download-$platform"
  RAW_ROOT="$CASE_DIR/raw"
  TARGET="$CASE_DIR/target"
  SNAPSHOT="$CASE_DIR/before"
  prepare_raw_root "$RAW_ROOT"
  prepare_target "$platform" "$TARGET"
  snapshot_target "$TARGET" "$SNAPSHOT"
  expect_failure_without_mutation "$platform" "$INSTALLER_DIR" "$RAW_ROOT" "$TARGET" "$SNAPSHOT" "download failure" "$SHIM_DIR:"
done

echo "OK: installer checksum/download failures are rollback-safe for all four platforms."
