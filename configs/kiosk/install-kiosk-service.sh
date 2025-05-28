#!/bin/bash

SERVICE_NAME="kiosk.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
USER_NAME="pi"

echo "🔧 Creating systemd service for Chromium kiosk..."

# Create the systemd service file
sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Chromium Kiosk with Screensaver
After=multi-user.target
Wants=graphical.target

[Service]
User=pi
WorkingDirectory=/home/pi
Environment=DISPLAY=:0
ExecStart=/usr/bin/startx
Restart=on-failure

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
