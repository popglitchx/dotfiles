#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
#  wallpaper.sh — wallhaven search + fzf preview + hyprpaper
#  Dependencies: fzf, chafa, curl, jq, ghostty, hyprpaper
#  Usage:
#    ./wallpaper.sh                  → interactive fzf search
#    ./wallpaper.sh <wallhaven URL>  → set directly from page link
#    ./wallpaper.sh <direct img URL> → set directly from image url
# ──────────────────────────────────────────────────────

CONFIG_FILE="$HOME/.config/hypr/scripts/wallpaper.conf"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THUMB_DIR="/tmp/wallhaven-thumbs"
API_KEY=""
SORTING="relevance"
CATEGORIES="111"
PURITY="100"

[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

mkdir -p "$WALLPAPER_DIR" "$THUMB_DIR"

notify() { notify-send "$1" "$2" -a 'Wallpaper' & disown; }

# ── If we're being re-launched inside ghostty for the picker ──
if [[ "$1" == "--picker" ]]; then
    RESULTS_FILE="$2"
    SELECTION_FILE="$3"

    mapfile -t lines < <(jq -r '
        .data[] |
        [.id, .resolution, (.views|tostring), .thumbs.small, .path]
        | @tsv
    ' "$RESULTS_FILE")

    # Download thumbs in parallel
    declare -A thumb_map
    for line in "${lines[@]}"; do
        IFS=$'\t' read -r id resolution views thumb_url img_url <<< "$line"
        dest="$THUMB_DIR/${id}.jpg"
        thumb_map[$id]="$dest"
        [[ -f "$dest" ]] || curl -fsSL "$thumb_url" -o "$dest" 2>/dev/null &
    done
    wait

    # Build fzf input: visible part TAB img_url TAB thumb_path
    fzf_input=""
    for line in "${lines[@]}"; do
        IFS=$'\t' read -r id resolution views thumb_url img_url <<< "$line"
        thumb_path="${thumb_map[$id]}"
        fzf_input+="${id}  │  ${resolution}  │  ${views} views"$'\t'"${img_url}"$'\t'"${thumb_path}"$'\n'
    done

    chosen=$(echo "$fzf_input" | fzf \
        --delimiter=$'\t' \
        --with-nth=1 \
        --prompt="󰋩  Pick wallpaper › " \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --preview='[[ -f {3} ]] && chafa --format=symbols --size=80x40 --stretch {3} || echo "⏳ Loading preview..."' \
        --preview-window='right:60%:wrap' \
        --ansi)

    if [[ -n "$chosen" ]]; then
        img_url=$(echo "$chosen" | cut -f2)
        echo "$img_url" > "$SELECTION_FILE"
    fi

    exit 0
fi

# ── Ensure hyprpaper is running ───────────────────────
ensure_hyprpaper() {
    if ! pgrep -x hyprpaper > /dev/null; then
        notify "Wallpaper" "Starting hyprpaper…"
        hyprpaper &
        sleep 1
    fi
}

# ── Apply via hyprpaper IPC ───────────────────────────
apply_wallpaper() {
    local path="$1"
    ensure_hyprpaper

    path="$(realpath "$path")"

    if [[ ! -f "$path" ]]; then
        notify "Error" "File not found: $path"
        exit 1
    fi

    hyprctl hyprpaper preload "$path"
    sleep 0.3

    while IFS= read -r monitor; do
        hyprctl hyprpaper wallpaper "$monitor, $path"
    done < <(hyprctl monitors -j | jq -r '.[].name')

    notify "Wallpaper set" "$(basename "$path")"
}

# ── Download full image ───────────────────────────────
download_image() {
    local img_url="$1"
    local ext="${img_url##*.}"
    local id
    id=$(basename "${img_url%.*}")
    local dest="$WALLPAPER_DIR/${id}.${ext}"

    if [[ -f "$dest" ]]; then
        echo "$dest"
        return
    fi

    notify "Downloading…" "$(basename "$dest")"
    if curl -fsSL "$img_url" -o "$dest"; then
        echo "$dest"
    else
        notify "Failed" "Could not download image"
        exit 1
    fi
}

# ── Resolve wallhaven page URL → direct image URL ─────
resolve_page_url() {
    local page_url="$1"
    local id
    id=$(echo "$page_url" | grep -oP '(?<=/w/)[a-zA-Z0-9]+')
    [[ -z "$id" ]] && { notify "Error" "Could not parse wallhaven URL"; exit 1; }

    local api_url="https://wallhaven.cc/api/v1/w/$id"
    [[ -n "$API_KEY" ]] && api_url+="?apikey=$API_KEY"

    curl -fsSL "$api_url" | jq -r '.data.path'
}

# ── Interactive search ────────────────────────────────
interactive_search() {
    local query
    query=$(echo "" | fuzzel --dmenu \
        --prompt "󰋩  Search wallhaven › " \
        --width 50 \
        --lines 0)

    [[ -z "$query" ]] && exit 0

    notify "Searching…" "\"$query\""

    local encoded_query
    encoded_query=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$query")

    local api_url="https://wallhaven.cc/api/v1/search"
    api_url+="?q=$encoded_query&sorting=$SORTING&categories=$CATEGORIES&purity=$PURITY&per_page=24"
    [[ -n "$API_KEY" ]] && api_url+="&apikey=$API_KEY"

    local results
    results=$(curl -fsSL "$api_url")

    local count
    count=$(echo "$results" | jq '.data | length')

    if [[ -z "$results" ]] || [[ "$count" -eq 0 ]]; then
        notify "No results" "Try a different search term"
        exit 1
    fi

    notify "Found $count results" "Loading picker…"

    local results_file
    results_file=$(mktemp /tmp/wallhaven-results-XXXXXX.json)
    local selection_file
    selection_file=$(mktemp /tmp/wallhaven-selection-XXXXXX)

    echo "$results" > "$results_file"

    ghostty \
        --class="wallpaper-picker" \
        --title="Wallpaper Picker" \
        -e bash "$(realpath "$0")" --picker "$results_file" "$selection_file"

    local img_url
    img_url=$(cat "$selection_file" 2>/dev/null)

    rm -f "$results_file" "$selection_file"

    [[ -z "$img_url" ]] && exit 0

    local dest
    dest=$(download_image "$img_url")
    apply_wallpaper "$dest"
}

# ── Entry point ───────────────────────────────────────
if [[ -n "$1" ]]; then
    ensure_hyprpaper
    if echo "$1" | grep -q 'wallhaven.cc/w/'; then
        img_url=$(resolve_page_url "$1")
    else
        img_url="$1"
    fi
    dest=$(download_image "$img_url")
    apply_wallpaper "$dest"
else
    interactive_search
fi
