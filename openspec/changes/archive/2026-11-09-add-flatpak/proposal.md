# Proposal

## Why

Some desktop applications Tom wants are not packaged in nixpkgs, or are packaged but badly out of date. Flatpak (with Flathub) is the common distribution channel for such apps on Linux, and NixOS needs the Flatpak service, portals and a configured remote before `flatpak install` works.

## What Changes

- Enable `services.flatpak` in `modules/nixos/common.nix` so every NixOS host built from this flake can run Flatpak applications (portals come from the already-enabled GNOME stack).
- Add the Flathub remote declaratively with a one-shot systemd service that runs `flatpak remote-add --if-not-exists flathub ...`, so a fresh host can `flatpak install flathub <app>` immediately after the first boot with network access.
- Document the workflow (`flatpak install flathub <app-id>`, `flatpak run`, `flatpak update`) in `README.md`.
- **BREAKING**: none.

## Capabilities

### New Capabilities
- `flatpak`: Flatpak runtime and a pre-configured Flathub remote on every NixOS host, for installing applications that are not in nixpkgs.

### Modified Capabilities
(none)

## Impact

- **Affected code**: `modules/nixos/common.nix`, `README.md`.
- **Not affected**: `modules/home/*`, `lib/unfree-allowlist.nix`, `flake.nix`, `hosts/template`, standalone `homeConfigurations`.
- **Assumptions**: Flatpak apps are installed imperatively by the user and live in `/var/lib/flatpak` (system) or `~/.local/share/flatpak` (user), outside the Nix store and outside Nix's unfree allowlist. The Flathub remote needs network access on first boot only.

## Non-goals

- Declaratively managing the list of installed Flatpak apps (for example with `nix-flatpak`); that can be a later change if wanted.
- Flatpak on standalone, non-NixOS home-manager activations (those systems have their own system package manager for Flatpak itself).
- Adding other remotes (Flathub beta, GNOME nightly) or GNOME Software integration.
