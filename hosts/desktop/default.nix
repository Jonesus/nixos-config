{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/apps.nix
    ../../modules/nixos/home-manager.nix
  ];

  networking.hostName = "desktop";

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  # For games that still misbehave under niri, set the Steam launch option
  # `gamescope -W 5120 -H 1440 -w 2560 -h 1440 -- %command%`: the game gets
  # its own nested compositor, so it never sees resizes or the real screen.
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  system.stateVersion = "26.05";
}
