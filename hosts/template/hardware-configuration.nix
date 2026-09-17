# Placeholder. Replace this entire file with the real output of:
#   nixos-generate-config --root /mnt
# run against the target machine after partitioning and mounting it.
# The commented example below shows the shape of a real generated file —
# do not uncomment and use these values as-is, they describe no real disk.
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  # boot.initrd.kernelModules = [ ];
  # boot.kernelModules = [ ];
  # boot.extraModulePackages = [ ];
  #
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/CHANGEME";
  #   fsType = "ext4";
  # };
  #
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/CHANGEME";
  #   fsType = "vfat";
  # };
  #
  # swapDevices = [ ];
}
