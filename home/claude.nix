{ ... }:
{
  programs.claude-code = {
    enable = true;
    # Merge these into a writable ~/.claude/settings.json instead of a read-only
    # symlink, so /config and permission prompts can still save changes.
    mutableSettings = true;
    settings = {
      permissions.defaultMode = "auto";
      tui = "fullscreen";
      skipAutoPermissionPrompt = true;
      agentPushNotifEnabled = true;
    };
    context = ''
      # Machine context
      - This machine runs NixOS (unstable) with niri + noctalia, configured as a flake at
        ~/nixos-config (home-manager is a NixOS module there).
      - Don't install software imperatively (no apt, no `nix-env -i`, no curl | sh). Add
        system packages in ~/nixos-config/modules/nixos/*.nix, user packages/dotfiles in
        ~/nixos-config/home/*.nix, then apply with `nh os switch`.
      - For one-off tools use `nix shell nixpkgs#<pkg>` / `nix run nixpkgs#<pkg>`; for project
        toolchains use a flake devShell + direnv (`use flake`).
      - niri config is ~/nixos-config/home/niri/config.kdl (live-reloaded; check with
        `niri validate`).
    '';
  };
}
