#!/bin/bash

BACKGROUND_DIR="$HOME/.config/backgrounds/"
WALLPAPER_DIR="$HOME/.config/wallpaper/"

selected=$(find "$BACKGROUND_DIR" -maxdepth 1 \
    -printf "%f\n" | sort | wofi --dmenu --prompt "Select Wallpaper")

[ -z "$selected" ] && exit 0

wallpaper="$BACKGROUND_DIR/$selected"
hyprctl hyprpaper wallpaper ",$wallpaper"
