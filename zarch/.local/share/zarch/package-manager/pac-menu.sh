#!/bin/bash

options="Update Packages
Install Package
Remove Package"

chosen=$(echo -e "$options" | rofi -dmenu --prompt "Package Menu")

case "$chosen" in
  "Update Packages")
    kitty --class packagemanager -e sudo pacman -Syu
    ;;

  "Install Package")
    kitty --class packagemanager -e ~/.local/share/zarch/package-manager/install-package.sh
    ;;

  "Remove Package")
    kitty --class packagemanager -e ~/.local/share/zarch/package-manager/remove-package.sh
    ;;

  *)
    exit 0
    ;;
esac
