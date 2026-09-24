# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single Nix flake that provisions both NixOS hosts and non-NixOS systems (any Linux, macOS via nix-darwin later) from one shared set of home-manager modules. Two users of the shared config exist: real NixOS machines (`nixosConfigurations`) and standalone home-manager-only machines (`homeConfigurations`).

## Commands

- `nix fmt` — format all `.nix` files with `nixfmt-rfc-style`.
- `nix develop` — shell with `statix` and `deadnix` (linters) available.
- `nix flake check` — validates `homeConfigurations."tom@linux"`, `apps.bootstrap-host`, and other flake outputs. There are no real `nixosConfigurations` checked here unless a host has been scaffolded under `hosts/`.
- `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` (or `"tom@darwin"`) — inspect the resolved package set for a given platform without building it.
- `nix build '.#homeConfigurations."tom@linux".activationPackage'` — build a standalone home-manager activation.
- `nix build '.#nixosConfigurations.<hostname>.config.system.build.toplevel'` — build a full NixOS system closure for an existing host directory.
- `nix run .#bootstrap-host -- <hostname> --root <path> --state-version <ver>` — scaffold `hosts/<hostname>/` from `hosts/template/` (see `scripts/bootstrap-host.sh --help`). This is the only supported way to add a new NixOS host; never hand-edit `flake.nix` to add one.

## Architecture

**Host discovery is automatic.** Any directory under `hosts/` other than `hosts/template` that contains a `system` file becomes a real `nixosConfigurations.<name>` output (see `flake.nix`). `hosts/template/` is a copy-source only, excluded by name, and is never built directly — `scripts/bootstrap-host.sh` copies it into a new `hosts/<hostname>/`.

**`lib/mkNixos.nix` and `lib/mkHome.nix`** are the two entry points that turn a hostname/username into a flake output:
- `mkNixos` builds a `nixosSystem`: shared `modules/nixos/common.nix` + the host's own `hosts/<hostname>/configuration.nix` + the home-manager NixOS module (wired with `useGlobalPkgs`/`useUserPackages`, importing each user's `users/<name>.nix`).
- `mkHome` builds a standalone `homeManagerConfiguration` from just `users/<username>.nix` — no NixOS involved.
- Both apply the same `nixpkgs.config.allowUnfreePredicate`, sourced from `lib/unfree-allowlist.nix` (a flat list of package names — add unfree packages here, never flip `allowUnfree = true` globally).

**`modules/home/` is the shared, cross-platform profile** — the same modules are consumed whether activated via a NixOS host's home-manager integration or a standalone `home-manager switch`. Because of this dual use, any module that needs to know whether it's running on a real NixOS/GNOME system (vs. a bare Linux or macOS home-manager-only box) must not assume Linux implies NixOS or GNOME:
  - Platform-only differences (`pkgs.stdenv.hostPlatform.isLinux`/`isDarwin`) are fine and used throughout (see `modules/home/dotfiles.nix`'s `platformDefaultExcludes`, `modules/home/desktop-apps.nix`'s `linuxOnlyApps`).
  - Package availability differences are handled via `lib.meta.availableOn pkgs.stdenv.hostPlatform`, filtered over a candidate list (`modules/home/desktop-apps.nix`) — this lets an unsupported platform's package silently drop out rather than fail evaluation.
  - Anything that actually depends on NixOS-level config (e.g. whether GNOME is enabled) must read the `osConfig` special arg, which home-manager's NixOS integration sets to the full NixOS `config` — but which is absent when a module is evaluated standalone via `mkHome`. Modules that reference it need `osConfig ? null` in their argument list and should treat a missing/false value as "not applicable" rather than erroring.

**`modules/nixos/common.nix`** holds everything applied unconditionally to every NixOS host: flakes enabled, the `tom` user (SSH keys pinned as a static literal, not fetched at build time), locale/timezone defaults (`mkDefault`, so a host can override), nix gc policy, sshd (key-only auth, firewall open only on 22), and the GNOME desktop stack (GDM, NetworkManager, PipeWire/rtkit, CUPS+Avahi). Per-host files under `hosts/<name>/configuration.nix` layer on top of this, not instead of it.

**`users/<name>.nix`** is the identity/profile file consumed by both `mkNixos` (as a home-manager user module) and `mkHome` (as the top-level module) — it's the one place that's the same regardless of which entry point is used.

**Personal dotfiles integration** (`modules/home/dotfiles.nix`) is opt-in via `home.dotfiles.repoUrl`. When set, it clones a separate personal dotfiles git repo to `~/dotfiles` and GNU-Stow-symlinks every top-level, non-hidden directory into `$HOME`, skipping platform-mismatched packages (built-in defaults in `platformDefaultExcludes`, plus anything listed in `home.dotfiles.excludePackages`) and skipping (with a warning, not a failure) any package whose target path conflicts with an existing file. An existing `~/dotfiles` checkout is never re-cloned or modified. Because `~/dotfiles/git/.gitconfig` and `~/dotfiles/bash/.bashrc` are the sole source of git/bash config once stowed, this repo's own `programs.git`/`programs.bash` home-manager management has been deliberately removed.

**Neovim** (`modules/home/editor.nix`) sets `programs.neovim.sideloadInitLua = true` specifically so home-manager never writes `~/.config/nvim/init.lua` — that path is owned exclusively by the dotfiles repo's `neovim` Stow package. Do not add `programs.neovim.extraConfig`/`plugins`/anything else that writes into `~/.config/nvim`; it will silently lose to the dotfiles automation's skip-on-conflict behavior and break plugin loading.

## Planning changes with OpenSpec

This repo uses OpenSpec (`openspec/`) for structured change proposals: `openspec/specs/<capability>/spec.md` are the current-truth capability specs, `openspec/changes/` holds in-flight change proposals (proposal/specs-delta/design/tasks), and `openspec/changes/archive/` holds completed ones. Use the `openspec-propose` / `openspec-update-change` / `openspec-apply-change` / `openspec-archive-change` skills (or their `/opsx:*` equivalents) rather than hand-editing these — they keep proposal, delta spec, design, and tasks coherent and validate via `openspec validate`. Read `openspec/changes/archive/*/proposal.md` for examples of this project's expected proposal depth (verified license/platform facts, explicit non-goals, precise file-level impact).
