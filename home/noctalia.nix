{ config, inputs, ... }:
let
  wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  home.file."Pictures/Wallpapers/aperture-vintage.jpg".source = ./wallpapers/aperture-vintage.jpg;

  # niri starts noctalia (spawn-at-startup in home/niri/config.kdl), so no
  # systemd service. Anything not set here can be changed in the settings UI
  # (Mod+Comma); UI changes land in ~/.local/state/noctalia/settings.toml and
  # override these, so copy settings you want to keep from there into here.
  programs.noctalia = {
    enable = true;
    settings = {
      accessibility.ui_scale = 1.25;

      shell = {
        font_family = "Inter";
        window_switcher.current_workspace_only = true;
      };

      bar.default = {
        smart_auto_hide = true;
        reserve_space = false;
        margin_ends = 6;
      };

      widget.network.show_label = false;

      location.auto_locate = true;

      # The top-level threshold only applies to the laptop battery; peripherals
      # need a per-device entry (selector matches upower model/serial/path).
      battery = {
        warning_threshold = 10;
        device = {
          "MX Vertical".warning_threshold = 10;
          "Corne".warning_threshold = 10;
        };
      };

      wallpaper = {
        directory = wallpaperDir;
        default.path = "${wallpaperDir}/aperture-vintage.jpg";
      };

      theme = {
        source = "community";
        community_palette = "Sway Classic";
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "ghostty"
            "gtk3"
            "gtk4"
          ];
        };
      };
    };
  };
}
