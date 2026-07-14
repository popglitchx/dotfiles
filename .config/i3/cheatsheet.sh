#!/bin/bash

CONFIG="$HOME/.config/i3/config"
MOD="Super"

sep() {
    printf '<span color="#665c54">────────────────────────────────────────────</span>\n'
}

header() {
    printf '\n'
    printf '<span color="#fabd2f"><b>  ╭──────────────────────────────────────╮</b></span>\n'
    printf '<span color="#fabd2f"><b>  │  %-35s│</b></span>\n' "$1"
    printf '<span color="#fabd2f"><b>  ╰──────────────────────────────────────╯</b></span>\n'
    printf '\n'
}

section() {
    printf '<span color="#fabd2f"><b>  ▸ %s</b></span>\n' "$1"
    sep
}

bind() {
    printf '<span color="#83a598"><b>  %-34s</b></span><span color="#d5c4a1"> %s</span>\n' "$1" "$2"
}

app() {
    printf '<span color="#d3869b"><b>  %-34s</b></span><span color="#d5c4a1"> %s</span>\n' "$1" "$2"
}

controller() {
    printf '<span color="#fb4934"><b>  %-34s</b></span><span color="#d5c4a1"> %s</span>\n' "$1" "$2"
}

danger() {
    printf '<span color="#fb4934"><b>  %-34s</b></span><span color="#fb4934"> %s</span>\n' "$1" "$2"
}

{
    header "I3 KEYBIND CHEATSHEET"

    section "Core"
    bind "$MOD+Return"              "Open terminal"
    bind "$MOD+q"                   "Open terminal (named)"
    bind "$MOD+Shift+q"             "Kill window"
    bind "$MOD+Shift+m"             "Exit i3"
    bind "$MOD+e"                   "File manager"
    bind "$MOD+d"                   "App launcher"
    printf '\n'

    section "Focus"
    bind "$MOD+h / j / k / l"       "Focus left / down / up / right"
    bind "$MOD+Space"               "Toggle focus tiling / floating"
    printf '\n'

    section "Layout"
    bind "$MOD+Shift+j"             "Split toggle"
    bind "$MOD+Shift+h"             "Split horizontal"
    bind "$MOD+Shift+v"             "Split vertical"
    bind "$MOD+f"                   "Fullscreen"
    bind "$MOD+Shift+Space"         "Toggle floating"
    bind "$MOD+m"                   "Move to next output"
    printf '\n'

    section "Workspaces"
    bind "$MOD+1-0"                 "Switch to workspace 1-10"
    bind "$MOD+Shift+1-0"           "Move window to workspace 1-10"
    bind "Ctrl+Shift+r"             "Rename workspace"
    printf '\n'

    section "Apps"
    app "$MOD+b"                    "Firefox"
    app "$MOD+g"                    "GIMP"
    app "$MOD+w"                    "Nitrogen (wallpaper)"
    app "$MOD+p"                    "Pavucontrol (volume)"
    app "$MOD+v"                    "Haruna (video)"
    app "$MOD+x"                    "KeePassXC"
    app "$MOD+Ctrl+b"               "bzmenu (Bluetooth manager)"
    app "$MOD+Ctrl+v"               "CopyQ (clipboard)"
    app "$MOD+Shift+w"              "Window rule tool (rofi)"
    app "Alt+Return"                "Floating terminal"
    printf '\n'

    section "Media & Volume"
    bind "XF86Audio Raise / Lower"  "Volume up / down"
    bind "XF86Audio Mute"           "Toggle mute"
    bind "XF86Audio Mic Mute"       "Toggle mic mute"
    bind "XF86Audio Play"           "Play / pause"
    printf '\n'

    section "Screenshots"
    bind "$MOD+Shift+s"             "Flameshot screenshot"
    bind "Ctrl+Print"               "Screenshot full (GIMP)"
    bind "Shift+Print"              "Screenshot selection (GIMP)"
    printf '\n'

    section "Notifications"
    bind "$MOD+BackSpace"           "Close notification"
    bind "$MOD+Shift+BackSpace"     "Close all notifications"
    bind "$MOD+grave"               "Notification history"
    bind "$MOD+Shift+grave"         "Notification context"
    printf '\n'

    section "System"
    bind "$MOD+a"                   "Reload config"
    bind "$MOD+Shift+r"             "Restart i3"
    danger "$MOD+Shift+e"           "Exit i3 (nagbar)"
    danger "Alt+Delete"             "System mode (lock / logout / suspend / reboot / poweroff)"
    bind "$MOD+/"                   "This cheatsheet"
    printf '\n'

    section "Xbox Controller"
    controller "Guide + RB / LB"    "Next / prev workspace"
    controller "Guide + Start"      "Reload i3 config"
    controller "Guide + Y"          "File manager"
    controller "Guide + A"          "Enter"
    controller "Guide + LT / RT"    "Move window to next output"
    controller "Guide + Back"       "System power menu"
    controller "Guide + ↑↓"         "Volume up / down"
    controller "Guide + ←"          "Mute"
    controller "Guide + →"          "Play / pause"
    controller "Guide + X"          "Find in page (Ctrl+F)"
    controller "Guide + L3"         "Toggle floating"
    controller "Guide + R3"         "Fullscreen"
    controller "Start + X"          "App launcher (rofi)"
    controller "Start + Y"          "Open terminal"
    controller "Start + LB"         "Screenshot (Flameshot)"
    controller "Start + RB"         "Clipboard manager (CopyQ)"
    controller "Start + Back"       "Notification history"
    controller "X"                  "Space"
    controller "Y"                  "Toggle virtual keyboard"
    controller "A"                  "Left click"
    controller "B"                  "Escape"
    controller "LT"                 "Browser back"
    controller "RT"                 "Browser forward"
    controller "D-pad"              "Arrow keys"
    controller "Left stick"         "Mouse movement"
    controller "Right stick"        "Scroll"
    controller "L3 + R3"            "Switch desktop / game mode"
    controller "Toggle floating"    "Keyboard: Super+Shift+Space"
    printf '\n'

    section "All Active Bindsyms"
    grep '^bindsym' "$CONFIG" | sed 's/^bindsym //' | sed 's/\$mainMod/'"$MOD"'/g; s/\$alt/Alt/g' | awk '{
        key = $1
        cmd = ""
        for (i = 2; i <= NF; i++) cmd = cmd " " $i
        gsub(/^ /, "", cmd)
        gsub(/exec --no-startup-id /, "", cmd)
        gsub(/exec /, "", cmd)
        gsub(/mode .*/, "", cmd)
        if (length(cmd) > 0) {
            gsub(/[[:space:]]+$/, "", cmd)
            printf "<span color=\"#83a598\"><b>  %-34s</b></span><span color=\"#a89984\"> %s</span>\n", key, cmd
        }
    }'
} | rofi -dmenu -i -p " Keybinds" -markup-rows -theme ~/.config/rofi/themes/cheatsheet.rasi
