#!/bin/bash

# Define the base directory (default is the current directory)
BASE_DIR="${1:-/home/pi/homelab}"

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
    "$BASE_DIR/data/mosquitto/config"
    "$BASE_DIR/data/mosquitto/data"
    "$BASE_DIR/data/mosquitto/log"
)

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
cp "$BASE_DIR/configs/pihole/etc-dnsmasq.d/05-pihole-custom-cname.conf" "$BASE_DIR/data/pihole/etc-dnsmasq.d/05-pihole-custom-cname.conf" 
echo "Pihole config copied..."

echo "Copying mosquitto config..."
cp "$BASE_DIR/configs/mosquitto/mosquitto.conf" "$BASE_DIR/data/mosquitto/config/mosquitto.conf" 
echo "Mosquitto config copied..."

# create docker network
docker network create --subnet=172.21.0.0/16 hlcl

