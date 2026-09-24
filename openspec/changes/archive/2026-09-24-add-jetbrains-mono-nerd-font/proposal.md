## Why

The shared home profile provisions Ghostty (terminal) and Neovim, both of which render icon glyphs (statusline segments, `nvim-tree`/`neo-tree` file icons, etc.) that require a "Nerd Font" patched typeface to display correctly. No font is currently provisioned by this repo at all, so those glyphs fall back to tofu boxes or missing-character placeholders on any freshly activated host or standalone machine.

## What Changes

- Provision the JetBrains Mono Nerd Font (`pkgs.nerd-fonts.jetbrains-mono`) through the shared home-manager profile, in a new `modules/home/fonts.nix`.
- Skip the font package on a platform where it has no supported build, following the same `lib.meta.availableOn` pattern already used in `modules/home/desktop-apps.nix`, rather than failing evaluation. (`nerd-fonts.jetbrains-mono` is currently unsupported on `x86_64-darwin` in the pinned nixpkgs, though none of this flake's actual `homeConfigurations`/`nixosConfigurations` outputs target that system today.)
- Enable home-manager's `fonts.fontconfig.enable` so the font is discoverable by fontconfig-based applications on standalone (non-NixOS) Linux activations, where it isn't already implied by a NixOS host's own `fonts.fontconfig.enable`. On Darwin, home-manager copies fonts from `home.packages` into `~/Library/Fonts/HomeManager` unconditionally, independent of this option.

## Capabilities

### New Capabilities
- `fonts`: Provisions typefaces (starting with the JetBrains Mono Nerd Font) through the shared home-manager profile, available wherever that profile is activated and discoverable by both fontconfig-based apps and native macOS font resolution.

### Modified Capabilities
(none)

## Impact

- New file: `modules/home/fonts.nix`.
- Modified: `modules/home/default.nix` (import the new module).
- No changes to `hosts/`, `users/tom.nix`, or NixOS-level modules — this is a cross-platform home-manager profile addition only.
