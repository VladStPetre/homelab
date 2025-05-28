#!/bin/bash

SERVICE_NAME="kiosk.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
USER_NAME="pi"

echo "🔧 Creating systemd service for Chromium kiosk..."

# Create the systemd service file
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Chromium Kiosk with Screensaver
After=graphical.target

[Service]
User=$USER_NAME
Environment=XDG_RUNTIME_DIR=/run/user/$(id -u $USER_NAME)
ExecStart=/usr/bin/startx
Restart=always
RestartSec=5s

[Install]
WantedBy=graphical.target
EOF

echo "✅ Service file created at $SERVICE_PATH"

# Reload systemd daemon to pick up the new service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# Enable the kiosk service
sudo systemctl enable "$SERVICE_NAME"

echo "✅ Service enabled. It will start on boot."
echo "🚀 You can start it now with: sudo systemctl start $SERVICE_NAME"
