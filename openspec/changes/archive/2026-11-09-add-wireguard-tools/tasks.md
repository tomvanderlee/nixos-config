# Tasks

## 1. Package

- [x] 1.1 Add `wireguard-tools` to the `with pkgs;` list in `modules/home/dev-tools.nix`; verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'ps: builtins.any (p: (p.pname or "") == "wireguard-tools") ps'` prints `true`
- [x] 1.2 Verify the package is available on all four target systems: `nix eval --json nixpkgs#wireguard-tools.meta.platforms` covers every system with a home or NixOS output in this flake (x86_64-linux, aarch64-linux, aarch64-darwin); x86_64-darwin is absent from nixpkgs but has no output here, recorded in design.md
- [x] 1.3 Verify `nix eval '.#homeConfigurations."tom@darwin".config.home.packages' --apply 'ps: builtins.any (p: (p.pname or "") == "wireguard-tools") ps'` prints `true`

## 2. Integration

- [x] 2.1 Run `nix fmt modules/home/dev-tools.nix` and `nix flake check`; verify both pass and `git status` shows only intended files
- [x] 2.2 Build the NixOS host (`nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link`); verify it succeeds
- [x] 2.3 After `nixos-rebuild switch`, verify `wg --version` and `command -v wg-quick` succeed in a new shell

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
