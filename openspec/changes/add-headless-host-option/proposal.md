# Proposal

## Why

Every NixOS host built from this flake unconditionally enables GNOME, GDM, audio and printing, and the shared home profile installs GUI apps. Tom wants to install NixOS in a VM with no graphics display, where that stack is wasted closure size, boot time and attack surface.

## What Changes

- Add a NixOS option `desktop.enable` (default `true`, so existing hosts are unchanged) in a new `modules/nixos/desktop.nix`. The GNOME/GDM/X server, dconf dark-mode default, PipeWire/rtkit, and CUPS/Avahi settings move out of `modules/nixos/common.nix` into this module, gated on the option.
- Add a home-manager option `home.desktop.enable` that defaults to the NixOS `desktop.enable` value when running under a NixOS host (via `osConfig`) and to `true` otherwise. When false, `modules/home/desktop-apps.nix` installs no GUI applications.
- Add a `--headless` flag to `scripts/bootstrap-host.sh` that writes `desktop.enable = false;` into the new host's `configuration.nix` (from a commented placeholder in `hosts/template/configuration.nix`).
- Update `README.md` for the new option and flag.
- **BREAKING**: none. The default keeps current behaviour.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `gnome-desktop`: the desktop stack becomes conditional on `desktop.enable` (default on); adds the option requirement. Dark mode, audio and printing requirements apply only when the desktop is enabled.
- `desktop-applications`: GUI apps are provisioned only when the desktop is enabled.
- `nix-flake-bootstrap`: host creation script gains `--headless`.

## Impact

- **Affected code**: `modules/nixos/common.nix` (desktop parts moved out), new `modules/nixos/desktop.nix`, `lib/mkNixos.nix` (import it), `modules/home/desktop-apps.nix`, `hosts/template/configuration.nix`, `scripts/bootstrap-host.sh`, `README.md`.
- **Not affected**: `hosts/test-vm` (keeps the default and its graphical VM settings), `lib/unfree-allowlist.nix`, `modules/home/dotfiles.nix`.
- **Assumptions**: `networking.networkmanager`, `automatic-timezoned`, sshd, Docker and nix-ld stay enabled on headless hosts; NetworkManager keeps a headless VM reachable without extra network setup, and the rest are not desktop features. Fonts (`modules/home/fonts.nix`) are left alone since they are small and also useful for terminals over SSH.
- **Non-goals**: a per-package opt-out, a headless profile for standalone Linux beyond the `home.desktop.enable` option, and removing `hardware.graphics` or VM-guest settings from existing hosts.
