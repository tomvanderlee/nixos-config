# Copy-source only — this directory is never wired into flake.nix as a real
# nixosConfigurations output. To bootstrap a real host:
#   cp -r hosts/template hosts/<real-hostname>
# then edit the CHANGEME values below and replace hardware-configuration.nix
# with the output of `nixos-generate-config`. See README.md for the full flow.
{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "CHANGEME";

  # UEFI (most modern machines):
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # BIOS/legacy alternative — comment out the two lines above and use instead:
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sdX";

  # Set to the NixOS release in use by the installer at install time
  # (e.g. "24.05"). This only affects on-disk state format compatibility —
  # never change it after the fact.
  system.stateVersion = "CHANGEME";
}
