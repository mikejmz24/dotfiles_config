install-mac.txt
Page
/1

#!/bin/bash
# =============================================================================
# install-mac.sh
# macOS (Apple Silicon) — Full Development Environment Setup
#
# Run this script after a fresh macOS install or when setting up a new Mac.
# It installs everything in the correct dependency order.
#
# Usage:
#   bash install-mac.sh
#
# Safe to re-run — most steps are idempotent.
#
# NOTE: This script assumes you are logged into the Mac App Store if you
# need any App Store apps. It also assumes you have an internet connection.
# =============================================================================

set -e  # Exit on any error

echo ""
echo "============================================="
echo " mikejmz24 — Mac Dev Environment Setup"
echo "============================================="
echo ""

# =============================================================================
# SECTION 1: XCODE COMMAND LINE TOOLS
# Must be installed first — Homebrew and git depend on it.
# =============================================================================

echo "→ Installing Xcode Command Line Tools..."
xcode-select --install 2>/dev/null || echo "Already installed"
echo "✅ Xcode Command Line Tools ready"

# =============================================================================
# SECTION 2: HOMEBREW
# Package manager for macOS. Must come before everything else.
# =============================================================================

echo "→ Installing Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for Apple Silicon Macs
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed"
fi
echo "✅ Homebrew $(brew --version | head -1) ready"

# =============================================================================
# SECTION 3: CHEZMOI
# Dotfile manager. Must be installed before applying dotfiles.
# On Mac, brew handles PATH automatically (unlike Linux).
# =============================================================================

echo "→ Installing chezmoi..."
brew install chezmoi
echo "✅ chezmoi $(chezmoi --version | head -1) installed"

# =============================================================================
# SECTION 4: MACHINE CONFIG (MANUAL STEP)
# chezmoi.toml is machine-specific and NEVER committed to the repo.
# It provides identity variables used in config templates.
# Must exist before chezmoi init so templates render correctly.
# =============================================================================

echo ""
echo "============================================="
echo " MANUAL STEP REQUIRED: chezmoi config"
echo "============================================="
echo ""
echo "Create your machine config before continuing:"
echo ""
echo "  mkdir -p ~/.config/chezmoi"
echo "  nvim ~/.config/chezmoi/chezmoi.toml"
echo ""
echo "Add this content (fill in YOUR actual values):"
echo ""
echo "  [data]"
echo "      name = \"Your Name\""
echo "      email = \"YOUR_ID+mikejmz24@users.noreply.github.com\""
echo "      github_user = \"mikejmz24\""
echo "      work_name = \"your-work-username\""
echo "      os = \"mac\""
echo ""
read -p "Press ENTER when done..."

# =============================================================================
# SECTION 5: SSH KEY SETUP (MANUAL STEP)
# SSH keys must be generated fresh on each machine — never copy between machines.
# Must be set up before chezmoi init so it can clone via SSH.
# =============================================================================

echo ""
echo "============================================="
echo " MANUAL STEP REQUIRED: SSH Key"
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
echo "Name it something descriptive (e.g. 'MacBook Pro M4')"
echo ""
echo "Test with: ssh -T git@github.com"
echo "Expected:  Hi mikejmz24! You've successfully authenticated."
echo ""
read -p "Press ENTER when done..."

# =============================================================================
# SECTION 6: APPLY DOTFILES VIA CHEZMOI
# Clones the dotfiles repo and deploys configs to their correct locations:
# - ~/.config/ghostty/config (from template — font size 18, super keybindings)
# - ~/.config/nvim/ (full Neovim config)
# - ~/.zshrc
# - ~/.gitconfig (from template — personal identity + work includeIf)
# - ~/.gitignore_global
# Must come before Oh My Zsh so .zshrc is in place.
# =============================================================================

echo "→ Applying dotfiles via chezmoi..."
chezmoi init git@github.com:mikejmz24/dotfiles_config.git
chezmoi apply
echo "✅ Dotfiles applied"

# =============================================================================
# SECTION 7: OH MY ZSH
# Must be installed after chezmoi applies .zshrc, because the installer
# may overwrite .zshrc. After install, re-apply chezmoi to restore our .zshrc.
# =============================================================================

echo "→ Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# Re-apply chezmoi to restore our .zshrc which Oh My Zsh may have overwritten
chezmoi apply ~/.zshrc
echo "✅ Oh My Zsh installed"

# =============================================================================
# SECTION 8: HOMEBREW BUNDLE
# Installs everything from ~/Brewfile in one command.
# This includes: git, neovim, ripgrep, fd, tree, jq, go, node, python,
# docker, ghostty, VSCode, all Nerd Fonts, and more.
#
# Install order within Brewfile:
# - Core tools first (git, neovim, ripgrep, fd, tree, jq, xz, wget, bat)
# - Runtimes (go, node, python@3.12)
# - Python tools (pyright, virtualenv, pipx, poetry, jupyterlab)
# - Rust (rustup, cargo-c)
# - Go tools (installed via 'go' directive)
# - Tree-sitter (tree-sitter, tree-sitter-cli, luarocks)
# - Linting (golangci-lint)
# - Docker (docker, docker-compose, docker-desktop)
# - Work tools (gh)
# - GUI apps (ghostty, vscode, chrome, slack, etc.)
# - VSCode extensions
# - Nerd Fonts
# =============================================================================

echo "→ Installing Homebrew packages from Brewfile..."
brew bundle install --file=~/Brewfile
echo "✅ All Homebrew packages installed"

# =============================================================================
# SECTION 9: RUST TOOLCHAIN INIT
# rustup is installed by Homebrew but the toolchain itself needs initializing.
# Must run after brew bundle install.
# =============================================================================

echo "→ Initializing Rust toolchain..."
rustup-init -y
source "$HOME/.cargo/env"
echo "✅ Rust $(rustc --version) initialized"

# =============================================================================
# SECTION 10: GO TOOLS
# These are installed via 'go install' — the Brewfile 'go' directive handles
# them but they require Go to be in PATH first.
# If any failed during brew bundle, install them manually:
# =============================================================================

echo "→ Verifying Go tools..."
go install github.com/cosmtrek/air@latest 2>/dev/null || true
go install github.com/melkeydev/go-blueprint@latest 2>/dev/null || true
go install github.com/cucumber/godog/cmd/godog@latest 2>/dev/null || true
go install golang.org/x/tools/gopls@latest 2>/dev/null || true
go install github.com/sqls-server/sqls@latest 2>/dev/null || true
go install github.com/a-h/templ/cmd/templ@latest 2>/dev/null || true
echo "✅ Go tools installed"

# =============================================================================
# SECTION 11: PYTHON TOOLS FOR NEOVIM
# pynvim is the Python provider for Neovim — required for :checkhealth to pass.
# Must be installed after python@3.12 from brew bundle.
# =============================================================================

echo "→ Installing Python tools for Neovim..."
pip install pynvim pyright black isort pylint sqlfluff
echo "✅ Python tools installed"

# =============================================================================
# SECTION 12: WORK GIT IDENTITY (MANUAL STEP)
# ~/.gitconfig-work is NEVER committed — it contains your real work email.
# The main ~/.gitconfig already has an includeIf that points to this file
# for any repo inside ~/Documents/work/.
# =============================================================================

echo ""
echo "============================================="
echo " MANUAL STEP REQUIRED: Work Git Identity"
echo "============================================="
echo ""
echo "Create your work git identity file (never committed):"
echo ""
echo "  nvim ~/.gitconfig-work"
echo ""
echo "Add:"
echo "  [user]"
echo "      name = your-work-username"
echo "      email = your-work@company.com"
echo ""
echo "This identity activates automatically for any repo inside ~/Documents/work/"
echo ""
read -p "Press ENTER when done (or skip if not needed)..."

# =============================================================================
# SECTION 13: DOCKER SETUP
# Docker Desktop must be launched manually at least once to complete setup.
# =============================================================================

echo ""
echo "→ Note: Open Docker Desktop manually to complete its setup."
echo "  It needs to be launched at least once before 'docker' CLI works."
echo ""

# =============================================================================
# DONE
# =============================================================================

echo "============================================="
echo " Setup complete!"
echo ""
echo " Next steps:"
echo " 1. Log out and back in (or open a new terminal)"
echo " 2. Open Ghostty — it should load with Hack Nerd Font + Challenger Deep"
echo " 3. Open nvim — lazy.nvim will auto-install all plugins on first launch"
echo " 4. Inside nvim run: :checkhealth"
echo " 5. Open Docker Desktop to complete Docker setup"
echo " 6. Verify git identity: git config user.email"
echo "============================================="
