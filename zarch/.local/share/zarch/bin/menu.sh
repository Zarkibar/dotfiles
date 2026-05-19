#!/bin/bash

options="⏺ Record Screen
★ Favorite Applications
Option3
Option4"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Quick Action")

case "$chosen" in
		"⏺ Record Screen")
				notify-send "Recording screen"
        wf-recorder -c libx264rgb -f ~/Videos/Recording/"$(date '+%Y-%m-%d-%H%M%S')"_wf_recorder.mkv -y
				;;
		"★ Favorite Applications")
        ~/.local/share/zarch/bin/favorites.sh
				;;
		"Option3")
				notify-send "Pressed Option 3"
				;;
		"Option4")
				notify-send "Pressed Option 4"
				;;
		*)
				exit 0
				;;
esac
