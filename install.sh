#!/usr/bin/env bash
set -euo pipefail

DOTFILES_GIT="https://github.com/Zarkibar/dotfiles.git"
YAY_GIT="https://aur.archlinux.org/yay.git"
GHOSTMIRROR_GIT="https://aur.archlinux.org/ghostmirror.git"


sudo -v || exit 1

while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &


msg() {
    printf "\n==> %s\n" "$1"
}

update_mirrors() {
    msg "Installing and reorganizing mirrors for pacman"

    if pacman -Q ghostmirror &>/dev/null; then
	echo "ghostmirror installed"
    else
	if [ ! -d "$HOME/ghostmirror" ]; then
	    git clone "$GHOSTMIRROR_GIT" "$HOME/ghostmirror"
	else
	    echo "ghostmirror git file already exists."
	fi

	cd ~/ghostmirror/
        makepkg -s --noconfirm
	sudo pacman -U --noconfirm ./*.pkg.tar.zst
        cd
	rm -rf ~/ghostmirror/
    fi

    COUNTRIES="Bangladesh,India,Singapore,Malaysia,Thailand,Indonesia,Japan,China,Germany,Netherlands"
    ghostmirror -Po -c "$COUNTRIES" -l ~/mirrorlist.new -L 30 -S state,outofdate,morerecent,ping
    ghostmirror -Po -mu ~/mirrorlist.new -l ~/mirrorlist.new -s light -S state,outofdate,morerecent,estimated,speed
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    sudo cp ~/mirrorlist.new /etc/pacman.d/mirrorlist
    echo "mirrors updated."
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
    update_mirrors
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

    mirrors)
	update_mirrors
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
