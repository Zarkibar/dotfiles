#!/bin/bash

options="Add ssh key"

chosen=$(echo -e "$options" | rofi -dmenu --prompt "Git Actions")

case "$chosen" in
  "Add ssh key")
    kitty -e ./add-ssh-key.sh
		;;

  *)
		exit 0
		;;
esac
