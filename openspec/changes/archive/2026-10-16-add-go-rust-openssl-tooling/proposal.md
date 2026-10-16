# Proposal

## Why

Tom wants to develop in Go and Rust on every machine that uses the shared home profile, and wants the `openssl` command available for inspecting certificates and keys. None of these are provisioned today, so each new machine needs manual installs.

## What Changes

- Add a Go toolchain (`go`, `gopls`) and a Rust toolchain (`cargo`, `rustc`, `rustfmt`, `clippy`, `rust-analyzer`) to the shared home profile, in a new `modules/home/languages.nix` imported from `modules/home/default.nix`.
- Add `openssl` (the command-line tool, nixpkgs `openssl` package) to `modules/home/dev-tools.nix`.
- Toolchains come from nixpkgs, not `rustup` or downloaded binaries, so they are reproducible and work identically on NixOS, other Linux, and macOS.
- **BREAKING**: none. Additive only.

## Capabilities

### New Capabilities
- `language-toolchains`: Go and Rust compilers, package/build tools, linters/formatters and language servers available on `PATH` through the shared home profile.

### Modified Capabilities
- `developer-environment`: adds an explicit requirement that the `openssl` command is provisioned.

## Impact

- **Affected code**: new `modules/home/languages.nix`; `modules/home/default.nix` (import); `modules/home/dev-tools.nix` (`openssl`).
- **Not affected**: `lib/unfree-allowlist.nix` (Go is BSD-3-Clause, Rust is MIT/Apache-2.0, OpenSSL is Apache-2.0, all free), `modules/nixos/common.nix`, `modules/home/editor.nix` and anything under `~/.config/nvim`.
- **Dependencies**: nixpkgs only (verified in the pinned flake: go 1.26.8, gopls 0.23.0, cargo/rustc/rustfmt/clippy 1.98.1, rust-analyzer 2026-09-28, openssl 3.5.8). No new flake inputs.
- **Non-goals**: `GOPATH`/`CARGO_HOME` environment variables, `pkg-config` and `openssl.dev` for crates linking against OpenSSL (use a per-project dev shell), `rustup` multi-toolchain management, cross-compilation targets, Go/Rust Neovim configuration (owned by the dotfiles repo).
