#!/bin/bash
# Kill any existing xboxdrv
sudo killall -9 xboxdrv 2>/dev/null
sleep 0.5

# Press Guide to toggle between Desktop mode and Game mode
sudo xboxdrv \
  --silent \
  --detach-kernel-driver \
  --dpad-as-button \
  --deadzone 4000 \
  --ui-clear \
  --ui-buttonmap guide=XK_Super_L,a=BTN_LEFT,b=BTN_RIGHT,x=BTN_MIDDLE,y=KEY_V \
  --ui-buttonmap start=KEY_LEFTMETA+XK_d,back=KEY_LEFTMETA+XK_q \
  --ui-buttonmap lb=XK_Left,rb=XK_Right,lt=BTN_LEFT,rt=BTN_RIGHT \
  --ui-buttonmap dl=KEY_LEFT,dr=KEY_RIGHT,du=KEY_UP,dd=KEY_DOWN \
  --ui-axismap "x2^dead:4000=REL_X:7:15,y2^dead:4000=REL_Y:7:15" \
  --next-config \
  --silent \
  --detach-kernel-driver \
  --deadzone 4000 \
  --toggle void \
  &
