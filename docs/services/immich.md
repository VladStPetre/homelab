---
title: Immich
description: Back up photos
tags: [self-host, Immich, open-source, photos, images, backup]
---

# Immich stack
Immich - open source photos mamagement app to self-host

## Compose
```yaml
database:
    image: ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_PASSWORD_FILE=/run/secrets/immich_pg_password
      - POSTGRES_INITDB_ARGS="--data-checksums"
      # DB_STORAGE_TYPE: "HDD"   # uncomment if your DB disk is HDD
    secrets:
      - immich_pg_password
    volumes:
      - immich_postgres:/var/lib/postgresql/data

redis:
    image: docker.io/valkey/valkey:8-bookworm
    volumes:
      - immich_valkey_data:/data

immich-server:
    image: ghcr.io/immich-app/immich-server:v2.0.1
    environment:
      - TZ=${TIMEZONE}
      # DB (must match database service)
      - DB_HOSTNAME=database
      - DB_USERNAME=${POSTGRES_USER}
      - DB_PASSWORD_FILE=/run/secrets/immich_pg_password
      - DB_DATABASE_NAME=${POSTGRES_DB}
      - REDIS_HOSTNAME=redis
      - REDIS_PORT=6379
      - CREDENTIALS_DIRECTORY=/run/secrets
    secrets:
      - immich_pg_password
    volumes:
      - immich_library:/data
      - /etc/localtime:/etc/localtime:ro
```

## Strategy
// WIP