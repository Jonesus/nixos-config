# Placeholder so the flake evaluates; scripts/install.sh overwrites it with
# the output of nixos-generate-config on the real machine.
{ lib, ... }:
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
