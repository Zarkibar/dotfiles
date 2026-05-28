#!/bin/bash

options="★ Favorite Applications
Package Manager
⏺ Record Screen
Git
Emoji
Themes
Bucket List"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Quick Action")

case "$chosen" in
		"⏺ Record Screen")
        wf-recorder -c libx264rgb -f ~/Videos/Recording/"$(date '+%Y-%m-%d-%H%M%S')"_wf_recorder.mkv -y
				;;
		"★ Favorite Applications")
        ~/.local/share/zarch/favorites/favorites.sh
				;;
		"Git")
				~/.local/share/zarch/github/github-menu.sh
				;;
		"Themes")
				notify-send "Pressed Themes"
				;;
		*)
				exit 0
				;;
esac
