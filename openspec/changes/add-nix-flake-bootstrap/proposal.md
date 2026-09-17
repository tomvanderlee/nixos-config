## Why

This repo currently has no Nix configuration at all — zero `.nix` files, zero commits. The goal is a single flake that can bootstrap a fresh NixOS install after manual disk partitioning, and can also be installed on non-NixOS systems (any Linux now, macOS via nix-darwin later), sharing as much configuration as possible for a uniform experience while staying idiomatic and avoiding hacks.

## What Changes

- Add a `flake.nix` with `nixpkgs` and `home-manager` inputs (following the same `nixpkgs`), exposing `nixosConfigurations`, `homeConfigurations`, `formatter`, and `devShells` outputs.
- Add `lib/mkNixos.nix` and `lib/mkHome.nix` — thin wrapper helpers around `nixpkgs.lib.nixosSystem` and `home-manager.lib.homeManagerConfiguration`, both consuming the same per-user module so NixOS and standalone home-manager activation stay in sync.
- Add `modules/nixos/common.nix` — shared NixOS-only system settings (flakes enabled, base user skeleton, locale, gc policy) applied to every NixOS host.
- Add `modules/home/*.nix` — the shared cross-platform home-manager profile (shell/zsh+starship+direnv, git, editor/neovim, CLI tools), consumed identically by NixOS's home-manager module and by standalone `home-manager switch`.
- Add `users/tom.nix` — the identity/profile file both `mkNixos` and `mkHome` import, with platform-computed `home.homeDirectory`.
- Add `hosts/template/` — a non-instantiated, copy-source-only NixOS host skeleton (`configuration.nix` + stub `hardware-configuration.nix`) used to bootstrap a real host after `nixos-generate-config`.
- Add a `homeConfigurations."tom@linux"` output so the shared profile is a real, buildable standalone target in this change.
- Add `README.md` documenting the NixOS install workflow (manual partition → `nixos-generate-config` → copy host template → `nixos-install --flake`) and the standalone workflow (install Nix → `home-manager switch --flake`).
- Add `formatter` (`nixfmt-rfc-style`) and a `devShells.default` (`statix`, `deadnix`) for linting/formatting this repo itself.
- Explicitly out of scope for this change: a concrete nix-darwin/macOS host, disko-based declarative partitioning, and any secrets management (agenix/sops-nix) — all deferred to follow-up changes.

## Capabilities

### New Capabilities
- `nix-flake-bootstrap`: A flake that provisions NixOS hosts from a copyable template and provisions a shared, cross-platform home-manager user profile installable standalone on non-NixOS systems, with both consumption paths built from the same per-user module.

### Modified Capabilities
(none — greenfield repo, no existing specs)

## Impact

- Affected code: entirely new — `flake.nix`, `flake.lock`, `lib/`, `modules/`, `hosts/template/`, `users/`, `README.md`.
- Dependencies introduced: `nixpkgs` (nixos-unstable), `home-manager` (following nixpkgs).
- Systems affected: none yet running this config (dev machine `glootie` has no Nix installed; no NixOS host exists yet). This change only needs to be validated via `nix flake check` / building the `homeConfigurations."tom@linux"` output — it does not touch any live system.
- Follow-up work (not part of this change): pushing the repo to a remote (needed before `nixos-install` can `git clone` it during a real install), adding a real NixOS host once hardware is partitioned, adding nix-darwin once a Mac is being configured, and adding secrets management.
