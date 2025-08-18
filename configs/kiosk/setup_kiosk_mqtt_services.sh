#!/bin/bash

# === Make scripts executable ===
chmod +x /home/pi/homelab/configs/kiosk/rpi_mqtt_*.py

# === Create sensor service ===
cat <<EOF | sudo tee /etc/systemd/system/rpi-mqtt-sensors.service > /dev/null
[Unit]
Description=Pi4 MQTT Sensors Publisher
After=network.target

[Service]
Environment="MQTT_BROKER=$MQTT_BROKER_IP"
ExecStart=/usr/bin/python3 /home/pi/homelab/configs/kiosk/rpi_mqtt_sensors.py
Restart=always
User=pi
WorkingDirectory=/home/pi/homelab/configs/kiosk

[Install]
WantedBy=multi-user.target
EOF

# === Create listener service ===
cat <<EOF | sudo tee /etc/systemd/system/rpi-mqtt-listener.service > /dev/null
[Unit]
Description=Pi4 MQTT Command Listener
After=network.target

[Service]
Environment="MQTT_BROKER=$MQTT_BROKER_IP"
ExecStart=/usr/bin/python3 /home/pi/homelab/configs/kiosk/rpi_mqtt_listener.py
Restart=always
User=pi
WorkingDirectory=/home/pi/homelab/configs/kiosk

[Install]
WantedBy=multi-user.target
EOF

# === Enable and start both services ===
sudo systemctl daemon-reload
sudo systemctl enable rpi-mqtt-sensors.service
sudo systemctl enable rpi-mqtt-listener.service
sudo systemctl start rpi-mqtt-sensors.service
sudo systemctl start rpi-mqtt-listener.service

echo "✅ Services installed and started."
