# Whole-disk layout: 1G ESP + LUKS2 container holding btrfs subvolumes.
# Used by `disko` at install time AND by the running system (fileSystems,
# boot.initrd.luks are generated from this), so keep it in sync with reality.
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            # Only read during install; scripts/install.sh writes it to tmpfs.
            passwordFile = "/tmp/luks-password";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes =
                let
                  opts = [
                    "compress=zstd"
                    "noatime"
                  ];
                in
                {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = opts;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = opts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = opts;
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = opts;
                  };
                  # Docker images churn a lot; keep them out of /home and @root snapshots.
                  "@docker" = {
                    mountpoint = "/var/lib/docker";
                    mountOptions = opts;
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = opts;
                  };
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "16G";
                  };
                };
            };
          };
        };
      };
    };
  };
}
