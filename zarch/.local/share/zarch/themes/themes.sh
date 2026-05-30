#!/bin/bash

options="Change wallpaper
"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Themes")

case "$chosen" in
  "Change wallpaper")
    ~/.local/share/zarch/themes/change-wallpaper.sh
		;;
	*)
		exit 0
		;;
esac
