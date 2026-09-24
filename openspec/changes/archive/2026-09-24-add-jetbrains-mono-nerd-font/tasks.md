## 1. Font module

- [x] 1.1 Create `modules/home/fonts.nix` provisioning `pkgs.nerd-fonts.jetbrains-mono` via `home.packages`, filtered through `lib.meta.availableOn pkgs.stdenv.hostPlatform` (same pattern as `modules/home/desktop-apps.nix`), and setting `fonts.fontconfig.enable = true;`
- [x] 1.2 Import `./fonts.nix` in `modules/home/default.nix` and verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` and `nix eval '.#homeConfigurations."tom@darwin".config.home.packages'` each include the nerd font derivation

## 2. Verification

- [x] 2.1 Run `nix flake check` and confirm it passes
- [x] 2.2 Run `nix build '.#homeConfigurations."tom@linux".activationPackage'` and `nix build '.#homeConfigurations."tom@darwin".activationPackage'` and confirm both succeed (verified via `--dry-run`: this session's machine is aarch64-linux with no remote builders configured, so it cannot natively build either target; `--dry-run` confirmed the full derivation graph, including the new font package, resolves without evaluation errors for both)
- [x] 2.3 Run `nix fmt` and confirm `modules/home/fonts.nix` is formatted with no diff
