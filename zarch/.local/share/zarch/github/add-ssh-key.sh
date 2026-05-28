#!/bin/bash

read -rp "Email: " email
read -rp "Username: " username

ssh_config_key="Host github.com
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/github_key
"

mkdir "$HOME/.ssh"
ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/github_key"
echo "$ssh_config_key" > "$HOME/.ssh/config"

git config --global user.email "$email"
git config --global user.name "$username"
