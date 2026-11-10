# Design

## Context

`modules/nixos/zfs.nix` already requires a per-host `hostId` and applies it as `networking.hostId`. NixOS 26.11 changes the default of `boot.zfs.forceImportRoot` from `true` to `false` and warns while the old default is in effect. `toms-thinkpad` boots from `zpool` (root and home datasets) and its pool host ID matches `850edb9e` (`hostid` and `networking.hostId` agree). See proposal.md for motivation and risk.

## Goals / Non-Goals

**Goals:**
- Adopt the safe 26.11 default now and remove the warning.

**Non-Goals:**
- Changing import behavior beyond the root pool.

## Decisions

- **`boot.zfs.forceImportRoot = lib.mkDefault false` inside the `storage.zfs.enable` block of `zfs.nix`.** The module already owns the host ID that makes a non-forced import work, so the safe setting lives next to it and applies to every ZFS host. `mkDefault` lets a host that needs `true` override it without `mkForce`. Alternatives: set `false` in `hosts/toms-thinkpad/configuration.nix` (rejected: leaves future ZFS hosts with the warning and the risky default), or set `true` explicitly to silence the warning (rejected: keeps the data-loss risk the warning is about).
- **No change to `forceImportAll`**: it already defaults to `false`.
- **Verification relies on the evaluated option and an absent warning**, since the first real test is a boot. The previous generation remains selectable as the rollback.

## Risks / Trade-offs

- [Boot fails to import the pool if its last owner had a different host ID] → The pool's host ID was confirmed to match; older generations (force on) stay in the boot menu; `zfs_force=1` on the kernel command line forces one boot.
- [A later host reuses a cloned disk] → That host sets `boot.zfs.forceImportRoot = true` temporarily or exports the pool first; documented in the spec scenario.

## Migration Plan

Switch, then reboot (already pending for the locale and login fixes). If the pool fails to import, pick the previous generation in the boot menu and revert the commit. Rollback: revert and switch again.
