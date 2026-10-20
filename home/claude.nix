{ pkgs, ... }:
let
  # Desktop notification from a hook's JSON on stdin (via noctalia's daemon).
  notify = pkgs.writeShellScript "claude-notify" ''
    input=$(cat)
    title=$(${pkgs.jq}/bin/jq -r '.title // "Claude Code"' <<<"$input")
    msg=$(${pkgs.jq}/bin/jq -r '.message // "Claude has a question for you"' <<<"$input")
    dir=$(basename "$(${pkgs.jq}/bin/jq -r '.cwd // ""' <<<"$input")")
    ${pkgs.libnotify}/bin/notify-send -a "Claude Code" "$title" "''${dir:+$dir: }$msg"
  '';
in
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
      theme = "dark";

      # Only notify when something is actually waiting on me. The built-in
      # alert also fires ~60s after every finished turn ("idle_prompt"), so
      # it's off and the hooks below cover the cases that need an answer.
      preferredNotifChannel = "notifications_disabled";
      hooks = {
        Notification = [
          {
            matcher = "permission_prompt|elicitation_dialog|elicitation_url_dialog|agent_needs_input";
            hooks = [
              {
                type = "command";
                command = "${notify}";
              }
            ];
          }
        ];
        # Questions (AskUserQuestion) aren't documented as a notification
        # type, so alert when one is asked.
        PreToolUse = [
          {
            matcher = "AskUserQuestion";
            hooks = [
              {
                type = "command";
                command = "${notify}";
              }
            ];
          }
        ];
      };
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
