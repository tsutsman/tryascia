#!/usr/bin/env bash
# Перевіряє published stable release assets і їх checksum contract.

set -euo pipefail

VERSION="${STABLE_VERSION:-1.1.0}"
TAG="v${VERSION}"
BASE="https://github.com/tsutsman/tryascia/releases/download/${TAG}"
RAW="https://raw.githubusercontent.com/tsutsman/tryascia/${TAG}"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT

cd "$WORK_DIR"
for file in "tryascia-${VERSION}.tar.gz" SHA256SUMS install-manifest.sha256; do
  curl --connect-timeout 15 --retry 3 --retry-all-errors -fsSLO "$BASE/$file"
done

sha256sum -c SHA256SUMS
curl --connect-timeout 15 --retry 3 --retry-all-errors -fsSL "$RAW/install-manifest.sha256" -o install-manifest.tag.sha256
cmp install-manifest.sha256 install-manifest.tag.sha256

tar -tzf "tryascia-${VERSION}.tar.gz" > archive-files.txt
grep -Fxq "tryascia-${VERSION}/package.json" archive-files.txt
grep -Fxq "tryascia-${VERSION}/skills/tryascia/SKILL.md" archive-files.txt
grep -Fxq "tryascia-${VERSION}/install-manifest.sha256" archive-files.txt

echo "OK: $TAG release assets існують, SHA256 валідні, manifest відповідає tag payload."
