# Proposal

## Why

A new NixOS host is being installed on ZFS (following the NixOS wiki ZFS guide), with only the home directory encrypted. The flake has no ZFS support: `networking.hostId` is mandatory for ZFS and nothing sets it, and there is no shared place to request the encrypted home dataset's passphrase at boot.

## What Changes

- Add `modules/nixos/zfs.nix` with an opt-in option `storage.zfs.enable` (default `false`). When enabled it sets `boot.supportedFilesystems = [ "zfs" ]`, `services.zfs.autoScrub.enable` and `services.zfs.trim.enable`.
- Add `storage.zfs.hostId` (8 lowercase hex characters, no default), written to `networking.hostId` when ZFS is enabled.
- Add `storage.zfs.encryptedHome.dataset` (nullable string, default `null`). When set, `boot.zfs.requestEncryptionCredentials = [ <dataset> ]` so the passphrase is requested during boot, before `/home` is mounted and before home-manager activation.
- Import the module from `lib/mkNixos.nix` and document it in `README.md`.
- **BREAKING**: none. Hosts that do not set the option are unchanged.

## Capabilities

### New Capabilities
- `zfs`: opt-in ZFS support with a required host ID and optional boot-time unlock of an encrypted home dataset.

### Modified Capabilities
(none)

## Impact

- **Affected code**: new `modules/nixos/zfs.nix`, `lib/mkNixos.nix`, `README.md`.
- **Not affected**: `hosts/template`, `hosts/test-vm`, `flake.nix`, `scripts/bootstrap-host.sh`, `lib/unfree-allowlist.nix` (ZFS is free software).

## Non-goals

- Pinning or selecting a kernel version compatible with the ZFS package.
- Creating pools or datasets; `fileSystems` entries stay in each host's `hardware-configuration.nix`.
- Changing `bootstrap-host` to generate the `storage.zfs` block or the host ID.
- Unlocking the home dataset at login via PAM.
- Encrypting anything other than the named dataset (swap, `/var`, root).
