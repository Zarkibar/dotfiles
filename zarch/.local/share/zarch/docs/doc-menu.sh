#!/bin/bash

DOCS="Github
Hyprland
DOC 1
DOC 2"

chosen=$(echo "$DOCS" | rofi -dmenu --prompt "Docs")

case "$chosen" in
  "Github")
    kitty -e glow -p "$HOME/.local/share/zarch/docs/github-setup.md"
    ;;
  "Hyprland")
    kitty -e glow -p "$HOME/.local/share/zarch/docs/hyprland.md"
    ;;
  "DOC 1")
    notify-send "DOC 1" "You have selected doc 1 from documentation"
    ;;
  "DOC 2")
    notify-send "DOC 2" "You have selected doc 2 from documentation"
    ;;
  *)
    exit 0
    ;;
esac
