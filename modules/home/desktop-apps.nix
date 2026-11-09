{
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
let
  # Qt opens GTK3's file dialog under GNOME, and GLib aborts the client when
  # adding a folder connection because org.gtk.Settings.FileChooser (shipped
  # by gtk3) is not in the session's XDG_DATA_DIRS. Wrapping instead of
  # overrideAttrs keeps the large Qt client binary-cached.
  nextcloud-client = pkgs.symlinkJoin {
    name = "nextcloud-client-${pkgs.nextcloud-client.version}";
    paths = [ pkgs.nextcloud-client ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nextcloud \
        --prefix XDG_DATA_DIRS : "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}" \
        --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    '';
    inherit (pkgs.nextcloud-client) meta;
  };
  crossPlatformApps = [
    pkgs.slack
    pkgs.discord
    pkgs.spotify
    pkgs.firefox
    pkgs.bitwarden-desktop
    pkgs.ghostty
    nextcloud-client
    # Not in nixpkgs: repackaged from Anthropic's official .deb (beta).
    (pkgs.callPackage ../../pkgs/claude-desktop.nix { })
  ];
  linuxOnlyApps = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.teams-for-linux;
  # GNOME Tweaks only makes sense where GNOME is actually enabled, which this
  # flake only does at the NixOS level (modules/nixos/common.nix) - not on
  # standalone, non-NixOS activations of this shared profile. osConfig is the
  # full NixOS config and is only present when home-manager is integrated
  # into a NixOS system; it's absent for standalone `home-manager switch`.
  gnomeOnlyApps = lib.optionals (osConfig.services.desktopManager.gnome.enable or false) [
    pkgs.gnome-tweaks
    pkgs.gnome-extension-manager
  ];
  candidateApps = crossPlatformApps ++ linuxOnlyApps ++ gnomeOnlyApps;
in
{
  home.packages = builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) candidateApps;
}
