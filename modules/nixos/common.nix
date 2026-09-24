{ pkgs, lib, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Per-host configuration.nix can override either of these without
  # conflicting, since they're set with mkDefault here.
  time.timeZone = lib.mkDefault "Etc/UTC";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  users.users.tom = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.bash;
    # Fetched once from https://github.com/tomvanderlee.keys and pinned here
    # as a static literal (not fetched at build time, which would require
    # --impure) — update this list by hand if keys are added/rotated on
    # GitHub.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZQd4C53B3v7Si6NjNH8uXTrLOx5NXIWhF6R9Mk7hpDWQWwvXzCL6I/aY7cai2s8QgM5ptdVlx5pkogedPJCFEzLQoal/X6hOfNj1xAhDxEyEf7h+tflsnWqMFy92H7cC5o/xM48JRX1Fpm62xN7MrkUsZvV/t+HV6rISCNxOVXI7m0PowQT9zDGrAI2Q0dSLiqxvq/lMsU6aSJJz1kkQhcxLHJbm72mhZxf7NrF4I1OoEyuLTLpsgx8VpZwDlkp1m6+wy8xS/jNzr3ukjlTFy2RtDFyhiYTtwZI8j0ESNF3bp+FApUtHQ6dtcHGf5qHO9DaMYL94hPXuyebih723vQLVXqXDyXn7rHXD/laCPoE/2NeMA9h+g+MH6xqxbASVzWJuRq3RE+7VdIR+Y6Du1QkxLlNoPlDJTGb+n1OSMvVKum+XzNdneEP4txeXjvg/sfB/d53BCLaWB9tQEelNJaSue6JxckYNug4NE68b5dx4gvPw5qiKM8fzDZJSyvS0="
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

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

  networking.networkmanager.enable = true;

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

  # Rootful: standard system service, starts at boot independent of any
  # login session (rootless was tried first but its per-user systemd unit
  # didn't reliably start in already-logged-in sessions after a switch).
  # tom's docker group membership is root-equivalent access, accepted here
  # for reliability over the rootless isolation guarantee.
  virtualisation.docker.enable = true;
}
