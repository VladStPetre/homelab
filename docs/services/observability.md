---
title: Observability (Prometheus + Grafana)
description: Metrics scraping, dashboards, and alerts.
tags: [prometheus, grafana, alertmanager, loki]
---

## Compose (example)
```yaml
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./data/prometheus:/prometheus
      - ./configs/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    ports: ["9090:9090"]
    restart: unless-stopped

  grafana:
    image: grafana/grafana
    volumes:
      - ./data/grafana:/var/lib/grafana
    ports: ["3000:3000"]
    restart: unless-stopped
```

## Scrape targets
- Node Exporter (host metrics)
- cAdvisor (container metrics)
- Traefik (/metrics)
- App-specific exporters

## Dashboards
- Import IDs: 1860 (Node Exporter), 12239 (Traefik), 19006 (Docker).

## Alerts
- Define SLOs (uptime, latency). Route critical alerts via Alertmanager to Telegram/Email.
