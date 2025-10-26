---
title: Monitoring
description: Monitor host and docker services
tags: [monitor, grafana, prometheus, loki, alloy, metrics, logs]
---

# Backup stack

## grafana
```yaml
  grafana:
    image: grafana/grafana-oss:12.1.1
    user: ${CUID}
    security_opt:
      - no-new-privileges:true
    environment:
      - GF_SECURITY_ALLOW_EMBEDDING=true
      - GF_ANALYTICS_REPORTING_ENABLED=false          # stop calls to stats.grafana.org
      - GF_ANALYTICS_CHECK_FOR_UPDATES=false          # optional: reduce other outbound checks
      - GF_ANALYTICS_CHECK_FOR_PLUGIN_UPDATES=false   # optional
    volumes:
      - grafana-data:/var/lib/grafana
```

## prometheus
```yaml
  prometheus:
    image: prom/prometheus:v3.6.0
    user: root
    configs:
      - source: prom_config
        target: /etc/prometheus/prometheus.yaml
    volumes:
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yaml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=401d'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
      - '--web.enable-remote-write-receiver'
```

## loki
```yaml
  loki:
    image: grafana/loki:3.5.5
    command: "-config.file=/etc/loki/config.yaml"
    user: ${CUID}
    configs:
      - source: loki_config
        target: /etc/loki/config.yaml
    volumes:
      - loki-data:/loki:rw
```

## alloy
```yaml
  alloy:
    image: grafana/alloy:v1.11.0
    hostname: echo
    command:
      - run
      - --server.http.listen-addr=0.0.0.0:12345
      - --storage.path=/var/lib/alloy/data
      - /etc/alloy/config.alloy
    configs:
      - source: alloy_config
        target: /etc/alloy/config.alloy
    volumes:
      - alloy-data:/var/lib/alloy/data
      - /:/rootfs:ro
      - /run:/run:ro
      - /var/log:/var/log:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker/:ro
      - /run/udev/data:/run/udev/data:ro
```

## Integration
// WIP - integration for all of them withing the homelab