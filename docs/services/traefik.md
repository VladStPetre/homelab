---
title: Traefik
description: Edge router for reverse proxy, TLS (Let's Encrypt), and middlewares.
tags: [traefik, reverse-proxy, tls, middleware]
---

## Why I run it
Central routing, automatic certificates, and clean service discovery.

## Docker Compose (example)
```yaml
services:
  traefik:
    image: traefik:v3.0
    container_name: traefik
    restart: unless-stopped
    command:
      - "--api.insecure=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--providers.docker=true"
      - "--certificatesresolvers.le.acme.tlschallenge=true"
      - "--certificatesresolvers.le.acme.email=vlad@example.com"
      - "--certificatesresolvers.le.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./data/traefik:/letsencrypt
    labels:
      - "traefik.enable=true"
```

## Common Router Example
```yaml
labels:
  - "traefik.http.routers.app.rule=Host(`app.example.com`)"
  - "traefik.http.routers.app.entrypoints=websecure"
  - "traefik.http.routers.app.tls.certresolver=le"
```

## Middlewares
- `redirect-to-https`, `secure-headers`, `rate-limit`, `auth@file`.

## Observability
- Enable Traefik metrics (`--metrics.prometheus=true`) and scrape with Prometheus.
