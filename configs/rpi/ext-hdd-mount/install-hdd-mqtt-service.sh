#!/bin/bash

# === Make scripts executable ===
chmod +x /home/adu/homelab/configs/rpi/ext-hdd-mount/hdd-mount-mqtt-*.py

# === Create sensor service ===
cat <<EOF | sudo tee /etc/systemd/system/hdd-mount-mqtt-sensors.service > /dev/null
[Unit]
Description=Echo ext hdd MQTT Sensors Publisher
After=network.target

[Service]
Environment="MQTT_BROKER_IP=$MQTT_BROKER_IP"
ExecStart=/usr/bin/python3 /home/adu/homelab/configs/rpi/ext-hdd-mount/hdd-mount-mqtt-sensors.py
Restart=on-failure
User=adu
WorkingDirectory=/home/adu/homelab/configs/rpi/ext-hdd-mount

[Install]
WantedBy=multi-user.target
EOF

# === Create listener service ===
cat <<EOF | sudo tee /etc/systemd/system/hdd-mount-mqtt-cmd.service > /dev/null
[Unit]
Description=Echo ext hdd MQTT Command Listener
After=network.target

[Service]
Environment="MQTT_BROKER_IP=$MQTT_BROKER_IP"
ExecStart=/usr/bin/python3 /home/adu/homelab/configs/rpi/ext-hdd-mount/hdd-mount-mqtt-cmd.py
Restart=on-failure
User=adu
WorkingDirectory=/home/adu/homelab/configs/rpi/ext-hdd-mount

[Install]
WantedBy=multi-user.target
EOF

# === Enable and start both services ===
sudo systemctl daemon-reload
sudo systemctl enable hdd-mount-mqtt-sensors.service
sudo systemctl enable hdd-mount-mqtt-cmd.service
sudo systemctl start hdd-mount-mqtt-sensors.service
sudo systemctl start hdd-mount-mqtt-cmd.service

echo "✅ Services installed and started."
