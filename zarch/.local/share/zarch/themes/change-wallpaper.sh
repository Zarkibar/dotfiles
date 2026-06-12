#!/bin/bash

BACKGROUND_DIR="$HOME/.config/backgrounds"

selected=$(find "$BACKGROUND_DIR/" -maxdepth 1 -printf "%f\n" | sort | fzf --preview="chafa --size=60x60 $BACKGROUND_DIR/{}")

[ -z "$selected" ] && exit 0

wallpaper="$BACKGROUND_DIR/$selected"

#hyprctl hyprpaper unload all
hyprctl hyprpaper wallpaper ",$wallpaper"

if [ ! -d "$HOME/.local/share/zarch/config" ]; then
  mkdir -p "$HOME/.local/share/zarch/config"
fi

echo "$wallpaper" > ~/.local/share/zarch/config/current-theme
