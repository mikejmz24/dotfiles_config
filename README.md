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
├── install-linux.sh                        # Linux full setup script (run once on fresh install)
├── linux-gnome-settings.sh                 # Linux-only: GNOME customizations
├── dot_gitconfig                           # → ~/.gitconfig (both platforms)
├── dot_zshrc                               # → ~/.zshrc (both platforms)
└── dot_config/
    ├── ghostty/
    │   └── config                          # → ~/.config/ghostty/config (both platforms)
    └── nvim/                               # → ~/.config/nvim/ (both platforms)
        ├── init.lua
        ├── lazy-lock.json                  # IMPORTANT: never run :Lazy update blindly
        ├── dot_sqlfluff                    # sqlfluff formatter config
        ├── dot_sqls/
        │   └── config.yml                  # sqls database connection config
        └── lua/
            └── mikejmnz/
                ├── core/
                │   ├── autocmds.lua        # Auto commands (format on save, etc.)
                │   ├── init.lua            # Core module entry point
                │   ├── keymaps.lua         # Custom keybindings
                │   └── options.lua         # Neovim options (clipboard, tabs, etc.)
                ├── lazy.lua                # lazy.nvim bootstrap and plugin loader
                └── plugins/
                    ├── colorscheme.lua     # tokyonight theme
                    ├── comment.lua         # gcc/gbc to comment lines/blocks
                    ├── cucumber.lua        # Cucumber/Gherkin syntax support
                    ├── formatting.lua      # conform.nvim — format on save
                    ├── init.lua            # Plugin module entry point
                    ├── lazydev.lua         # Lua LSP improvements for nvim config editing
                    ├── linting.lua         # nvim-lint — async linting
                    ├── lsp/
                    │   ├── lspconfig.lua   # LSP server configurations
                    │   └── mason.lua       # Mason + mason-tool-installer setup
                    ├── lualine.lua         # Status line
                    ├── mini-icons.lua      # File type icons
                    ├── nvim-autopairs.lua  # Auto-close brackets, quotes, etc.
                    ├── nvim-cmp.lua        # Autocompletion engine
                    ├── nvim-treesitter-text-objects.lua
                    ├── nvim-treesitter.lua # Syntax highlighting (pinned to master)
                    ├── oil.lua             # File explorer as a buffer
                    ├── surround.lua        # Add/change/delete surrounding pairs
                    ├── telescope.lua       # Fuzzy finder
                    ├── todo-comments.lua   # Highlight TODO/FIXME/NOTE comments
                    ├── trouble.lua         # Diagnostics panel
                    └── which-key.lua       # Keybinding hints popup
```

---

## What Is NOT In This Repo

| Item          | Reason                                             |
| ------------- | -------------------------------------------------- |
| `Brewfile`    | Mac-only, managed separately via Homebrew          |
| SSH keys      | Never commit keys — generate fresh on each machine |
| Credentials   | Never store credentials in dotfiles                |
| `.oh-my-zsh/` | Installed separately by its own installer          |
| Nerd Fonts    | Installed via Homebrew (Mac) or curl (Linux)       |

---

## Tools Reference

Every tool in this setup — what it does, why it's here, and important notes.

### Shell & Terminal

| Tool          | What It Does                      | Why We Use It                                                                                                   |
| ------------- | --------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **zsh**       | Shell that replaces bash          | More features, better completion, required by Oh My Zsh                                                         |
| **Oh My Zsh** | Zsh configuration framework       | Manages zsh config, provides robbyrussell theme and git plugin                                                  |
| **Ghostty**   | GPU-accelerated terminal emulator | Fast, cross-platform (Mac+Linux), excellent font rendering, built-in shell integration, verified Snap publisher |

### File & Search Utilities

| Tool         | Command | What It Does                                     | Why We Use It                                                                                                                                    |
| ------------ | ------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **ripgrep**  | `rg`    | Searches file contents extremely fast            | Required by Telescope (nvim) for live grep. Much faster than grep.                                                                               |
| **fd**       | `fd`    | Finds files by name extremely fast               | Required by Telescope for extended file finding. Much faster than `find`. On Ubuntu installed as `fdfind` — symlinked to `fd` in `~/.local/bin`. |
| **tree**     | `tree`  | Shows directory structure as a visual tree       | Useful for understanding project layouts at a glance.                                                                                            |
| **jq**       | `jq`    | Processes and queries JSON from the command line | Required by jq-lsp in Neovim. Also useful for inspecting API responses.                                                                          |
| **xz-utils** | `xz`    | Compresses/decompresses .xz and .tar.xz files    | Needed when extracting downloaded software. Pre-installed on Ubuntu but set to manual.                                                           |

### Development Runtimes

| Tool             | What It Does                       | Why We Use It                                                                 |
| ---------------- | ---------------------------------- | ----------------------------------------------------------------------------- |
| **Go**           | Go programming language runtime    | Required by Mason LSPs: gopls, gofumpt, goimports, gomodifytags, sqls, jq-lsp |
| **Node.js**      | JavaScript runtime                 | Required by Mason LSPs: html-lsp, css-lsp, htmx-lsp, prettier, pyright        |
| **npm**          | Node package manager               | Installed alongside Node.js. Used by Mason internally for JS-based tools.     |
| **Python 3**     | Python interpreter                 | Required by Mason tools: pyright, black, isort, pylint, sqlfluff              |
| **pip**          | Python package installer           | Used to install Python-based Neovim tools                                     |
| **python3-venv** | Python virtual environment support | Required by Mason's Python tooling                                            |

### Clipboard & System

| Tool             | What It Does                                  | Why We Use It                                                                                                                                     |
| ---------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **wl-clipboard** | Wayland clipboard provider (wl-copy/wl-paste) | Required for Neovim clipboard on Wayland. Without this, yanking in nvim doesn't reach the system clipboard. Verified via `:checkhealth provider`. |

### Dotfile Management

| Tool        | What It Does                              | Why We Use It                                                                                                                                                                   |
| ----------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **chezmoi** | Manages dotfiles across multiple machines | Single command to deploy all configs on a new machine. Handles cross-platform differences. Tracks everything in git. On Linux installs to `~/bin/` — must add to PATH manually. |

### Neovim LSPs (via Mason)

| LSP                   | Language | Runtime | What It Does                                                                  |
| --------------------- | -------- | ------- | ----------------------------------------------------------------------------- |
| `lua-language-server` | Lua      | bundled | Autocomplete, diagnostics, hover docs for Lua (used when editing nvim config) |
| `pyright`             | Python   | Node.js | Type checking, autocomplete, go-to-definition for Python                      |
| `gopls`               | Go       | Go      | Full Go language support                                                      |
| `html-lsp`            | HTML     | Node.js | HTML completion and validation                                                |
| `css-lsp`             | CSS      | Node.js | CSS completion and validation                                                 |
| `htmx-lsp`            | HTMX     | Go      | HTMX attribute completion                                                     |
| `jq-lsp`              | jq       | Go      | jq query completion                                                           |
| `sqls`                | SQL      | Go      | SQL completion with database connection support                               |

### Neovim Formatters (conform.nvim)

| Formatter   | Language    | What It Does                             |
| ----------- | ----------- | ---------------------------------------- |
| `stylua`    | Lua         | Opinionated Lua code formatter           |
| `black`     | Python      | Opinionated Python formatter (PEP 8)     |
| `isort`     | Python      | Sorts Python import statements           |
| `prettier`  | HTML/CSS/MD | Multi-language formatter                 |
| `gofumpt`   | Go          | Stricter Go formatter                    |
| `goimports` | Go          | Formats Go and manages import statements |
| `sqlfluff`  | SQL         | SQL linter and formatter                 |

### Neovim Linters (nvim-lint)

| Linter     | Language | What It Does                               |
| ---------- | -------- | ------------------------------------------ |
| `pylint`   | Python   | Comprehensive Python static analysis       |
| `sqlfluff` | SQL      | SQL linting (also used as formatter above) |

---

## Quick Start — New Machine

### Mac

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install chezmoi
brew install chezmoi

# 3. Install core tools
brew install git neovim ripgrep tree xz fd jq go node python@3.12
brew install --cask ghostty

# 4. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 5. Install Hack Nerd Font
brew install --cask font-hack-nerd-font

# 6. Apply dotfiles
chezmoi init git@github.com:mikejmz24/dotfiles_config.git
chezmoi apply

# 7. Install Python tools for Neovim
pip install pynvim pyright black isort pylint sqlfluff

# 8. Set up SSH key for GitHub (see SSH Setup section below)
```

### Linux (Ubuntu 24.04 / System76 Darter Pro)

Run the included install script — it handles everything in the correct order:

```bash
# Clone repo first (before chezmoi is installed)
git clone https://github.com/mikejmz24/dotfiles_config.git ~/dotfiles_config

# Run the full setup script
bash ~/dotfiles_config/install-linux.sh
```

See `install-linux.sh` for full details with explanations of every step and
the reasoning behind the install order.

---

## SSH Setup (Both Platforms)

Run on every new machine. Never copy SSH keys between machines.

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
public key, and name it something descriptive (e.g. `Darter Pro Ubuntu`).

Test the connection:

```bash
ssh -T git@github.com
# Expected: Hi mikejmz24! You've successfully authenticated.
```

> **First connection:** Type `yes` when asked to verify GitHub's fingerprint.
> This is expected and only happens once per machine.
> GitHub's fingerprint: `SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`

---

## Updating Dotfiles

### After making changes on any machine

```bash
# Stage changes
chezmoi add ~/.config/ghostty/config  # or whichever file changed

# Commit and push
cd ~/.local/share/chezmoi
git add -A
git commit -m "describe your change"
git push
```

### Pulling changes on another machine

```bash
chezmoi update
```

---

## Ghostty Configuration

- **Config:** `~/.config/ghostty/config`
- **Font:** Hack Nerd Font, size 18, with ligatures (calt, liga, ss13)
- **Theme:** Challenger Deep (built-in, no download needed)
- **Cursor:** Bar style, blinking, opacity 0.8, thickness 3
- **Background:** opacity 0.92
- **Shell integration:** enabled via `$GHOSTTY_RESOURCES_DIR`

**Copy/Paste keybindings:**

| Platform | Copy         | Paste        | Select All   |
| -------- | ------------ | ------------ | ------------ |
| Mac      | ⌘+C          | ⌘+V          | ⌘+A          |
| Linux    | Ctrl+Shift+C | Ctrl+Shift+V | Ctrl+Shift+A |

> **Why different on Linux?** The Super key is intercepted by the Wayland
> compositor (GNOME) before any app sees it. This is a fundamental GNOME/Wayland
> design decision — not a config problem. `Ctrl+Shift+C/V` is the Linux
> terminal standard and works across all terminals without configuration.

> **Config file name:** Must be `config`, NOT `config.ghostty`.

---

## Neovim Configuration

- **Config:** `~/.config/nvim/`
- **Plugin manager:** lazy.nvim (auto-bootstraps on first launch)
- **LSP manager:** Mason
- **Version:** 0.12.2 on both platforms

**Critical: nvim-treesitter branch pinning**

`nvim-treesitter` had a full breaking rewrite in March 2026 (master → main
branch, incompatible API) and was archived April 3, 2026. Our config pins
both treesitter plugins to `branch = "master"` in the plugin specs.

**Never run `:Lazy update` without checking the treesitter changelog first.**

If treesitter breaks after an update:

```bash
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter-textobjects
# Inside nvim: :Lazy install
```

---

## Zsh Configuration

- **Framework:** Oh My Zsh
- **Theme:** robbyrussell (identical on Mac and Linux)
- **Plugins:** git
- **Prompt:** `→ %F{cyan}%~%f ` (two-line, cyan path)
- **PATH:** `$HOME/bin` (chezmoi), `$HOME/.local/bin` (fd symlink on Linux)

---

## Linux-Specific: GNOME Settings

`linux-gnome-settings.sh` documents and applies all GNOME customizations.

**Current settings:**

- Frees `Super+A` from GNOME app drawer
- Frees `Super+V` from GNOME message tray
- Sets GNOME Terminal copy/paste keybindings

**Pending — App Launcher (System76 PPA outage):**
`pop-launcher` is the correct Spotlight-like launcher for GNOME Wayland.
Rofi, Fuzzel, and Ulauncher all fail with `no layer shell interface` on GNOME.

When PPA is back:

```bash
sudo apt update && sudo apt install pop-launcher
```

---

## Known Mac vs Linux Differences

| Feature            | Mac                           | Linux                                  |
| ------------------ | ----------------------------- | -------------------------------------- |
| Copy in terminal   | ⌘+C                           | Ctrl+Shift+C                           |
| Paste in terminal  | ⌘+V                           | Ctrl+Shift+V                           |
| Select all         | ⌘+A                           | Ctrl+Shift+A                           |
| App launcher       | Spotlight (⌘+Space)           | Super key (pop-launcher pending)       |
| Clipboard provider | Native                        | wl-clipboard                           |
| Font install       | `brew install --cask`         | curl to `~/.local/share/fonts`         |
| Neovim install     | `brew install neovim`         | `snap install nvim --classic`          |
| Ghostty install    | `brew install --cask ghostty` | `snap install ghostty --classic`       |
| chezmoi install    | `brew install chezmoi`        | `sh -c "$(curl -fsLS get.chezmoi.io)"` |
| chezmoi PATH       | Automatic                     | Add `$HOME/bin` manually               |
| fd binary name     | `fd`                          | `fdfind` → symlinked to `fd`           |

---

## Troubleshooting

### chezmoi not found after install on Linux

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

### Neovim Treesitter errors (`no file 'nvim-treesitter/configs.lua'`)

```bash
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter-textobjects
# Inside nvim: :Lazy install
```

### Mason LSPs failing to install

Run `:checkhealth` — each LSP needs its runtime (Node/Go/Python).

### Ghostty wrong config file name

```bash
mv ~/.config/ghostty/config.ghostty ~/.config/ghostty/config
```

### Zsh shows `/bin/bash` for `$SHELL`

Expected until logout/login. Run `echo $0` to confirm Zsh is active.

### Clipboard not working in Neovim

```bash
sudo apt install wl-clipboard
# Inside nvim: :checkhealth provider
```

### fd not found by Telescope

```bash
mkdir -p ~/.local/bin && ln -s $(which fdfind) ~/.local/bin/fd
```

### System76 PPA unavailable

```bash
sudo apt update 2>&1 | grep system76  # check if back online
```

---

## Hardware

- **Mac:** MacBook (ARM, Apple Silicon)
- **Linux:** System76 Darter Pro, Ubuntu 24.04 LTS, GNOME/Wayland

---

## References

- [chezmoi docs](https://www.chezmoi.io/user-guide/setup/)
- [Ghostty docs](https://ghostty.org/docs)
- [lazy.nvim docs](https://lazy.folke.io/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [System76 Darter Pro](https://system76.com/laptops/darter)
- [nvim-treesitter archived (April 2026)](https://byteiota.com/nvim-treesitter-archived-13k-star-plugin-shut-down-2026/)
- [Neovim 0.12 treesitter migration](https://www.qu8n.com/posts/treesitter-migration-guide-for-nvim-0-12)
- [dotfiles.github.io](https://dotfiles.github.io/)
