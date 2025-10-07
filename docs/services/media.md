---
title: Media Services
description: Media stack (e.g., Jellyfin/Plex, qBittorrent, Sonarr/Radarr, Bazarr, Prowlarr).
tags: [media, jellyfin, plex, sonarr, radarr]
---

## Compose (example)
```yaml
services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Bucharest
    volumes:
      - ./data/jellyfin/config:/config
      - /mnt/media:/media
    ports:
      - "8096:8096"
    restart: unless-stopped
```

## Reverse proxy
- Use Traefik with a subdomain and TLS.

## Storage
- Separate library and transcode paths. Prefer SSD for transcode.

## Notes
- Hardware transcoding requires device pass-through (QuickSync/NVENC).
