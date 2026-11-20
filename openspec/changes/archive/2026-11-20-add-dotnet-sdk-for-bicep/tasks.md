# Tasks

## 1. Home module

- [x] 1.1 In `modules/home/editor.nix`, add `lib` to the module arguments and add `dotnet-sdk_10` to `home.packages`, filtered with `lib.meta.availableOn pkgs.stdenv.hostPlatform`; extend the comment above the list to mention dotnet-launched Mason servers (the Bicep language server). Verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'ps: map (p: p.name) ps'` contains `dotnet-sdk-10.*` (note `ps` includes `dotnet-sdk-wrapped`; match on `dotnet-sdk`)
- [x] 1.2 Verify evaluation still succeeds for `homeConfigurations."tom@darwin"` and that `git status` shows only `modules/home/editor.nix` changed for this task

## 2. Integration

- [x] 2.1 Run `nix fmt -- modules/home/editor.nix`, `nix flake check --no-build` and `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link`; verify all succeed
- [x] 2.2 After `nixos-rebuild switch`, verify `dotnet --list-runtimes` shows a `Microsoft.NETCore.App 10.0.x` entry
- [x] 2.3 In Neovim (with the Bicep config from the dotfiles repo), install `bicep-lsp` through Mason and open a `.bicep` file; verify the language server attaches (`:LspInfo`) with no missing-runtime error (done by the user; if it fails with a missing-runtime message, swap the SDK major version per design.md)
