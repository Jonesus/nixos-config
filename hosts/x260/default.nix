{ inputs, ... }:
{
  imports = [
    # Skylake i5/i7-6x00U: Intel graphics, TLP/thinkpad_acpi tweaks.
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x260
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/apps.nix
    ../../modules/nixos/home-manager.nix
  ];

  networking.hostName = "x260";

  # Little RAM on this machine: compressed swap in RAM before the swapfile.
  zramSwap.enable = true;

  # Set once at install time; don't bump it on upgrades.
  system.stateVersion = "26.05";
}
