{ pkgs, user, ... }:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./niri
    ./noctalia.nix
    ./vscode.nix
    ./vim.nix
    ./claude.nix
  ];

  home.username = user;
  home.homeDirectory = "/home/${user}";

  home.packages = with pkgs; [
    gh
    ripgrep
    fd
    jq
    htop
    btop
    unzip
    zip
    file
    tree
    uv
  ];

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
  };

  # GTK apps (and Firefox's own pages) read the UI font from here; unset, they
  # fall back to Cantarell, which isn't installed.
  dconf.settings = {
    "org/gnome/desktop/interface".font-name = "Inter 11";
    "org/gnome/nautilus/preferences".default-folder-viewer = "list-view";
    "org/gnome/nautilus/list-view".default-zoom-level = "small";
  };

  # Automount USB drives (via udisks2) and open them in Nautilus.
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
    settings.program_options = {
      file_manager = "nautilus";
      event_hook = "${pkgs.writeShellScript "udiskie-open" ''
        [ "$1" = device_mounted ] && [ -n "$2" ] && exec nautilus --new-window "$2"
      ''} {event} {mount_path}";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };

  home.stateVersion = "26.05";
}
