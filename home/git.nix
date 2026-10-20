{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
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
      alias.dft = "difftool";
      diff.tool = "difftastic";
      difftool.prompt = false;
      "difftool \"difftastic\"".cmd = "difft --display=inline $LOCAL $REMOTE";
      pager.difftool = true;
    };
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options.display = "inline";
  };

  # Restore ~/.gnupg from the backup stick; keys are not managed here.
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
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
