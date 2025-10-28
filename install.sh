#!/bin/bash
set -e

  if ! sudo -v; then
    echo "ERROR: This script requires sudo privileges." >&2
    exit 1
  fi

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

if ! command -v nix &>/dev/null; then
  echo "Nix not found. Installing Nix..."
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon --yes
fi

tmp=$(mktemp)
sudo cp /etc/nix/nix.conf "$tmp"
nix-shell -p crudini --run "crudini --list --set --list-sep='' $tmp '' experimental-features nix-command"
nix-shell -p crudini --run "crudini --list --set --list-sep='' $tmp '' experimental-features flakes"
sudo cp "$tmp" /etc/nix/nix.conf

echo set zsh as default shell
"$SCRIPT_DIR"/install_zsh

echo "Setting the home-manager environment (installing packages)"
nix-shell -p home-manager --run \
"home-manager switch --flake $SCRIPT_DIR"

#set the dotfiles
stow --dir="$SCRIPT_DIR/dotfiles" --target="$HOME" .

