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

## Identity Overview

This setup handles two GitHub identities on one Mac:

| Identity | Username | Used For |
|----------|----------|----------|
| Personal | `mikejmz24` | Default — all personal repos, Ubuntu machine |
| Work | `work-username` | Work repos only, inside `~/Documents/work/` |

Git automatically switches identities based on directory using `includeIf`.
See **Git Identity Setup** below.

---

## Repo Structure

```
dotfiles_config/
├── README.md                               # This file — read before anything else
├── Brewfile                                # Mac packages (managed by chezmoi → ~/Brewfile)
├── install-mac.sh                          # Mac full setup script (run once on fresh install)
├── install-linux.sh                        # Linux full setup script (run once on fresh install)
├── linux-gnome-settings.sh                 # Linux-only: GNOME customizations
├── dot_gitconfig.tmpl                      # → ~/.gitconfig (template — switches identity by OS)
├── dot_gitignore_global                    # → ~/.gitignore_global (both platforms)
├── dot_zshrc                               # → ~/.zshrc (both platforms)
└── dot_config/
    ├── ghostty/
    │   └── config.tmpl                     # → ~/.config/ghostty/config (template — font/keys by OS)
    └── nvim/                               # → ~/.config/nvim/ (both platforms)
        ├── init.lua
        ├── lazy-lock.json                  # IMPORTANT: never run :Lazy update blindly
        ├── dot_sqlfluff                    # sqlfluff formatter config
        ├── dot_sqls/
        │   └── config.yml                  # sqls database connection config
        └── lua/
            └── mikejmnz/
                ├── core/
                │   ├── autocmds.lua
                │   ├── init.lua
                │   ├── keymaps.lua
                │   └── options.lua
                ├── lazy.lua
                └── plugins/
                    ├── colorscheme.lua
                    ├── comment.lua
                    ├── cucumber.lua
                    ├── formatting.lua
                    ├── init.lua
                    ├── lazydev.lua
                    ├── linting.lua
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

| Item | Reason |
|------|--------|
| `~/.gitconfig-work` | Contains work email — never commit. Create manually on Mac. |
| `~/.config/gh/hosts.yml` | Contains GitHub auth tokens — never commit. |
| SSH keys | Never commit — generate fresh on each machine. |
| `.oh-my-zsh/` | Installed separately by its own installer. |
| Nerd Fonts | Installed via Brewfile (Mac) or curl (Linux). |
| `~/.config/chezmoi/chezmoi.toml` | Machine-specific identity — never commit. |
| `~/.config/fish/` | Not actively used. |
| `~/.config/zed/` | Not actively used. |
| `~/.config/iterm2/` | Replaced by Ghostty. |
| Python virtualenvs | Local to each project. |
| `node_modules/` | Never committed. |

---

## chezmoi Template System

Two files use chezmoi templates (`.tmpl` extension) to handle Mac vs Linux differences.

### `dot_config/ghostty/config.tmpl`
```
font-size = {{ if eq .os "mac" }}18{{ else }}16{{ end }}

{{ if eq .os "mac" -}}
keybind = super+c=copy_to_clipboard
keybind = super+v=paste_from_clipboard
keybind = super+a=select_all
{{- else -}}
keybind = ctrl+shift+c=copy_to_clipboard
keybind = ctrl+shift+v=paste_from_clipboard
keybind = ctrl+shift+a=select_all
{{- end }}
```

### `dot_gitconfig.tmpl`
```
[user]
    name = {{ .github_user }}
    email = {{ .email }}

{{ if eq .os "mac" -}}
[includeIf "gitdir:~/Documents/work/"]
    path = ~/.gitconfig-work
{{- end }}
```

### Machine config (`~/.config/chezmoi/chezmoi.toml`)
Created **manually on each machine** — **never committed**.

**Mac:**
```toml
[data]
    name = "Your Name"
    email = "YOUR_ID+mikejmz24@users.noreply.github.com"
    github_user = "mikejmz24"
    work_name = "your-work-username"
    os = "mac"
```

**Linux:**
```toml
[data]
    name = "Your Name"
    email = "YOUR_ID+mikejmz24@users.noreply.github.com"
    github_user = "mikejmz24"
    os = "linux"
```

Verify a template before applying:
```bash
chezmoi execute-template < ~/.local/share/chezmoi/dot_config/ghostty/config.tmpl
chezmoi execute-template < ~/.local/share/chezmoi/dot_gitconfig.tmpl
```

---

## Git Identity Setup

### Default identity (personal — works everywhere)
Managed automatically by chezmoi via `dot_gitconfig.tmpl`.

### Work identity (Mac only — `~/Documents/work/` only)

**Create this file manually. Never commit it.**

```bash
nvim ~/.gitconfig-work
```

Add:
```gitconfig
[user]
    name = your-work-username
    email = your-work@company.com
```

Git uses this identity automatically for any repo inside `~/Documents/work/`.

**Verify:**
```bash
# From a personal repo
git config user.email  # → YOUR_ID+mikejmz24@users.noreply.github.com

# From inside ~/Documents/work/
git config user.email  # → your-work@company.com
```

---

## Global Gitignore

**Location:** `~/.gitignore_global` (managed by chezmoi, both platforms)
**Activated by:** `core.excludesfile` in `~/.gitconfig`

Applies to every git repo on your machine automatically.

### macOS system files
| Pattern | Why ignored |
|---------|-------------|
| `.DS_Store` | Folder metadata created automatically by Finder |
| `._*` | macOS resource fork files |
| `.Spotlight-V100` | Spotlight search index |
| `.Trashes` | macOS trash folder |
| `.AppleDouble` | macOS double-encoding files |
| `.LSOverride` | macOS launch services override |

### Credentials & secrets (CRITICAL — never commit)
| Pattern | Why ignored |
|---------|-------------|
| `.gitconfig-work` | Work git identity with real work email |
| `*.pem` | SSL/TLS certificates |
| `*.key` | Private keys of any kind |
| `*.env` | Environment files with secrets |
| `.env*` | Any .env variant (.env.local, .env.production, etc.) |
| `secrets/` | Any directory named secrets |
| `credentials/` | Any directory named credentials |

### Editor files
| Pattern | Why ignored |
|---------|-------------|
| `.vscode/extensions/` | VSCode extensions — installed per machine not per project |
| `*.swp`, `*.swo` | Vim/Neovim swap files created during editing |
| `.idea/` | JetBrains IDE project files |

### Python
| Pattern | Why ignored |
|---------|-------------|
| `__pycache__/` | Python bytecode cache — auto-generated |
| `*.py[cod]` | Compiled Python files |
| `.venv/`, `venv/` | Virtual environments — always recreate locally |
| `*.egg-info/` | Python package metadata |

### Node.js
| Pattern | Why ignored |
|---------|-------------|
| `node_modules/` | Dependencies — always install fresh via npm |
| `npm-debug.log` | npm error log |

### Logs
| Pattern | Why ignored |
|---------|-------------|
| `*.log` | Any log file |

---

## chezmoi Ignore File

**Location:** `~/.local/share/chezmoi/.chezmoiignore`

```
# Work credentials — never commit
.gitconfig-work

# Mac-only apps we don't manage
.config/fish/**
.config/zed/**
.config/iterm2/**
.config/uv/**
.config/gh/hosts.yml

# VSCode — managed separately
Library/Application Support/Code/User/globalStorage/**
Library/Application Support/Code/User/workspaceStorage/**
Library/Application Support/Code/User/History/**

# chezmoi config — machine specific, never committed
.config/chezmoi/**
```

---

## Quick Start — Fresh Mac Install

Run the included script which handles everything in the correct order:

```bash
# Clone repo to get the install script
git clone https://github.com/mikejmz24/dotfiles_config.git ~/dotfiles_config
bash ~/dotfiles_config/install-mac.sh
```

See `install-mac.sh` for full details with explanations of every step.

**Install order summary:**
1. Xcode Command Line Tools
2. Homebrew
3. chezmoi
4. chezmoi.toml (manual — machine identity)
5. SSH key setup (manual)
6. chezmoi apply (deploys all dotfiles)
7. Oh My Zsh
8. `brew bundle install` (all packages from Brewfile)
9. `rustup-init` (Rust toolchain)
10. Go tools
11. Python tools for Neovim (`pynvim`)
12. Work git identity (manual — `~/.gitconfig-work`)

---

## Quick Start — Restoring an Existing Mac

If your dotfiles are already set up and you just need to pull latest changes:

```bash
# Pull and apply latest dotfiles
chezmoi update

# If Brewfile changed, update packages
brew bundle install --file=~/Brewfile

# Remove packages no longer in Brewfile
brew bundle cleanup --file=~/Brewfile

# Update Brewfile to reflect current installs
brew bundle dump --force --file=~/Brewfile
chezmoi add ~/Brewfile
cd ~/.local/share/chezmoi
git add -A && git commit -m "Update Brewfile" && git push
```

---

## Quick Start — New Linux (Ubuntu 24.04 / System76 Darter Pro)

```bash
# Create machine config first (never committed)
mkdir -p ~/.config/chezmoi
nvim ~/.config/chezmoi/chezmoi.toml  # paste Linux toml from above

# Clone and run install script
git clone https://github.com/mikejmz24/dotfiles_config.git ~/dotfiles_config
bash ~/dotfiles_config/install-linux.sh
```

---

## SSH Setup (Both Platforms)

```bash
ssh-keygen -t ed25519 -C "YOUR_ID+mikejmz24@users.noreply.github.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

Go to **GitHub → Settings → SSH and GPG keys → New SSH key**.
Name it descriptively (e.g. `MacBook Pro M4` or `Darter Pro Ubuntu`).

```bash
ssh -T git@github.com
# Expected: Hi mikejmz24! You've successfully authenticated.
```

> First connection: type `yes` for GitHub's fingerprint prompt.
> Fingerprint: `SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`

---

## Updating Dotfiles

### After making changes

```bash
chezmoi add ~/.config/ghostty/config   # stage a changed file
chezmoi add ~/Brewfile                  # or the Brewfile
cd ~/.local/share/chezmoi
git add -A
git commit -m "describe your change"
git push
```

### On another machine

```bash
chezmoi update
```

---

## Tools Reference

### Shell & Terminal

| Tool | What It Does | Why We Use It |
|------|-------------|---------------|
| **zsh** | Shell that replaces bash | Better completion, required by Oh My Zsh |
| **Oh My Zsh** | Zsh framework | robbyrussell theme, git plugin |
| **Ghostty** | GPU-accelerated terminal | Fast, cross-platform, built-in shell integration |

### File & Search Utilities

| Tool | Command | What It Does | Notes |
|------|---------|-------------|-------|
| **ripgrep** | `rg` | Searches file contents fast | Required by Telescope in Neovim |
| **fd** | `fd` | Finds files by name fast | Required by Telescope. Ubuntu: installed as `fdfind`, symlinked to `fd` |
| **tree** | `tree` | Shows directory structure as tree | Project navigation |
| **jq** | `jq` | Processes JSON from command line | Required by jq-lsp in Neovim |
| **bat** | `bat` | Better `cat` with syntax highlighting | Drop-in replacement for cat |
| **xz** | `xz` | Decompresses .xz files | Needed when extracting software |
| **wget** | `wget` | Downloads files from URLs | Alternative to curl |

### Development Runtimes

| Tool | What It Does | Required By |
|------|-------------|-------------|
| **Go** | Go runtime | gopls, gofumpt, goimports, sqls, jq-lsp, air, templ |
| **Node.js** | JavaScript runtime | html-lsp, css-lsp, prettier, pyright |
| **Python 3.12** | Python interpreter | pyright, black, isort, pylint, sqlfluff |
| **Rust (rustup)** | Rust toolchain manager | cargo, cargo-c — run `rustup-init` after install |

### Python Tools

| Tool | What It Does | Notes |
|------|-------------|-------|
| **pyright** | Python type checker | Used by Mason LSP in Neovim |
| **virtualenv** | Virtual environment manager | Project isolation |
| **pipx** | Installs Python CLIs in isolation | Better than pip for CLI tools |
| **poetry** | Dependency management + packaging | Modern alternative to pip+venv |
| **jupyterlab** | Web-based Python notebooks | Data analysis and exploration |
| **pynvim** | Python provider for Neovim | Required for `:checkhealth provider` to pass |

### Go Tools

| Tool | What It Does |
|------|-------------|
| **air** | Live reload for Go apps during development |
| **go-blueprint** | Go project scaffolding with best practices |
| **godog** | BDD testing framework (Cucumber for Go) |
| **gopls** | Official Go language server (also in Mason) |
| **sqls** | SQL language server (also in Mason) |
| **templ** | Compile-time safe HTML templating for Go |

### Docker

| Tool | What It Does |
|------|-------------|
| **docker** | Docker CLI (link:false to avoid conflicts with Desktop) |
| **docker-compose** | Multi-container orchestration |
| **docker-desktop** | Docker GUI + daemon for Mac — must be opened manually once |

### Tree-sitter & Lua

| Tool | What It Does |
|------|-------------|
| **tree-sitter** | Parsing library used by Neovim internally |
| **tree-sitter-cli** | CLI for developing tree-sitter grammars |
| **luarocks** | Lua package manager used by some Neovim plugins |

### Linting

| Tool | What It Does |
|------|-------------|
| **golangci-lint** | Fast Go linter aggregator — used by nvim-lint in Neovim |

### Dotfile Management

| Tool | What It Does | Notes |
|------|-------------|-------|
| **chezmoi** | Manages dotfiles across machines | On Linux installs to `~/bin/` — must add to PATH manually |

### Work Tools (Mac only)

| Tool | What It Does | Notes |
|------|-------------|-------|
| **gh** | GitHub CLI | Team onboarding. `config.yml` committed, `hosts.yml` never committed. |
| **VSCode** | Code editor | Team onboarding docs. Settings: Dark Modern theme only. |
| **nerdfix** | Fixes broken Nerd Font icon references | Useful when Nerd Font updates change icon codepoints |

### GUI Apps (Mac only)

| App | What It Does |
|-----|-------------|
| **Ghostty** | Primary terminal |
| **Google Chrome** | Web browser |
| **Slack** | Team messaging |
| **WhatsApp** | Messaging |
| **Postman** | API development and testing |
| **MacTeX** | LaTeX distribution for document typesetting |

### Neovim LSPs (via Mason)

| LSP | Language | Runtime |
|-----|----------|---------|
| `lua-language-server` | Lua | bundled |
| `pyright` | Python | Node.js |
| `gopls` | Go | Go |
| `html-lsp` | HTML | Node.js |
| `css-lsp` | CSS | Node.js |
| `htmx-lsp` | HTMX | Go |
| `jq-lsp` | jq | Go |
| `sqls` | SQL | Go |

### Neovim Formatters & Linters

| Tool | Type | Language |
|------|------|----------|
| `stylua` | Formatter | Lua |
| `black` | Formatter | Python |
| `isort` | Formatter | Python imports |
| `prettier` | Formatter | HTML/CSS/Markdown |
| `gofumpt` | Formatter | Go |
| `goimports` | Formatter | Go imports |
| `sqlfluff` | Formatter + Linter | SQL |
| `pylint` | Linter | Python |
| `golangci-lint` | Linter | Go |

---

## Ghostty Configuration

- **Config:** `~/.config/ghostty/config` (generated from `config.tmpl`)
- **Font:** Hack Nerd Font, with ligatures (calt, liga, ss13)
- **Theme:** Challenger Deep (built-in — no download needed)
- **Cursor:** Bar style, blinking, opacity 0.8, thickness 3
- **Background:** opacity 0.92

| Feature | Mac | Linux |
|---------|-----|-------|
| Font size | 18 (Retina) | 16 (standard display) |
| Copy | ⌘+C (`super+c`) | Ctrl+Shift+C |
| Paste | ⌘+V (`super+v`) | Ctrl+Shift+V |
| Select All | ⌘+A (`super+a`) | Ctrl+Shift+A |

> **Why different keybindings?** On Mac, `super` maps to ⌘ — a dedicated
> app-level modifier. On Linux, the Super key is intercepted by the Wayland
> compositor (GNOME) before any terminal sees it. This is a fundamental
> GNOME/Wayland design limitation, not a config problem. `Ctrl+Shift` is the
> Linux terminal standard and works across all terminals without configuration.

---

## Neovim Configuration

- **Plugin manager:** lazy.nvim (auto-bootstraps on first launch)
- **LSP manager:** Mason
- **Version:** 0.12.2

**Critical: nvim-treesitter branch pinning**

`nvim-treesitter` was archived April 3, 2026 after a breaking API rewrite
(`master` → `main`). Both plugins are pinned to `branch = "master"` in their
specs. **Never run `:Lazy update` without checking the treesitter changelog.**

If treesitter breaks:
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
- **Prompt:** `→ %F{cyan}%~%f `
- **PATH:** `$HOME/bin` (chezmoi on Linux), `$HOME/.local/bin` (fd on Linux)

---

## Linux-Specific: GNOME Settings

```bash
bash ~/dotfiles_config/linux-gnome-settings.sh
```

Frees Super+A and Super+V from GNOME so terminals can use them.

**Pending (System76 PPA outage):**
```bash
sudo apt update && sudo apt install pop-launcher
```
Rofi, Fuzzel, and Ulauncher all fail on GNOME Wayland (`no layer shell interface`).
`pop-launcher` is the only native GNOME Wayland launcher.

---

## Known Mac vs Linux Differences

| Feature | Mac | Linux |
|---------|-----|-------|
| Copy | ⌘+C | Ctrl+Shift+C |
| Paste | ⌘+V | Ctrl+Shift+V |
| Select all | ⌘+A | Ctrl+Shift+A |
| Font size | 18 | 16 |
| App launcher | Spotlight (⌘+Space) | Super key (pop-launcher pending) |
| Clipboard | Native | wl-clipboard |
| Font install | Brewfile | curl to `~/.local/share/fonts` |
| Neovim install | `brew install neovim` | `snap install nvim --classic` |
| Ghostty install | Brewfile | `snap install ghostty --classic` |
| chezmoi install | `brew install chezmoi` | `sh -c "$(curl -fsLS get.chezmoi.io)"` |
| chezmoi PATH | Automatic | Add `$HOME/bin` manually |
| fd binary name | `fd` | `fdfind` → symlinked to `fd` |
| Work identity | `~/.gitconfig-work` (manual) | Not needed |
| Docker | Docker Desktop | Not installed |
| Package manager | Homebrew + Brewfile | apt + install-linux.sh |

---

## Troubleshooting

### chezmoi not found on Linux
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

### Neovim Treesitter errors (`no file 'nvim-treesitter/configs.lua'`)
```bash
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter-textobjects
# Inside nvim: :Lazy install
```

### Wrong git identity being used
```bash
git config user.email          # Check active identity
cat ~/.gitconfig-work          # Verify work file exists on Mac
ls ~/Documents/work/           # Work identity only applies here
```

### Mason LSPs failing to install
Run `:checkhealth` — each needs its runtime (Node/Go/Python).

### Ghostty wrong config filename
```bash
mv ~/.config/ghostty/config.ghostty ~/.config/ghostty/config
```

### Clipboard not working in Neovim on Linux
```bash
sudo apt install wl-clipboard
# Inside nvim: :checkhealth provider
```

### fd not found by Telescope on Linux
```bash
mkdir -p ~/.local/bin && ln -s $(which fdfind) ~/.local/bin/fd
```

### `.config` showing as symlink in chezmoi diff
Old dotfiles setup had `~/.config → ~/.dotfiles/.config`. Fix:
```bash
rm ~/.config && mkdir ~/.config
cp -r ~/.dotfiles/.config/* ~/.config/
```

### Rust not available after install
```bash
source "$HOME/.cargo/env"
# Or add to ~/.zshrc: source "$HOME/.cargo/env"
```

### Docker CLI not working
Open Docker Desktop manually at least once to complete daemon setup.

### Oh My Zsh overwrote `.zshrc`
```bash
chezmoi apply ~/.zshrc  # Re-apply our .zshrc
```

### System76 PPA unavailable
```bash
sudo apt update 2>&1 | grep system76  # check if back online
```

---

## Hardware

- **Mac:** MacBook (ARM, Apple Silicon) — work machine
- **Linux:** System76 Darter Pro, Ubuntu 24.04 LTS, GNOME/Wayland — personal

---

## References

- [chezmoi docs](https://www.chezmoi.io/user-guide/setup/)
- [chezmoi templates](https://www.chezmoi.io/user-guide/templating/)
- [Ghostty docs](https://ghostty.org/docs)
- [lazy.nvim docs](https://lazy.folke.io/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [System76 Darter Pro](https://system76.com/laptops/darter)
- [nvim-treesitter archived (April 2026)](https://byteiota.com/nvim-treesitter-archived-13k-star-plugin-shut-down-2026/)
- [dotfiles.github.io](https://dotfiles.github.io/)
