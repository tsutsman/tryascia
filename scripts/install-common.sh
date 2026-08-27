#!/usr/bin/env bash
# Shared installer primitives. Sourced by platform installers after bootstrap verification.

tryascia_hash_file() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    echo "Потрібен sha256sum або shasum для перевірки payload." >&2
    return 1
  fi
}

tryascia_manifest_hash() {
  local manifest="$1"
  local rel="$2"
  awk -v wanted="$rel" '$2 == wanted { print $1; found = 1; exit } END { if (!found) exit 1 }' "$manifest"
}

tryascia_verify_file() {
  local manifest="$1"
  local root="$2"
  local rel="$3"
  local expected actual

  expected="$(tryascia_manifest_hash "$manifest" "$rel")" || {
    echo "Маніфест не містить checksum для $rel." >&2
    return 1
  }
  test -f "$root/$rel" || {
    echo "Payload не містить $rel." >&2
    return 1
  }
  actual="$(tryascia_hash_file "$root/$rel")"
  if [ "$actual" != "$expected" ]; then
    echo "Checksum mismatch для $rel." >&2
    return 1
  fi
}

tryascia_download_file() {
  local url="$1"
  local output="$2"
  local attempts="${TRYASCIA_DOWNLOAD_ATTEMPTS:-4}"
  local sleep_base="${TRYASCIA_RETRY_SLEEP_BASE:-2}"
  local attempt

  mkdir -p "$(dirname "$output")"
  for ((attempt = 1; attempt <= attempts; attempt++)); do
    if curl --connect-timeout 15 -fsSL "$url" -o "$output"; then
      return 0
    fi
    if [ "$attempt" -lt "$attempts" ]; then
      sleep $((attempt * sleep_base))
    fi
  done
  echo "Не вдалося завантажити $url після $attempts спроб." >&2
  return 1
}

tryascia_stage_payload() {
  local source_mode="$1"
  local local_root="$2"
  local raw_base="$3"
  local manifest="$4"
  local stage_root="$5"
  shift 5
  local rel

  rm -rf -- "$stage_root"
  mkdir -p "$stage_root"

  for rel in "$@"; do
    mkdir -p "$stage_root/$(dirname "$rel")"
    if [ "$source_mode" = "local" ]; then
      cp "$local_root/$rel" "$stage_root/$rel"
    else
      tryascia_download_file "$raw_base/$rel" "$stage_root/$rel"
    fi
  done

  for rel in "$@"; do
    tryascia_verify_file "$manifest" "$stage_root" "$rel"
  done
}

tryascia_atomic_overlay_dir() {
  local target="$1"
  local payload_root="$2"
  local source_prefix="$3"
  shift 3
  local parent next backup had_target=0 rel

  parent="$(dirname "$target")"
  mkdir -p "$parent"
  next="$(mktemp -d "$parent/.tryascia-next.XXXXXX")"
  backup="$parent/.tryascia-backup.$$.${RANDOM}"

  if [ -e "$target" ] && [ ! -d "$target" ]; then
    echo "Очікував каталог, але знайдено інший тип: $target" >&2
    rm -rf -- "$next"
    return 1
  fi

  if [ -d "$target" ]; then
    cp -a "$target/." "$next/"
  fi

  for rel in "$@"; do
    mkdir -p "$next/$(dirname "$rel")"
    cp "$payload_root/$source_prefix/$rel" "$next/$rel"
  done

  if [ -d "$target" ]; then
    mv "$target" "$backup"
    had_target=1
  fi

  if mv "$next" "$target"; then
    if [ "$had_target" -eq 1 ]; then
      rm -rf -- "$backup"
    fi
    return 0
  fi

  rm -rf -- "$next" "$target" 2>/dev/null || true
  if [ "$had_target" -eq 1 ] && [ -d "$backup" ]; then
    mv "$backup" "$target"
  fi
  echo "Не вдалося атомарно замінити $target; попередній стан відновлено." >&2
  return 1
}

tryascia_atomic_replace_file() {
  local source="$1"
  local target="$2"
  local parent temp

  parent="$(dirname "$target")"
  mkdir -p "$parent"
  temp="$(mktemp "$parent/.tryascia-file.XXXXXX")"
  if ! cp "$source" "$temp"; then
    rm -f -- "$temp"
    return 1
  fi
  if ! mv -f "$temp" "$target"; then
    rm -f -- "$temp"
    return 1
  fi
}
