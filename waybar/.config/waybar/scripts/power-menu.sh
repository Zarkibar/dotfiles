#!/bin/bash

options="Power Off\nReboot\nSleep\nLogout\nCancel"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu")

case "$chosen" in
		"Power Off")
				systemctl poweroff
				;;
		"Reboot")
				systemctl reboot
				;;
		"Sleep")
				systemctl suspend && hyprlock
				;;
		"Logout")
				command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit
				;;
		*)
				exit 0
				;;
esac
