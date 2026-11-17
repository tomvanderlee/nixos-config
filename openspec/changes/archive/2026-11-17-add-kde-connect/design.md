# Design

## Context

`modules/nixos/desktop.nix` holds the whole GNOME stack inside `lib.mkIf config.desktop.enable`, including a `programs.dconf.profiles.user.databases` entry that sets defaults (currently only dark mode). The firewall is otherwise closed except SSH and Avahi. nixpkgs' `programs.kdeconnect` module takes a `package` option and documents `gnomeExtensions.gsconnect` as the GNOME alternative; the module installs the package, opens TCP/UDP 1714-1764, and sets `hardware.uinput.enable` (mkDefault) for the remote-input plugin.

## Goals / Non-Goals

**Goals:**
- Phone clipboard sharing and companion features working after one pairing, on every desktop host.
- Extension enabled by default without manual Extension Manager steps.

**Non-Goals:**
- Anything for non-NixOS or macOS profiles.
- Managing paired devices or GSConnect plugin settings declaratively.

## Decisions

- **GSConnect over the Qt `kdeconnect-kde` daemon.** GSConnect speaks the same protocol, so the phone app is identical, and it integrates with GNOME Shell and Files. The Qt daemon has no GNOME tray or indicator. Alternative: the Qt daemon plus an AppIndicator extension, which adds more moving parts for a worse result.
- **`programs.kdeconnect` with `package = pkgs.gnomeExtensions.gsconnect`, inside the existing `mkIf config.desktop.enable` block.** Reuses the upstream module for firewall and uinput instead of hand-written rules, and headless hosts are excluded automatically. Alternative: `environment.systemPackages` plus manual firewall ranges, which duplicates the module.
- **The nixpkgs package, not an extensions.gnome.org install.** The upstream extension's daemon starts through D-Bus activation of `daemon.js` (`#!/usr/bin/env -S gjs -m`), which needs `gjs` on PATH and the GTK3 typelibs (`Gdk-3.0` etc.). On NixOS neither is available to a user-installed copy, so the service is "not activatable" and the host never answers discovery. The nixpkgs package wraps the daemon with the right environment. A copy under `~/.local/share/gnome-shell/extensions` also shadows the packaged one and must be removed.
- **Enable the extension through the existing dconf user database**, adding `settings."org/gnome/shell".enabled-extensions = [ "gsconnect@andyholmes.github.io" ]`. It is a default, not a lock, consistent with how dark mode is handled. A user-level `enabled-extensions` value (for example one written by Extension Manager, which is installed) overrides this default, so the extension may need a one-time toggle; the README documents that.
- **NixOS level, not home-manager.** The firewall and the GNOME extension install path are system concerns, and the shared home profile is also used on hosts without GNOME.

## Risks / Trade-offs

- [LAN exposure on ports 1714-1764] → Only paired (mutually confirmed, TLS-pinned) devices are accepted. Not opened on headless hosts.
- [User-level `enabled-extensions` shadows the dconf default] → README notes toggling GSConnect on once in Extension Manager.
- [A browser-installed copy shadows the packaged extension and cannot start its daemon] → README warns against it and gives the removal command.
- [`hardware.uinput.enable` is turned on as a side effect] → Upstream module default, needed for remote input; accepted.
- [GNOME major-version bumps can break the extension until nixpkgs updates it] → Accepted; fixed by a flake update.
