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
      # Sway Classic's dark ANSI colours are unreadable on its #222222
      # background (red is 1.7:1). Lighter versions of the same hues, all
      # >= 4.5:1; these override the theme. (minimum-contrast is no good: it
      # swaps failing colours for plain white.) Revisit if the palette changes.
      palette = [
        "1=#ea5a5a" # red
        "2=#78a300" # green
        "4=#5b9bd5" # blue
        "5=#a08fd0" # magenta
        "8=#878e91" # bright black (comments, hints)
        "9=#ff7a7a" # bright red
        "10=#9acd32" # bright green
        "12=#7fb3e3" # bright blue
        "13=#c0b0f0" # bright magenta
      ];
    };
  };
}
