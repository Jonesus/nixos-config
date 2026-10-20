#!/usr/bin/env bash
# Run from the NixOS live ISO, as root, from inside a checkout of this repo:
#   sudo ./scripts/install.sh
# WIPES the disk named in hosts/x13/disko.nix (/dev/nvme0n1).
set -euo pipefail

HOST=x13
USER_NAME=jones
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NIX=(nix --extra-experimental-features "nix-command flakes"
  --option extra-substituters https://noctalia.cachix.org
  --option extra-trusted-public-keys noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=)

[ "$(id -u)" = 0 ] || { echo "run as root (sudo)"; exit 1; }
[ -d /sys/firmware/efi ] || { echo "not booted in UEFI mode"; exit 1; }

lsblk -o NAME,SIZE,MODEL /dev/nvme0n1
read -rp "This ERASES /dev/nvme0n1. Type 'erase' to continue: " ok
[ "$ok" = erase ] || exit 1

while :; do
  read -rsp "New disk encryption (LUKS) password: " p1; echo
  read -rsp "Repeat: " p2; echo
  [ -n "$p1" ] && [ "$p1" = "$p2" ] && break
  echo "Passwords don't match, try again."
done
# /tmp is tmpfs on the live ISO, so this never touches a disk.
printf '%s' "$p1" > /tmp/luks-password
chmod 600 /tmp/luks-password
unset p1 p2

echo ">>> Partitioning, encrypting and mounting with disko"
"${NIX[@]}" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --yes-wipe-all-disks "$REPO/hosts/$HOST/disko.nix"
rm -f /tmp/luks-password

echo ">>> Generating hardware-configuration.nix for this machine"
nixos-generate-config --no-filesystems --root /mnt --show-hardware-config \
  > "$REPO/hosts/$HOST/hardware-configuration.nix"

echo ">>> Copying the repo to /mnt/home/$USER_NAME/nixos-config"
mkdir -p "/mnt/home/$USER_NAME"
cp -r "$REPO" "/mnt/home/$USER_NAME/nixos-config"
TARGET="/mnt/home/$USER_NAME/nixos-config"
# Flakes only see git-tracked files; make sure the new hardware config is included.
git -c safe.directory="*" -C "$TARGET" add -A

echo ">>> Installing (this downloads a few GB)"
nixos-install --no-root-passwd --flake "$TARGET#$HOST" \
  --option extra-substituters https://noctalia.cachix.org \
  --option extra-trusted-public-keys noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=

echo ">>> Set the login password for $USER_NAME"
nixos-enter --root /mnt -c "passwd $USER_NAME"
nixos-enter --root /mnt -c "chown -R $USER_NAME:users /home/$USER_NAME"

echo
echo "Done. Reboot, remove the USB stick, unlock the disk, log in."
echo "Then commit the generated hardware-configuration.nix:"
echo "  cd ~/nixos-config && git commit -am 'x13: real hardware-configuration'"
