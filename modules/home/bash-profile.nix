{ config, lib, pkgs, ... }:
let
  bashProfileContent = pkgs.writeText "bash_profile" ''
    # Written once by home-manager (modules/home/bash-profile.nix) so login
    # shells actually source ~/.bashrc — NixOS and other Linux distros don't
    # ship a ~/.bash_profile that does this by default. Only created if it
    # didn't already exist; home-manager never touches it again after that,
    # so it's yours to edit.
    if [ -f "$HOME/.bashrc" ]; then
      . "$HOME/.bashrc"
    fi
  '';
in
{
  home.activation.bashProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    BASH_PROFILE=${lib.escapeShellArg "${config.home.homeDirectory}/.bash_profile"}
    if [ ! -e "$BASH_PROFILE" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m 644 ${bashProfileContent} "$BASH_PROFILE"
    fi
  '';
}
