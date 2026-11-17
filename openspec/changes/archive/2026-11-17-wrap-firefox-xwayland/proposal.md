# Proposal

## Why

On Firefox 159.0.1 and 160.0 running natively on Wayland under GNOME (NixOS 26.11, Intel Arrow Lake, Mesa 26.3.0, three monitors, one at 1.25x scale), the browser crashed twice (crash-stats `bp-8b235d02-d79e-41ce-b5c5-055020261117` and `bp-e1ce58c1-f6b5-4201-88c7-c31c10261117`). It also stalled repeatedly: the window stops repainting while audio and input keep working (seen on YouTube Shorts, and as a black GeoFS canvas). Running Firefox through XWayland fixed both symptoms.

## What Changes

- Wrap `pkgs.firefox` in `modules/home/desktop-apps.nix` so `firefox` launches with `MOZ_ENABLE_WAYLAND=0`, using the same `symlinkJoin` + `makeWrapper` pattern as the existing `nextcloud-client` wrapper.
- Use the wrapped package in `crossPlatformApps` in place of `pkgs.firefox`.
- Record in the design how to revert once upstream fixes the Wayland path.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `desktop-applications`: Firefox is provisioned so that it runs through XWayland rather than the native Wayland backend.

## Impact

- **Affected code**: `modules/home/desktop-apps.nix` only.
- **Not affected**: `lib/unfree-allowlist.nix` (Firefox is free), `flake.nix`, `hosts/*`, `modules/nixos/*`, and the `desktop.enable` / platform filtering of the app list.
- **Assumptions**:
  - The wrapper applies on every platform that gets the shared profile. On macOS the variable is harmless, since Firefox does not use it there.
  - The Firefox profile and `about:config` prefs are untouched, so existing user settings keep working.
  - Observed with Firefox 159.0.1/160.0 only; the bug is not confirmed fixed in any later version.

## Non-goals

- No hardware-acceleration pref changes.
- No kernel, i915 or Mesa changes.
- No forcing or disabling of hardware video decode.
- No change to other browsers or apps' Wayland/X11 behaviour.
