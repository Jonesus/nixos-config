# Whole-disk layout: 1G ESP + btrfs subvolumes (no LUKS).
# Only touches nvme0n1; nvme1n1 (Windows) is left alone.
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
        root = {
          size = "100%";
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
}
