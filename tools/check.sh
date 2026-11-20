#!/bin/sh
# Copyright 2026 Warren D. MacEvoy. Apache-2.0. See LICENSE.
# The check: builds gosh-shpool (tools/build.sh), then runs shpool's own tests, the seam's
# included, in the patched copy, and shpool_vt100's tests of what the seam changes there. Arguments go to cargo test (a test name, --no-fail-fast).
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
"$ROOT/tools/build.sh"
# shpool_vt100's whole suite (which passes with the seam: vt100/02 fixes the csi tests that
# fail as published)
(cd "$ROOT/.build/vt100" && cargo test)
cd "$ROOT/.build/core"
cargo test --locked "$@"
