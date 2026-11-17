# Design

## Context

`modules/home/desktop-apps.nix` already wraps `nextcloud-client` with `pkgs.symlinkJoin` + `makeWrapper`, so a large binary-cached package keeps its cache hit while gaining an environment tweak. Firefox in nixpkgs is itself a `wrapFirefox` result, so its `bin/firefox` is a wrapper script. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Force XWayland for Firefox with no rebuild of Firefox itself.
- Keep the existing app-list structure and platform/desktop filtering.

**Non-Goals:**
- Any graphics, GPU or media pref changes (see proposal Non-goals).

## Decisions

- **Wrap with `symlinkJoin` + `wrapProgram ... --set MOZ_ENABLE_WAYLAND 0`**, mirroring `nextcloud-client`. `--set` (not `--set-default`) so the value wins even if the inner nixpkgs wrapper or the session sets `MOZ_ENABLE_WAYLAND=1`. Alternatives: `overrideAttrs` or a `wrapFirefox` override would rebuild or re-wrap Firefox; `programs.firefox` in home-manager would introduce a second way to manage the browser and its profile. A session-wide `MOZ_ENABLE_WAYLAND=0` via `home.sessionVariables` would be inherited by every child process and only apply to new login sessions.
- **Wrap only `bin/firefox`**, and `inherit (pkgs.firefox) meta` so `mainProgram`, license and platforms still drive `availableOn` filtering.
- **Desktop entry**: `symlinkJoin` links `share/applications/firefox.desktop` from the original. If its `Exec` resolves to the unwrapped store path rather than `firefox` on `PATH`, menu launches would bypass the wrapper; the apply tasks verify this and fix it if needed.
- **System integration is preserved by construction.** `symlinkJoin` over the `wrapFirefox` output keeps `lib/mozilla/native-messaging-hosts`, and only the outer `bin/firefox` is re-wrapped, so the inner wrapper (with its `MOZ_SYSTEM_DIR`) still runs and host lookup is unchanged. No hosts are configured in this repo today (no Bitwarden or GNOME connector wiring), so this change adds none. To enable them later, pass `nativeMessagingHosts` through an override on `pkgs.firefox` *before* wrapping (e.g. `pkgs.firefox.override { nativeMessagingHosts = [ ... ]; }`), or use home-manager `programs.firefox` with `package = <wrapper>` and no profiles declared, in a separate change.

**Revert**: once a Firefox release fixes the Wayland stall/crash, delete the wrapper binding and put `pkgs.firefox` back in `crossPlatformApps`. Test by launching with `MOZ_ENABLE_WAYLAND=1 firefox` first (about:support should show `wayland`), then play YouTube Shorts and GeoFS for a while.

## Risks / Trade-offs

- [XWayland loses native-Wayland niceties (fractional-scale sharpness on the 1.25x monitor, touchpad gestures, per-monitor scaling)] → Accepted; the workaround is explicitly temporary.
- [Wrapper bypassed by the desktop entry] → Verify the menu launch shows `x11` in about:support; adjust the desktop file if not.
- [Wrapper keeps applying after upstream is fixed] → The revert note above, plus the spec requirement being removed in the revert change.
- [Outer wrapper shadows the inner `MOZ_SYSTEM_DIR` and breaks native-messaging lookup] → The outer wrapper sets only `MOZ_ENABLE_WAYLAND`; task 1.3 verifies the hosts directory and variable are intact.
