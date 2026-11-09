# Proposal

## Why

Tom uses Nextcloud and wants the desktop sync client available on every desktop machine provisioned from this flake, the same way Slack, Firefox and the other GUI apps are. nixpkgs packages it as `nextcloud-client` ("Desktop sync client for Nextcloud", GPL-2.0-or-later, free).

## What Changes

- Add `pkgs.nextcloud-client` to the candidate GUI app list in `modules/home/desktop-apps.nix`, so it is provisioned wherever the shared home profile is activated and the package is supported. Its `meta.platforms` is Linux only, so the existing `lib.meta.availableOn` filter drops it silently on macOS.
- Add a short README note on first-run sign-in and autostart.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `desktop-applications`: the Nextcloud desktop sync client joins the provisioned GUI applications.

## Impact

- **Affected code**: `modules/home/desktop-apps.nix`, `README.md`.
- **Not affected**: `lib/unfree-allowlist.nix` (the package is free), `flake.nix`, `modules/nixos/*`, `hosts/*`, `pkgs/`.
- **Assumptions** (no clarification needed, recorded here):
  - "Nextcloud client" means the desktop sync client (`nextcloud-client`), not a server, a CLI-only `nextcloudcmd`, or GNOME Online Accounts integration.
  - Account setup is manual. The server URL and credentials are not stored in this repository; the client keeps its login in the GNOME keyring, which every host already has.
  - The client's own "Launch on system startup" setting handles autostart.

## Non-goals

- Declarative account or sync-folder configuration (it would require storing a server URL and app password; the client has no supported declarative account config).
- Home-manager `services.nextcloud-client` autostart, to avoid coupling with the in-flight `add-headless-host-option` gating and the missing GNOME tray.
- GNOME Files / Online Accounts integration, and Nextcloud server hosting.
