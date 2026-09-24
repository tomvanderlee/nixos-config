## 1. GNOME Extension Manager package

- [x] 1.1 Add `pkgs.gnome-extension-manager` to the `gnomeOnlyApps` list in `modules/home/desktop-apps.nix` (alongside `pkgs.gnome-tweaks`).
- [x] 1.2 Verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` excludes `gnome-extension-manager` (standalone, no `osConfig`), while `nix eval '.#nixosConfigurations.test-vm.config.home-manager.users.tom.home.packages'` includes it (NixOS host, GNOME enabled).
- [x] 1.3 Build `nixosConfigurations.test-vm`'s system closure (`nix build '.#nixosConfigurations.test-vm.config.system.build.toplevel'`) and verify it succeeds.

## 2. Spec sync

- [x] 2.1 Verify `openspec validate --change add-gnome-extension-manager --strict` passes once the above are implemented, confirming the delta spec matches the shipped behavior.
