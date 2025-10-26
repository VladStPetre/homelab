---
title: Home Assistant
description: My Home Assistant stack with integrations, backups, and upgrade notes.
tags: [home-assistant, automations, dashboards, influxdb, timeseries, mosquitto, mqtt]
---

# HA Stack
Home automation stack containing Home Assistant, InfluxDb and mosquitto mqtt broker

## Why I run it
Single pane of glass for sensors, automations, and dashboards.

## homeassistant
Just a default docker configuration - backups and in-app configs are maintained directly in HA
```yaml
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:2025.10.1
    volumes:
      - ha-data:/config
      - /etc/localtime:/etc/localtime:ro
```

## influxdb
Time series db linked with HA to export all the data - keeping a longer history
```yaml
  influxdb:
    image: influxdb:2.7.12
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME_FILE=/run/secrets/influxdb2-admin-username
      - DOCKER_INFLUXDB_INIT_PASSWORD_FILE=/run/secrets/influxdb2-admin-password
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN_FILE=/run/secrets/influxdb2-admin-token
      - DOCKER_INFLUXDB_INIT_ORG=${DOCKER_INFLUXDB_INIT_ORG}
      - DOCKER_INFLUXDB_INIT_BUCKET=${DOCKER_INFLUXDB_INIT_BUCKET}
      - DOCKER_INFLUXDB_INIT_RETENTION=${DOCKER_INFLUXDB_INIT_RETENTION}
    secrets:
      - influxdb2-admin-username
      - influxdb2-admin-password
      - influxdb2-admin-token
    volumes:
      - influxdb2-config:/etc/influxdb2
      - influxdb2-data:/var/lib/influxdb2
```
## mosquitto
Mosquitto mqtt broker - linked with HA to automatically use mqtt sensors and more
```yaml
  mosquitto:
    image: eclipse-mosquitto:2.0.22
    ports:
      - "1883:1883"
      - "9001:9001"  # Optional WebSocket
    configs:
      - source: mosquitto_config
        target: /mosquitto/config/mosquitto.conf
    volumes:
      - mosquitto-data:/mosquitto/data
      - mosquitto-logs:/mosquitto/log
```

mosquitto.conf - dafault config
```
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log

listener 1883
allow_anonymous true  # Change to false for secure setups

```

## Reverse proxy / TLS
// WIP

## Backups & Upgrades
//WIP

## Monitoring
// WIP

## Troubleshooting
// WIP
