# Design

## Context

Hosts layer on `modules/nixos/common.nix`; `lib/mkNixos.nix` assembles shared modules, and option-gated modules such as `development.postgresql.enable` are the established pattern. `nixos-generate-config` already emits `fileSystems` entries for mounted ZFS datasets into the host's `hardware-configuration.nix`.

## Goals / Non-Goals

**Goals:** make a ZFS host buildable with a required host ID, and prompt for one encrypted home dataset at boot. **Non-Goals:** see proposal.md.

## Decisions

- **Opt-in `storage.zfs.enable`** in a shared module imported by `lib/mkNixos.nix`, so non-ZFS hosts are untouched.
- **`hostId` typed `strMatching "[0-9a-f]{8}"` with no default**, so a ZFS host fails at evaluation, not at build or boot, if it is missing or malformed.
- **Boot-time unlock** via `boot.zfs.requestEncryptionCredentials = [ dataset ]`. Alternative: PAM unlock at login. Rejected because the `home-manager-tom` activation and the dotfiles clone need `/home/tom` mounted before login.
- **Encryption is by dataset name only**: pool creation, `keyformat`, `mountpoint=legacy` and the `fileSystems."/home"` entry stay outside the module.
- **Kernel not pinned**: `latestCompatibleLinuxPackages` no longer exists on `nixos-unstable`; compatibility is checked by the user at install time.

## Risks / Trade-offs

- [ZFS package may lack support for the default kernel] → Documented; user verifies the build before installing.
- [Only the home dataset is encrypted] → Accepted; swap, `/var` and `/nix` remain unencrypted.
- [Wrong dataset name makes boot prompt for nothing] → Name is the user's responsibility; verify after first boot.
