# Placeholder until install: scripts/install.sh overwrites this with
# `nixos-generate-config --no-filesystems` output from the real machine.
# Filesystems and LUKS come from disko.nix, not from here.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
}
