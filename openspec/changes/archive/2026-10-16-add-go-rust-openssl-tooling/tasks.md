# Tasks

## 1. Go and Rust toolchains

- [x] 1.1 Create `modules/home/languages.nix` with `home.packages` containing `go`, `gopls`, `cargo`, `rustc`, `rustfmt`, `clippy`, `rust-analyzer`, and import it from `modules/home/default.nix`; verify with `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'map (p: p.name)'` that all seven appear
- [x] 1.2 Verify the same packages evaluate for `"tom@darwin"` using the equivalent `nix eval` command
- [x] 1.3 Build `.#homeConfigurations."tom@linux".activationPackage` and verify `go version`, `cargo --version` and `rust-analyzer --version` run from the built profile

## 2. openssl

- [x] 2.1 Add `openssl` to `home.packages` in `modules/home/dev-tools.nix` and verify `openssl version` runs from the built `tom@linux` activation package

## 3. Integration

- [x] 3.1 Run `nix fmt` and `nix flake check`; verify both pass and `git status` shows only the intended files changed
- [x] 3.2 If a NixOS host exists (use `path:/home/tom/desktop-flake#nixosConfigurations.<host>`), verify its toplevel still builds

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
