#!/bin/bash

DOCS="Github
Hyprland
Convert bash script into an application
Quickshell notification system
Setting Up Lutris to run windows game"

chosen=$(echo "$DOCS" | rofi -dmenu --prompt "Docs")

case "$chosen" in
  "Github")
    kitty -e glow -p "$HOME/.local/share/zarch/docs/github-setup.md"
    ;;
  "Hyprland")
    kitty -e glow -p "$HOME/.local/share/zarch/docs/hyprland.md"
    ;;
  "Convert bash script into an application")
    kitty -e glow -p "$HOME/.local/share/zarch/docs/from-bash-to-app.md"
    ;;
  "Quickshell notification system")
    kitty -e glow -p "$HOME/.local/share/zarch/docs/quickshell-notification.md"
    ;;
  "Setting Up Lutris to run windows game")
    kitty -e glow -p "$HOME/.local/share/zarch/docs/lutris.md"
    ;;
  *)
    exit 0
    ;;
esac
