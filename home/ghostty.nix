{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;
      window-padding-x = 8;
      window-padding-y = 8;
      window-decoration = false;
      confirm-close-surface = false;
      # Colors come from noctalia's ghostty template (home/noctalia.nix), which
      # writes ~/.config/ghostty/themes/noctalia and reloads open terminals.
      # The template's hook only edits this file if this line is missing, which
      # it can't do since home-manager makes the file read-only.
      theme = "noctalia";
      # Readable ANSI colours come from the palette (home/noctalia/). Don't
      # use minimum-contrast: it swaps failing colours for plain white.
    };
  };
}
