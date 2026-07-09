#!/bin/bash

package=$(pacman -Qq | fzf --prompt="Uninstall > " --preview="pacman -Qi {}")

[ -z "$package" ] && exit 0

sudo pacman -Rn "$package"

sudo pacman -Rns $(pacman -Qdtq)

echo ""
read -p "Press Enter To Close The Window: " input

