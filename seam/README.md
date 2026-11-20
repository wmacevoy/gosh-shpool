# The seam

What gosh-shpool changes in shpool. `core/` is upstream's shpool at its pinned release and is
never edited. `tools/build.sh` copies it to `.build/core` and applies every `*.patch` here to
the copy, in the order of their names. A patch that does not apply exactly (`--fuzz=0`) stops
the build.

Each patch begins by saying what it is for, what it changes and where, whether it only adds or
also reshapes, which patches it needs before it, and its status upstream. The aim is an empty
seam: every patch here is also offered to shpool, and goes once a shpool release includes it.

| Patch | Upstream |
| --- | --- |
| `01-rename.patch` | [shell-pool/shpool#459](https://github.com/shell-pool/shpool/pull/459) |
| `02-macos-tests.patch` | not yet offered (tests only: find zsh/fish, unskip the motd pager tests) |

To change one: edit the copy in `.build/core`, see it build and `tools/check.sh` pass, and cut
the patch again from the difference (`git diff` in a checkout of `core/` with the earlier patches
applied). To move the pin: move `core/` to the new release tag, build, and repair or drop the
first patch that no longer applies.
