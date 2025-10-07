---
title: DNS & Networking
description: Local DNS, DHCP, and ad-blocking (e.g., AdGuard Home / Pi-hole). VLANs and subnets.
tags: [dns, dhcp, adguard, pihole, vlan]
---

## Compose (AdGuard example)
```yaml
services:
  adguard:
    image: adguard/adguardhome
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3000:3000"
      - "80:80"
    volumes:
      - ./data/adguard/work:/opt/adguardhome/work
      - ./data/adguard/conf:/opt/adguardhome/conf
    restart: unless-stopped
```

## Network Layout
- VLAN10: Servers
- VLAN20: Clients
- VLAN30: IoT

## Notes
- Disable DNS rebinding protection for internal hostnames if needed.
