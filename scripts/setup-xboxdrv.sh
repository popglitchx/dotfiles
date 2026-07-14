#!/bin/sh
# Xbox 360 controller setup for i3wm on Void Linux
# Provides: xboxdrv (driver), xvkbd (virtual keyboard), desktop/game mode switching
#
# Usage: ./scripts/setup-xboxdrv.sh

set -e

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
XBOXDRV_DIR="$HOME/.config/xboxdrv"

echo "==> Installing packages..."
sudo xbps-install -Sy xboxdrv xvkbd

echo "==> Blacklisting xpad kernel module..."
sudo tee /etc/modprobe.d/blacklist-xpad.conf > /dev/null <<'EOF'
blacklist xpad
EOF

echo "==> Adding udev rule for USB access..."
sudo tee /etc/udev/rules.d/99-xbox360.rules > /dev/null <<'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="028e", MODE="0666"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "==> Installing xboxdrv-ctl wrapper..."
sudo tee /usr/local/bin/xboxdrv-ctl > /dev/null <<'WRAPPER'
#!/bin/bash
DESKTOP_CONF="/home/null/.config/xboxdrv/xboxdrv.conf"
GAME_CONF="/home/null/.config/xboxdrv/game.conf"
STATE="/tmp/xboxdrv-mode"

case "$1" in
  desktop)
    killall -9 xboxdrv 2>/dev/null
    sleep 3
    /usr/bin/xboxdrv --config "$DESKTOP_CONF" &
    echo "desktop" > "$STATE"
    ;;
  game)
    killall -9 xboxdrv 2>/dev/null
    sleep 3
    /usr/bin/xboxdrv --config "$GAME_CONF" &
    echo "game" > "$STATE"
    ;;
  toggle)
    if [ "$(cat "$STATE" 2>/dev/null)" = "game" ]; then
      sudo $0 desktop
    else
      sudo $0 game
    fi
    ;;
  stop)
    killall -9 xboxdrv 2>/dev/null
    echo "stopped" > "$STATE"
    ;;
  *)
    echo "Usage: xboxdrv-ctl {desktop|game|toggle|stop}"
    exit 1
    ;;
esac
WRAPPER
sudo chmod +x /usr/local/bin/xboxdrv-ctl

echo "==> Configuring sudoers..."
sudo tee /etc/sudoers.d/xboxdrv > /dev/null <<'SUDOERS'
null ALL=(root) NOPASSWD: /usr/local/bin/xboxdrv-ctl
SUDOERS
sudo chmod 440 /etc/sudoers.d/xboxdrv

echo "==> Setting permissions on helper scripts..."
chmod +x "$XBOXDRV_DIR/switch-xboxdrv-mode.sh"
chmod +x "$XBOXDRV_DIR/toggle-keyboard.sh"

echo "==> Removing any runit service (conflicts with manual control)..."
if [ -L /var/service/xboxdrv ]; then
  sudo rm /var/service/xboxdrv
  sudo sv stop xboxdrv 2>/dev/null || true
  echo "    Removed runit symlink"
fi

echo "==> Reloading i3 config..."
i3-msg reload 2>/dev/null || echo "    (i3 not running, reload manually later)"

echo ""
echo "Setup complete! Start xboxdrv with:"
echo "  xboxdrv-ctl desktop"
echo ""
echo "Controller mappings (desktop mode):"
echo "  B                    Escape"
echo "  A                    Left click"
echo "  X                    Space"
echo "  Y                    Toggle virtual keyboard (Super+F9)"
echo "  Left stick (L3)      Toggle floating"
echo "  Right stick (R3)     Play / pause"
echo "  D-pad                Arrow keys"
echo "  Left stick           Mouse movement"
echo "  Right stick          Scroll"
echo "  LT                   Browser back"
echo "  RT                   Browser forward"
echo "  LB / RB              Arrow left / right"
echo "  Start+X              App launcher (rofi)"
echo "  Start+Y              Open terminal"
echo "  Start+LB             Screenshot (Flameshot)"
echo "  Start+RB             Clipboard manager (CopyQ)"
echo "  Start+Back           Notification history"
echo "  L3+R3                Switch desktop/game mode"
echo ""
echo "Guide combos (hold Guide):"
echo "  Guide+B              Kill focused window"
echo "  Guide+A              Enter"
echo "  Guide+X              Find in page (Ctrl+F)"
echo "  Guide+Y              File manager"
echo "  Guide+L3             Fullscreen"
echo "  Guide+Start          Reload i3 config"
echo "  Guide+Back           System power menu"
echo "  Guide+RB / Guide+LB  Next / prev workspace"
echo "  Guide+LT / Guide+RT  Move window prev/next workspace"
echo "  Guide+du / Guide+dd  Volume up / down"
echo "  Guide+dl             Mute"
echo "  Guide+dr             Play / pause"
echo "  Guide+dl             Open cheatsheet"
