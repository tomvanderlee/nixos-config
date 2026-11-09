# Design

## Context

nixpkgs builds `nextcloud-client` with `wrapQtAppsHook` and sets `qtWrapperArgs` only for `LD_LIBRARY_PATH` and `PATH`. Qt picks its GTK3 platform-theme file dialog under GNOME, and `org.gtk.Settings.FileChooser` is shipped by `gtk3`, which is not in the user session's `XDG_DATA_DIRS`. Observed crash and confirmation test are in proposal.md.

## Goals / Non-Goals

**Goals:**
- Folder chooser works regardless of session schema path, with no rebuild of the client.

**Non-Goals:**
- Session-wide environment changes, portal-based dialogs, other apps (see proposal).

## Decisions

- **`symlinkJoin` + `wrapProgram`** around `pkgs.nextcloud-client`, defined in `modules/home/desktop-apps.nix` and used in `crossPlatformApps` in place of the bare package. It prefixes `XDG_DATA_DIRS` with `${gtk3}/share/gsettings-schemas/${gtk3.name}` and `${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}`. Alternative: `overrideAttrs` adding to `qtWrapperArgs` (rejected: recompiles the Qt client, no cache hit). Alternative: install `gtk3` system-wide or set `XDG_DATA_DIRS` in the session (rejected: broad change for one app). Alternative: `QT_QPA_PLATFORMTHEME=xdgdesktopportal` (rejected: changes dialog behavior and depends on portal config).
- **Preserve platform filtering.** The wrapper derivation keeps `meta` of the original (`meta = nextcloud-client.meta;`) so `lib.meta.availableOn` still drops it on darwin and `mainProgram` stays `nextcloud`.
- **Keep the desktop entry.** `symlinkJoin` carries over `share/applications` and icons; `Exec=nextcloud` resolves through the profile PATH to the wrapped binary (verify in tasks).

## Risks / Trade-offs

- [Schema versions from `gtk3` could mismatch the GTK3 library the client loads] → Both come from the same nixpkgs revision; verified by opening the dialog on the host.
- [Double wrapping (the package's own Qt wrapper plus ours)] → Harmless; ours only adds `XDG_DATA_DIRS`.
- [Upstream nixpkgs may fix this later] → The wrapper is then redundant but harmless; remove it when `nixpkgs` carries the fix.
