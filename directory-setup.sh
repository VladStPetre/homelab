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
)

# Create directories
echo "Creating directory structure under '$BASE_DIR'..."
for DIR in "${DIRECTORIES[@]}"; do
    mkdir -p "$DIR"
    echo "Created: $DIR"
done

echo "Directory structure created successfully!"
