#!/bin/bash

SCREENSAVER_PATH="file:///home/pi/homelab/configs/kiosk/screensaver.html"
INACTIVITY_LIMIT=120000  # 2 minutes in milliseconds

while true; do
  idle_time=$(xprintidle)
  if [ "$idle_time" -gt "$INACTIVITY_LIMIT" ]; then
    if ! pgrep -f "screensaver.html" > /dev/null; then
      chromium-browser --app="$SCREENSAVER_PATH" --kiosk --noerrdialogs --disable-infobars --incognito &
    fi
  fi
  sleep 5
done
