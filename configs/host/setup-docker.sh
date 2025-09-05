#!/bin/bash

set -e

echo "=== Updating system ==="
sudo apt-get update
sudo apt-get upgrade -y

echo "=== Installing required packages ==="
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git

echo "=== Installing Docker ==="
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

echo "=== Adding $USER to the docker group ==="
sudo usermod -aG docker $USER

echo "=== Installing Docker Compose plugin ==="
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins

ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
    COMPOSE_ARCH="aarch64" # initially was arm64 - but not found in releases
elif [ "$ARCH" = "x86_64" ]; then
    COMPOSE_ARCH="x86_64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${COMPOSE_ARCH}" -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "=== Docker Compose version installed ==="
docker compose version

echo "=== Git version installed ==="
git --version

echo "Create docker network..."
# compose
# docker network create --subnet=172.21.0.0/16 hlcl
# swarm
docker network create --subnet=172.21.0.0/16 -d overlay hlel
echo "Docker network created..."

echo "=== All done! ==="
echo "You may need to log out and back in for docker group permissions to take effect."