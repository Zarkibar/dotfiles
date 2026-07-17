#!/bin/bash

BACKGROUND_DIR="$HOME/.config/backgrounds"

selected=$(find "$BACKGROUND_DIR/" -maxdepth 1 -printf "%f\n" | sort | fzf --preview="chafa --size=60x60 $BACKGROUND_DIR/{}")

[ -z "$selected" ] && exit 0

wallpaper="$BACKGROUND_DIR/$selected"

#hyprctl hyprpaper unload all
hyprctl hyprpaper wallpaper ",$wallpaper"

if [ ! -d "$HOME/.config/zarch" ]; then
  mkdir -p "$HOME/.config/zarch"
fi

echo "$wallpaper" > ~/.config/zarch/current-theme
