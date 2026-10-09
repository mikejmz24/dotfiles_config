#!/bin/bash
# =============================================================================
# install-linux.sh
# Ubuntu 26.04 / System76 Darter Pro — Full Development Environment Setup
#
# Run this script after a fresh Ubuntu install to set up your full dev
# environment. It installs everything in the correct dependency order.
#
# Usage (from the README quick start — the repo is cloned straight into
# chezmoi's source directory, and the script runs from there):
#   bash ~/.local/share/chezmoi/install-linux.sh
#
# Prerequisite: ~/.config/chezmoi/chezmoi.toml must exist (see README).
#
# Safe to re-run — every step checks whether it is already done.
# =============================================================================

set -e  # Exit on any error

# Directory this script lives in (the chezmoi source dir) — used to find
# linux-gnome-settings.sh next to it.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/mikejmz24/dotfiles_config.git"

echo ""
echo "============================================="
echo " mikejmz24 — Linux Dev Environment Setup"
echo "============================================="
echo ""

# =============================================================================
# SECTION 0: PRE-FLIGHT — chezmoi.toml
# chezmoi templates need the `os` variable from this machine-specific file.
# Check it first so the script fails in second 1, not halfway through.
# =============================================================================

if ! grep -qs 'os *= *"linux"' ~/.config/chezmoi/chezmoi.toml; then
  echo "❌ ~/.config/chezmoi/chezmoi.toml is missing or has no os = \"linux\"."
  echo ""
  echo "Create it first (nano is preinstalled on Ubuntu):"
  echo ""
  echo "  mkdir -p ~/.config/chezmoi"
  echo "  nano ~/.config/chezmoi/chezmoi.toml"
  echo ""
  echo "Content (fill in your values):"
  echo ""
  echo "  [data]"
  echo "      name = \"Your Name\""
  echo "      email = \"YOUR_ID+mikejmz24@users.noreply.github.com\""
  echo "      github_user = \"mikejmz24\""
  echo "      os = \"linux\""
  echo ""
  exit 1
fi
echo "✅ chezmoi.toml found"

# =============================================================================
# SECTION 1: APT PACKAGES
# Core system utilities installed via apt.
# These must be installed first as other tools depend on them.
#
# Note: comments must NOT follow a trailing backslash — "pkg \  # comment"
# ends the command there. Each package is explained above the list instead.
#
#   git              Version control. Required by chezmoi, nvim plugins, Oh My Zsh.
#   curl             HTTP client. Downloads chezmoi, Oh My Zsh, Nerd Fonts, Nordic.
#   zsh              Shell. Replaces bash. Required before Oh My Zsh can be installed.
#   xz-utils         .xz / .tar.xz extraction (Nordic theme, other downloads).
#   ripgrep          (rg) Fast content search. Required by Telescope.
#   tree             Directory structure as a tree.
#   jq               Command-line JSON processor. Required by jq-lsp.
#   golang           Go runtime. Required by gopls, gofumpt, goimports, sqls, jq-lsp.
#   nodejs, npm      JS runtime + package manager. Required by Mason's JS-based LSPs.
#   python3          Required by pyright, black, isort, pylint, sqlfluff.
#   python3-pip      Installs the Python tools in section 10.
#   python3-venv     Required by Mason's Python tooling.
#   wl-clipboard     Wayland clipboard (wl-copy/wl-paste) for Neovim.
#   fd-find          (fdfind on Ubuntu) Fast file finder. Optional (Telescope uses rg);
#                    kept so `:checkhealth lazy` is clean and `fd` works in the shell.
#   chromium-browser Browser. Used instead of Firefox (Wayland issues on System76).
# =============================================================================

echo "→ Installing apt packages..."

sudo apt update

sudo apt install -y \
  git \
  curl \
  zsh \
  xz-utils \
  ripgrep \
  tree \
  jq \
  golang \
  nodejs \
  npm \
  python3 \
  python3-pip \
  python3-venv \
  wl-clipboard \
  fd-find \
  chromium-browser

echo "✅ apt packages installed"

# =============================================================================
# SECTION 2: REMOVE PRE-INSTALLED BLOAT
# Ubuntu ships with several apps and language packs that are not needed
# for this setup. Removing them keeps the system lean and performant.
#
# Safe to re-run — apt remove is idempotent.
# =============================================================================

echo "→ Removing pre-installed bloat..."

# Webcam app and video player — not needed, using web browser for media
sudo apt remove --purge -y cheese totem example-content 2>/dev/null || true

# Thunderbird — using web-based email instead (ships as apt AND snap)
# LibreOffice — using Google Docs/Sheets/Slides instead
sudo apt remove --purge -y 'thunderbird*' 'libreoffice*' 2>/dev/null || true
sudo snap remove thunderbird 2>/dev/null || true

# Firefox — using Chromium instead (Wayland compatibility)
sudo apt remove --purge -y firefox 'firefox*' 2>/dev/null || true

# CJK input methods — English and Spanish only
sudo apt remove --purge -y \
  ibus-chewing ibus-libpinyin ibus-m17n \
  'ibus-table-cangjie*' ibus-table-wubi ibus-table-quick-classic \
  libchewing3 libchewing3-data libpinyin-data libpinyin15 \
  libm17n-0 libotf1 m17n-db libopencc1.1 libopencc-data \
  libmarisa0 fonts-arphic-ukai fonts-arphic-uming 2>/dev/null || true

# Non-ES/EN language packs — keeping English and Spanish only
sudo apt remove --purge -y \
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
sudo apt remove --purge -y \
  hyphen-de hyphen-fr hyphen-it hyphen-ru \
  hyphen-pt-br hyphen-pt-pt hyphen-en-ca hyphen-en-gb \
  mythes-de mythes-de-ch mythes-fr mythes-it \
  mythes-ru mythes-pt-pt mythes-en-au hunspell-fr 2>/dev/null || true

sudo apt autoremove -y && sudo apt clean

echo "✅ Bloat removed"

# =============================================================================
# SECTION 3: fd SYMLINK
# Ubuntu names the fd binary 'fdfind' to avoid conflicts with another package.
# We create a symlink so every tool that calls 'fd' finds it correctly.
# ~/.local/bin is already on PATH via the chezmoi-managed ~/.zshrc.
# =============================================================================

echo "→ Setting up fd symlink..."

mkdir -p ~/.local/bin
ln -sf "$(command -v fdfind)" ~/.local/bin/fd

echo "✅ fd symlink created at ~/.local/bin/fd"

# =============================================================================
# SECTION 4: SNAP PACKAGES
# Applications installed via Snap. These are sandboxed and auto-updating.
#
# Why Snap for Ghostty and Neovim?
# - The Ubuntu apt versions are outdated (Neovim 0.9.x vs current 0.12.x)
# - Snap provides the latest stable versions automatically
# --classic: both need full filesystem / GPU / shell access
# =============================================================================

echo "→ Installing Snap packages..."
sudo snap install ghostty --classic
sudo snap install nvim --classic
echo "✅ Snap packages installed"

# =============================================================================
# SECTION 5: HACK NERD FONT
# Must be installed before Ghostty is launched, otherwise Ghostty falls back
# to a default font. Required by the Ghostty config, lualine, mini-icons,
# oil.nvim and the robbyrussell prompt.
# =============================================================================

echo "→ Installing Hack Nerd Font..."

mkdir -p ~/.local/share/fonts
BASE_URL="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack"

for style in Regular Bold Italic BoldItalic; do
  if [ ! -f ~/.local/share/fonts/HackNerdFont-$style.ttf ]; then
    curl -fLo ~/.local/share/fonts/HackNerdFont-$style.ttf \
      "$BASE_URL/$style/HackNerdFont-$style.ttf"
  fi
done

fc-cache -f
echo "✅ Hack Nerd Font installed and font cache refreshed"

# =============================================================================
# SECTION 6: ZSH + OH MY ZSH + PLUGINS
# Oh My Zsh must exist before chezmoi applies .zshrc, because .zshrc loads
# $ZSH/oh-my-zsh.sh and the two custom plugins below.
# KEEP_ZSHRC=yes stops the installer from replacing an existing .zshrc.
# =============================================================================

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  echo "→ Setting Zsh as default shell..."
  chsh -s "$(command -v zsh)"
  echo "✅ Zsh set as default shell (takes effect after logout/login)"
fi

if [ ! -d ~/.oh-my-zsh ]; then
  echo "→ Installing Oh My Zsh..."
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo "✅ Oh My Zsh installed"
fi

ZSH_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$ZSH_PLUGINS/$plugin" ]; then
    git clone "https://github.com/zsh-users/$plugin" "$ZSH_PLUGINS/$plugin"
  fi
done
echo "✅ Zsh plugins installed"

# =============================================================================
# SECTION 7: CHEZMOI
# Installed to ~/bin. -b is required: the installer's default is ./bin
# relative to the CURRENT directory, which would put it inside the repo.
# ~/bin is on PATH via the chezmoi-managed ~/.zshrc; exported here for the
# rest of this script.
# =============================================================================

export PATH="$HOME/bin:$PATH"

if ! command -v chezmoi >/dev/null; then
  echo "→ Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/bin"
fi
echo "✅ $(chezmoi --version | head -1)"

# =============================================================================
# SECTION 8: APPLY DOTFILES VIA CHEZMOI
# Uses HTTPS so it works before an SSH key exists. If the repo is already
# cloned in ~/.local/share/chezmoi (README quick start), init reuses it.
# Deploys .zshrc, .gitconfig, .gitignore_global, .ssh/config, Ghostty,
# Neovim, and the GTK 3/4 theme CSS (Linux only).
# =============================================================================

echo "→ Applying dotfiles via chezmoi..."
chezmoi init "$REPO_URL"
chezmoi apply
echo "✅ Dotfiles applied"

# =============================================================================
# SECTION 9: PYTHON PACKAGES FOR NEOVIM
# Installed after chezmoi applies the Neovim config, before Mason first runs.
#   pynvim    Python provider for Neovim (:checkhealth)
#   pyright   Python type checker / LSP
#   black     Python formatter (conform.nvim)
#   isort     Python import sorter (conform.nvim)
#   pylint    Python linter (nvim-lint)
#   sqlfluff  SQL linter + formatter
#
# --break-system-packages is required on Ubuntu (PEP 668). Without sudo, pip
# installs into ~/.local, leaving system Python untouched.
# =============================================================================

echo "→ Installing Python packages for Neovim..."
pip install --user --break-system-packages \
  pynvim pyright black isort pylint sqlfluff
echo "✅ Python packages installed"

# =============================================================================
# SECTION 10: CHROMIUM AS DEFAULT BROWSER
# =============================================================================

echo "→ Setting Chromium as default browser..."

sudo update-alternatives --install \
  /usr/bin/x-www-browser x-www-browser /usr/bin/chromium-browser 50
sudo update-alternatives --install \
  /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/chromium-browser 50
xdg-settings set default-web-browser chromium_chromium.desktop 2>/dev/null || true

echo "✅ Chromium set as default browser"

# =============================================================================
# SECTION 11: GHOSTTY AS DEFAULT TERMINAL
# Used by Nautilus "Open in Terminal" and Ctrl+Alt+T.
# =============================================================================

echo "→ Setting Ghostty as default terminal..."

gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty' 2>/dev/null || true
sudo update-alternatives --install \
  /usr/bin/x-terminal-emulator x-terminal-emulator "$(command -v ghostty)" 50

echo "✅ Ghostty set as default terminal"

# =============================================================================
# SECTION 12: GTK THEME — Nordic with Admiral accent #2354a0
# The theme files are downloaded here; the customized gtk.css files for
# GTK 3 and GTK 4 are managed by chezmoi (dot_config/private_gtk-*), so this
# script never edits them. An existing ~/.local/share/themes/Nordic is left
# untouched (it may be a different Nordic version than the latest release).
# =============================================================================

echo "→ Setting up Nordic theme..."

THEME_DIR="$HOME/.local/share/themes/Nordic"
if [ ! -d "$THEME_DIR" ]; then
  mkdir -p ~/.local/share/themes
  curl -fsSL https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz \
    | tar -xJ -C ~/.local/share/themes
fi

gsettings set org.gnome.desktop.interface gtk-theme 'Nordic'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# GTK 4 apps read gtk-dark.css and assets/ from ~/.config/gtk-4.0 — point
# them at Nordic (they previously pointed at an old Graphite theme).
mkdir -p ~/.config/gtk-4.0
ln -sfn "$THEME_DIR/gtk-4.0/gtk-dark.css" ~/.config/gtk-4.0/gtk-dark.css
if [ -d "$THEME_DIR/gtk-4.0/assets" ]; then
  ln -sfn "$THEME_DIR/gtk-4.0/assets" ~/.config/gtk-4.0/assets
fi

echo "✅ Nordic theme applied"

# =============================================================================
# SECTION 13: GNOME SETTINGS
# Scaling flag, window keybindings, dock, workspaces.
# =============================================================================

echo "→ Applying GNOME settings..."
bash "$SCRIPT_DIR/linux-gnome-settings.sh"
echo "✅ GNOME settings applied"

# =============================================================================
# SECTION 14: SYSTEM76 DRIVER AND FIRMWARE
# Only available when the System76 apt repository is configured (it ships
# with System76's factory Ubuntu image). Skipped otherwise.
# =============================================================================

if apt-cache show system76-driver >/dev/null 2>&1; then
  echo "→ Installing System76 driver..."
  sudo apt install -y system76-driver
  echo "✅ System76 driver installed"

  echo "→ Checking for firmware updates..."
  sudo system76-firmware-cli schedule && echo "Firmware scheduled — reboot to install" \
    || echo "Firmware already up to date"
else
  echo "⚠️  system76-driver not available (System76 apt repo not configured) — skipped"
fi

# =============================================================================
# DONE — manual steps
# =============================================================================

echo ""
echo "============================================="
echo " Setup complete! Manual steps remaining:"
echo "============================================="
echo ""
echo "1. SSH key (needed to push to GitHub):"
echo "     ssh-keygen -t ed25519 -C 'YOUR_ID+mikejmz24@users.noreply.github.com'"
echo "     eval \"\$(ssh-agent -s)\" && ssh-add ~/.ssh/id_ed25519"
echo "     cat ~/.ssh/id_ed25519.pub   # add at GitHub → Settings → SSH keys"
echo "     ssh -T git@github.com"
echo "   Then switch the dotfiles remote from HTTPS to SSH:"
echo "     git -C ~/.local/share/chezmoi remote set-url origin git@github.com:mikejmz24/dotfiles_config.git"
echo ""
echo "2. GNOME extensions:"
echo "     sudo apt install gnome-shell-extension-manager && extension-manager &"
echo "     Install 'Hide Top Bar' by tuxor1337 and 'Just Perfection'"
echo ""
echo "3. Log out and back in (activates Zsh and the Nordic theme)"
echo "4. Open nvim — lazy.nvim installs all plugins; then run :checkhealth"
echo "5. Settings → Displays: set the external monitor's scale (e.g. 150%)"
echo ""
