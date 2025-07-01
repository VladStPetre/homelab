#!/bin/bash
#
# mount-external-hdd.sh
# Ensures /mnt/media (your USB HDD) exists and is mounted via /etc/fstab.
#

MNT_POINT="/mnt/media"
LOG_FILE="/var/log/mount-hdd.log"

timestamp() {
  date '+%F %T'
}

{
  echo "$(timestamp) - Checking mount point ${MNT_POINT}..."

  # 1) Make sure the directory exists
  if [ ! -d "${MNT_POINT}" ]; then
    echo "$(timestamp) - ${MNT_POINT} does not exist, creating..."
    mkdir -p "${MNT_POINT}" \
      && echo "$(timestamp) - Created ${MNT_POINT}" \
      || { echo "$(timestamp) - ERROR: Failed to create ${MNT_POINT}"; exit 1; }
  fi

  # 2) If already mounted, nothing to do
  if mountpoint -q "${MNT_POINT}"; then
    echo "$(timestamp) - Already mounted."
    exit 0
  fi

  # 3) Try to mount via fstab
  echo "$(timestamp) - Not mounted. Running mount -a..."
  if mount -a; then
    if mountpoint -q "${MNT_POINT}"; then
      echo "$(timestamp) - SUCCESS: ${MNT_POINT} is now mounted."
      exit 0
    else
      echo "$(timestamp) - ERROR: mount -a ran without error, but ${MNT_POINT} is still not mounted."
      exit 1
    fi
  else
    echo "$(timestamp) - ERROR: mount -a failed."
    exit 1
  fi

} >> "${LOG_FILE}" 2>&1
