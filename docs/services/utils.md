---
title: Utils
description: Utilities to ease hamelab usage
tags: [homepage, n8n, portainer, dashboard, automations, docker management]
---

# Utils stack

## portainer
```yaml
  portainer:
    image: portainer/portainer-ce:2.34.0
    command: -H unix:///var/run/docker.sock
    volumes:
      - portainer-data:/data
      - /var/run/docker.sock:/var/run/docker.sock
```
## n8n
```yaml
  n8n:
    image: docker.n8n.io/n8nio/n8n:1.115.0
    environment:
      - N8N_HOST=${SUBDOMAIN}.${DOMAIN_NAME}
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - N8N_SECURE_COOKIE=${N8N_SECURE_COOKIE}
      - WEBHOOK_URL=https://${SUBDOMAIN}.${DOMAIN_NAME}/
      - GENERIC_TIMEZONE=${TIMEZONE}
    volumes:
      - n8n-data:/home/node/.n8n
      - n8n-local-files:/files
```
    
## homepage
```yaml
  homepage:
    image: ghcr.io/gethomepage/homepage:v1.5.0
    environment:
      - TZ=Europe/Bucharest
      - HOMEPAGE_ALLOWED_HOSTS=home.${DOMAIN_NAME}
      - HOMEPAGE_VAR_BASE_DOMAIN=${DOMAIN_NAME}
      - HOMEPAGE_VAR_NAS_ADDR=${NAS_ADDR}
      - HOMEPAGE_VAR_EXT_DOMAIN_NAME=${EXT_DOMAIN_NAME}
    configs:
      - source: homepage_settings_yaml
        target: /app/config/settings.yaml
      - source: homepage_services_yaml
        target: /app/config/services.yaml
      - source: homepage_bookmarks_yaml
        target: /app/config/bookmarks.yaml
      - source: homepage_widgets_yaml
        target: /app/config/widgets.yaml
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      # Optional: persistent user assets (custom icons/backgrounds):
      - homepage-data:/app/config/user
```


## Strategy
// WIP