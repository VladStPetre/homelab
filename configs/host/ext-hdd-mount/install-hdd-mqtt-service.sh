#!/bin/bash

echo "=== Providing execution privileges for python scripts ==="
# === Make scripts executable ===
chmod +x /home/adu/homelab/configs/host/ext-hdd-mount/hdd-mount-mqtt-*.py
echo "=== privileges done ==="

echo "=== Creating -> hdd-mount-mqtt-sensors.service ==="
# === Create sensor service ===
cat <<EOF | sudo tee /etc/systemd/system/hdd-mount-mqtt-sensors.service > /dev/null
[Unit]
Description=Echo ext hdd MQTT Sensors Publisher
After=network.target

[Service]
Environment="MQTT_BROKER_IP=$MQTT_BROKER_IP"
ExecStartPre=/bin/sleep 40
ExecStart=/usr/bin/python3 /home/adu/homelab/configs/host/ext-hdd-mount/hdd-mount-mqtt-sensors.py
Restart=always
User=adu
WorkingDirectory=/home/adu/homelab/configs/host/ext-hdd-mount
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
echo "=== Created -> hdd-mount-mqtt-sensors.service ==="

echo "=== Creating -> hdd-mount-mqtt-cmd.service ==="
# === Create listener service ===
cat <<EOF | sudo tee /etc/systemd/system/hdd-mount-mqtt-cmd.service > /dev/null
[Unit]
Description=Echo ext hdd MQTT Command Listener
After=network.target

[Service]
Environment="MQTT_BROKER_IP=$MQTT_BROKER_IP"
ExecStartPre=/bin/sleep 40
ExecStart=/usr/bin/python3 /home/adu/homelab/configs/host/ext-hdd-mount/hdd-mount-mqtt-cmd.py
Restart=always
User=adu
WorkingDirectory=/home/adu/homelab/configs/host/ext-hdd-mount
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
echo "=== Created -> hdd-mount-mqtt-cmd.service ==="

# === Enable and start both services ===

echo "=== Reloading daemon ==="
sudo systemctl daemon-reload

echo "=== Enabling services ==="
sudo systemctl enable hdd-mount-mqtt-sensors.service
sudo systemctl enable hdd-mount-mqtt-cmd.service

echo "=== Starting services ==="
sudo systemctl start hdd-mount-mqtt-sensors.service
sudo systemctl start hdd-mount-mqtt-cmd.service

echo "✅ Services installed and started."
