#!/bin/bash
#
# mount-external-hdd.sh
# Ensures /mnt/media (your USB HDD) is mounted.
#

MNT_POINT="/mnt/media"

# Try to mount via fstab if not already mounted
if ! mountpoint -q "${MNT_POINT}"; then
  echo "$(date '+%F %T') - ${MNT_POINT} not mounted, attempting mount…" >> /var/log/mount-hdd.log
  if mount "${MNT_POINT}"; then
    echo "$(date '+%F %T') - Successfully mounted ${MNT_POINT}" >> /var/log/mount-hdd.log
  else
    echo "$(date '+%F %T') - ERROR mounting ${MNT_POINT}" >> /var/log/mount-hdd.log
  fi
else
  echo "$(date '+%F %T') - ${MNT_POINT} already mounted" >> /var/log/mount-hdd.log
fi
