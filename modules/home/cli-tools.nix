{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    ripgrep
    fd
    bat
    eza
    jq
    fzf
    tree
  ];
}
