# Tasks

## 1. Module

- [x] 1.1 Create `modules/nixos/zfs.nix` with `storage.zfs.enable`, `storage.zfs.hostId` and `storage.zfs.encryptedHome.dataset` implementing the spec; import it in `lib/mkNixos.nix`
- [x] 1.2 Verify with a throwaway host (removed afterwards) that `networking.hostId` is `8425e349` and `boot.zfs.requestEncryptionCredentials` is `[ "rpool/home" ]`, and that `test-vm` still has only ext4/vfat in `boot.supportedFilesystems`

## 2. Docs and checks

- [x] 2.1 Document `storage.zfs.*` in `README.md`
- [x] 2.2 Run `nix fmt` and `nix flake check`; verify both pass and `git status` shows only intended files
  - Note: `nix flake check` passes. `nix fmt` prints a bare-invocation `nixfmt` stdin parse error that also occurs without this change; `modules/nixos/zfs.nix` passes `nixfmt --check`.

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
