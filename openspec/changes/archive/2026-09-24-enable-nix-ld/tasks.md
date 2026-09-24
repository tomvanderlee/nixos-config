## 1. Enable nix-ld on NixOS hosts

- [x] 1.1 In `modules/nixos/common.nix`, add `programs.nix-ld.enable = true;` alongside the other unconditional host-level services, with a short comment explaining why (uv-managed prebuilt binaries need an FHS-style loader path). Verify by re-reading the diff: the option is set unconditionally, matching the file's existing style.
- [x] 1.2 In the same file, add `programs.nix-ld.libraries = with pkgs; [ ncurses libffi sqlite readline gdbm expat ];`. Verify the six packages resolve in the pinned nixpkgs by running `nix eval '.#nixosConfigurations.test-vm.config.programs.nix-ld.libraries' --apply 'builtins.length'` (or equivalent) and confirming it evaluates without error.

## 2. Verify the change builds

- [x] 2.1 Run `nix flake check` and confirm it passes.
- [x] 2.2 Run `nix build '.#nixosConfigurations.test-vm.config.system.build.toplevel'` and confirm the system closure builds successfully with `programs.nix-ld` enabled.

## 3. Manual follow-up (deferred, not verifiable in this environment)

- [ ] 3.1 After deploying to an activated NixOS host, run `uv python install 3.12` and confirm the installed interpreter executes (e.g. `uv run python3.12 --version`) instead of failing with a missing-interpreter error. This cannot be verified from this development environment since it requires an activated host, not just a successful build.
