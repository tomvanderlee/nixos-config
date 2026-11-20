{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    # Never write ~/.config/nvim/init.lua ourselves - that path is owned by
    # the externally-managed dotfiles config (lazy.nvim + plugins), stowed
    # in separately. Without this, home-manager's own generated init.lua
    # permanently conflicts with that stow package and it gets skipped.
    sideloadInitLua = true;
    # Pin the legacy (stateVersion < 26.05) provider defaults explicitly so
    # this doesn't silently change if stateVersion is ever bumped.
    withRuby = true;
    withPython3 = true;
  };

  # tree-sitter (parser compilation) and a C compiler for natively-built
  # Neovim plugins declared by the dotfiles-owned config above.
  # nodejs/python3/unzip: required on PATH by mason.nvim's installers
  # (npm-based LSP servers, debugpy, terraform-ls).
  # dotnet-sdk_10: Mason's dotnet-launched servers (the Bicep language server,
  # a net10.0 assembly run via `dotnet`). Filtered by availableOn because
  # nixpkgs lacks it on x86_64-darwin.
  home.packages =
    with pkgs;
    [
      tree-sitter
      stdenv.cc
      nodejs
      python3
      unzip
    ]
    ++ builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [ dotnet-sdk_10 ];
}
