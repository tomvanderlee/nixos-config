# Design

## Context

Hardware-specific settings live in `hosts/<name>/configuration.nix`, layered on `modules/nixos/common.nix`, which already provides GDM.

## Goals / Non-Goals

**Goals:** make the ThinkPad's reader usable for login, lock screen and sudo. **Non-Goals:** see proposal.md.

## Decisions

- **Set `services.fprintd.enable` directly in the host file** rather than adding a shared option: it is a single line, and only machines with a reader want it.
- **Default driver first.** `services.fprintd.tod` is added only if `fprintd-enroll` reports no device, because the sensor model is unverified.
- **Keep default PAM integration.** fprintd's NixOS module enables fingerprint for login/GDM/sudo; per-service opt-outs via `security.pam.services.<name>.fprintAuth = false` are deferred until wanted.

## Risks / Trade-offs

- [Sensor unsupported by default driver] → Check `lsusb`; follow-up change adds the `tod` driver.
- [GDM login with fingerprint does not unlock the keyring] → Accepted; password is still required after boot, which also unlocks the encrypted ZFS home.
