{ pkgs, user, ... }:
{
  # --- boot ---
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 15;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.systemd.enable = true; # nicer LUKS prompt, needed for plymouth etc.

  # --- nix ---
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    trusted-users = [
      "root"
      user
    ];
  };
  nixpkgs.config.allowUnfree = true; # chrome, vscode, spotify

  # `nh os switch` etc.; also does weekly GC keeping the last 10 days / 5 generations.
  programs.nh = {
    enable = true;
    flake = "/home/${user}/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep-since 10d --keep 5";
    };
  };

  # --- locale: English UI, Finnish formats ---
  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
  };
  console.keyMap = "fi";
  services.xserver.xkb = {
    layout = "fi";
    options = "caps:escape";
  };

  # --- user ---
  users.users.${user} = {
    isNormalUser = true;
    description = "Joonas Palosuo";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "dialout"
      "docker"
    ];
    # Password is set by scripts/install.sh (`passwd` inside nixos-enter).
  };

  # --- hardware / services ---
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true; # ThinkPad firmware updates via LVFS
  services.fstrim.enable = true;
  services.btrfs.autoScrub.enable = true;
  zramSwap.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    pciutils
    usbutils
    btrfs-progs
  ];
}
