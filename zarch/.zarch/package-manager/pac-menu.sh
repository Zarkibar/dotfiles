#!/bin/bash

options="Update Packages
Install Package
Remove Package"

chosen=$(echo -e "$options" | rofi -dmenu --prompt "Package Menu")

case "$chosen" in
  "Update Packages")
    kitty --class packagemanager -e ~/.zarch/package-manager/update-package.sh
    ;;

  "Install Package")
    kitty --class packagemanager -e ~/.zarch/package-manager/install-package.sh
    ;;

  "Remove Package")
    kitty --class packagemanager -e ~/.zarch/package-manager/remove-package.sh
    ;;

  *)
    exit 0
    ;;
esac
