#!/bin/bash

options="Change wallpaper"

chosen=$(echo -e "$options" | rofi -dmenu --prompt "Themes")

case "$chosen" in
  "Change wallpaper")
    kitty --class changetheme -e ~/.zarch/themes/change-wallpaper.sh
		;;
	*)
		exit 0
		;;
esac
