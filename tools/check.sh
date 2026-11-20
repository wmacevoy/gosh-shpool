#!/bin/sh
# Copyright 2026 Warren D. MacEvoy. Apache-2.0. See LICENSE.
# The check: builds gosh-shpool (tools/build.sh), then runs shpool's own tests, the seam's
# included, in the patched copy. Arguments go to cargo test (a test name, --no-fail-fast).
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
"$ROOT/tools/build.sh"
cd "$ROOT/.build/core"
cargo test --locked "$@"
