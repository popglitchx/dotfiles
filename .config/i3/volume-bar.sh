#!/bin/bash

# Get current volume level
VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -n 1)
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [ "$MUTE" = "yes" ]; then
    echo "<span color='#e89393'>☊ [  MUTED  ]</span>"
else
    TRACK_LENGTH=12
    POSITION=$(( (VOL * TRACK_LENGTH) / 100 ))

    # Cap boundaries
    (( POSITION > TRACK_LENGTH )) && POSITION=$TRACK_LENGTH
    (( POSITION < 0 )) && POSITION=0

    LEFT_SIDE=$(( POSITION ))
    RIGHT_SIDE=$(( TRACK_LENGTH - POSITION ))

    # Generate raw strings
    TRACK_LEFT=$(printf '─%.0s' $(seq 1 $LEFT_SIDE 2>/dev/null))
    TRACK_RIGHT=$(printf '─%.0s' $(seq 1 $RIGHT_SIDE 2>/dev/null))

    # Apply Zenburn Pango Color Tags
    COLOR_LABEL="<span color='#9f9f9f'>vol</span>"
    COLOR_BRACKET="<span color='#8f8f8f'>[</span>"
    COLOR_TRACK_L="<span color='#ccdc90'>${TRACK_LEFT}</span>"
    COLOR_NEEDLE="<span color='#ffffff'><b>|</b></span>"
    COLOR_TRACK_R="<span color='#ccdc90'>${TRACK_RIGHT}</span>"
    COLOR_BRACKET_CLOSE="<span color='#8f8f8f'>]</span>"
    COLOR_TEXT="<span color='#88b090'>${VOL}%</span>"

    # Print the full colored string sequence assembly
    echo "${COLOR_LABEL} ${COLOR_BRACKET}${COLOR_TRACK_L}${COLOR_NEEDLE}${COLOR_TRACK_R}${COLOR_BRACKET_CLOSE} ${COLOR_TEXT}"
fi
