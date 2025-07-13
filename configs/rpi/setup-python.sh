#!/bin/bash
set -e

echo "Updating package lists..."
sudo apt-get update

echo "Installing Python 3 and pip..."
sudo apt-get install -y python3 python3-pip python3-paho-mqtt

echo "Installation complete."
python3 -m pip show paho-mqtt
