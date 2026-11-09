# Copy-source only — this directory is never wired into flake.nix as a real
# nixosConfigurations output. To bootstrap a real host:
#   cp -r hosts/template hosts/<real-hostname>
# then edit the CHANGEME values below and replace hardware-configuration.nix
# with the output of `nixos-generate-config`. See README.md for the full flow.
{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "toms-thinkpad";

  # UEFI (most modern machines):
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # BIOS/legacy alternative — comment out the two lines above and use instead:
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sdX";

  storage.zfs = {
    enable = true;
    hostId = "850edb9e";
    encryptedHome.dataset = "zpool/home";
  };

  # Loopback-only PostgreSQL for local development.
  development.postgresql.enable = true;

  # Bring the "Home" WireGuard profile up on untrusted networks. Wired and
  # these SSIDs are trusted (VPN down); GNOME toggling still works.
  vpn.autoConnect = {
    enable = true;
    trustedSsids = [ "ErmeLan" ];
  };

  # Fingerprint reader (fprintd). Enroll with `fprintd-enroll`.
  services.fprintd.enable = true;

  # Bitwarden's "Unlock with system authentication" goes through polkit, which
  # only reads policies from the system profile. Bitwarden itself comes from
  # home-manager (per-user profile), so install it system-wide as well to expose
  # its com.bitwarden.Bitwarden.unlock policy.
  security.polkit.enable = true;
  environment.systemPackages = [ pkgs.bitwarden-desktop ];

  # Set to the NixOS release in use by the installer at install time
  # (e.g. "24.05"). This only affects on-disk state format compatibility —
  # never change it after the fact.
  system.stateVersion = "26.05";
}
