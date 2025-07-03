#!/bin/bash


##### DO NOT USE anymore



SERVICE_NAME="vexthdd.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
USER_NAME="pi"

echo "🔧 Creating systemd service for Chromium kiosk..."

# Create the systemd service file
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Ensure external USB HDD is mounted
After=local-fs.target
Wants=local-fs.target

[Service]
Type=oneshot
ExecStart=/home/pi/homelab/configs/jellyfin/mount-external-hdd.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Service file created at $SERVICE_PATH"

# Reload systemd daemon to pick up the new service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# Enable the kiosk service
sudo systemctl enable "$SERVICE_NAME"

echo "✅ Service enabled. It will start on boot."
echo "🚀 You can start it now with: sudo systemctl start $SERVICE_NAME"