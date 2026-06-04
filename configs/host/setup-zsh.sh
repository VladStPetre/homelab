#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/projects/dotfiles"

echo "Updating package index..."
sudo apt update

echo "Installing Zsh and dependencies..."
sudo apt install -y \
  zsh \
  curl \
  git \
  unzip \
  fzf \
  fontconfig \
  gnome-shell-extension-manager \
  rsync

echo "Installing JetBrainsMono Nerd Font..."

FONT_DIR="${HOME}/.local/share/fonts"

mkdir -p "$FONT_DIR"

curl -fLo /tmp/JetBrainsMono.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"

fc-cache -fv

echo "Installing Oh My Posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s

echo "Copying dotfiles..."
if [ -d "$DOTFILES_DIR" ]; then
  rsync -av --exclude=".git" "$DOTFILES_DIR"/ "$HOME"/
else
  echo "Warning: $DOTFILES_DIR not found. Skipping dotfiles copy."
fi

echo "Configuring Oh My Posh in ~/.zshrc..."
if ! grep -q "oh-my-posh init zsh" "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" <<'EOF'

# Oh My Posh
eval "$(oh-my-posh init zsh)"
EOF
fi

echo "Setting Zsh as default shell..."
chsh -s "$(which zsh)"

echo
echo "Done."
echo "Log out and back in, or start a new shell with:"
echo "exec zsh"