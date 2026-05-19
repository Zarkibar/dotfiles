#!/bin/bash

FAVES="Firefox
Kitty
Neovim
Foliate
Volume Control
Helvum
Blender
Yazi
Music Player"

chosen=$(echo "$FAVES" | wofi --dmenu --prompt "Favorites")

case "$chosen" in
  Firefox) firefox;;
  Kitty) kitty;;
  Neovim) kitty -e nvim;;
  Foliate) foliate;;
  "Volume Control") pavucontrol;;
  Helvum) helvum;;
  Blender) blender;;
  Yazi) kitty -e yazi;;
  "Music Player") kitty -e ncmpcpp;;
esac
