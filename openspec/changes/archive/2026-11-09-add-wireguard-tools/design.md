# Design

## Context

`modules/home/dev-tools.nix` holds the client CLIs (gh, kubectl, awscli2, openssl, ...) in a single `with pkgs; [ ... ]` list, shared by NixOS hosts and standalone home-manager activations. `wireguard-tools` is a plain CLI package with no daemon, so it fits that pattern. See proposal.md for scope.

## Goals / Non-Goals

**Goals:**
- `wg` and `wg-quick` on `PATH` everywhere the shared profile is used.

**Non-Goals:**
- Anything that configures WireGuard (see proposal).

## Decisions

- **Install via home-manager, in `dev-tools.nix`.** Matches how every other client CLI is provided and works on standalone Linux and macOS too. Alternative: `environment.systemPackages` in `common.nix`; rejected because it would exclude non-NixOS machines and the repo keeps user tooling in the home profile.
- **No `availableOn` filtering.** `wireguard-tools` is available on every system a `homeConfigurations` or `nixosConfigurations` output here uses (x86_64-linux, aarch64-linux, aarch64-darwin), verified by eval. Nixpkgs no longer lists x86_64-darwin for it, but the flake defines no x86_64-darwin home configuration; if one is added later, wrap the package in the existing `availableOn` filter.
- **No NixOS module or option.** Reading state with `wg show` works against the in-kernel WireGuard with root privileges; nothing needs enabling.

## Risks / Trade-offs

- [`wg-quick` on NixOS relies on `resolvconf`/`openresolv` for `DNS =` lines in configs, which may not be present] → Out of scope; only matters if the user brings tunnels up with `wg-quick` and DNS entries. Revisit if it bites.
- [On macOS `wg-quick` needs the userspace `wireguard-go`] → Not provisioned here; the tools are still useful for key generation and `wg show` against existing tunnels.
