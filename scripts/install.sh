#!/usr/bin/env bash
# Run from the NixOS live ISO, as root, from inside a checkout of this repo:
#   sudo ./scripts/install.sh <host>
# WIPES the disk named in hosts/<host>/disko.nix.
set -euo pipefail

HOST="${1:?Usage: $0 <host>  (e.g. x13, desktop)}"
USER_NAME=jones
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NIX=(nix --extra-experimental-features "nix-command flakes"
  --option extra-substituters https://noctalia.cachix.org
  --option extra-trusted-public-keys noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=)

[ "$(id -u)" = 0 ] || { echo "run as root (sudo)"; exit 1; }
[ -d /sys/firmware/efi ] || { echo "not booted in UEFI mode"; exit 1; }
[ -d "$REPO/hosts/$HOST" ] || { echo "no host config at hosts/$HOST"; exit 1; }

DISKO="$REPO/hosts/$HOST/disko.nix"
DISK=$(grep 'device = ' "$DISKO" | head -1 | sed 's/.*"\(.*\)".*/\1/')
echo "Host:  $HOST"
echo "Disk:  $DISK"
lsblk -o NAME,SIZE,MODEL "$DISK"
read -rp "This ERASES $DISK. Type 'erase' to continue: " ok
[ "$ok" = erase ] || exit 1

if grep -q 'type = "luks"' "$DISKO"; then
  while :; do
    read -rsp "New disk encryption (LUKS) password: " p1; echo
    read -rsp "Repeat: " p2; echo
    [ -n "$p1" ] && [ "$p1" = "$p2" ] && break
    echo "Passwords don't match, try again."
  done
  printf '%s' "$p1" > /tmp/luks-password
  chmod 600 /tmp/luks-password
  unset p1 p2
fi

echo ">>> Partitioning and mounting with disko"
"${NIX[@]}" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --yes-wipe-all-disks "$DISKO"
rm -f /tmp/luks-password

echo ">>> Generating hardware-configuration.nix for this machine"
nixos-generate-config --no-filesystems --root /mnt --show-hardware-config \
  > "$REPO/hosts/$HOST/hardware-configuration.nix"

echo ">>> Copying the repo to /mnt/home/$USER_NAME/nixos-config"
mkdir -p "/mnt/home/$USER_NAME"
cp -r "$REPO" "/mnt/home/$USER_NAME/nixos-config"
TARGET="/mnt/home/$USER_NAME/nixos-config"
git -c safe.directory="*" -C "$TARGET" add -A

echo ">>> Installing (this downloads a few GB)"
nixos-install --no-root-passwd --flake "$TARGET#$HOST" \
  --option extra-substituters https://noctalia.cachix.org \
  --option extra-trusted-public-keys noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=

echo ">>> Set the login password for $USER_NAME"
nixos-enter --root /mnt -c "passwd $USER_NAME"
nixos-enter --root /mnt -c "chown -R $USER_NAME:users /home/$USER_NAME"

echo
echo "Done. Reboot, remove the USB stick, log in."
echo "Then commit the generated hardware-configuration.nix:"
echo "  cd ~/nixos-config && git commit -am '$HOST: real hardware-configuration'"
