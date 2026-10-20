{ inputs, ... }:
{
  imports = [ inputs.noctalia.homeModules.default ];

  # niri starts noctalia (spawn-at-startup in home/niri/config.kdl), so no
  # systemd service. Anything not set here can be changed in the settings UI
  # (Mod+Comma); copy settings you want to keep from ~/.config/noctalia into here.
  programs.noctalia = {
    enable = true;
    settings = {
      shell.font = "Inter";
      theme.templates = {
        enable_builtin_templates = true;
        builtin_ids = [
          "ghostty"
          "gtk3"
          "gtk4"
        ];
      };
    };
  };
}
