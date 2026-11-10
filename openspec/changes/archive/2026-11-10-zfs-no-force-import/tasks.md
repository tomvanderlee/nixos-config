# Tasks

## 1. Import behavior

- [x] 1.1 Add `boot.zfs.forceImportRoot = lib.mkDefault false;` with an explanatory comment to the `storage.zfs.enable` block in `modules/nixos/zfs.nix`; verify `nix eval '.#nixosConfigurations.toms-thinkpad.config.boot.zfs.forceImportRoot'` prints `false`
- [x] 1.2 Verify the warning is gone (building the toplevel prints no `forceImportRoot` text), a host overriding it to `true` still evaluates to `true` (via `extendModules`), and that the setting sits inside the `storage.zfs.enable` block so non-ZFS hosts are unaffected (checked structurally; no non-ZFS host exists to evaluate)
- [x] 1.3 Run `nixfmt --check modules/nixos/zfs.nix` and `nix flake check`; verify both pass

## 2. Documentation

- [x] 2.1 Update the `zfs.nix` description in `README.md` to mention the non-forced import and the override; verify the README text matches the module

## Workflow follow-up

- Reboot after the switch and confirm the pool imports (`zpool status`) before archiving.
