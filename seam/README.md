# The seam

What gosh-shpool changes in shpool. `core/` is upstream's shpool at its pinned release and is
never edited, and so is `vt100/`, upstream's shpool_vt100 (shpool's terminal emulator) at the
release shpool uses. `seam/vt100/*.patch` apply to a copy of `vt100/` the same way, and
`03-vt100-seam.patch` points shpool at that copy instead of crates.io's. `tools/build.sh` copies it to `.build/core` and applies every `*.patch` here to
the copy, in the order of their names. A patch that does not apply exactly (`--fuzz=0`) stops
the build.

Each patch begins by saying what it is for, what it changes and where, whether it only adds or
also reshapes, which patches it needs before it, and its status upstream. The aim is an empty
seam: every patch here is also offered to shpool, and goes once a shpool release includes it.

| Patch | Upstream |
| --- | --- |
| `01-rename.patch` | [shell-pool/shpool#459](https://github.com/shell-pool/shpool/pull/459) |
| `02-macos-tests.patch` | not yet offered (tests only: find zsh/fish, unskip tests that pass on macOS) |
| `03-vt100-seam.patch` | becomes a version bump once shpool_vt100 releases the fix |
| `04-test-timing.patch` | not yet offered (tests only: three unit tests wait instead of assuming a timing) |
| `vt100/01-last-n-rows.patch` | [shell-pool/shpool_vt100#2](https://github.com/shell-pool/shpool_vt100/pull/2) |
| `vt100/02-restore-pending-wrap.patch` | [shell-pool/shpool_vt100#3](https://github.com/shell-pool/shpool_vt100/pull/3) |

To change one: edit the copy in `.build/core`, see it build and `tools/check.sh` pass, and cut
the patch again from the difference (`git diff` in a checkout of `core/` with the earlier patches
applied). To move the pin: move `core/` to the new release tag, build, and repair or drop the
first patch that no longer applies.
