{ pkgs, lib, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
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
}
