# Proposal

## Why

Tom uses AirPods with the ThinkPad. Under Linux they pair as plain Bluetooth headphones, so noise control modes, conversational awareness, battery level and ear detection are unavailable. LibrePods (https://github.com/librepods-org/librepods) is a native Linux app that exposes these features, and nixpkgs already packages it.

## What Changes

- Add `pkgs.librepods` (nixpkgs, version 0.2.5, GPL-3.0, the Qt6 tray app plus the `librepods-ctl` CLI built from the `linux/` directory of the upstream repo) to the shared home profile in `modules/home/desktop-apps.nix`. It is Linux-only and, like the other GUI apps, follows `home.desktop.enable`.
- Enable WirePlumber's dummy AVRCP player (`bluez5.dummy-avrcp-player = true`) on desktop-enabled hosts in `modules/nixos/desktop.nix`. The upstream README lists this as required for AirPods tap gestures (play, pause, skip) to reach the media player under PipeWire.
- Update `README.md` with a short LibrePods section: what it provides, how to launch it, and the hearing-aid caveat.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `desktop-applications`: LibrePods is provisioned on Linux systems.
- `gnome-desktop`: desktop-enabled hosts forward Bluetooth media button events (AVRCP) to media players.

## Impact

- **Affected code**: `modules/home/desktop-apps.nix`, `modules/nixos/desktop.nix`, `README.md`.
- **Verified facts**: `nixpkgs#librepods` evaluates and is not broken or insecure; its license is free (GPL-3.0), so `lib/unfree-allowlist.nix` is untouched. The package sets no `meta.platforms`, so `availableOn` alone does not exclude macOS; the Linux-only gate is explicit. The `toms-thinkpad` host already has `hardware.bluetooth.enable = true` (GNOME enables it), and `services.pipewire.wireplumber.extraConfig` exists as an option.
- **Assumptions**: the nixpkgs build (the old Qt app, upstream's "old version") is what is wanted, rather than the upstream Rust rewrite, which is alpha and not packaged. Only the main app is provisioned.
- **Non-goals**: hearing-aid features (they need `DeviceID = bluetooth:004C:0000:0000` in the BlueZ config, an Apple-spoofing change that requires re-pairing, plus a Python script that nixpkgs does not install); a GNOME tray extension (per-user GNOME customization is out of scope in this repo); autostart of the app; installing the upstream AppImage or Android app.
