{
  inputs,
  pkgs,
  user,
  ...
}:
{
  imports = [
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  # niri from nixpkgs: provides the session file, portals and polkit wiring.
  # Its config lives in home/niri/config.kdl (symlinked by home-manager).
  programs.niri.enable = true;

  programs.noctalia = {
    enable = true;
    # NetworkManager, Bluetooth, UPower, power-profiles-daemon.
    recommendedServices.enable = true;
  };

  # greetd + noctalia-greeter. The shell can push its theme/wallpaper to the
  # greeter ("greeter sync"); allow that without a password prompt for us.
  services.displayManager.noctalia-greeter = {
    enable = true;
    passwordless-sync-users = [ user ];
    settings = {
      session.default = "niri";
      keyboard = {
        layout = "fi";
        options = "caps:escape";
      };
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 24;
        path = pkgs.bibata-cursors;
      };
    };
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true; # secret service for chrome/vscode
  security.pam.services.greetd.enableGnomeKeyring = true;
  programs.dconf.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # electron/chromium on wayland

  environment.systemPackages = with pkgs; [
    xwayland-satellite # niri spawns it automatically for X11 apps
    wl-clipboard
    bibata-cursors
    adwaita-icon-theme
    nautilus
    brightnessctl
    playerctl
  ];

  fonts.packages = with pkgs; [
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Inter" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
  };
  # Uninstalled UI fonts otherwise fuzzy-match "Noto Sans Arabic UI" (odd
  # metrics for Latin text). Cantarell is GTK's default font, which Firefox
  # uses for its own pages; Segoe UI is common in website font stacks.
  fonts.fontconfig.localConf = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <alias binding="same"><family>Cantarell</family><prefer><family>Inter</family></prefer></alias>
      <alias binding="same"><family>Segoe UI</family><prefer><family>Inter</family></prefer></alias>
    </fontconfig>
  '';
}
