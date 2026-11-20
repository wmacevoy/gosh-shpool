#!/bin/sh
# Copyright 2026 Warren D. MacEvoy. Apache-2.0. See LICENSE.
# Builds gosh-shpool in .build/: a copy of shpool at its pinned release (core/), with the
# seam's patches applied in the order of their names, built there, and the program put at
# .build/bin/shpool.
#
# A copy, so that core/ stays upstream's byte for byte. A patch that does not apply exactly
# stops the build: that is how a moved pin says what the seam costs (seam/README.md).
#
# SHPOOL_TARGET=TRIPLE builds for that Rust target (x86_64-unknown-linux-musl, ...); unset,
# for this machine. Extra words for cargo go in SHPOOL_CARGO.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
BUILD="$ROOT/.build"
[ -f "$ROOT/core/Cargo.toml" ] || { echo "build: core/ is empty: git submodule update --init"; exit 1; }
rm -rf "$BUILD/core" "$BUILD/bin" && mkdir -p "$BUILD/core" "$BUILD/bin"
(cd "$ROOT/core" && git ls-files -z | tar --null -T - -cf - | tar -xf - -C "$BUILD/core")
cd "$BUILD/core"
applied=0
for patch in "$ROOT"/seam/*.patch; do
    [ -f "$patch" ] || continue
    patch -p1 --fuzz=0 --no-backup-if-mismatch -s < "$patch" \
        || { echo "build: the seam's $(basename "$patch") does not apply to the core"; exit 1; }
    applied=$((applied + 1))
done
echo "build: $applied of the seam's patches applied"

# The Rust the core pins (its rust-toolchain.toml), where rustup can provide it; without
# rustup, whatever cargo is on the PATH (pixi's, locally).
if command -v rustup >/dev/null 2>&1; then
    channel=$(sed -n 's/^channel *= *"\(.*\)"/\1/p' rust-toolchain.toml)
    rustup toolchain install "$channel" --profile minimal
fi

target_args=""
out="target/release/shpool"
if [ -n "${SHPOOL_TARGET:-}" ]; then
    # (rustup, where there is one, honours the core's rust-toolchain.toml from here)
    if command -v rustup >/dev/null 2>&1; then rustup target add "$SHPOOL_TARGET"; fi
    target_args="--target $SHPOOL_TARGET"
    out="target/$SHPOOL_TARGET/release/shpool"
fi
# shellcheck disable=SC2086 # (word splitting of the optional arguments is meant)
cargo build --release --locked -p shpool $target_args ${SHPOOL_CARGO:-}
cp "$out" "$BUILD/bin/shpool"
"$BUILD/bin/shpool" version 2>/dev/null || echo "build: (built for another machine; not run)"
echo "build: $BUILD/bin/shpool"
