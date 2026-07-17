#!/bin/bash

options="Favorite Applications
Package Manager
Record Screen
Themes
Emoji
Documentation
Dual N-Back
TODO"

chosen=$(echo -e "$options" | rofi -dmenu --prompt "Quick Action")

case "$chosen" in
  "Record Screen")
    wf-recorder -c libx264rgb -f ~/Videos/Recording/"$(date '+%Y-%m-%d-%H%M%S')"_wf_recorder.mkv -y
    ;;
  "Favorite Applications")
    ~/.zarch/favorites/favorites.sh
    ;;
  "Themes")
    ~/.zarch/themes/themes.sh
    ;;
  "Package Manager")
    ~/.zarch/package-manager/pac-menu.sh
    ;;
  "Emoji")
    rofi -show emoji
    ;;
  "Documentation")
    ~/.zarch/docs/doc-menu.sh
    ;;
  "Dual N-Back")
    xdg-open https://dual-n-back.io/
    ;;
  "TODO")
    kitty -e zarch-todos
    ;;
  *)
    exit 0
    ;;
esac
