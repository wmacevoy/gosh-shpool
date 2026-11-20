# gosh-shpool

[shpool](https://github.com/shell-pool/shpool) keeps shell sessions alive on a remote host. Your
connection can drop and the shell, with whatever is running in it, carries on; you attach again
and pick up where you were. gosh-shpool is shpool as released upstream, with a small set of
patches on top, built and published for Linux and macOS.

It exists because gosh, a remote shell, and its editor extension use shpool for persistent
terminals, and needed two things shpool does not have yet:

- **Renaming sessions.** `shpool rename [OLD_NAME] NEW_NAME`, and a `SHPOOL_SESSION_ID` that
  never changes, so a terminal can be given a name that says what is in it, and found again by
  that name after a reconnect.
- **Fixes for two bugs in shpool's terminal emulator that can lose what is on screen** when you
  reattach. One left out the line the cursor was on (usually the prompt, with whatever was being
  typed) and put the cursor in empty space below the rest. The other made the next character
  overwrite the last one on a full line, instead of starting a new line.

Every change here is also offered to shpool upstream. The goal is for gosh-shpool to become
unnecessary: each patch is dropped once a shpool release includes it.

## What is in it

| Change | Patch | Upstream |
| --- | --- | --- |
| `shpool rename` and `SHPOOL_SESSION_ID` | [`seam/01-rename.patch`](seam/01-rename.patch) | [shell-pool/shpool#459](https://github.com/shell-pool/shpool/pull/459) (closes [#57](https://github.com/shell-pool/shpool/issues/57)) |
| Line-mode restore redraws the last lines up to and including the prompt, with the cursor on it | [`seam/vt100/01-last-n-rows.patch`](seam/vt100/01-last-n-rows.patch) | [shell-pool/shpool_vt100#2](https://github.com/shell-pool/shpool_vt100/pull/2) |
| Restoring the cursor keeps a pending wrap, so the next character is not written over the last | [`seam/vt100/02-restore-pending-wrap.patch`](seam/vt100/02-restore-pending-wrap.patch) | [shell-pool/shpool_vt100#3](https://github.com/shell-pool/shpool_vt100/pull/3) |
| shpool built against the fixed shpool_vt100, with tests that catch both bugs | [`seam/03-vt100-seam.patch`](seam/03-vt100-seam.patch) | a version bump in shpool, once shpool_vt100 releases the fixes |
| shpool's tests run on macOS where they had been skipped for reasons of the tests | [`seam/02-macos-tests.patch`](seam/02-macos-tests.patch) | not yet offered |
| Three unit tests that failed now and then wait for what they check | [`seam/04-test-timing.patch`](seam/04-test-timing.patch) | not yet offered |

Each patch starts with a note of what it is for, what it changes, and where it stands upstream.
[`seam/README.md`](seam/README.md) says how the patches are kept.

### Renaming

```
shpool rename old-name new-name     # rename a session
shpool rename new-name              # rename the session you are in
```

The session keeps running, and stays attached if it is attached. Its shell picks up the new name
in `$SHPOOL_SESSION_NAME` and in its prompt the next time it draws a prompt. `$SHPOOL_SESSION_ID`
stays the same for the life of the session, and `shpool list --json` shows both. Renaming to a
name another session has, or to a name shpool would not accept for a new session, is refused.

### The restore bugs

With `session_restore_mode = { lines = N }` (shpool's default engine is the one affected), a
reattach should redraw the last N lines and leave the cursor where it was. It redrew the N lines
*above* the cursor's line instead, and moved the cursor to its old row on the screen, below what
it drew. So the prompt you were at was missing, along with anything you had typed at it. It only
showed once more than N lines were on the screen, which is why it went unnoticed.

Separately, saving and restoring the cursor (which shpool's restore also does) lost the state a
terminal is in right after a line is filled to the last column: the next character overwrote
that last column instead of starting the next line. This also broke three of shpool_vt100's own
tests, which have failed since the change that caused it.

## Downloads

[Releases](https://github.com/wmacevoy/gosh-shpool/releases) have, for each version,

| File | For |
| --- | --- |
| `gosh-shpool-<version>-linux-x86_64.tar.gz` | Linux on x86_64, glibc 2.34 or newer |
| `gosh-shpool-<version>-linux-aarch64.tar.gz` | Linux on ARM64, glibc 2.34 or newer |
| `gosh-shpool-<version>-linux-x86_64-musl.tar.gz` | Linux on x86_64, any (static: Alpine and the like) |
| `gosh-shpool-<version>-linux-aarch64-musl.tar.gz` | Linux on ARM64, any (static) |
| `gosh-shpool-<version>-macos-universal.tar.gz` | macOS 11 or newer, Apple Silicon and Intel |
| `SHA256SUMS` | checksums of all of the above |

Each archive holds `shpool`, shpool's licence and a note of what it is. To install, check it and
put `shpool` on your `PATH`:

```
f=gosh-shpool-<version>-<platform>.tar.gz
grep " $f\$" SHA256SUMS | sha256sum -c       # on macOS: shasum -a 256 -c
tar -xzf "$f"
install -m 755 "${f%.tar.gz}/shpool" ~/.local/bin/shpool
```

It is used exactly as shpool is; see [shpool's README](https://github.com/shell-pool/shpool#usage).
A daemon from plain shpool should be restarted after switching, since the protocol has a new
message (`shpool` warns about a version mismatch until it is).

Versions are `<shpool version>-gosh.<n>`: `0.11.7-gosh.2` is shpool 0.11.7 with this repository's
patches, second release.

## How it is built

- `core/` is upstream shpool at its release tag, and `vt100/` is upstream
  [shpool_vt100](https://github.com/shell-pool/shpool_vt100) (shpool's terminal emulator) at the
  release shpool uses. Both are git submodules, and neither is ever edited.
- `seam/*.patch` apply to a copy of `core/`, and `seam/vt100/*.patch` to a copy of `vt100/`, in
  the order of their names. A patch that does not apply exactly stops the build.
- `tools/build.sh` makes the copies in `.build/`, applies the patches, and builds
  `.build/bin/shpool`. `SHPOOL_TARGET=<rust target>` builds for another machine.
- `tools/check.sh` builds, then runs shpool's whole test suite and shpool_vt100's on the result.
  CI runs it on Linux and macOS for every push.
- A tag `v<version>` builds the five platforms, refuses a glibc build that needs newer than glibc
  2.34, and publishes the release, only once the check has passed on the same commit.

To build it yourself you need Rust 1.85 or newer (rustup picks up the version shpool pins):

```
git clone --recurse-submodules https://github.com/wmacevoy/gosh-shpool
cd gosh-shpool
tools/check.sh      # build and test
tools/build.sh      # build only
```

## About

Not independently reviewed. The patches were written with Claude Code (Claude Opus 5.5) and
reviewed by Warren MacEvoy, who offered them upstream.

Apache-2.0, as shpool and shpool_vt100 are ([LICENSE](LICENSE)).
