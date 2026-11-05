# Proposal

## Why

`fix-python-native-libs` and `pin-uv-default-python` set `UV_PYTHON_PREFERENCE=only-managed` and `UV_PYTHON=3.14` through `home.sessionVariables`, but those variables never reach the user's shells. Home-manager writes them to `hm-session-vars.sh`, and nothing on this system sources it: `/etc/set-environment` does not, and `programs.bash` is deliberately unmanaged because the dotfiles repo owns `~/.bashrc`. Verified: `bash -lc` and `bash -lic` both show both variables empty. The earlier verification passed only because the variables were exported by hand. In the user's own shell, `uv sync` in `~/Projects/ttun-server` picked managed CPython 3.15.1 and failed building `cffi` (`ffi.h` missing); the resulting `.venv` is a 3.15 venv.

uv reads user-level config files regardless of shell. Verified with uv 0.13.5 and a throwaway `XDG_CONFIG_HOME` with no `UV_*` variables set: `uv.toml` with `python-preference = "only-managed"` plus a `.python-version` file containing `3.14` in the same directory selects CPython 3.14.9, whereas without them uv selects 3.15.

## What Changes

- In `modules/home/dev-tools.nix`, remove the two `home.sessionVariables` entries and instead write `~/.config/uv/uv.toml` (`python-preference = "only-managed"`) and `~/.config/uv/.python-version` (`3.14`) with `xdg.configFile`.
- **BREAKING**: none. A project-level `.python-version` or `--python` still overrides the global pin.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `developer-environment`: the two uv requirements (managed interpreters; 3.14 default) are delivered through uv's user config files rather than environment variables, and must hold without any shell setup.

## Impact

- **Affected code**: `modules/home/dev-tools.nix`.
- **Not affected**: `modules/home/editor.nix` (the Nix `python3` stays for tooling), `modules/nixos/common.nix`, `hosts/*`, the dotfiles repo, `EDITOR`/`VISUAL` handling.
- **Side effects**: needs a switch. The existing 3.15 `.venv` in `~/Projects/ttun-server` must be recreated (removing it needs the user's go-ahead). `~/.config/uv` does not exist yet, so there is no file conflict.

## Non-goals

- Sourcing `hm-session-vars.sh` from the shell or changing the dotfiles repo, which would affect every variable and is a broader decision.
- Making `EDITOR` and other session variables work; out of scope here.
- Removing the Nix `python3` or running a switch without the user's approval.
