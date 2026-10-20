{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    historySize = 10000;
    historyFileSize = 100000;
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";

      gs = "git status";
      gc = "git commit";
      gcm = "git commit -m";
      gcam = "git commit -am";
      gco = "git checkout";
      gp = "git push";
      gpu = "git push --set-upstream origin HEAD";
      gl = "git log --all --decorate --oneline --graph --ext-diff";
      gd = "git diff";
      gds = "git diff --staged";
    };
    initExtra = ''
      export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"
    '';
  };

  programs.fzf.enable = true;
  programs.starship.enable = true;

  # Per-project toolchains: drop a flake.nix / .envrc with `use flake` into a
  # repo instead of installing nvm/pyenv globally.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
