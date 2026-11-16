# Design

## Context

Home packages are split by purpose across `modules/home/*.nix` (see `cli-tools.nix`, `dev-tools.nix`). Platform filtering uses `lib.meta.availableOn pkgs.stdenv.hostPlatform` (`modules/home/desktop-apps.nix`). `modules/nixos/common.nix` currently declares no `environment.systemPackages`. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Utilities work identically from standalone home-manager and NixOS hosts where the platform allows.
- Linux-only system diagnostics are available to root and all users on NixOS.

**Non-Goals:**
- Wrappers, services or per-host overrides.

## Decisions

- **Split by portability.** Portable tools (dnsutils, whois, nmap, mtr, netcat, curl, wget, rsync, zip, unzip, p7zip, file, ncdu, less, procps for `watch`) go in a new `modules/home/network-tools.nix`, filtered through `availableOn`. Linux-only diagnostics (tcpdump, traceroute, lsof, strace, psmisc, pciutils, usbutils, iotop, ethtool) go in `modules/nixos/common.nix` `environment.systemPackages`, so they exist for root and without home-manager. Alternative: all in home profile; rejected because the user chose system-wide availability for core diagnostics on NixOS.
- **Own module for utilities, not `cli-tools.nix`.** Keeps that file as the "modern replacement" toolset and gives the new capability a clear home.
- **`openspec` in `dev-tools.nix`.** It is a developer workflow tool (nixpkgs `openspec` 1.16.0).
- **No wrappers.** `sudo` suffices on a single-user workstation; avoids setuid surface.

## Risks / Trade-offs

- [`mtr`/`nmap` unprivileged limits] → documented; use `sudo`.
- [Duplicate binaries if a tool is in both home and system lists] → lists are disjoint by construction.
- [`openspec` may be unavailable or mispackaged on darwin] → pass through `availableOn` filter or confirm via `nix eval` for `tom@darwin`.
