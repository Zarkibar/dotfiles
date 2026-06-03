#!/bin/bash

BACKGROUND_DIR="$HOME/.config/backgrounds"

selected=$(find "$BACKGROUND_DIR/" -maxdepth 1 -printf "%f\n" | sort | fzf --preview="chafa --size=60x60 $BACKGROUND_DIR/{}")

wallpaper="$BACKGROUND_DIR/$selected"
hyprctl hyprpaper wallpaper ",$wallpaper"
