# Proposal

## Why

In `~/Projects/ttun-server`, `uv run python -c "import greenlet"` fails with `libstdc++.so.6: cannot open shared object file`, which breaks SQLAlchemy's async layer.

Investigation on the dev machine (host `test-vm`, aarch64-linux, NixOS 26.11) showed:

- The running generation is built from this flake, `NIX_LD` and `NIX_LD_LIBRARY_PATH` are set, and `/run/current-system/sw/share/nix-ld/lib` already contains `libstdc++.so.6` and `libz.so.1`. nix-ld's defaults include `stdenv.cc.cc.lib` and `zlib` on this nixpkgs revision.
- The venv's interpreter is not a uv-managed foreign binary. `.venv/pyvenv.cfg` points at `/etc/profiles/per-user/tom/bin` and the interpreter resolves to `/nix/store/...-python3-3.14.8/bin/python3.14`, the nixpkgs `python3` that `modules/home/editor.nix` installs for mason.nvim. uv chose it because it satisfied the project and there is no `.python-version`. A Nix-built interpreter has a store RUNPATH and does not go through nix-ld, so greenlet's prebuilt `_greenlet*.so` never searches the nix-ld libraries. `LD_DEBUG=libs` confirms only LD_LIBRARY_PATH, the interpreter RUNPATH and glibc are searched.
- The `x86_64-linux` pin on `tom@linux` in `flake.nix` is not involved: this machine is the `nixosConfigurations.test-vm` host (`system` = `aarch64-linux`).

Adding libraries to `programs.nix-ld.libraries` alone will not fix greenlet. uv must use a managed interpreter, which does run under nix-ld.

## What Changes

- Set `UV_PYTHON_PREFERENCE=only-managed` for the user via the shared home profile so uv ignores the Nix-built `python3` on PATH. The `python3` package stays installed for mason.nvim.
- List `stdenv.cc.cc.lib` and `zlib` explicitly in `programs.nix-ld.libraries` in `modules/nixos/common.nix`, plus `libuuid` and `libxcrypt-legacy`, which common native wheels link against and the defaults lack.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `dynamic-linking-support`: the nix-ld library set explicitly includes the C++ runtime and zlib.
- `developer-environment`: uv uses its own managed Python interpreters rather than a Nix-built one from PATH.

## Impact

- **Affected code**: `modules/nixos/common.nix`, the home module owning developer tooling (session variable), `README.md` if it describes nix-ld or uv.
- **Not affected**: `flake.nix`, `hosts/*`, `~/Projects/ttun-server` (no `shell.nix` or `flake.nix` added there).
- **Side effects**: the first `uv run` after the switch downloads a Python 3.14 build (only 3.13 is currently in `~/.local/share/uv/python`), and the existing `.venv` must be recreated because it is bound to the Nix interpreter.

## Non-goals

- Making the Nix-built `python3` load foreign wheels (wrapping it or `NIX_LD_LIBRARY_PATH` hacks).
- Running `nixos-rebuild switch` or `home-manager switch` without the user's approval.
