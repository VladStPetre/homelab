#!/bin/bash

# CONFIG - Update with your MQTT broker IP
MQTT_BROKER="192.168.7.173"

# === Make scripts executable ===
chmod +x /home/pi/homelab/configs/kiosk/pi3_mqtt_*.py

# === Create sensor service ===
cat <<EOF | sudo tee /etc/systemd/system/pi3-mqtt-sensors.service > /dev/null
[Unit]
Description=Pi3 MQTT Sensors Publisher
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/homelab/configs/pi3_mqtt_sensors.py
Restart=always
User=pi
WorkingDirectory=/home/pi

[Install]
WantedBy=multi-user.target
EOF

# === Create listener service ===
cat <<EOF | sudo tee /etc/systemd/system/pi3-mqtt-listener.service > /dev/null
[Unit]
Description=Pi3 MQTT Command Listener
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/homelab/configs/pi3_mqtt_listener.py
Restart=always
User=pi
WorkingDirectory=/home/pi

[Install]
WantedBy=multi-user.target
EOF

# === Enable and start both services ===
sudo systemctl daemon-reload
sudo systemctl enable pi3-mqtt-sensors.service
sudo systemctl enable pi3-mqtt-listener.service
sudo systemctl start pi3-mqtt-sensors.service
sudo systemctl start pi3-mqtt-listener.service

echo "✅ Services installed and started."
