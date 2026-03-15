#!/bin/bash
set -euo pipefail

echo "=== Termux Setup Script ==="

# 1. Update/Upgrade
echo "[1/6] Updating packages..."
pkg update && pkg upgrade -y

# 2. Install core packages
echo "[2/6] Installing packages..."
pkg install -y \
  git \
  tmux \
  fzf \
  ripgrep \
  curl \
  wget \
  build-essential \
  clang \
  unzip \
  stow \
  htop \
  neovim \
  fontconfig-utils

# 3. Clean up existing dotfiles to avoid stow conflicts
echo "[3/6] Cleaning up existing dotfiles..."
FILES_TO_REMOVE=(
  ".bashrc"
  ".bash_logout"
  ".profile"
  ".tmux.conf"
)
DIRS_TO_REMOVE=(
  ".config/i3"
  ".config/polybar"
  ".config/rofi"
  ".config/alacritty"
  ".config/nvim"
)

for f in "${FILES_TO_REMOVE[@]}"; do
  rm -f "$HOME/$f"
done
for d in "${DIRS_TO_REMOVE[@]}"; do
  rm -rf "$HOME/$d"
done

# 4. Prepare Neovim
echo "[4/6] Setting up Neovim..."
mkdir -p "$HOME/.config/nvim/pack/nvim/start"
if [ ! -d "$HOME/.config/nvim/pack/nvim/start/nvim-lspconfig" ]; then
  git clone --depth 1 https://github.com/neovim/nvim-lspconfig "$HOME/.config/nvim/pack/nvim/start/nvim-lspconfig"
fi

# 5. Stow dotfiles
echo "[5/6] Stowing dotfiles..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/dotfiles"

# Stow essential ones for Termux
stow -v -R -t "$HOME" bash tmux nvim

# 6. Fonts
echo "[6/6] Setting up fonts..."
mkdir -p "$HOME/.local/share/fonts"
if [ ! -d "$HOME/.local/share/fonts/MoralerspaceHW_v2.0.0" ]; then
  echo "Downloading Moralerspace font..."
  curl -L https://github.com/yuru7/moralerspace/releases/download/v2.0.0/MoralerspaceHW_v2.0.0.zip -o /tmp/font.zip
  unzip -o /tmp/font.zip -d "$HOME/.local/share/fonts"
  rm /tmp/font.zip
  fc-cache -fv
fi

echo "=== Setup Complete! ==="
echo "Please restart Termux or run 'source ~/.bashrc'."
