## Purpose

Governs what the shared home-manager profile provisions for the default editor (Neovim): the package and wrapper itself, non-interference with the user's externally-managed dotfiles editor configuration, and the native build toolchain that natively-built plugins in that configuration need.

## ADDED Requirements

### Requirement: Neovim is provisioned as the default editor
The shared home-manager profile SHALL install Neovim, set it as the default `$EDITOR`/`$VISUAL`, and provide a `vim` alias pointing to it, identically wherever the profile is activated (standalone or via a NixOS host).

#### Scenario: Neovim available after activation
- **WHEN** the shared home profile is activated on any supported platform
- **THEN** the `nvim` binary is on `PATH`, `$EDITOR`/`$VISUAL` resolve to `nvim`, and `vim` invokes `nvim`

### Requirement: Home-manager does not manage Neovim's config directory
The shared home-manager profile SHALL NOT write its own generated content to the user's Neovim configuration directory (`$XDG_CONFIG_HOME/nvim`), so that a separately-managed, externally-owned configuration (such as a personal dotfiles repository symlinked into place by another mechanism) can occupy that path without conflict.

#### Scenario: Config directory left free for external ownership
- **WHEN** the shared home profile is activated, independent of whether an external configuration has been placed at `$XDG_CONFIG_HOME/nvim` yet
- **THEN** no file under `$XDG_CONFIG_HOME/nvim` is created, modified, or symlinked by the home-manager-managed profile itself

### Requirement: A native build toolchain is available for editor plugins
The shared home-manager profile SHALL provide a C compiler and the `tree-sitter` CLI on `PATH`, so that natively-built Neovim plugins configured by an externally-managed configuration can compile successfully, on every platform this flake targets.

#### Scenario: Compiler and tree-sitter CLI available after activation
- **WHEN** the shared home profile is activated on NixOS or Darwin
- **THEN** a working C compiler (`cc`) and the `tree-sitter` CLI are both resolvable on `PATH` without any additional manual installation step
