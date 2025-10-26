---
title: Media Services
description: Media stack for personal movie/series library
tags: [media, jellyfin, movies, shows, series, self-host]
---

# Media Stack

## jellyfin
```yaml
  jellyfin:
    image: jellyfin/jellyfin:2025100605
    user: root
    ports:
      - "8096:8096"
    environment:
      - PUID=${CUID}
      - PGID=${CGID}
      - TZ=${TIMEZONE}
    volumes:
      - jellyfin-data:/config
      - /mnt/media:/media
```

## qbittorrent
```yaml
  qbittorrent:
    image: linuxserver/qbittorrent:20.04.1
    ports:
      - "8081:8081"              # web UI
      - "6881:6881"              # torrent traffic TCP
      - "6881:6881/udp"          # torrent traffic UDP
    environment:
      - PUID=${CUID}                # your local user ID
      - PGID=${CGID}                # your local group ID
      - TZ=${TIMEZONE}
      - WEBUI_PORT=8081
      - UMASK_SET=000            # sensible file perms
    volumes:
      - qbittorrent-data:/config
      - /mnt/media/Movies:/movies
      - /mnt/media/Series:/series
      - /mnt/media/Watch:/watch
```

## Storage
external HDD

## Notes
// WIP
