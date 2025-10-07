---
title: Backups
description: Strategies, tools, and retention for volumes and configs.
tags: [backups, restic, borg, s3, minio]
---

## Strategy
- 3-2-1: three copies, two media, one off-site.
- Daily diffs, weekly fulls. Keep 30/12/3 (days/months/years).

## Tools
- `restic` to S3/MinIO
- `borgbackup` to local NAS

## Example (restic via cron)
```bash
RESTIC_PASSWORD=change-me
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=yyyy
restic -r s3:https://minio.example.com/backups/homelab backup /path/to/data
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune
```

## Restores
- Practice: restore to a temp path monthly; document timings.
