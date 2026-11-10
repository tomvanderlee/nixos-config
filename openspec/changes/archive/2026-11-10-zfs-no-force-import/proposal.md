# Proposal

## Why

Every build of `toms-thinkpad` prints the evaluation warning: "`boot.zfs.forceImportRoot` is using the default value of `true`. It is highly recommended to set it to `false`, the new default from 26.11 on, to reduce the risk of data loss." With `true`, the initrd imports the root pool with `zpool import -f`, which overrides ZFS's safeguard against importing a pool that another system may still have imported. The host sets a stable `networking.hostId` (`850edb9e`), and the running pool already carries that host ID (`hostid` prints `850edb9e`), so the force flag is not needed.

## What Changes

- In the shared ZFS module (`modules/nixos/zfs.nix`), set `boot.zfs.forceImportRoot = lib.mkDefault false` when `storage.zfs.enable` is on, so the pool is imported without `-f`.
- Add one requirement to the `zfs` capability stating that the root pool is not force-imported, and that a host can still opt back in.
- **BREAKING**: none for `toms-thinkpad`. It only changes behavior for a ZFS host whose pool was last imported under a different host ID (see Risk).

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `zfs`: adds the requirement that ZFS hosts import their root pool without forcing, overridable per host.

## Impact

- **Affected code**: `modules/nixos/zfs.nix`.
- **Not affected**: `hosts/toms-thinkpad/*` (no per-host line needed), `hardware-configuration.nix`, `boot.zfs.forceImportAll` (already `false`), scrub/trim/encryption settings.
- **Risk**: If the pool was last imported by a system with a different host ID (for example after cloning the disk, or importing it from a live ISO without exporting), the next boot fails to import it. Mitigations: the previous generation stays in the boot menu, which still force-imports; the kernel option `zfs_force=1` forces a single boot; and `zpool import -f` from a live ISO repairs it. The current pool's host ID matches `networking.hostId`, so this does not apply on the first boot after the switch.
- **Assumptions**: The default applies to all ZFS hosts through `mkDefault`, so a host that needs the old behavior sets `boot.zfs.forceImportRoot = true`. Placing it in `zfs.nix` (not the host file) keeps the safer value with the module that already requires `hostId`.

## Non-goals

- Changing `boot.zfs.forceImportAll`, pool layout, or encryption settings.
- Removing or relocating other evaluation warnings.
