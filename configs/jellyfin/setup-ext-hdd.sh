#!/bin/bash
set -e

# 1. Install ntfs-3g if missing
echo "Installing ntfs-3g (if not present)..."
sudo apt-get update
sudo apt-get install -y ntfs-3g

# 2. List NTFS partitions and get UUID
echo "Detecting NTFS drives..."
lsblk -f | grep ntfs
echo
read -p "Enter the device (e.g. /dev/sda1) of your NTFS USB drive: " DRIVE

UUID=$(sudo blkid -s UUID -o value "$DRIVE")
if [ -z "$UUID" ]; then
    echo "Could not detect UUID for $DRIVE. Exiting."
    exit 1
fi
echo "Found UUID: $UUID"

# 3. Ask for mount point
DEFAULT_MOUNT="/mnt/media"
read -p "Enter desired mount point (default: $DEFAULT_MOUNT): " MOUNTPOINT
MOUNTPOINT="${MOUNTPOINT:-$DEFAULT_MOUNT}"

# 4. Ask for user (default is 'pi')
DEFAULT_USR_ID=$(id -u pi 2>/dev/null || echo 1000)
DEFAULT_GRP_ID=$(id -g pi 2>/dev/null || echo 1000)
read -p "Enter UID to own files (default: $DEFAULT_USR_ID): " USR_ID
USR_ID="${USR_ID:-$DEFAULT_USR_ID}"
read -p "Enter GID to own files (default: $DEFAULT_GRP_ID): " GRP_ID
GRP_ID="${GRP_ID:-$DEFAULT_GRP_ID}"

# 5. Ask for umask (default 022)
read -p "Enter umask for permissions (default: 022, use 000 for all users RW): " UMASK
UMASK="${UMASK:-022}"

# 6. Create mount point if it doesn't exist
if [ ! -d "$MOUNTPOINT" ]; then
    echo "Creating mount point $MOUNTPOINT ..."
    sudo mkdir -p "$MOUNTPOINT"
fi

# 7. Add to /etc/fstab
FSTAB_LINE="UUID=${UUID}   ${MOUNTPOINT}   ntfs-3g   defaults,nofail,uid=${USR_ID},gid=${GRP_ID},umask=${UMASK},x-systemd.automount   0   0"

echo "Adding the following line to /etc/fstab:"
echo "$FSTAB_LINE"

# Backup and append
sudo cp /etc/fstab /etc/fstab.backup.$(date +%s)
echo "$FSTAB_LINE" | sudo tee -a /etc/fstab

# 8. Reload and test
sudo systemctl daemon-reload
echo "Attempting to mount all drives (non-blocking)..."
sudo mount -a

echo
echo "Done! Your NTFS drive should be mounted at $MOUNTPOINT."
echo "It will mount automatically on boot, even if not present at startup (nofail, x-systemd.automount)."
echo "Original /etc/fstab is backed up as /etc/fstab.backup.TIMESTAMP."
