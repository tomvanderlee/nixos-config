# Proposal

## Why

Bitwarden desktop's "Unlock with system authentication" on Linux asks polkit to authenticate through the action `com.bitwarden.Bitwarden.unlock`, and polkit authenticates via PAM, where fprintd now provides the fingerprint. Verified on the current flake: `security.polkit.enable` is already `true` (pulled in by GNOME) and `security.pam.services.polkit-1.fprintAuth` is `true`, but Bitwarden is installed through home-manager (`modules/home/desktop-apps.nix`, landing in `/etc/profiles/per-user/tom`). The polkit daemon only reads policies from the system profile, so the `com.bitwarden.Bitwarden.policy` file shipped by `bitwarden-desktop` (confirmed present in `share/polkit-1/actions`) is never seen and the fingerprint unlock option cannot work.

## What Changes

- In `hosts/toms-thinkpad/configuration.nix`, set `security.polkit.enable = true` explicitly (already true through GNOME; stated so the dependency is visible) and add `pkgs.bitwarden-desktop` to `environment.systemPackages` so polkit finds Bitwarden's policy.
- Keep the home-manager `bitwarden-desktop` entry unchanged.
- After rebuilding, enable "Unlock with system authentication" in Bitwarden's settings (a per-user runtime step).
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `fingerprint-authentication`: add a requirement that the ThinkPad lets Bitwarden desktop authenticate via polkit and the fingerprint reader.

## Impact

- **Affected code**: `hosts/toms-thinkpad/configuration.nix` only.
- **Not affected**: `modules/home/desktop-apps.nix`, `modules/nixos/common.nix`, `lib/unfree-allowlist.nix` (`bitwarden-desktop` is GPL-3.0).

## Non-goals

- Moving Bitwarden out of home-manager or into `common.nix`; only machines with a reader need the system-level copy, and the duplicate store path costs nothing.
- Custom polkit rules (e.g. passwordless actions); only the stock Bitwarden policy is used.
- Browser extension biometrics, which depend on the desktop app's native-messaging integration and are not part of this change.
- Changing fingerprint use for sudo or GDM.
