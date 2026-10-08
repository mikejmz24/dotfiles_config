#!/bin/bash
# =============================================================================
# install-mac.sh
# macOS (Apple Silicon) — Full Development Environment Setup
#
# Run this script after a fresh macOS install or when setting up a new Mac.
# It installs everything in the correct dependency order.
#
# Usage (from the README quick start — the repo is cloned straight into
# chezmoi's source directory, and the script runs from there):
#   bash ~/.local/share/chezmoi/install-mac.sh
#
# Safe to re-run — every step checks whether it is already done.
#
# NOTE: This script assumes you are logged into the Mac App Store if you
# need any App Store apps. It also assumes you have an internet connection.
# =============================================================================

set -e  # Exit on any error

REPO_URL="https://github.com/mikejmz24/dotfiles_config.git"

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
if [ ! -x /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed"
fi
# Add Homebrew to PATH for Apple Silicon Macs — once in ~/.zprofile, and
# always for this script (a re-run from the same terminal may not have it yet)
if ! grep -qs 'brew shellenv' ~/.zprofile; then
  # shellcheck disable=SC2016  # written literally on purpose
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "✅ Homebrew $(brew --version | head -1) ready"

# =============================================================================
# SECTION 3: CHEZMOI
# Dotfile manager. Must be installed before applying dotfiles.
# On Mac, brew handles PATH automatically (unlike Linux).
# =============================================================================

echo "→ Installing chezmoi..."
brew list chezmoi &>/dev/null || brew install chezmoi
echo "✅ $(chezmoi --version | head -1) installed"

# =============================================================================
# SECTION 4: MACHINE CONFIG (MANUAL STEP)
# chezmoi.toml is machine-specific and NEVER committed to the repo.
# It provides identity variables used in config templates.
# Must exist before chezmoi init so templates render correctly.
# Edited with nano — Neovim is not installed until the Brewfile step.
# =============================================================================

until grep -qs 'os *= *"mac"' ~/.config/chezmoi/chezmoi.toml; do
  echo ""
  echo "============================================="
  echo " MANUAL STEP REQUIRED: chezmoi config"
  echo "============================================="
  echo ""
  echo "Create your machine config before continuing:"
  echo ""
  echo "  mkdir -p ~/.config/chezmoi"
  echo "  nano ~/.config/chezmoi/chezmoi.toml"
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
  read -r -p "Press ENTER when done..."
done
echo "✅ chezmoi.toml found"

# =============================================================================
# SECTION 5: SSH KEY SETUP (MANUAL STEP)
# SSH keys must be generated fresh on each machine — never copy between machines.
# Not needed for the clone (HTTPS), but needed to push changes back.
# =============================================================================

if [ ! -f ~/.ssh/id_ed25519 ]; then
  echo ""
  echo "============================================="
  echo " MANUAL STEP REQUIRED: SSH Key"
  echo "============================================="
  echo ""
  echo "Run these commands to set up your SSH key:"
  echo ""
  echo "  ssh-keygen -t ed25519 -C 'YOUR_ID+mikejmz24@users.noreply.github.com'"
  echo "  eval \"\$(ssh-agent -s)\""
  echo "  ssh-add --apple-use-keychain ~/.ssh/id_ed25519"
  echo "  cat ~/.ssh/id_ed25519.pub"
  echo ""
  echo "Then go to: GitHub → Settings → SSH and GPG keys → New SSH key"
  echo "Name it something descriptive (e.g. 'MacBook Pro M4')"
  echo ""
  echo "Test with: ssh -T git@github.com"
  echo "Expected:  Hi mikejmz24! You've successfully authenticated."
  echo ""
  read -r -p "Press ENTER when done..."
fi

# =============================================================================
# SECTION 6: APPLY DOTFILES VIA CHEZMOI
# Uses HTTPS so it works regardless of SSH. If the repo is already cloned
# in ~/.local/share/chezmoi (README quick start), init reuses it.
# Deploys configs to their correct locations:
# - ~/.config/ghostty/config (from template — font size 18, super keybindings)
# - ~/.config/nvim/ (full Neovim config)
# - ~/.zshrc
# - ~/.gitconfig (from template — personal identity + work includeIf)
# - ~/.gitignore_global, ~/.ssh/config
# - ~/Brewfile (Mac only — used by the next sections)
# =============================================================================

echo "→ Applying dotfiles via chezmoi..."
chezmoi init "$REPO_URL"
chezmoi apply
echo "✅ Dotfiles applied"

# =============================================================================
# SECTION 7: OH MY ZSH + PLUGINS
# KEEP_ZSHRC=yes stops the installer from replacing our chezmoi .zshrc.
# The two custom plugins are listed in .zshrc and must be cloned separately.
# =============================================================================

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

# Safety net in case anything rewrote .zshrc
chezmoi apply ~/.zshrc
echo "✅ Zsh plugins installed"

# =============================================================================
# SECTION 8: HOMEBREW BUNDLE
# Installs everything from ~/Brewfile in one command: core CLI tools,
# runtimes (go, node, python@3.12), Python CLIs, Rust, Go tools,
# tree-sitter, Docker, gh, GUI apps, VSCode extensions, Nerd Fonts.
#
# "$HOME", not "~": a tilde after "--file=" is NOT expanded by bash.
# One failed entry (e.g. a renamed cask) makes brew bundle exit non-zero;
# that is reported but doesn't stop the rest of the setup.
# =============================================================================

echo "→ Installing Homebrew packages from Brewfile..."
if brew bundle install --file="$HOME/Brewfile"; then
  echo "✅ All Homebrew packages installed"
else
  echo "⚠️  Some Brewfile entries failed — see above. Continuing."
fi

# =============================================================================
# SECTION 9: RUST TOOLCHAIN
# Homebrew's rustup is keg-only and no longer ships `rustup-init`: its bin
# dir (rustup plus cargo/rustc proxies) must be on PATH — ~/.zshrc does that
# for new shells — and the stable toolchain is installed with rustup itself.
# =============================================================================

export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
if ! rustup toolchain list | grep -q stable; then
  echo "→ Installing Rust stable toolchain..."
  rustup default stable
fi
echo "✅ $(rustc --version) ready"

# =============================================================================
# SECTION 10: GO TOOLS
# Also listed as `go` entries in the Brewfile; installed here explicitly in
# case brew bundle skipped them. Failures are reported, not hidden.
# =============================================================================

echo "→ Installing Go tools..."
for tool in \
  github.com/air-verse/air \
  github.com/melkeydev/go-blueprint \
  github.com/cucumber/godog/cmd/godog \
  golang.org/x/tools/gopls \
  github.com/sqls-server/sqls \
  github.com/a-h/templ/cmd/templ; do
  go install "$tool@latest" || echo "⚠️  go install $tool failed"
done
echo "✅ Go tools done"

# =============================================================================
# SECTION 11: PYTHON TOOLS FOR NEOVIM
# Homebrew's Python blocks system-wide pip installs (PEP 668), and has no
# plain `pip` command. So:
# - CLI tools (black, isort, pylint, sqlfluff) go through pipx (from Brewfile)
# - pynvim is a library Neovim imports, so it goes into the user site of
#   Homebrew's python3.12
# - pyright already comes from the Brewfile
# =============================================================================

echo "→ Installing Python tools for Neovim..."
for tool in black isort pylint sqlfluff; do
  pipx list --short 2>/dev/null | grep -q "^$tool " || pipx install "$tool"
done
python3.12 -m pip install --user --break-system-packages pynvim
echo "✅ Python tools installed"

# =============================================================================
# SECTION 12: WORK GIT IDENTITY (MANUAL STEP)
# ~/.gitconfig-work is NEVER committed — it contains your real work email.
# The main ~/.gitconfig already has an includeIf that points to this file
# for any repo inside ~/Documents/work/.
# =============================================================================

if [ ! -f ~/.gitconfig-work ]; then
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
  read -r -p "Press ENTER when done (or skip if not needed)..."
fi

# =============================================================================
# DONE
# =============================================================================

echo "============================================="
echo " Setup complete!"
echo ""
echo " Next steps:"
echo " 1. Switch the dotfiles remote to SSH (needed to push):"
echo "      git -C ~/.local/share/chezmoi remote set-url origin git@github-personal:mikejmz24/dotfiles_config.git"
echo " 2. Log out and back in (or open a new terminal)"
echo " 3. Open Ghostty — it should load with Hack Nerd Font + Challenger Deep"
echo " 4. Open nvim — lazy.nvim will auto-install all plugins on first launch"
echo " 5. Inside nvim run: :checkhealth"
echo " 6. Open Docker Desktop once to complete Docker setup"
echo " 7. Verify git identity: git config user.email"
echo "============================================="
