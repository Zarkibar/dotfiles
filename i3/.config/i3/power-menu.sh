#!/bin/bash

choice=$(printf "lock\nlogout\nreboot\nshutdown" | rofi -dmenu -p "power")

case "$choice" in
  lock) ~/.config/i3/lock.sh ;;
  logout) i3-msg exit ;;
  reboot) systemctl reboot ;;
  shutdown) systemctl poweroff ;;
esac

