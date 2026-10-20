{ config, ... }:
{
  # Symlink straight into the repo checkout (not the nix store) so edits to
  # config.kdl apply instantly via niri's live reload, and are still tracked
  # by git. Run `niri validate` after editing.
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/niri/config.kdl";
}
