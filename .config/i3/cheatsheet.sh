#!/bin/bash

CONFIG="$HOME/.config/i3/config"
MOD="Super"

section() {
    printf '<span color="#b8bb26"><b>  ═══ %s ═══</b></span>\n' "$1"
}

bind() {
    printf '<span color="#fabd2f"><b>%-38s</b></span><span color="#ebdbb2">%s</span>\n' "$1" "$2"
}

app() {
    printf '<span color="#b8bb26"><b>%-38s</b></span><span color="#ebdbb2">%s</span>\n' "$1" "$2"
}

system() {
    printf '<span color="#fb4934"><b>%-38s</b></span><span color="#ebdbb2">%s</span>\n' "$1" "$2"
}

{
    section "Core"
    bind "$MOD+Return"              "Open terminal"
    bind "$MOD+q"                   "Open terminal (named)"
    bind "$MOD+Shift+q"             "Kill window"
    bind "$MOD+Shift+m"             "Exit i3"
    bind "$MOD+e"                   "File manager"
    bind "$MOD+d"                   "App launcher"

    section "Focus"
    bind "$MOD+h / j / k / l"       "Focus left / down / up / right"
    bind "$MOD+Space"               "Toggle focus tiling / floating"

    section "Layout"
    bind "$MOD+Shift+j"             "Split toggle"
    bind "$MOD+Shift+h"             "Split horizontal"
    bind "$MOD+Shift+v"             "Split vertical"
    bind "$MOD+f"                   "Fullscreen"
    bind "$MOD+Shift+Space"         "Toggle floating"
    bind "$MOD+m"                   "Move to next output"

    section "Workspaces"
    bind "$MOD+1-0"                 "Switch to workspace 1-10"
    bind "$MOD+Shift+1-0"           "Move window to workspace 1-10"
    bind "Ctrl+Shift+r"             "Rename workspace"

    section "Apps"
    app "$MOD+b"                    "Firefox"
    app "$MOD+g"                    "GIMP"
    app "$MOD+w"                    "Nitrogen (wallpaper)"
    app "$MOD+p"                    "Pavucontrol (volume)"
    app "$MOD+v"                    "Haruna (video)"
    app "$MOD+x"                    "KeePassXC"
    app "$MOD+Ctrl+v"               "CopyQ (clipboard)"
    app "Alt+Return"                "Floating terminal"

    section "Media & Volume"
    bind "XF86Audio Raise / Lower"  "Volume up / down"
    bind "XF86Audio Mute"           "Toggle mute"
    bind "XF86Audio Mic Mute"       "Toggle mic mute"
    bind "XF86Audio Play"           "Play / pause"

    section "Screenshots"
    bind "$MOD+Shift+s"             "Flameshot screenshot"
    bind "Ctrl+Print"               "Screenshot full (GIMP)"
    bind "Shift+Print"              "Screenshot selection (GIMP)"

    section "Notifications"
    bind "$MOD+BackSpace"           "Close notification"
    bind "$MOD+Shift+BackSpace"     "Close all notifications"
    bind "$MOD+grave"               "Notification history"
    bind "$MOD+Shift+grave"         "Notification context"

    section "System"
    bind "$MOD+a"                   "Reload config"
    bind "$MOD+Shift+r"             "Restart i3"
    system "$MOD+Shift+e"           "Exit i3 (nagbar)"
    system "Alt+Delete"             "System mode (lock / logout / suspend / reboot / poweroff)"
    bind "$MOD+/"                   "This cheatsheet"

    # Auto-generated: parse active bindsym lines from config
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
            printf "<span color=\"#d3869b\"><b>%-38s</b></span><span color=\"#808080\">%s</span>\n", key, cmd
        }
    }'
} | rofi -dmenu -i -p " Keybinds" -markup-rows -theme ~/.config/rofi/themes/cheatsheet.rasi
