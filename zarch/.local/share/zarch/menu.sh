#!/bin/bash

options="★ Favorite Applications
Package Manager
⏺ Record Screen
Themes
Git
Emoji
Bucket List"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Quick Action")

case "$chosen" in
  "⏺ Record Screen")
    wf-recorder -f ~/Videos/Recording/"$(date '+%Y-%m-%d-%H%M%S')"_wf_recorder.mkv -y
    ;;
  "★ Favorite Applications")
    ~/.local/share/zarch/favorites/favorites.sh
    ;;
  "Git")
    ~/.local/share/zarch/github/github-menu.sh
    ;;
  "Themes")
    ~/.local/share/zarch/themes/themes.sh
    ;;
  *)
    exit 0
    ;;
esac
