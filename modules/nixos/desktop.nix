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

    # GDM lists every AccountsService user whose SystemAccount is false, and
    # root is cached that way (shown as "System administrator").
    # services.displayManager.hiddenUsers is not read by GDM, so mark root as
    # a system account directly; f+ also corrects a stale SystemAccount=false.
    systemd.tmpfiles.rules = [
      "f+ /var/lib/AccountsService/users/root 0600 root root - [User]\\nSystemAccount=true\\n"
    ];

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;

    # Dummy AVRCP media player so Bluetooth headsets (AirPods tap gestures)
    # can send play/pause/skip; the declarative form of the wireplumber
    # snippet in LibrePods' README. Do not also run mpris-proxy.
    services.pipewire.wireplumber.extraConfig."51-bluez-avrcp"."monitor.bluez.properties" = {
      "bluez5.dummy-avrcp-player" = true;
    };

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
