# Proposal

## Why

The Nextcloud desktop client provisioned by `add-nextcloud-client` aborts (SIGABRT) when the user adds a folder connection. Three core dumps on `toms-thinkpad` (13:57, 14:00, 14:01) all stop in `OCC::FolderWizardLocalPath::slotChooseLocalFolder`, the wizard's local-folder picker. The journal line just before the last crash reads `Settings schema 'org.gtk.Settings.FileChooser' is not installed`. Qt opens GTK3's native file dialog, and GLib aborts because the GTK3 schema is not in the session's `XDG_DATA_DIRS` (which carries GNOME and GTK4 schemas but not GTK3's). Launching the client with `gtk3`'s schema directory prepended fixed it, so the cause is confirmed. Logging out and back in does not help, because nothing puts that directory in the session.

## What Changes

- Wrap the client in `modules/home/desktop-apps.nix` (or a small package expression next to it) so its launcher always prefixes `XDG_DATA_DIRS` with the `gtk3` and `gsettings-desktop-schemas` schema directories. The wrap uses `symlinkJoin` plus `wrapProgram`, so the large Qt client is not rebuilt and stays binary-cached.
- Reopen `add-nextcloud-client` task 2.2 as unverified in the archived copy, since the earlier "it works" covered launch and sign-in only.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `desktop-applications`: the Nextcloud client must be able to open its folder chooser (and so add a sync folder) without crashing.

## Impact

- **Affected code**: `modules/home/desktop-apps.nix`; the archived `openspec/changes/archive/2026-11-09-add-nextcloud-client/tasks.md` (task 2.2 left unchecked).
- **Not affected**: `lib/unfree-allowlist.nix`, `flake.nix`, `modules/nixos/*`, `hosts/*`, `pkgs/`.
- **Assumptions**: the wrapped `nextcloud` on the profile PATH is what the app-menu entry (`Exec=nextcloud`) launches; both Linux and any future Linux host with GNOME behave the same. The fix is no-op where the schemas are already present.

## Non-goals

- Changing the system-wide `XDG_DATA_DIRS` or GNOME configuration.
- Forcing the xdg-desktop-portal file dialog (a larger behavior change than needed).
- Rebuilding `nextcloud-client` with `overrideAttrs` (slow, uncached).
- Wrapping other GUI apps preemptively.
