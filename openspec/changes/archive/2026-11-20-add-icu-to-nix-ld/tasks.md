# Tasks

## 1. NixOS module

- [x] 1.1 In `modules/nixos/common.nix`, append `icu` to `programs.nix-ld.libraries` with a comment naming prebuilt self-contained .NET executables (such as the Azure-installed Bicep CLI) as the reason; verify `nix eval '.#nixosConfigurations.toms-thinkpad.config.programs.nix-ld.libraries' --apply 'ls: map (p: p.name) ls'` includes an `icu4c-*` entry
- [x] 1.2 Run `nix fmt -- modules/nixos/common.nix`, `nix flake check --no-build` and `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link`; verify all succeed and the built `nix-ld/lib` directory contains `libicuuc.so` (check under `result`/`--print-out-paths` `sw/share/nix-ld/lib`)

## 2. Verification on the host

- [x] 2.1 After `nixos-rebuild switch`, in a new shell run `~/.azure/bin/bicep --version`; verify it prints `Bicep CLI version ...` and no ICU error (done by the user)
