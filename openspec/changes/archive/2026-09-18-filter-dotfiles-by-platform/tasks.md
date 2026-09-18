## 1. Exclude-list option and platform defaults

- [x] 1.1 In `modules/home/dotfiles.nix`, add the `home.dotfiles.excludePackages` option (`lib.types.listOf lib.types.str`, default `[ ]`) and verify `nix flake check` still evaluates the module without errors
- [x] 1.2 Add a `let`-bound built-in exclude list computed from `pkgs.stdenv.isDarwin`/`isLinux` (`iterm2` excluded when not Darwin; `herbstluftwm` and `xorg` excluded when not Linux), combined with `cfg.excludePackages`, and verify by inspecting the evaluated module (e.g. `nix eval` or a scratch `home-manager build`) that the combined list contains the expected names for each platform

## 2. Skip excluded packages during stow

- [x] 2.1 Pass the combined exclude list into the `home.activation.dotfiles` script via `lib.escapeShellArgs` and extend the `for pkg in ...` loop (currently `modules/home/dotfiles.nix:22-28`) to skip any package name present in that list, printing a message that it was skipped as not relevant on this platform, and verify by rendering the activation script (`home-manager build --flake .#tom@darwin` or `.#tom@linux`, or `nix eval .#homeConfigurations.\"tom@darwin\".activationPackage` and inspecting the generated script) that the skip branch is present
- [x] 2.2 Verify non-excluded packages are unaffected: confirm the rendered activation script still calls `stow` for packages outside the exclude list (e.g. `git`, `neovim`, `tmux`)

## 3. Validation

- [x] 3.1 Run `openspec validate filter-dotfiles-by-platform --strict` and confirm it passes
