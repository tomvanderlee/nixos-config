## 1. Package addition

- [x] 1.1 Add `kubernetes-helm` to the `with pkgs; [ ... ]` list in `modules/home/dev-tools.nix`, alongside `kubectl`
- [x] 1.2 Verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` and `nix eval '.#homeConfigurations."tom@darwin".config.home.packages'` each include the `kubernetes-helm` derivation

## 2. Verification

- [x] 2.1 Run `nix flake check` and confirm it passes
- [x] 2.2 Run `nix build '.#homeConfigurations."tom@linux".activationPackage'` and `nix build '.#homeConfigurations."tom@darwin".activationPackage'` and confirm both succeed (verified via `--dry-run`: this session's machine is aarch64-linux with no remote builders configured, so it cannot natively build either cross-platform target; `--dry-run` confirmed the full derivation graph, including `kubernetes-helm`, resolves without evaluation errors for both)
- [x] 2.3 Run `nix fmt` and confirm `modules/home/dev-tools.nix` is formatted with no diff
