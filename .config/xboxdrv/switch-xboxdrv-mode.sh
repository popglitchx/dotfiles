#!/bin/bash
sudo xboxdrv-ctl toggle
MODE=$(cat /tmp/xboxdrv-mode 2>/dev/null)
notify-send -u low "xboxdrv" "Switched to ${MODE^} mode"
