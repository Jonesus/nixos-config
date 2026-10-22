{ pkgs, ... }:
{
  # VS Code Dev Containers copy ~/.config/git/config into containers, which
  # have no /nix/store. So everything here refers to programs by bare name
  # (on PATH both here and in a typical container) rather than HM's
  # lfs.enable / difftastic.git.enable, which write /nix/store paths.
  home.packages = [ pkgs.git-lfs ];

  programs.git = {
    enable = true;
    signing = {
      key = "040E3EDC6AF623CE";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Joonas Palosuo";
        email = "joonas.palosuo@gmail.com";
      };
      core.editor = "vim";
      color.ui = true;
      init.defaultBranch = "main";
      pull.rebase = true;
      remote.origin.tagopt = "--tags";
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
      # Plain `git diff` stays built-in so it works in containers without
      # difftastic; `git dft` runs difftastic.
      alias.dft = "difftool";
      diff.tool = "difftastic";
      difftool.prompt = false;
      "difftool \"difftastic\"".cmd = "difft --display=inline $LOCAL $REMOTE";
      pager.difftool = true;
    };
  };

  programs.difftastic.enable = true;

  # Restore ~/.gnupg from the backup stick; keys are not managed here.
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
    # S.gpg-agent.extra is what ~/.ssh/config.local RemoteForwards to remote
    # hosts for commit signing; under systemd socket activation it only
    # exists if enabled here.
    enableExtraSocket = true;
  };

  # Restore ~/.ssh from the backup stick as well. Host entries live in the
  # unmanaged ~/.ssh/config.local so internal hosts stay out of this public repo.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "config.local" ];
    settings."*".AddKeysToAgent = "yes";
  };
  services.ssh-agent.enable = true;
}
