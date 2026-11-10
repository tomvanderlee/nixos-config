# Design

## Context

GUI apps come from `modules/home/desktop-apps.nix` (`crossPlatformApps`, `linuxOnlyApps`, `gnomeOnlyApps`, filtered by `availableOn`, gated by `home.desktop.enable`). Audio and the other desktop services live in `modules/nixos/desktop.nix` behind `desktop.enable`. `nixpkgs#librepods` is the Qt6 app from upstream's `linux/` directory and sets no `meta.platforms`.

## Goals / Non-Goals

**Goals:**
- AirPods noise control, conversational awareness, battery and ear detection work on the laptop after a switch.
- Tap gestures control media playback.

**Non-Goals:**
- Hearing-aid mode, tray extension and autostart (see proposal).

## Decisions

- **Package from nixpkgs, in the home profile.** It is a per-user GUI app, so it sits with the other apps and inherits the `home.desktop.enable` gate. Alternatives: a system package (would ignore the per-user profile split) or the upstream AppImage (not declarative).
- **Add it to `linuxOnlyApps`.** The package declares no platforms, so `availableOn` would keep it on macOS where it cannot work (BlueZ and Qt Bluetooth). `linuxOnlyApps` already holds teams-for-linux for the same reason.
- **Dummy AVRCP via `services.pipewire.wireplumber.extraConfig` in `desktop.nix`.** This is the declarative form of the `~/.config/wireplumber/wireplumber.conf.d/51-bluez-avrcp.conf` file from the upstream README, system-wide instead of in the user's home. It is a PipeWire-stack setting, so it belongs with the desktop audio config and is automatically absent on headless hosts. The upstream README warns not to run `mpris-proxy` alongside it; this repo does not.
- **Plain (not `mkDefault`) value.** Nothing else sets it.

## Risks / Trade-offs

- [GNOME has no system tray, and the app is driven from a tray icon] → The app's window can still be launched from the menu; if the tray proves unusable, a follow-up can add the AppIndicator extension.
- [The package is the upstream "old version"; upstream is rewriting in Rust] → Accepted; switch to the new package when nixpkgs ships it.
- [Dummy AVRCP applies to all Bluetooth devices] → It only adds a placeholder media player so button events are accepted; low impact.
- [Unverified on hardware: build success does not prove AirPods features work] → Manual check after switching (open the app with AirPods connected).
