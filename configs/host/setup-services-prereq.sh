#!/bin/bash

set -e


echo "===  Create docker network  ==="
docker network create --subnet=172.21.0.0/16 -d overlay hlel
echo "===  Docker network created  ==="

echo "===  Create docker secrets  ==="
printf 'admin' | docker secret create influxdb2-admin-username -
printf 'vladminmax.2251' | docker secret create influxdb2-admin-password -
printf 'fmfi2NeHqnW5MzeTt2NA3x2r!DWFD2wc' | docker secret create influxdb2-admin-token -
printf 'fuUcdStQCAymj5BS7e7FNyxdhR9XM77u' | docker secret create immich_pg_password -
echo "===  Docker secrets created  ==="


echo "===  Create docker configs  ==="
docker config create traefik_yaml_config ./configs/traefik/traefik.yml
docker config create traefik_config_yaml_config ./configs/traefik/config.yml

docker config create mosquitto_config ./configs/mosquitto/mosquitto.conf
docker config create nas_ssh_key ~/.ssh/kiri-nas

docker config create alloy_config ./configs/alloy/config.alloy
docker config create loki_config ./configs/loki/config.yaml
docker config create prom_config ./configs/prometheus/prometheus.yaml

docker config create homepage_settings_yaml ./configs/homepage/settings.yaml
docker config create homepage_services_yaml ./configs/homepage/services.yaml
docker config create homepage_bookmarks_yaml ./configs/homepage/bookmarks.yaml
docker config create homepage_widgets_yaml ./configs/homepage/widgets.yaml
echo "===  Docker configs created  ==="

echo "===  Deploy stacks  ==="
docker stack deploy -c stacks/backup/docker-stack.yaml --prune --resolve-image=changed backup
docker stack deploy -c stacks/gh-runner/docker-stack.yaml --prune --resolve-image=changed gh-runner
docker stack deploy -c stacks/ha/docker-stack.yaml --prune --resolve-image=changed ha
docker stack deploy -c stacks/immich/docker-stack.yaml --prune --resolve-image=changed immich
docker stack deploy -c stacks/infra/docker-stack.yaml --prune --resolve-image=changed infra
docker stack deploy -c stacks/kiosk/docker-stack.yaml --prune --resolve-image=changed kiosk
docker stack deploy -c stacks/media/docker-stack.yaml --prune --resolve-image=changed media
docker stack deploy -c stacks/monitoring/docker-stack.yaml --prune --resolve-image=changed monitoring
docker stack deploy -c stacks/utils/docker-stack.yaml --prune --resolve-image=changed utils
echo "===  Stacks deployed  ==="