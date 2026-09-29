## 1. Module enablement

- [x] 1.1 Add `programs.nh.enable = true;` to `modules/home/dev-tools.nix`
- [x] 1.2 Verify `nix eval '.#homeConfigurations."tom@linux".config.programs.nh.enable'` and `nix eval '.#homeConfigurations."tom@darwin".config.programs.nh.enable'` both return `true`
- [x] 1.3 Verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` and `nix eval '.#homeConfigurations."tom@darwin".config.home.packages'` each include the `nh` derivation

## 2. Verification

- [x] 2.1 Run `nix flake check` and confirm it passes
- [x] 2.2 Run `nix build '.#homeConfigurations."tom@linux".activationPackage'` and `nix build '.#homeConfigurations."tom@darwin".activationPackage'` (or `--dry-run` if this machine can't natively build one of the two targets) and confirm both resolve without evaluation errors
- [x] 2.3 Run `nix fmt` and confirm `modules/home/dev-tools.nix` is formatted with no diff
