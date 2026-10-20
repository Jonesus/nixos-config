{ pkgs, ... }:
{
  # Only the package and a few extensions are managed; settings.json stays
  # writable so Settings Sync / the UI keep working.
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      mkhl.direnv
    ];
  };
}
