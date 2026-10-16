# Design

## Context

Packages in the shared profile are plain `home.packages` lists grouped by theme (`cli-tools.nix`, `dev-tools.nix`, `editor.nix`). `modules/home/default.nix` imports each module. `editor.nix` already provides `stdenv.cc`, which Rust needs as its linker, so no extra C toolchain is required. `nix-ld` is enabled on NixOS hosts, so Mason-installed prebuilt binaries still run if the editor config prefers them. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Reproducible Go and Rust toolchains from the flake's pinned nixpkgs on all platforms.
- A new module that keeps language toolchains in one place and can grow (for example, more languages).

**Non-Goals:**
- Per-project toolchain pinning (belongs in project dev shells).
- Anything under `~/.config/nvim`.

## Decisions

- **nixpkgs packages instead of `rustup`**: `rustup` downloads unmanaged binaries, which break on NixOS without extra work and are not reproducible. Trade-off: the toolchain version follows the flake input, and nightly or extra targets are not available. Projects needing them use their own dev shell.
- **Separate `modules/home/languages.nix`** rather than appending to `dev-tools.nix` or `editor.nix`: `dev-tools.nix` is for CLI clients, and `editor.nix` is tied to the dotfiles-owned Neovim config. A dedicated module follows the existing one-theme-per-file layout.
- **`gopls` and `rust-analyzer` from nixpkgs**: they match the installed compiler versions, and Mason can still install its own copies if the dotfiles config prefers that.
- **`openssl` in `dev-tools.nix`** as a plain package entry, next to the other CLI tools. Only the binary is needed, so no `openssl.dev` or `pkg-config`.
- **No unfree entries**: all packages are free, so `lib/unfree-allowlist.nix` is untouched.

## Risks / Trade-offs

- [Crates using `openssl-sys` fail to build outside a dev shell, since headers and `pkg-config` are absent] → Documented non-goal; use a project `flake.nix` dev shell or the `vendored` feature.
- [Mac builds of Rust may need Xcode command-line tools for some crates] → Out of scope; same as any Nix-on-macOS setup.
- [Closure size grows by several hundred MB] → Accepted.
