#!/bin/bash
# Game mode: raw controller passthrough (no mouse/keyboard emulation)
sudo killall -9 xboxdrv 2>/dev/null
sleep 0.5

sudo xboxdrv \
  --silent \
  --detach-kernel-driver \
  --deadzone 4000 \
  &
