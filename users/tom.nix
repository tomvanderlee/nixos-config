{ pkgs, ... }:
{
  imports = [ ../modules/home ];

  home.username = "tom";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/tom" else "/home/tom";

  # Set once at first install/activation; never bump retroactively.
  home.stateVersion = "24.05";

  programs.git = {
    userName = "Tom van der Lee";
    userEmail = "t0m.vd.l33@gmail.com";
  };
}
