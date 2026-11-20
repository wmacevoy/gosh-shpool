#!/bin/sh
# Copyright 2026 Warren D. MacEvoy. Apache-2.0. See LICENSE.
# Packages .build/bin/shpool as dist/gosh-shpool-VERSION-PLATFORM.tar.gz, with shpool's licence
# and a note of what it is, under a directory of the same name.
#   tools/package-release.sh VERSION PLATFORM [DIST]
# PLATFORM is gosh's name for the machine: linux-x86_64, linux-aarch64, linux-x86_64-musl,
# linux-aarch64-musl, macos-universal.
set -eu
[ $# -ge 2 ] || { echo "usage: $0 VERSION PLATFORM [DIST]"; exit 2; }
VERSION=$1 PLATFORM=$2 DIST=${3:-dist}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
name="gosh-shpool-$VERSION-$PLATFORM"
stage=$(mktemp -d)
mkdir -p "$stage/$name" "$DIST"
cp "$ROOT/.build/bin/shpool" "$stage/$name/shpool"
chmod 755 "$stage/$name/shpool"
cp "$ROOT/core/LICENSE" "$stage/$name/LICENSE"
upstream=$(cd "$ROOT/core" && git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD)
patches=$(cd "$ROOT/seam" && ls ./*.patch ./vt100/*.patch 2>/dev/null | sed 's|^\./||' | tr '\n' ' ')
cat > "$stage/$name/README.md" <<NOTE
gosh-shpool $VERSION for $PLATFORM.

shpool $upstream (https://github.com/shell-pool/shpool) with gosh-shpool's patches applied:
$patches(https://github.com/wmacevoy/gosh-shpool/tree/main/seam). Its licence is in LICENSE
beside this file. Not independently reviewed.
NOTE
tar -C "$stage" -czf "$DIST/$name.tar.gz" "$name"
rm -rf "$stage"
echo "package: $DIST/$name.tar.gz"
