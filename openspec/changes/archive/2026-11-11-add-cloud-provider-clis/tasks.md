# Tasks

## 1. Packages

- [x] 1.1 Add `google-cloud-sdk`, `google-cloud-sql-proxy` and `ssm-session-manager-plugin` to the `with pkgs;` list in `modules/home/dev-tools.nix` beside `awscli2`, and add `azure-cli.withExtensions [ azure-cli.extensions.bastion ]` (via `pkgs.azure-cli`); verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'ps: map (n: builtins.any (p: (p.pname or "") == n) ps) ["awscli2" "azure-cli" "google-cloud-sdk" "google-cloud-sql-proxy" "ssm-session-manager-plugin"]'` prints all `true` (adjust the `azure-cli` match to the wrapped package's name if `withExtensions` changes `pname`)
- [x] 1.2 Verify the same eval against `.#homeConfigurations."tom@darwin"` prints all `true`
- [x] 1.3 Bump `flake.lock` (`nix flake update`) because `azure-cli` is unbuildable on the previously pinned nixpkgs (its `python3.14-fabric` dependency was marked broken); verify `nix flake check` and the host build pass

## 2. Integration

- [x] 2.1 Run `nix fmt modules/home/dev-tools.nix` and `nix flake check`; verify both pass and `git status` shows only intended files
- [x] 2.2 Build the NixOS host (`nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link`); verify it succeeds
- [x] 2.3 Verified against the built system closure's tom profile (`etc/profiles/per-user/tom/bin`) instead of after a live switch: verify `aws --version`, `az version`, `gcloud --version`, `cloud-sql-proxy --version` and `session-manager-plugin --version` all succeed, and `az network bastion tunnel --help` runs without prompting for an extension install
- [x] 2.4 Run `nix run nixpkgs#openspec -- validate add-cloud-provider-clis`; verify it reports the change as valid

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
