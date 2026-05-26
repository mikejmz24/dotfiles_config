#!/bin/bash
# =============================================================================
# install-linux.sh
# Ubuntu 24.04 / System76 Darter Pro — Full Development Environment Setup
#
# Run this script after a fresh Ubuntu install to set up your full dev
# environment. It installs everything in the correct dependency order.
#
# Usage:
#   bash install-linux.sh
#
# Safe to re-run — most steps are idempotent.
# =============================================================================

set -e  # Exit on any error

echo ""
echo "============================================="
echo " mikejmz24 — Linux Dev Environment Setup"
echo "============================================="
echo ""

# =============================================================================
# SECTION 1: APT PACKAGES
# Core system utilities installed via apt.
# These must be installed first as other tools depend on them.
# =============================================================================

echo "→ Installing apt packages..."

sudo apt update

sudo apt install -y \
  git \          # Version control. Required by chezmoi, nvim plugins, and everything else.
  curl \         # HTTP client. Required to download chezmoi, Oh My Zsh, and Nerd Fonts.
  zsh \          # Shell. Replaces bash. Required before Oh My Zsh can be installed.
  xz-utils \    # Compression/decompression for .xz and .tar.xz files. Often needed when extracting downloaded software.
  ripgrep \      # (rg) Extremely fast file content search. Required by Telescope (nvim fuzzy finder).
  tree \         # Displays directory structure as a visual tree. Useful for navigating projects.
  jq \           # Command-line JSON processor. Required by jq-lsp in Neovim.
  golang \       # Go programming language runtime. Required by gopls, gofumpt, goimports, gomodifytags, sqls, jq-lsp.
  nodejs \       # JavaScript runtime. Required by html-lsp, css-lsp, prettier, pyright (Mason installs).
  npm \          # Node package manager. Installed alongside nodejs. Required by Mason for JS-based LSPs.
  python3 \      # Python 3 interpreter. Required by pyright, black, isort, pylint, sqlfluff.
  python3-pip \  # Python package installer. Required to install pyright, black, isort, pylint, pynvim.
  python3-venv \ # Python virtual environment support. Required by Mason's Python tooling.
  wl-clipboard \ # Wayland clipboard provider. Required by Neovim clipboard integration (wl-copy/wl-paste).
  fd-find        # (fdfind on Ubuntu) Fast file finder. Required by Telescope for extended file search capabilities.

echo "✅ apt packages installed"

# =============================================================================
# SECTION 2: fd SYMLINK
# Ubuntu names the fd binary 'fdfind' to avoid conflicts with another package.
# We create a symlink so every tool that calls 'fd' finds it correctly.
# This is a symlink, not an alias — works system-wide for all apps and scripts.
# =============================================================================

echo "→ Setting up fd symlink..."

mkdir -p ~/.local/bin
ln -sf $(which fdfind) ~/.local/bin/fd

# Add ~/.local/bin to PATH if not already there
if ! grep -q 'HOME/.local/bin' ~/.zshrc; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

echo "✅ fd symlink created at ~/.local/bin/fd"

# =============================================================================
# SECTION 1b: REMOVE PRE-INSTALLED BLOAT
# Ubuntu 24.04 ships with several apps and language packs that are not needed
# for this setup. Removing them keeps the system lean and performant.
#
# Safe to re-run — apt remove is idempotent.
# =============================================================================

echo "→ Removing pre-installed bloat..."

# Webcam app and video player — not needed, using web browser for media
sudo apt remove --purge cheese totem example-content 2>/dev/null || true

# Thunderbird — using web-based email instead
# LibreOffice — using Google Docs/Sheets/Slides instead
sudo apt remove --purge 'thunderbird*' 'libreoffice*' 2>/dev/null || true

# CJK input methods — English and Spanish only
sudo apt remove --purge \
  ibus-chewing ibus-libpinyin ibus-m17n \
  'ibus-table-cangjie*' ibus-table-wubi ibus-table-quick-classic \
  libchewing3 libchewing3-data libpinyin-data libpinyin15 \
  libm17n-0 libotf1 m17n-db libopencc1.1 libopencc-data \
  libmarisa0 fonts-arphic-ukai fonts-arphic-uming 2>/dev/null || true

# Non-ES/EN language packs — keeping English and Spanish only
sudo apt remove --purge \
  language-pack-de language-pack-de-base \
  language-pack-fr language-pack-fr-base \
  language-pack-it language-pack-it-base \
  language-pack-ru language-pack-ru-base \
  language-pack-pt language-pack-pt-base \
  language-pack-zh-hans language-pack-zh-hans-base \
  language-pack-gnome-de language-pack-gnome-de-base \
  language-pack-gnome-fr language-pack-gnome-fr-base \
  language-pack-gnome-it language-pack-gnome-it-base \
  language-pack-gnome-ru language-pack-gnome-ru-base \
  language-pack-gnome-pt language-pack-gnome-pt-base \
  language-pack-gnome-zh-hans language-pack-gnome-zh-hans-base \
  gnome-user-docs-de gnome-user-docs-fr gnome-user-docs-it \
  gnome-user-docs-ru gnome-user-docs-pt gnome-user-docs-zh-hans 2>/dev/null || true

# Spell/hyphen/thesaurus for unused languages
sudo apt remove --purge \
  hyphen-de hyphen-fr hyphen-it hyphen-ru \
  hyphen-pt-br hyphen-pt-pt hyphen-en-ca hyphen-en-gb \
  mythes-de mythes-de-ch mythes-fr mythes-it \
  mythes-ru mythes-pt-pt mythes-en-au hunspell-fr 2>/dev/null || true

sudo apt autoremove -y && sudo apt clean

echo "✅ Bloat removed"

# =============================================================================
# SECTION 3: SNAP PACKAGES
# Applications installed via Snap. These are sandboxed and auto-updating.
# Snap is pre-installed on Ubuntu.
#
# Why Snap for Ghostty and Neovim?
# - The Ubuntu apt versions are outdated (Neovim 0.9.x vs current 0.12.x)
# - The System76 PPA was unavailable during setup (outage)
# - Snap provides the latest stable versions automatically
# =============================================================================

echo "→ Installing Snap packages..."

# Ghostty — GPU-accelerated terminal emulator
# Publisher: Ken VanDine (✪ verified)
# --classic flag required: Ghostty needs full system access for GPU and shell integration
sudo snap install ghostty --classic

# Neovim — Hyperextensible text editor
# Using Snap to get latest version (0.12.x)
# --classic flag required: Neovim needs full filesystem access
sudo snap install nvim --classic

echo "✅ Snap packages installed"

# =============================================================================
# SECTION 4: ZSH + OH MY ZSH
# Oh My Zsh must be installed AFTER zsh but BEFORE chezmoi applies .zshrc,
# because .zshrc references $ZSH (the Oh My Zsh install directory).
# =============================================================================

echo "→ Setting Zsh as default shell..."
chsh -s $(which zsh)
echo "✅ Zsh set as default shell (takes effect after logout/login)"

echo "→ Installing Oh My Zsh..."
# --unattended flag skips the interactive prompt
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
echo "✅ Oh My Zsh installed"

# =============================================================================
# SECTION 5: ZSH PLUGINS
# Must be installed AFTER Oh My Zsh so the custom plugins directory exists.
# zsh-autosuggestions: grey suggestions from history, press → to accept
# zsh-syntax-highlighting: colors commands green (valid) or red (invalid)
# =============================================================================

echo "→ Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "✅ Zsh plugins installed"

# =============================================================================
# SECTION 6: CHEZMOI
# Dotfile manager. Installed after Zsh so chezmoi can apply .zshrc correctly.
# Installs to ~/bin/ — we add this to PATH.
# =============================================================================

echo "→ Installing chezmoi..."
sh -c "$(curl -fsLS get.chezmoi.io)"

# Add ~/bin to PATH if not already there
if ! grep -q 'HOME/bin' ~/.zshrc; then
  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
fi

export PATH="$HOME/bin:$PATH"
echo "✅ chezmoi $(chezmoi --version | head -1) installed"

# =============================================================================
# SECTION 7: HACK NERD FONT
# Must be installed before Ghostty is launched, otherwise Ghostty falls back
# to a default font and the terminal looks wrong.
#
# Hack Nerd Font is a patched version of the Hack monospace font with
# thousands of extra icons/glyphs added. Required by:
# - Ghostty config (font-family = Hack Nerd Font)
# - Neovim plugins (lualine, mini-icons, oil.nvim use nerd font glyphs)
# - Oh My Zsh robbyrussell theme (uses special prompt characters)
# =============================================================================

echo "→ Installing Hack Nerd Font..."

mkdir -p ~/.local/share/fonts

BASE_URL="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack"

curl -fLo ~/.local/share/fonts/HackNerdFont-Regular.ttf \
  "$BASE_URL/Regular/HackNerdFont-Regular.ttf"

curl -fLo ~/.local/share/fonts/HackNerdFont-Bold.ttf \
  "$BASE_URL/Bold/HackNerdFont-Bold.ttf"

curl -fLo ~/.local/share/fonts/HackNerdFont-Italic.ttf \
  "$BASE_URL/Italic/HackNerdFont-Italic.ttf"

curl -fLo ~/.local/share/fonts/HackNerdFont-BoldItalic.ttf \
  "$BASE_URL/BoldItalic/HackNerdFont-BoldItalic.ttf"

fc-cache -fv
echo "✅ Hack Nerd Font installed and font cache refreshed"

# =============================================================================
# SECTION 8: APPLY DOTFILES VIA CHEZMOI
# This deploys all configs from the GitHub repo to their correct locations:
# - ~/.config/ghostty/config
# - ~/.config/nvim/ (full Neovim config)
# - ~/.zshrc
# - ~/.gitconfig
# =============================================================================

echo "→ Applying dotfiles via chezmoi..."
chezmoi init git@github.com:mikejmz24/dotfiles_config.git
chezmoi apply
echo "✅ Dotfiles applied"

# =============================================================================
# SECTION 9: PYTHON PACKAGES FOR NEOVIM
# These must be installed AFTER chezmoi applies the Neovim config,
# because Mason (Neovim's LSP manager) will try to use them on first launch.
#
# --break-system-packages flag is required on Ubuntu 24.04 because pip
# is restricted by PEP 668 to avoid conflicts with system Python packages.
# =============================================================================

echo "→ Installing Python packages for Neovim..."

pip install \
  pynvim \    # Python provider for Neovim. Required for Python-based plugins and :checkhealth.
  pyright \   # Python type checker and LSP. Used by Mason's pyright install.
  black \     # Python code formatter. Used by conform.nvim for Python files.
  isort \     # Python import sorter. Used by conform.nvim alongside black.
  pylint \    # Python linter. Used by nvim-lint for Python diagnostics.
  sqlfluff \  # SQL linter and formatter. Used by conform.nvim and nvim-lint for SQL files.
  --break-system-packages

echo "✅ Python packages installed"

# =============================================================================
# SECTION 10: GHOSTTY AS DEFAULT TERMINAL
# Configures GNOME to use Ghostty when opening a terminal from the file
# manager (Nautilus) or keyboard shortcut (Ctrl+Alt+T).
# =============================================================================

echo "→ Setting Ghostty as default terminal..."

gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'

sudo update-alternatives --install \
  /usr/bin/x-terminal-emulator \
  x-terminal-emulator \
  $(which ghostty) 50

echo "✅ Ghostty set as default terminal"

# =============================================================================
# SECTION 11: GNOME SETTINGS
# Apply all GNOME customizations documented in linux-gnome-settings.sh
# =============================================================================

echo "→ Applying GNOME settings..."
bash "$(dirname "$0")/linux-gnome-settings.sh"
echo "✅ GNOME settings applied"

# =============================================================================
# SECTION 12: SSH KEY SETUP (MANUAL STEP)
# SSH keys cannot be automated — they must be generated fresh on each machine
# and manually added to GitHub. This section prints instructions.
# =============================================================================

echo ""
echo "============================================="
echo " MANUAL STEP REQUIRED: SSH Key Setup"
echo "============================================="
echo ""
echo "Run these commands to set up your SSH key:"
echo ""
echo "  ssh-keygen -t ed25519 -C 'YOUR_ID+mikejmz24@users.noreply.github.com'"
echo "  eval \"\$(ssh-agent -s)\""
echo "  ssh-add ~/.ssh/id_ed25519"
echo "  cat ~/.ssh/id_ed25519.pub"
echo ""
echo "Then go to: GitHub → Settings → SSH and GPG keys → New SSH key"
echo "Paste the output of 'cat ~/.ssh/id_ed25519.pub' and save."
echo ""
echo "Test with: ssh -T git@github.com"
echo ""

# =============================================================================
# SECTION 13: GNOME EXTENSIONS (MANUAL STEP)
# Install via: sudo apt install gnome-shell-extension-manager
# Then open extension-manager and install:
# 1. "Hide Top Bar" by tuxor1337 (NOT sonersg)
# 2. "Just Perfection"
# See README for configuration details.
# =============================================================================

echo ""
echo "MANUAL STEP: Install GNOME extensions via Extension Manager"
echo "  sudo apt install gnome-shell-extension-manager"
echo "  extension-manager &"
echo "  Install: 'Hide Top Bar' by tuxor1337 and 'Just Perfection'"
echo ""

# =============================================================================
# SECTION 14: SYSTEM76 DRIVER AND FIRMWARE
# system76-driver: hardware integration for Darter Pro 11
# system76-firmware-cli: firmware updates (reboot to apply)
# =============================================================================

echo "→ Installing System76 driver..."
sudo apt install -y system76-driver
echo "✅ System76 driver installed"

echo "→ Checking for firmware updates..."
sudo system76-firmware-cli schedule && echo "Firmware scheduled — reboot to install" \
  || echo "Firmware already up to date"

# =============================================================================
# DONE
# =============================================================================

echo "============================================="
echo " Setup complete!"
echo ""
echo " Next steps:"
echo " 1. Log out and back in (activates Zsh as default shell)"
echo " 2. Open Ghostty"
echo " 3. Open nvim — lazy.nvim will auto-install all plugins"
echo " 4. Inside nvim run: :checkhealth"
echo " 5. Complete the SSH key setup above"
echo "============================================="
