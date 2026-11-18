{
  config,
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
  # Firefox 159/160 on native Wayland (GNOME, Intel Arrow Lake, Mesa 26.3.0,
  # mixed-scale multi-monitor) crashed and stalled repainting while audio and
  # input kept working. XWayland avoids both. TEMPORARY: to revert, drop this
  # binding and use pkgs.firefox again, after checking that
  # `MOZ_ENABLE_WAYLAND=1 firefox` shows Window Protocol "wayland" in
  # about:support and survives YouTube Shorts / GeoFS. Only the outer
  # bin/firefox is re-wrapped so nixpkgs' own wrapper (native messaging hosts,
  # MOZ_SYSTEM_DIR) is untouched.
  firefox = pkgs.symlinkJoin {
    name = "firefox-${pkgs.firefox.version}";
    paths = [ pkgs.firefox ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/firefox --set MOZ_ENABLE_WAYLAND 0
    '';
    inherit (pkgs.firefox) meta;
  };
  crossPlatformApps = [
    pkgs.slack
    pkgs.discord
    pkgs.spotify
    firefox
    pkgs.bitwarden-desktop
    pkgs.ghostty
    nextcloud-client
    # Camera RAW viewer/editor. Chosen over darktable and the GNOME image viewer's
    # glycin loader because it decodes Apple ProRAW DNGs; it is binary-cached.
    pkgs.rawtherapee
    # Not in nixpkgs: repackaged from Anthropic's official .deb (beta).
    (pkgs.callPackage ../../pkgs/claude-desktop.nix { })
  ];
  # librepods declares no meta.platforms, so availableOn would not drop it on
  # macOS; it needs BlueZ and Qt Bluetooth, hence Linux-only.
  linuxOnlyApps = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.teams-for-linux
    pkgs.librepods
  ];
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
  options.home.desktop.enable = lib.mkOption {
    type = lib.types.bool;
    # Follows the NixOS host's desktop.enable when activated through one;
    # standalone activations (no osConfig) default to having a desktop.
    default = osConfig.desktop.enable or true;
    description = "Whether to install desktop GUI applications.";
  };

  config.home.packages = lib.optionals config.home.desktop.enable (
    builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) candidateApps
  );
}
