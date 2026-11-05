# Design

## Context

`modules/nixos/common.nix` enables `programs.nix-ld` with ncurses, libffi, sqlite, readline, gdbm and expat. The evaluated `test-vm` library list also contains nix-ld's defaults (zlib, zstd, gcc, curl, openssl, bzip2, libxml2, xz, systemd and others). See proposal.md for the evidence that the failure comes from a Nix-built interpreter ignoring nix-ld.

## Goals / Non-Goals

**Goals:** `uv run python -c "import greenlet"` works in `~/Projects/ttun-server` with no project-level Nix files; the C++ runtime and zlib no longer depend on upstream nix-ld defaults.

**Non-Goals:** see proposal.md.

## Decisions

- **`UV_PYTHON_PREFERENCE=only-managed` via `home.sessionVariables`**, rather than removing `python3` from `modules/home/editor.nix` (mason.nvim needs it) or a per-project `.python-version` (the user wants the system to provide everything). `only-managed` over `managed` so uv never silently falls back to the Nix interpreter. It applies to NixOS hosts and standalone home-manager machines alike; managed interpreters work natively on macOS and non-NixOS Linux, so it is harmless there.
- **Explicit nix-ld libraries** `stdenv.cc.cc.lib`, `zlib`, `libuuid`, `libxcrypt-legacy` appended to the existing list, consistent with the "additive" requirement. This is belt-and-braces for managed interpreters, not the fix for the observed failure. `libuuid` evaluated to `util-linux-minimal` and `libxcrypt-legacy` to `libxcrypt`; confirm during implementation that the built directory has `libuuid.so.1` and `libcrypt.so.1`.

## Risks / Trade-offs

- [The managed Python may still miss a library] → The verification task inspects `LD_DEBUG=libs` before adding more libraries.
- [`LD_LIBRARY_PATH` exported by the dotfiles `.bashrc` could interfere] → It currently holds a store alsa-lib path and `~/.local` dirs; verify after the switch and report any interference rather than editing the dotfiles repo here.
- [The existing `.venv` is bound to the Nix interpreter] → Recreate it, only with the user's go-ahead.
