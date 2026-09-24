{
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
let
  crossPlatformApps = [
    pkgs.slack
    pkgs.discord
    pkgs.spotify
    pkgs.firefox
    pkgs.bitwarden-desktop
    pkgs.ghostty
  ];
  linuxOnlyApps = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.teams-for-linux;
  # GNOME Tweaks only makes sense where GNOME is actually enabled, which this
  # flake only does at the NixOS level (modules/nixos/common.nix) - not on
  # standalone, non-NixOS activations of this shared profile. osConfig is the
  # full NixOS config and is only present when home-manager is integrated
  # into a NixOS system; it's absent for standalone `home-manager switch`.
  gnomeOnlyApps = lib.optional (osConfig.services.desktopManager.gnome.enable or false
  ) pkgs.gnome-tweaks;
  candidateApps = crossPlatformApps ++ linuxOnlyApps ++ gnomeOnlyApps;
in
{
  home.packages = builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) candidateApps;
}
