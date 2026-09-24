## 1. Ghostty and GNOME Tweaks packages

- [x] 1.1 Add `pkgs.ghostty` to `crossPlatformApps` in `modules/home/desktop-apps.nix` and verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` includes it while `nix eval '.#homeConfigurations."tom@darwin".config.home.packages'` does not (nixpkgs currently has no Darwin build).
- [x] 1.2 Add `osConfig ? null` to `modules/home/desktop-apps.nix`'s function arguments, and add `pkgs.gnome-tweaks` via `lib.optional (osConfig.services.desktopManager.gnome.enable or false) pkgs.gnome-tweaks` (kept separate from `linuxOnlyApps`, which stays `teams-for-linux`-only). Verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` excludes `gnome-tweaks` (standalone, no `osConfig`), while `nix eval '.#nixosConfigurations.test-vm.config.home-manager.users.tom.home.packages'` includes it (NixOS host, GNOME enabled).
- [x] 1.3 Build both home configurations end to end (`nix build '.#homeConfigurations."tom@linux".activationPackage'` and `.../"tom@darwin".activationPackage`) and verify both evaluate and build successfully with no unfree-allowlist errors.

## 2. GNOME dark-mode default

- [x] 2.1 Add `programs.dconf.enable = true;` and `programs.dconf.profiles.user.databases = [ { settings."org/gnome/desktop/interface".color-scheme = "prefer-dark"; } ];` to `modules/nixos/common.nix`, alongside the existing `services.desktopManager.gnome.enable = true;`.
- [x] 2.2 Build a NixOS host from this flake (`nix build '.#nixosConfigurations.<hostname>.config.system.build.toplevel'` for an existing host, e.g. `test-vm`) and verify the build succeeds.
- [x] 2.3 On a booted host (or a VM built from it), verify a fresh user session (no prior `color-scheme` set in that user's own dconf database) starts in dark mode, and that switching to light mode from GNOME Settings' Appearance page still works and persists across a re-login.

## 3. Spec sync

- [x] 3.1 Verify `openspec validate --change add-ghostty-gnome-tweaks-dark-mode --strict` passes once the above are implemented, confirming the delta specs match the shipped behavior.
