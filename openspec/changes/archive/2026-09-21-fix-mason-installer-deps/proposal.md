## Why

`mason.nvim` (managed by the externally-owned, Stow-linked Neovim dotfiles config)
fails to install several LSP/tooling packages on this flake's Home Manager profile:
`pyright`, `bash-language-server`, `yaml-language-server`,
`typescript-language-server`, `css-lsp`, and `html-lsp` fail because `npm` is not on
`PATH`; `debugpy` fails because no `python3`/`python` is on `PATH`; `terraform-ls`
fails because `unzip` is not on `PATH`. `programs.neovim.withPython3 = true` only
wires up Neovim's Python *provider* (pynvim) and does not put a `python3` binary on
`PATH`, so it does not cover this. `js-debug-adapter` and `lua-language-server`
already install successfully and need no change.

## What Changes

- Provision `nodejs` (for `npm`), `python3`, and `unzip` on `PATH` via the shared
  Home Manager profile, so `mason.nvim`'s installers can find the interpreters/tools
  they shell out to.

## Capabilities

### New Capabilities
- `editor-toolchain`: The shared home-manager profile provisions the runtime
  toolchain (interpreters, package managers, archive tools) that the externally
  Stow-managed Neovim/mason.nvim config depends on to install and run LSP servers
  and debug adapters, without home-manager owning any of that config itself.

### Modified Capabilities
(none — `developer-environment` covers general most-used CLI tools, not the
Neovim/mason.nvim dependency contract, so a new capability is used instead of
overloading that one.)

## Impact

- `modules/home/editor.nix`: extend the existing `home.packages` list (already used
  for `tree-sitter`/`stdenv.cc`, the same "tools the dotfiles-owned nvim config
  needs" pattern) with `nodejs`, `python3`, `unzip`.
- Applies to both Home Manager configs that import this module — `tom@linux` and
  `tom@darwin` (per `flake.nix`) — covering all supported systems.
- No changes to the externally-managed dotfiles/Neovim Lua config itself.
