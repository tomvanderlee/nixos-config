{ pkgs, ... }:
{
  imports = [ ../modules/home ];

  home.username = "tom";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/tom" else "/home/tom";

  # Set once at first install/activation; never bump retroactively.
  home.stateVersion = "24.05";

  home.dotfiles.repoUrl = "https://git.tomvanderlee.com/dotfiles";
}
