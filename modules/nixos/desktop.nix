{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.desktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether to enable the graphical desktop stack: X server, GDM, GNOME,
      desktop audio (PipeWire) and printing (CUPS + Avahi). Set to false for
      headless hosts such as servers or VMs without a display. The shared
      home profile follows this setting and skips GUI applications.
    '';
  };

  config = lib.mkIf config.desktop.enable {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Defaults GNOME to dark mode without locking it - GNOME Settings'
    # Appearance toggle still writes to the user's own dconf database, which
    # is searched before this default database.
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [
      { settings."org/gnome/desktop/interface".color-scheme = "prefer-dark"; }
    ];

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;

    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Flatpak for desktop apps that nixpkgs doesn't package. The remote is added
    # at system level by a one-shot unit; it is not a dependency of anything, so
    # failing offline at boot is harmless and --if-not-exists makes retries safe.
    # Desktop-only: Flatpak requires xdg portals, which a headless host lacks.
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
