#!/bin/bash

options="Favorite Applications
Package Manager
Record Screen
Themes
Git
Emoji"
#Bucket List

chosen=$(echo -e "$options" | rofi -dmenu --prompt "Quick Action")

case "$chosen" in
  "Record Screen")
    wf-recorder -c libx264rgb -f ~/Videos/Recording/"$(date '+%Y-%m-%d-%H%M%S')"_wf_recorder.mkv -y
    ;;
  "Favorite Applications")
    ~/.local/share/zarch/favorites/favorites.sh
    ;;
  "Git")
    ~/.local/share/zarch/github/github-menu.sh
    ;;
  "Themes")
    ~/.local/share/zarch/themes/themes.sh
    ;;
  "Package Manager")
    ~/.local/share/zarch/package-manager/pac-menu.sh
    ;;
  "Emoji")
    rofi -show emoji
    ;;
  *)
    exit 0
    ;;
esac
