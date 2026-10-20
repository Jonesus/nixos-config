{ pkgs, ... }:
{
  programs.firefox.enable = true;

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Spotify Connect / local device discovery.
  networking.firewall = {
    allowedTCPPorts = [ 57621 ];
    allowedUDPPorts = [ 5353 ];
  };

  environment.systemPackages = with pkgs; [
    google-chrome
    telegram-desktop
    spotify
    keepassxc
  ];

  # Run unpatched binaries (VS Code extensions' language servers, prebuilt CLIs).
  programs.nix-ld.enable = true;
}
