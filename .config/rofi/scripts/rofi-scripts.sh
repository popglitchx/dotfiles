#!/bin/sh

SCRIPT_DIR="$HOME/scripts"

entries=""
for f in "$SCRIPT_DIR"/*.sh; do
  [ -x "$f" ] || continue
  name=$(basename "$f" .sh)
  entries="$entries$name\n"
done

chosen=$(printf "%b" "$entries" | rofi -dmenu -theme ~/.config/rofi/themes/launcher.rasi -show-icons -p "Scripts" $*)

[ -z "$chosen" ] && exit 0

exec "$SCRIPT_DIR/$chosen.sh"
