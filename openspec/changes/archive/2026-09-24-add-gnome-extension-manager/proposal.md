## Why

Tom wants the GNOME Shell Extension Manager app ([mjakeman/extension-manager](https://github.com/mjakeman/extension-manager)) available for managing GNOME Shell extensions through a GUI, on NixOS hosts that run GNOME.

## What Changes

- Add `pkgs.gnome-extension-manager` to `modules/home/desktop-apps.nix`. Verified against the flake's pinned `nixos-unstable` nixpkgs: the attribute is named `gnome-extension-manager` (not `extension-manager`) and its `meta.homepage` is exactly `https://github.com/mjakeman/extension-manager`, confirming it's the same project; GPL-3.0-or-later license, Linux-only `meta.platforms`.
- Scoped the same way as GNOME Tweaks (added in `add-ghostty-gnome-tweaks-dark-mode`, already archived): gated on `(osConfig.services.desktopManager.gnome.enable or false)`, not on `pkgs.stdenv.hostPlatform.isLinux`. Extension Manager only makes sense where GNOME Shell is actually running — it's a management UI for GNOME Shell extensions — and `modules/home/desktop-apps.nix` is shared by both every NixOS host (GNOME force-enabled) and the standalone, non-NixOS `homeConfigurations."tom@linux"`, which has no GNOME involved. `osConfig ? null` is already present on the module's function signature from the prior change, so no further signature change is needed.
- **BREAKING**: none — additive only.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `desktop-applications`: add a requirement that GNOME Extension Manager is provisioned only where GNOME is enabled, following the same pattern and wording style as the existing "GNOME Tweaks is provisioned only where GNOME is enabled" requirement.

## Impact

- **Affected code**: `modules/home/desktop-apps.nix` (add `pkgs.gnome-extension-manager` to the existing `gnomeOnlyApps` list, alongside `pkgs.gnome-tweaks`).
- **Not affected**: `lib/unfree-allowlist.nix` (free-licensed), `modules/nixos/common.nix` (GNOME is already enabled unconditionally for every NixOS host; no further system-level change needed).
- **Dependencies**: nixpkgs' `gnome-extension-manager` package (already present in the pinned `nixos-unstable` input; no new flake inputs).
- **Platforms**: Linux-only in nixpkgs today, and further scoped to NixOS hosts with GNOME enabled via `osConfig` — it will not appear on `tom@darwin`, on the standalone `tom@linux` homeConfiguration, or on a hypothetical future NixOS host that disables GNOME.
