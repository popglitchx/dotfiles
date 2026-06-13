#!/usr/bin/env bash
# ──────────────────────────────────────────────
#  wf-recorder wrapper  –  no quickshell needed
#  Config: ~/.config/wf-record/config.sh
# ──────────────────────────────────────────────

CONFIG_FILE="$HOME/.config/wf-record/config.sh"

# ── Defaults (overridden by config if it exists) ──
RECORDING_DIR="/run/media/lahcen"
AUDIO_SOURCE=""          # leave empty = auto-detect monitor sink
PIXEL_FORMAT="yuv420p"
NOTIFY_TIMEOUT=3000      # ms

[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# ── Helpers ───────────────────────────────────────
getdate()         { date '+%Y-%m-%d_%H.%M.%S'; }

getaudiooutput() {
    if [[ -n "$AUDIO_SOURCE" ]]; then
        echo "$AUDIO_SOURCE"
    else
        pactl list sources | awk '/Name.*monitor/{print $2; exit}'
    fi
}

getactivemonitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name'
}

notify() { notify-send "$1" "$2" -t "$NOTIFY_TIMEOUT" -a 'Recorder' & disown; }

# ── Argument parsing ──────────────────────────────
MANUAL_REGION=""
SOUND_FLAG=0
FULLSCREEN_FLAG=0
ARGS=("$@")

for ((i=0; i<${#ARGS[@]}; i++)); do
    case "${ARGS[i]}" in
        --region)
            if (( i+1 < ${#ARGS[@]} )); then
                MANUAL_REGION="${ARGS[i+1]}"
            else
                notify "Recording cancelled" "No region specified for --region"
                exit 1
            fi ;;
        --sound)      SOUND_FLAG=1 ;;
        --fullscreen) FULLSCREEN_FLAG=1 ;;
    esac
done

# ── Output dir ────────────────────────────────────
mkdir -p "$RECORDING_DIR"
cd "$RECORDING_DIR" || exit 1

OUTFILE="./recording_$(getdate).mp4"
BASE_FLAGS="--pixel-format $PIXEL_FORMAT -f $OUTFILE"

# ── Toggle: stop if already running ───────────────
if pgrep -x wf-recorder > /dev/null; then
    notify "Recording Stopped" "File saved to $RECORDING_DIR"
    pkill wf-recorder
    exit 0
fi

# ── Start recording ───────────────────────────────
if [[ $FULLSCREEN_FLAG -eq 1 ]]; then
    notify "Recording started" "$OUTFILE"
    MONITOR="$(getactivemonitor)"
    if [[ $SOUND_FLAG -eq 1 ]]; then
        wf-recorder -o "$MONITOR" $BASE_FLAGS --audio="$(getaudiooutput)"
    else
        wf-recorder -o "$MONITOR" $BASE_FLAGS
    fi

else
    if [[ -n "$MANUAL_REGION" ]]; then
        region="$MANUAL_REGION"
    else
        if ! region="$(slurp 2>&1)"; then
            notify "Recording cancelled" "Selection was cancelled"
            exit 1
        fi
    fi

    notify "Recording started" "$OUTFILE"
    if [[ $SOUND_FLAG -eq 1 ]]; then
        wf-recorder $BASE_FLAGS --geometry "$region" --audio="$(getaudiooutput)"
    else
        wf-recorder $BASE_FLAGS --geometry "$region"
    fi
fi
