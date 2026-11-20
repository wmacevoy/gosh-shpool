# gosh-shpool

[shpool](https://github.com/shell-pool/shpool) as gosh uses it: upstream's release, pinned, with a
small seam of patches, built for the same machines as a gosh release. remote-gosh copies it to
hosts that have no shpool, for its persistent terminals.

- `core/` is upstream shpool at its pinned release (now `v0.11.7`), a submodule, never edited.
- `seam/` is what gosh-shpool changes, one patch per change, each also offered upstream
  ([seam/README.md](seam/README.md)). The aim is an empty seam.
- `tools/build.sh` copies the core to `.build/core`, applies the seam exactly (`--fuzz=0`), and
  builds `.build/bin/shpool`. `SHPOOL_TARGET=<rust target>` builds for another machine.
- `tools/check.sh` builds and runs shpool's own tests on the result, the seam's included.

## What it adds to shpool

`shpool rename [OLD_NAME] NEW_NAME`, and `SHPOOL_SESSION_ID`, an id for each session that never
changes (also in `shpool list --json`). Offered upstream as
[shell-pool/shpool#459](https://github.com/shell-pool/shpool/pull/459).

## Releases

A tag `v<shpool version>-gosh.<n>` (for example `v0.11.7-gosh.1`) publishes a pre-release with
`gosh-shpool-<version>-<platform>.tar.gz` for `linux-x86_64`, `linux-aarch64` (glibc 2.34 or
newer), `linux-x86_64-musl`, `linux-aarch64-musl` (static, for Alpine and the like) and
`macos-universal`, with `SHA256SUMS`. Each holds `shpool`, shpool's `LICENSE` and a note of what
it is. A release goes out only of a commit whose check (`ci.yml`) passed.

## Building here

Needs Rust 1.85 or newer (rustup reads the pin from the core) and `git submodule update --init`:

    tools/check.sh            # build, then shpool's tests
    tools/build.sh            # build only

Not independently reviewed. Apache-2.0, as shpool is ([LICENSE](LICENSE)).
