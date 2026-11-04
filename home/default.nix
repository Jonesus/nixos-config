{ lib, pkgs, user, ... }:
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
    loupe
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
      # Only our own mounts: fwupd briefly mounts every EFI partition as root
      # under /run/media/root, which would otherwise pop up "no permission"
      # windows.
      event_hook = "${pkgs.writeShellScript "udiskie-open" ''
        [ "$1" = device_mounted ] || exit 0
        case "$2" in
          /run/media/"$USER"/*) exec nautilus --new-window "$2" ;;
        esac
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
    }
    # Loupe for every image type it handles (its .desktop MimeType list).
    // lib.genAttrs [
      "image/apng"
      "image/avif"
      "image/bmp"
      "image/gif"
      "image/heic"
      "image/jp2"
      "image/jpeg"
      "image/jxl"
      "image/png"
      "image/qoi"
      "image/svg+xml"
      "image/svg+xml-compressed"
      "image/tiff"
      "image/vnd.microsoft.icon"
      "image/webp"
      "image/x-dds"
      "image/x-exr"
      "image/x-portable-anymap"
      "image/x-portable-bitmap"
      "image/x-portable-graymap"
      "image/x-portable-pixmap"
      "image/x-qoi"
      "image/x-tga"
      "image/x-win-bitmap"
      "image/x-xbitmap"
      "image/x-xpixmap"
    ] (_: "org.gnome.Loupe.desktop");
  };

  home.stateVersion = "26.05";
}
