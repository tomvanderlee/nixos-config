{ pkgs, ... }:
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
  };

  # tree-sitter (parser compilation) and a C compiler for natively-built
  # Neovim plugins declared by the dotfiles-owned config above.
  home.packages = with pkgs; [
    tree-sitter
    stdenv.cc
  ];
}
