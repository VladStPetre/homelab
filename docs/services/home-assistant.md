---
title: Home Assistant
description: My Home Assistant stack with integrations, backups, and upgrade notes.
tags: [home-assistant, automations, dashboards]
---

## Why I run it
Single pane of glass for sensors, automations, and dashboards.

## Docker Compose (example)
```yaml
services:
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:stable
    container_name: homeassistant
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./data/homeassistant:/config
    environment:
      - TZ=Europe/Bucharest
```

## Reverse proxy / TLS
- Usually not proxied when using `network_mode: host`. If proxied, ensure websockets are forwarded.

## Backups & Upgrades
- Weekly full snapshot via `ha backups`.
- Keep 3 versions. Export to object storage (e.g., S3/MinIO).

## Monitoring
- Export Prom metrics via integrations or Node-Exporter on host.
- Grafana panels for automations duration, db size, errors.

## Troubleshooting
- Check `home-assistant.log` in `/config`.
