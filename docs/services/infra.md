---
title: Infra
description: Infrastructure tools 
tags: [infrastructure, adblock, network, reverse proxy, tls, loadbalance]
---

# Infra stack

## pi-hole
```yaml
  pihole:
    image: pihole/pihole:2025.08.0
    environment:
      - TZ=${TIMEZONE}
      - FTLCONF_webserver_api_password=${PIHOLE_PASS}
      - FTLCONF_dns_listeningMode=ALL
      - FTLCONF_dns_upstreams=1.1.1.1;1.0.0.1
      - VIRTUAL_HOST=pihole.${DOMAIN_NAME_SEC}
      - DNSMASQ_USER=root
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "81:80"
    volumes:
      - pihole-data:/etc/pihole
      - pihole-dnsmasq-data:/etc/dnsmasq.d
    cap_add:
      - NET_ADMIN
      - SYS_TIME
      - SYS_NICE
      - NET_BIND_SERVICE
```

## wireguard
```yaml
  wireguard:
    image: lscr.io/linuxserver/wireguard:1.0.20250521
    cap_add:
      - NET_ADMIN
      - SYS_MODULE #optional
    environment:
      - PUID=${CUID}
      - PGID=${CGID}
      - TZ=${TIMEZONE}
      - SERVERURL=${WG_SERVER_URL}
      - SERVERPORT=${WG_SERVER_PORT}
      - PEERS=5 #optional
      - PEERDNS=auto #optional
      - INTERNAL_SUBNET=10.13.13.0 #optional
      - ALLOWEDIPS=0.0.0.0/0 #optional
      - PERSISTENTKEEPALIVE_PEERS=all #optional
      - LOG_CONFS=true #optional
    ports:
      - "51820:51820/udp"
    volumes:
      - wireguard-data:/config
      - /lib/modules:/lib/modules #optional
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
```

## traefik
```yaml
  traefik:
    image: traefik:v3.5.3
    ports:
      - "80:80"
      - "443:443"
    environment:
      #      - CF_API_EMAIL=user@example.com
      #      - CF_DNS_API_TOKEN_FILE=/run/secrets/cf_api_token
      - CLOUDFLARE_DNS_API_TOKEN=${CF_DNS_API_TOKEN}
    secrets:
      - cf_api_token
    configs:
      - source: traefik_yaml_config
        target: /etc/traefik/traefik.yml
      - source: traefik_config_yaml_config
        target: /etc/traefik/config.yml
    volumes:
      - traefik-data:/etc/traefik
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    deploy:
      labels:
        - "portainer.io/managed=true"
        - "io.portainer.accesscontrol.users=admin"
        - "traefik.enable=true"
        - "traefik.swarm.network=hlel"
        - "traefik.http.routers.traefik.rule=Host(`traefik.${DOMAIN_NAME}`)"
        - "traefik.http.routers.traefik.entrypoints=websecure"
        - "traefik.http.routers.traefik.tls=true"
        - "traefik.http.routers.traefik.tls.certresolver=cloudflare"
        - "traefik.http.routers.traefik.tls.domains[0].main=${DOMAIN_NAME_SEC}"
        - "traefik.http.routers.traefik.tls.domains[0].sans=*.${DOMAIN_NAME_SEC}"
        - "traefik.http.routers.traefik.service=api@internal"
          # Satisfy Swarm provider: declare an explicit (unused) backend service/port.
        # It's OK because no router points to it.
        - "traefik.http.services.noop.loadbalancer.server.port=65535"
```

## Compose
// WIP

## Strategy
// WIP