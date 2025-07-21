#!/bin/bash

# Define the base directory (default is the current directory)
export BASE_DIR="${1:-$HOME/homelab}"

# Define the directory structure as an array
DIRECTORIES=(
    "$BASE_DIR/data"
    "$BASE_DIR/data/portainer"
    "$BASE_DIR/data/pihole"
    "$BASE_DIR/data/pihole/etc-pihole"
    "$BASE_DIR/data/pihole/etc-dnsmasq.d"
    "$BASE_DIR/data/grafana"
    "$BASE_DIR/data/prometheus"
    "$BASE_DIR/data/influxdb2"
    "$BASE_DIR/configs/influxdb2"
    "$BASE_DIR/configs/wireguard"
    "$BASE_DIR/configs/esphome"
    "$BASE_DIR/configs/jellyfin"
    "$BASE_DIR/configs/jellyfin/cache"
    "$BASE_DIR/data/mosquitto/data"
    "$BASE_DIR/data/mosquitto/log"
    "$BASE_DIR/data/n8n"
    "$BASE_DIR/data/n8n/local-files"
)

# setup env vars for Grp id
export GID=$(id -g $USER)

# Create directories
echo "Creating directory structure under '$BASE_DIR'..."
for DIR in "${DIRECTORIES[@]}"; do
    mkdir -p "$DIR"
    echo "Created: $DIR"
done

echo "Directory structure created successfully!"

#copy dependencies where needed
echo "Copying pihole config..."
cp "$BASE_DIR/configs/pihole/etc-pihole/custom.list" "$BASE_DIR/data/pihole/etc-pihole/custom.list" 
cp "$BASE_DIR/configs/pihole/etc-pihole/adlists.list" "$BASE_DIR/data/pihole/etc-pihole/adlists.list" 
cp "$BASE_DIR/configs/pihole/etc-pihole/pihole-FTL.conf" "$BASE_DIR/data/pihole/etc-pihole/pihole-FTL.conf"
cp "$BASE_DIR/configs/pihole/etc-dnsmasq.d/05-pihole-custom-cname.conf" "$BASE_DIR/data/pihole/etc-dnsmasq.d/05-pihole-custom-cname.conf"
echo "Pihole config copied..."

# create docker network
echo "Create docker network..."
docker network create --subnet=172.21.0.0/16 hlcl
echo "Docker network created..."
