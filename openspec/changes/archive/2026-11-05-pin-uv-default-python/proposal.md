# Proposal

## Why

After `fix-python-native-libs`, uv uses managed interpreters, but with no version pinned it picks the newest one. In `~/Projects/ttun-server` (`requires-python = ">=3.14"`, no `.python-version`) that is managed CPython 3.15.1. There, `cffi` (pulled in via `authlib` → `cryptography`) has no wheel and tries to build from source, failing for lack of `ffi.h`. Observed with a throwaway venv: `uv run --python 3.14` creates a working venv on CPython 3.14.9 and `import greenlet` prints `3.5.3`; unpinned it fails. The original `.venv` no longer exists, so the next `uv run` creates a fresh one, which makes this testable end to end.

## What Changes

- Set `UV_PYTHON=3.14` through `home.sessionVariables` in `modules/home/dev-tools.nix`, next to `UV_PYTHON_PREFERENCE`, so uv defaults to the 3.14 series (resolved to the latest managed 3.14.x) for projects that do not pin their own version.
- **BREAKING**: none for existing projects that pin a version in `.python-version` or `uv run --python`; those take precedence over `UV_PYTHON`.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `developer-environment`: adds a requirement that uv's default interpreter series is pinned by the shared home profile.

## Impact

- **Affected code**: `modules/home/dev-tools.nix` only.
- **Not affected**: `modules/nixos/common.nix`, `hosts/*`, `~/Projects/ttun-server` (no files added there).
- **Side effects**: needs a switch (the session variable ships through the home-manager generation) and a new login shell to take effect. Projects requiring a newer Python than 3.14 must pin their own version.

## Non-goals

- Removing the Nix `python3` from `modules/home/editor.nix`: it stays for tooling; only development Python is meant to come from uv or pyenv.
- Adding `.python-version` to any project (the system should provide everything).
- Supplying C headers (`libffi.dev`) to build sdists from source.
- Running a switch without the user's approval.
