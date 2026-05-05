# mikejmz24/dotfiles_config

Cross-platform dotfiles for macOS and Linux (Ubuntu 24.04 / System76 Darter Pro),
managed with [chezmoi](https://www.chezmoi.io/).

---

## Who This Is For

This README is written for two audiences:

1. **The human owner (mikejmz24)** — step-by-step instructions to set up a new
   Mac or Linux machine from scratch
2. **An AI assistant (e.g. Claude)** — full context about every decision made,
   every gotcha encountered, and the reasoning behind the current setup, so
   future sessions can pick up without losing context

---

## Philosophy

- **One repo, two platforms** — Mac and Linux share the same configs wherever possible
- **No clever hacks** — if it needs a custom README to understand, it's too complex
- **Keyboard first** — every tool is configured for keyboard-driven workflows
- **Documented** — every decision is explained so future-you (and future AI) knows why
- **chezmoi manages everything** — no manual symlinks, no custom install scripts,
  no fragile one-liners. One command to deploy on any machine.

---

## Repo Structure

```
dotfiles_config/
├── README.md                               # This file — read before anything else
├── linux-gnome-settings.sh                 # Linux-only: run after fresh Ubuntu install
├── dot_gitconfig                           # → ~/.gitconfig (both platforms)
├── dot_zshrc                               # → ~/.zshrc (both platforms)
└── dot_config/
    ├── ghostty/
    │   └── config                          # → ~/.config/ghostty/config (both platforms)
    └── nvim/                               # → ~/.config/nvim/ (both platforms)
        ├── init.lua
        ├── lazy-lock.json                  # IMPORTANT: never run :Lazy update blindly
        ├── dot_sqlfluff                    # sqlfluff config
        ├── dot_sqls/
        │   └── config.yml                  # sqls database config
        └── lua/
            └── mikejmnz/
                ├── core/
                │   ├── autocmds.lua
                │   ├── init.lua
                │   ├── keymaps.lua
                │   └── options.lua
                ├── lazy.lua                # lazy.nvim bootstrap
                └── plugins/
                    ├── colorscheme.lua     # tokyonight
                    ├── comment.lua
                    ├── cucumber.lua
                    ├── formatting.lua      # conform.nvim
                    ├── init.lua
                    ├── lazydev.lua
                    ├── linting.lua         # nvim-lint
                    ├── lsp/
                    │   ├── lspconfig.lua
                    │   └── mason.lua
                    ├── lualine.lua
                    ├── mini-icons.lua
                    ├── nvim-autopairs.lua
                    ├── nvim-cmp.lua
                    ├── nvim-treesitter-text-objects.lua
                    ├── nvim-treesitter.lua
                    ├── oil.lua
                    ├── surround.lua
                    ├── telescope.lua
                    ├── todo-comments.lua
                    ├── trouble.lua
                    └── which-key.lua
```

---

## What Is NOT In This Repo

| Item          | Reason                                             |
| ------------- | -------------------------------------------------- |
| `Brewfile`    | Mac-only, managed separately via Homebrew          |
| SSH keys      | Never commit keys — generate fresh on each machine |
| Credentials   | Never store credentials in dotfiles                |
| `.oh-my-zsh/` | Installed separately, not a dotfile                |
| Nerd Fonts    | Installed via Homebrew (Mac) or curl (Linux)       |

---

## Quick Start — New Machine

### Mac

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install chezmoi
brew install chezmoi

# 3. Install core tools
brew install git neovim ripgrep tree xz pyright
brew install --cask ghostty

# 4. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 5. Install Hack Nerd Font
brew install --cask font-hack-nerd-font

# 6. Apply dotfiles
chezmoi init git@github.com:mikejmz24/dotfiles_config.git
chezmoi apply

# 7. Set up SSH key for GitHub (see SSH Setup section below)
```

### Linux (Ubuntu 24.04 / System76 Darter Pro)

```bash
# 1. Install core tools
sudo apt install -y git curl zsh xz-utils ripgrep tree jq golang \
  nodejs npm python3 python3-pip python3-venv wl-clipboard fd-find

# 2. Make fd available system-wide (Ubuntu names it fdfind)
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd

# 3. Install Ghostty via Snap
sudo snap install ghostty --classic

# 4. Install Neovim via Snap
sudo snap install nvim --classic

# 5. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 6. Set Zsh as default shell (requires logout/login to take effect)
chsh -s $(which zsh)

# 7. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 8. Install Hack Nerd Font manually
mkdir -p ~/.local/share/fonts
curl -fLo ~/.local/share/fonts/HackNerdFont-Regular.ttf \
  https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf
curl -fLo ~/.local/share/fonts/HackNerdFont-Bold.ttf \
  https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Bold/HackNerdFont-Bold.ttf
curl -fLo ~/.local/share/fonts/HackNerdFont-Italic.ttf \
  https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Italic/HackNerdFont-Italic.ttf
curl -fLo ~/.local/share/fonts/HackNerdFont-BoldItalic.ttf \
  https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/BoldItalic/HackNerdFont-BoldItalic.ttf
fc-cache -fv

# 9. Apply dotfiles
chezmoi init git@github.com:mikejmz24/dotfiles_config.git
chezmoi apply

# 10. Apply GNOME settings
bash ~/dotfiles_config/linux-gnome-settings.sh

# 11. Set Ghostty as default terminal
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'
sudo update-alternatives --install /usr/bin/x-terminal-emulator \
  x-terminal-emulator $(which ghostty) 50

# 12. Install Python tools for Neovim
pip install pyright black isort pylint sqlfluff pynvim --break-system-packages

# 13. Set up SSH key for GitHub (see SSH Setup section below)
```

---

## SSH Setup (Both Platforms)

Run this on every new machine. Never copy SSH keys between machines.

```bash
# Generate key using GitHub no-reply email
ssh-keygen -t ed25519 -C "YOUR_ID+mikejmz24@users.noreply.github.com"

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Print public key — copy this to GitHub
cat ~/.ssh/id_ed25519.pub
```

Go to **GitHub → Settings → SSH and GPG keys → New SSH key**, paste the
public key, and name it something descriptive (e.g. `Darter Pro Ubuntu` or `MacBook Pro`).

Test the connection:

```bash
ssh -T git@github.com
# Expected: Hi mikejmz24! You've successfully authenticated.
```

> **First connection:** SSH will ask you to verify GitHub's fingerprint.
> Type `yes` — this is expected and only happens once per machine.

---

## Updating Dotfiles

### After making changes on any machine

```bash
# Add new or changed files to chezmoi
chezmoi add ~/.config/ghostty/config
chezmoi add ~/.zshrc
# etc.

# Review what changed
chezmoi diff

# Commit and push via chezmoi's git wrapper
chezmoi cd
git add -A
git commit -m "describe your change"
git push
```

### Pulling changes on another machine

```bash
chezmoi update
```

This pulls from GitHub and applies changes in one command.

---

## Tool Details

### Ghostty Terminal

- **Config location:** `~/.config/ghostty/config`
- **Font:** Hack Nerd Font, size 18
- **Theme:** Challenger Deep (built into Ghostty, no download needed)
- **Cursor:** Bar style, blinking, opacity 0.8
- **Background opacity:** 0.92
- **Shell integration:** Enabled via `$GHOSTTY_RESOURCES_DIR`

**Copy/Paste keybindings:**

| Platform | Copy         | Paste        | Select All   |
| -------- | ------------ | ------------ | ------------ |
| Mac      | ⌘+C          | ⌘+V          | ⌘+A          |
| Linux    | Ctrl+Shift+C | Ctrl+Shift+V | Ctrl+Shift+A |

> **Why different on Linux?** The Super key (equivalent to ⌘ on Mac) is
> intercepted by the Wayland compositor (GNOME) before any terminal app can
> see it. This is a fundamental Wayland/GNOME design decision, not a
> configuration problem. `Ctrl+Shift+C/V` is the Linux terminal standard
> and works across all terminals without any configuration.

> **Config file name:** Must be named `config`, NOT `config.ghostty`.
> Ghostty on Linux only reads `~/.config/ghostty/config`.

---

### Neovim

- **Config location:** `~/.config/nvim/`
- **Plugin manager:** lazy.nvim (auto-bootstraps on first launch)
- **LSP manager:** Mason
- **Colorscheme:** tokyonight (loaded at startup)
- **Version:** 0.12.2 (Snap on Linux, Homebrew on Mac)

**Mason LSPs and their runtime requirements:**

| LSP/Tool    | Language    | Runtime needed |
| ----------- | ----------- | -------------- |
| `pyright`   | Python      | Node.js        |
| `lua-ls`    | Lua         | (bundled)      |
| `gopls`     | Go          | Go             |
| `html-lsp`  | HTML        | Node.js        |
| `css-lsp`   | CSS         | Node.js        |
| `prettier`  | HTML/CSS/MD | Node.js        |
| `black`     | Python      | Python + pip   |
| `isort`     | Python      | Python + pip   |
| `pylint`    | Python      | Python + pip   |
| `sqlfluff`  | SQL         | Python + pip   |
| `stylua`    | Lua         | (binary)       |
| `gofumpt`   | Go          | Go             |
| `goimports` | Go          | Go             |
| `sqls`      | SQL         | Go             |
| `jq-lsp`    | jq          | Go             |

**Critical: nvim-treesitter branch pinning**

`nvim-treesitter` underwent a full breaking rewrite in March 2026, moving
from `master` to `main` branch with an incompatible API. The plugin was
archived on April 3, 2026.

Our config pins both treesitter plugins to `master` (the frozen, stable branch)
using the `branch = "master"` option in the plugin specs. This ensures the
old `require("nvim-treesitter.configs")` API continues to work.

**Never run `:Lazy update` without checking the treesitter changelog first.**
If treesitter breaks after an update:

```bash
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter-textobjects
# Then inside nvim: :Lazy install
```

**Neovim clipboard on Linux:**
Requires `wl-clipboard` on Wayland. Already installed in the Linux setup above.
Config uses `opt.clipboard:append("unnamedplus")` which works with `wl-copy`.

---

### Zsh

- **Framework:** Oh My Zsh
- **Theme:** robbyrussell (matches Mac exactly)
- **Plugins:** git (minimal, fast startup)
- **Custom prompt:** `→ %F{cyan}%~%f ` (two-line with cyan path)
- **ls colors:** `alias ls='ls --color=auto'`

**Ghostty shell integration** (in `.zshrc`):

```bash
if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi
```

> **Note on $SHELL:** After installing Zsh and running `chsh`, the `$SHELL`
> variable may still show `/bin/bash` until you fully log out and back in.
> This is expected. Run `echo $0` to confirm Zsh is actually active — the
> prompt will show `%` instead of `$`.

---

### Git

- **Config location:** `~/.gitconfig`
- **Email:** GitHub no-reply address (privacy best practice)
- **Credential storage:** SSH keys (no passwords needed)

---

## Linux-Specific: GNOME Settings

The `linux-gnome-settings.sh` script documents and applies all GNOME
customizations. Run it after a fresh Ubuntu install:

```bash
bash ~/dotfiles_config/linux-gnome-settings.sh
```

**What it does:**

- Frees `Super+A` from GNOME app drawer (toggle-application-view)
- Frees `Super+V` from GNOME message tray (toggle-message-tray)
- Sets GNOME Terminal keybindings for copy/paste

**App Launcher (pending):**
The System76 PPA (`ppa:system76-dev/stable`) provides `pop-launcher`,
a GNOME Wayland-native Spotlight-like launcher designed for System76 hardware.
It was unavailable during initial setup due to a PPA outage.

Once the PPA is back online:

```bash
sudo apt update && sudo apt install pop-launcher
```

Then bind it to `Super+Space` by adding to `linux-gnome-settings.sh`:

```bash
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
command 'pop-launcher'
```

> **Why not Rofi, Fuzzel, or Ulauncher?**
> All three were attempted and failed on GNOME Wayland due to the
> `no layer shell interface` error. They require XWayland or a non-GNOME
> Wayland compositor. `pop-launcher` is the only option that integrates
> natively with GNOME Shell on Wayland.

---

## Known Mac vs Linux Differences

| Feature            | Mac                           | Linux                                  |
| ------------------ | ----------------------------- | -------------------------------------- |
| Copy in terminal   | ⌘+C                           | Ctrl+Shift+C                           |
| Paste in terminal  | ⌘+V                           | Ctrl+Shift+V                           |
| Select all         | ⌘+A                           | Ctrl+Shift+A                           |
| App launcher       | Spotlight (⌘+Space)           | Super key (pending pop-launcher)       |
| Clipboard provider | Native                        | wl-clipboard (Wayland)                 |
| Font install       | `brew install --cask`         | Manual curl to `~/.local/share/fonts`  |
| Neovim install     | `brew install neovim`         | `snap install nvim --classic`          |
| Ghostty install    | `brew install --cask ghostty` | `snap install ghostty --classic`       |
| chezmoi install    | `brew install chezmoi`        | `sh -c "$(curl -fsLS get.chezmoi.io)"` |
| chezmoi PATH       | Auto                          | Add `$HOME/bin` to `$PATH` manually    |
| iTerm2 integration | `.zshrc` line present         | Line ignored (no-op on Linux)          |

---

## Troubleshooting

### chezmoi not found after install on Linux

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Neovim Treesitter errors (`no file 'nvim-treesitter/configs.lua'`)

The plugin pulled from `main` instead of `master`. Fix:

```bash
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter-textobjects
# Inside nvim: :Lazy install
```

### Mason LSPs failing to install

Run `:checkhealth` inside Neovim. Each LSP needs its runtime:

- `html-lsp`, `css-lsp`, `prettier` → need Node.js
- `gopls`, `gofumpt`, `goimports` → need Go
- `pyright`, `black`, `isort`, `pylint` → need Python + pip

### Ghostty theme not loading

Config file must be named `config`, not `config.ghostty`:

```bash
mv ~/.config/ghostty/config.ghostty ~/.config/ghostty/config
```

### Zsh shows `/bin/bash` for `$SHELL`

Expected until full desktop logout/login. Run `echo $0` to confirm
Zsh is active. The prompt changing from `$` to `%` also confirms it.

### Clipboard not working in Neovim on Linux

```bash
sudo apt install wl-clipboard
# Inside nvim: :checkhealth provider
# Should show: Clipboard tool found: wl-copy
```

### SSH GitHub connection prompt on first use

Type `yes` when asked about GitHub's fingerprint. This is expected
and only happens once per machine.

### System76 PPA unavailable

The `ppa.launchpadcontent.net` server may be temporarily down.
This affects System76-specific packages. Use `sudo apt update` to check
if it's back online before retrying any System76 package installs.

---

## Hardware

- **Mac:** MacBook (ARM, Apple Silicon)
- **Linux:** System76 Darter Pro, Ubuntu 24.04 LTS, Wayland/GNOME

---

## References

- [chezmoi docs](https://www.chezmoi.io/user-guide/setup/)
- [Ghostty docs](https://ghostty.org/docs)
- [lazy.nvim docs](https://lazy.folke.io/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [System76 Darter Pro](https://system76.com/laptops/darter)
- [nvim-treesitter archived](https://byteiota.com/nvim-treesitter-archived-13k-star-plugin-shut-down-2026/)
- [Neovim 0.12 migration guide](https://www.qu8n.com/posts/treesitter-migration-guide-for-nvim-0-12)
