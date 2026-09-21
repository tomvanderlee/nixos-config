{ pkgs, lib, ... }:
let
  crossPlatformApps = [ pkgs.slack pkgs.discord pkgs.spotify ];
  linuxOnlyApps = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.teams-for-linux;
  candidateApps = crossPlatformApps ++ linuxOnlyApps;
in
{
  home.packages =
    builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) candidateApps;
}
