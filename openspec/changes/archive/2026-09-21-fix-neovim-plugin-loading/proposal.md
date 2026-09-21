## Why

On every fresh install of this flake, Neovim's plugins never load: home-manager's `programs.neovim` module always writes `~/.config/nvim/init.lua` itself (nixpkgs' `wrapNeovimUnstable` generates non-empty Lua RC content regardless of whether any plugins are declared through the module), which permanently conflicts with GNU Stow's attempt to link the user's externally-managed dotfiles config (lazy.nvim + all plugins) to that same path. Stow skips the conflicting package, so the real `init.lua` that bootstraps lazy.nvim never gets linked — only home-manager's empty plumbing-only file is active, and commands like `:LazyInstall` don't exist. Separately, no C compiler toolchain is provisioned anywhere in this flake, so even once the real config loads, natively-built plugins (e.g. nvim-treesitter's parser compilation via the `tree-sitter` CLI) would still fail on NixOS — a gap invisible on the user's Mac because Xcode Command Line Tools provide a compiler for free.

## What Changes

- Set `programs.neovim.sideloadInitLua = true` in `modules/home/editor.nix` so home-manager stops writing to `~/.config/nvim/init.lua` entirely (it loads its own generated runtime plumbing via wrapper args instead), freeing that path for the dotfiles-owned Stow package to own exclusively.
- Provision a native build toolchain (a C compiler plus the `tree-sitter` CLI) via `home.packages` in `modules/home/editor.nix`, so natively-built Neovim plugins can actually compile on every platform this flake targets.
- Move `tree-sitter` out of `modules/home/dev-tools.nix` into `modules/home/editor.nix`, since its only consumer is Neovim's treesitter plugin, not general-purpose dev tooling.

## Capabilities

### New Capabilities
- `editor-environment`: Governs what the shared home-manager profile provisions for the default editor (Neovim) — the package/wrapper itself, non-interference with the externally-managed dotfiles config directory, and the native build toolchain natively-built plugins need. `editor.nix` currently has no spec coverage at all.

### Modified Capabilities
(none — `dotfiles-management`'s existing per-package conflict-skip requirement is unchanged by this fix; this change removes the source of one specific conflict, it doesn't change how conflicts are handled)

## Impact

- `modules/home/editor.nix` — gains `sideloadInitLua = true` and a `home.packages` list (`tree-sitter`, a C compiler).
- `modules/home/dev-tools.nix` — loses `tree-sitter` from its package list.
- Affects every `homeConfigurations`/`nixosConfigurations` output built from the shared home profile (`lib/mkHome.nix`, `lib/mkNixos.nix`), on both NixOS and Darwin.
- No change to the external `~/dotfiles` repository or its Neovim config — this change only removes the Nix-side conflict blocking it from being linked.
