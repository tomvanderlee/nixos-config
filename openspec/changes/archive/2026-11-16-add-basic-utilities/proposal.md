# Proposal

## Why

The profile provisions developer tooling but not the everyday diagnostics expected on any workstation: there is no `dig`, `nslookup`, `traceroute`, `lsof` or `strace`. Debugging DNS, connectivity or a misbehaving process currently needs an ad-hoc `nix shell`. `openspec`, used on this repo's own changes, is also not installed and has to be fetched each time.

## What Changes

- Add a shared home-manager module of portable network and file/archive utilities (DNS lookups, whois, nmap, mtr, netcat, curl, wget, rsync, zip/unzip/7z, file, ncdu, watch, less).
- Add Linux system-diagnostic utilities (tcpdump, traceroute, lsof, strace, psmisc, pciutils, usbutils, iotop, ethtool) system-wide on every NixOS host.
- Add the `openspec` CLI to the developer tools in the shared home profile.
- No privilege wrappers: tools needing raw sockets or capabilities (tcpdump, nmap scans, mtr) are run with `sudo`.

## Capabilities

### New Capabilities

### Modified Capabilities
- `developer-environment`: adds requirements for basic network/file utilities in the home profile, system diagnostics on NixOS hosts, and the `openspec` CLI.

## Impact

- `modules/home/network-tools.nix` (new) and `modules/home/default.nix` (import).
- `modules/home/dev-tools.nix` (add `openspec`).
- `modules/nixos/common.nix` (new `environment.systemPackages`).
- All packages are free software; `lib/unfree-allowlist.nix` is unchanged. No services, ports or users are affected.

## Non-goals

- Setuid/capability wrappers (`security.wrappers`, `programs.mtr`) and Wireshark.
- Any daemon or service configuration.
