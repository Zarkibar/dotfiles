#!/usr/bin/env bash
set -euo pipefail

DOTFILES_GIT="https://github.com/Zarkibar/dotfiles.git"
YAY_GIT="https://aur.archlinux.org/yay.git"

msg() {
    printf "\n==> %s\n" "$1"
}

update_system() {
    msg "Updating system"
    sudo pacman -Syu --needed --noconfirm
}

install_base() {
    msg "Installing base packages"
    sudo pacman -S --needed --noconfirm git stow neovim base-devel man ttf-font-awesome ttf-jetbrains-mono-nerd pavucontrol nautilus wf-recorder ghostty
}

install_yay() {
    msg "Installing yay"
    cd
    if [ ! -d "$HOME/yay" ]; then
	git clone "$YAY_GIT" "$HOME/yay"
    else
	echo "yay git file already exists."
    fi

    if test "$(command -v yay)" = "/usr/bin/yay"; then
	echo "yay already exists."
    else
	cd ~/yay
	makepkg -si --noconfirm
	cd ..
    fi

    rm -rf ~/yay
}

install_dotfiles() {
    msg "Installing dotfiles"

    if [ ! -d "$HOME/dotfiles" ]; then
	git clone "$DOTFILES_GIT" "$HOME/dotfiles"
    else
	echo "$HOME/dotfiles already exists."
    fi   
}

setup_hyprland() {
    msg "Setting up hyprland ecosystem"

    sudo pacman -S --needed --noconfirm hyprland wofi waybar kitty hyprshot swaync hyprlock hypridle hyprpaper starship

    stow --restow -t "$HOME" -d "$HOME/dotfiles" backgrounds hypridle hyprland hyprlock hyprpaper kitty waybar wofi starship

    if [ ! grep -q "starship init bash" ~/.bashrc ]; then
        echo 'eval "$(starship init bash)"' >> ~/.bashrc
    fi
}

setup_nvim() {
    msg "Configuring neovim and it's plugins"

    sudo pacman -S --noconfirm --needed gcc make git ripgrep fd unzip neovim tree-sitter-cli

    stow --restow -t "$HOME" -d "$HOME/dotfiles" nvim
}

all() {
    update_system    # Update the system first
    install_base    # Install necessary packages
    install_yay    # Installing yay
    install_dotfiles    # install the dotfiles
    setup_hyprland    # Setup hyprland
    # SDDM theming - NOT TOUCHED
    setup_nvim    # Neovim config
}

case "${1:-all}" in
	all)
		all
		;;

	update)
		update_system
		;;

	base)
		install_base
		;;

	yay)
		install_yay
		;;

	dotfiles)
		install_dotfiles
		;;

	hyprland)
		setup_hyprland
		;;

	nvim)
		setup_nvim
		;;

	    *)
		echo "Usage:"
		echo "./setup.sh [all|update|base|yay|dotfiles|hyprland|nvim]"
		exit 1
		;;
	esac
