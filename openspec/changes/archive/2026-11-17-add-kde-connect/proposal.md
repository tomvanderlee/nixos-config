# Proposal

## Why

Tom wants to use his phone together with the desktop: shared clipboard (copy on one, paste on the other), plus the other things KDE Connect supports such as notification mirroring, file sending, and remote input. The hosts run GNOME, where the Qt `kdeconnect` daemon has no tray integration. GSConnect (`gnomeExtensions.gsconnect`, GPL-2.0-or-later, free) implements the same protocol as the phone's KDE Connect app and integrates natively with GNOME Shell and Files.

## What Changes

- Enable `programs.kdeconnect` in `modules/nixos/desktop.nix` with `package = pkgs.gnomeExtensions.gsconnect`. The upstream NixOS module installs the extension, opens TCP/UDP 1714-1764 in the firewall, and (as a side effect) enables `hardware.uinput` for the remote-input plugin.
- Enable the extension by default for users via the existing `programs.dconf.profiles.user.databases` default settings (`org/gnome/shell` `enabled-extensions` containing `gsconnect@andyholmes.github.io`).
- Add a short README note on pairing the phone.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `gnome-desktop`: the desktop stack provides phone integration through GSConnect, which is compatible with the KDE Connect Android/iOS apps.

## Impact

- **Affected code**: `modules/nixos/desktop.nix`, `README.md`.
- **Not affected**: `modules/home/*`, `lib/unfree-allowlist.nix` (package is free), `flake.nix`, `hosts/*`, headless hosts (`desktop.enable = false`).
- **Assumptions** (no clarification needed, recorded here):
  - "KDE Connect" means the KDE Connect protocol and phone app. GSConnect is the GNOME-side implementation, not the KDE `kdeconnect-kde` daemon.
  - Pairing is manual and per device; no device IDs or certificates are stored in the repository.
  - The extension is enabled by default but the user can still turn it off in Extensions, since it is set as a dconf default, not a lock.
  - The extension must come from nixpkgs, not extensions.gnome.org: the upstream copy's daemon (`#!/usr/bin/env -S gjs -m`) needs `gjs` and GTK3 typelibs that only the Nix package wires up, and otherwise fails with "The name is not activatable".
- **Security note**: ports 1714-1764 are opened to the LAN on every desktop host. GSConnect only accepts connections from devices paired through an explicit confirmation on both ends.

## Non-goals

- Standalone home-manager / non-NixOS / macOS support (GNOME and the firewall are NixOS-level here).
- Declarative device pairing or trusted-device lists.
- The Qt `kdeconnect-kde` daemon or KDE Plasma.
- Configuring individual GSConnect plugins beyond their defaults.
