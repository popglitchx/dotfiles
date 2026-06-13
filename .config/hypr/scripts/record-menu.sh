#!/usr/bin/env bash
# ──────────────────────────────────────────────
#  record-menu.sh  –  fuzzel picker for wf-record
#  Calls record.sh with the chosen flags
# ──────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RECORD="$SCRIPT_DIR/record.sh"

# ── Menu entries: "Label" → "flags to pass" ───
declare -A FLAGS
OPTIONS=(
    "󰑊  Region — no sound"
    "󰑊  Region — with sound"
    "󰍹  Fullscreen — no sound"
    "󰍹  Fullscreen — with sound"
    "󰓛  Stop recording"
)
FLAGS["󰑊  Region — no sound"]=""
FLAGS["󰑊  Region — with sound"]="--sound"
FLAGS["󰍹  Fullscreen — no sound"]="--fullscreen"
FLAGS["󰍹  Fullscreen — with sound"]="--fullscreen --sound"
FLAGS["󰓛  Stop recording"]="--stop"

# ── If already recording, surface stop at the top ─
if pgrep -x wf-recorder > /dev/null; then
    OPTIONS=("󰓛  Stop recording" "${OPTIONS[@]}")
fi

# ── Build the menu string ─────────────────────
MENU=$(printf '%s\n' "${OPTIONS[@]}")

# ── Show fuzzel ───────────────────────────────
CHOICE=$(echo "$MENU" | fuzzel \
    --dmenu \
    --prompt "  Record › " \
    --width 35 \
    --lines "${#OPTIONS[@]}")

[[ -z "$CHOICE" ]] && exit 0   # dismissed

# ── Handle stop without calling record.sh ────
if [[ "$CHOICE" == "󰓛  Stop recording" ]]; then
    pkill wf-recorder
    notify-send "Recording Stopped" "File saved" -a 'Recorder' & disown
    exit 0
fi

# ── Launch recorder with chosen flags ─────────
CHOSEN_FLAGS="${FLAGS[$CHOICE]}"
# shellcheck disable=SC2086
exec "$RECORD" $CHOSEN_FLAGS
