#!/bin/bash

package=$(pacman -Slq | fzf --prompt="Install > " --preview="pacman -Si {}")

sudo pacman -S "$package"

echo ""
read -p "Press Enter To Close The Window: " input
