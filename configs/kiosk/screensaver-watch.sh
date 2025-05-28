#!/bin/bash

LOG_FILE="/home/pi/screensaver.log"
SCREENSAVER_PATH="file:///home/pi/homelab/configs/kiosk/screensaver.html"
INACTIVITY_LIMIT=120000  # 2 minutes

echo "🕒 Screensaver watchdog started" >> "$LOG_FILE"

while true; do
  idle_time=$(xprintidle)
  echo "$(date) - Idle: $idle_time ms" >> "$LOG_FILE"
  
  if [ "$idle_time" -gt "$INACTIVITY_LIMIT" ]; then
    if ! pgrep -f screensaver.html > /dev/null; then
      echo "$(date) - Idle limit reached. Launching screensaver." >> "$LOG_FILE"
      chromium-browser --app="$SCREENSAVER_PATH" --kiosk --noerrdialogs --disable-infobars --incognito &
    else
      echo "$(date) - Screensaver already running." >> "$LOG_FILE"
    fi
  fi

  sleep 5
done
