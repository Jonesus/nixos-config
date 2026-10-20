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
  ];

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
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
