{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-amd
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/apps.nix
    ../../modules/nixos/home-manager.nix
  ];

  networking.hostName = "x13";

  # Set once at install time; don't bump it on upgrades.
  system.stateVersion = "26.05";
}
