# Proposal

## Why

`toms-thinkpad` has a fingerprint sensor, but nothing in the flake enables fingerprint support, so the reader is unusable for login, the lock screen or `sudo`.

## What Changes

- Set `services.fprintd.enable = true` in `hosts/toms-thinkpad/configuration.nix`. The NixOS module then installs `fprintd` and adds fingerprint auth to PAM services (login, GDM, sudo).
- Document enrollment (`fprintd-enroll`) next to the setting.
- **BREAKING**: none. Other hosts are unchanged.

## Capabilities

### New Capabilities
- `fingerprint-authentication`: per-host fingerprint reader support through fprintd.

### Modified Capabilities
(none)

## Impact

- **Affected code**: `hosts/toms-thinkpad/configuration.nix` only.
- **Not affected**: `modules/nixos/common.nix`, `hosts/template`, `lib/mkNixos.nix`, `lib/unfree-allowlist.nix` (the default `fprintd` driver is free software).

## Non-goals

- Enabling fingerprint support on every host; not all machines have a reader, so this stays per-host rather than in `common.nix`.
- Shared option wrapper module; one line of host config does not justify one.
- Proprietary or `tod` drivers. The sensor model is unverified (`lsusb` showed no match from the current session); if the default driver does not detect it, a follow-up change will add the matching `services.fprintd.tod` driver.
- Enrolling fingerprints declaratively; enrollment is a per-user runtime step.
