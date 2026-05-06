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
- **Validate before commit** — always run the validation checklist before pushing

---

## Identity Overview

| Identity | Username        | Used For                                               |
| -------- | --------------- | ------------------------------------------------------ |
| Personal | `mikejmz24`     | Default — all personal repos, Ubuntu machine           |
| Work     | `work-username` | Work repos only, inside `~/Documents/work/` (Mac only) |

---

## Repo Structure

```
dotfiles_config/
├── README.md                               # This file — read before anything else
├── Brewfile                                # Mac packages (managed by chezmoi → ~/Brewfile)
├── install-mac.sh                          # Mac full setup script (run once on fresh install)
├── install-linux.sh                        # Linux full setup script (run once on fresh install)
├── linux-gnome-settings.sh                 # Linux-only: GNOME customizations (run manually)
├── dot_gitconfig.tmpl                      # → ~/.gitconfig (template — switches identity by OS)
├── dot_gitignore_global                    # → ~/.gitignore_global (both platforms)
├── dot_zshrc                               # → ~/.zshrc (both platforms)
├── private_dot_ssh/
│   └── config.tmpl                         # → ~/.ssh/config (template — Mac/Linux differences)
│                                           # private_ prefix preserves 700 permissions on ~/.ssh
└── dot_config/
    ├── ghostty/
    │   └── config.tmpl                     # → ~/.config/ghostty/config (template — font/keys by OS)
    └── nvim/                               # → ~/.config/nvim/ (both platforms)
        ├── init.lua
        ├── lazy-lock.json                  # IMPORTANT: never run :Lazy update blindly
        ├── dot_sqlfluff                    # sqlfluff formatter config
        ├── dot_sqls/
        │   └── config.yml                  # sqls database config (connections: [] — no credentials)
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

| Item                             | Reason                                                           |
| -------------------------------- | ---------------------------------------------------------------- |
| `~/.gitconfig-work`              | Contains work email — never commit. Create manually on Mac.      |
| `~/.config/gh/hosts.yml`         | Contains GitHub auth tokens — never commit.                      |
| `~/.ssh/id_*`                    | Private SSH keys — never commit. Generate fresh on each machine. |
| `~/.ssh/known_hosts`             | Machine-specific host fingerprints — never commit.               |
| `.oh-my-zsh/`                    | Installed separately by its own installer.                       |
| Nerd Fonts                       | Installed via Brewfile (Mac) or curl (Linux).                    |
| `~/.config/chezmoi/chezmoi.toml` | Machine-specific identity — never commit.                        |
| `~/.config/fish/`                | Not actively used.                                               |
| `~/.config/zed/`                 | Not actively used.                                               |
| `~/.config/iterm2/`              | Replaced by Ghostty.                                             |
| `~/.config/gh/hosts.yml`         | Auth tokens — never commit.                                      |

---

## Validation Checklist (Run Before Every Commit)

We learned this the hard way by hitting real pitfalls — always validate before
committing. Skipping this caused SSH to break on Linux and exposed a work
username in a public repo. The checklist below prevents both.

```bash
# 1. Verify ALL templates render correctly for current OS
chezmoi execute-template < ~/.local/share/chezmoi/private_dot_ssh/config.tmpl
chezmoi execute-template < ~/.local/share/chezmoi/dot_config/ghostty/config.tmpl
chezmoi execute-template < ~/.local/share/chezmoi/dot_gitconfig.tmpl

# 2. Dry run — see what chezmoi WOULD deploy without doing it
chezmoi apply --dry-run --verbose

# 3. Diff — confirm no unexpected changes
chezmoi diff

# 4. Verify — confirm deployed files match repo
chezmoi verify

# 5. Check git status carefully before staging
cd ~/.local/share/chezmoi
git status  # review every file — deletions and renames matter

# 6. Check for sensitive data in anything being added
git diff --staged  # review what's actually being committed

# 7. Only if all above are clean — commit and push
git add -A
git commit -m "describe your change"
git push
```

> **Why this matters:** chezmoi deploys files to your live system. A bad
> template or wrong config can break SSH, git identity, or your terminal.
> The dry-run and diff steps catch issues before they affect your system.
> Committing without validating has caused real breakage in this setup.

### Pitfalls We Hit (and How to Avoid Them)

**1. Mac-only SSH option broke Linux**
`UseKeychain yes` is a macOS-only SSH option. When the Mac SSH config was
committed without a template, chezmoi deployed it to Linux where it caused:

```
Bad configuration option: usekeychain
fatal: Could not read from remote repository.
```

**Fix:** Always use `private_dot_ssh/config.tmpl` — never commit `~/.ssh/config`
directly. The `{{- if eq .os "mac" }}` block handles it automatically.

**2. Mac-only configs committed to repo**
Files from `~/.config/fish`, `~/.config/gh`, `~/.config/iterm2`, `~/.config/zed`,
`~/.config/uv` were committed from the Mac. They kept reappearing on Linux
after every git pull because they were in git history, not just the working tree.
**Fix:** Use `.chezmoiignore` to exclude them AND scrub from git history with
`git filter-repo` if already committed.

**3. Sensitive data in git history**
`~/.config/gh/hosts.yml` (work GitHub username) and `gh/config.yml` were
committed before `.chezmoiignore` was set up. Even after deleting the files,
the data lived in git history on a public repo.
**Fix:** Use `git filter-repo` to scrub files from all history, then force push.
Always check `.chezmoiignore` covers sensitive files BEFORE first commit.

**4. Committing without validating templates**
Renaming `config → config.tmpl` without verifying the template renders
correctly on both platforms caused cascading issues across multiple commits.
**Fix:** Always run `chezmoi execute-template` on every `.tmpl` file after
any change. Verify on both Mac and Linux if possible.

**5. chezmoi.toml missing `os` variable**
After a `git filter-repo` operation, templates failed with:

```
map has no entry for key "os"
```

**Fix:** Always verify `~/.config/chezmoi/chezmoi.toml` exists with the correct
`os` variable before running `chezmoi apply` on any machine.

### Scrubbing Sensitive Data from Git History

If sensitive data was accidentally committed to a public repo:

```bash
# Install git-filter-repo
pip install git-filter-repo --break-system-packages
export PATH="$HOME/.local/bin:$PATH"

# Remove specific files from ALL history
cd ~/.local/share/chezmoi
git filter-repo \
  --path path/to/sensitive/file \
  --path path/to/another/file \
  --invert-paths \
  --force

# Re-add remote (filter-repo removes it)
git remote add origin git@github.com:mikejmz24/dotfiles_config.git

# Force push (rewrites history on GitHub)
git push origin main --force

# Re-set tracking branch
git branch --set-upstream-to=origin/main main
```

> **After scrubbing:** Anyone who cloned the repo before the force push
> will still have the sensitive data locally. For personal dotfiles repos
> this is usually acceptable. For team repos, notify all collaborators
> to re-clone.

---

## chezmoi Template System

Three files use chezmoi templates (`.tmpl` extension):

### `private_dot_ssh/config.tmpl`

Handles Mac-only SSH options and work identity:

```
Host github-personal
    HostName github.com
    User git
    AddKeysToAgent yes
{{- if eq .os "mac" }}
    UseKeychain yes    # macOS Keychain integration — NOT available on Linux
{{- end }}
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
{{- if eq .os "mac" }}

# Work GitHub — Mac only
Host github-work
    HostName github.com
    ...
{{- end }}
```

> **Critical gotcha:** `UseKeychain` is a **macOS-only** SSH option. It does
> not exist on Linux and will cause SSH to fail with "Bad configuration option".
> Always use the template — never copy the Mac SSH config directly to Linux.

### `dot_config/ghostty/config.tmpl`

Handles font size and keybindings:

- Mac: font-size 18 (Retina display), `super+c/v/a` (⌘ key)
- Linux: font-size 16 (standard display), `ctrl+shift+c/v/a`

### `dot_gitconfig.tmpl`

Handles identity and Mac-only work profile:

- Both: personal identity (`mikejmz24`)
- Mac only: `includeIf` block for work identity inside `~/Documents/work/`

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

> **Critical:** The `os` variable must be set in `chezmoi.toml` before running
> `chezmoi apply`. Without it, all templates fail with "map has no entry for key 'os'".

---

## Git Identity Setup

### Default identity (personal — works everywhere)

Managed automatically by chezmoi via `dot_gitconfig.tmpl`.

### Work identity (Mac only — `~/Documents/work/` only)

**Create manually. Never commit.**

```bash
nvim ~/.gitconfig-work
```

Add:

```gitconfig
[user]
    name = your-work-username
    email = your-work@company.com
```

> **How it works:** Git's `includeIf "gitdir:~/Documents/work/"` only activates
> inside an actual git repo within that directory — not in the directory itself.
> Always `git init` or clone before testing identity.

**Verify:**

```bash
cd ~/Documents/work
mkdir test && cd test && git init
git config user.email  # Should show work email
rm -rf ~/Documents/work/test
```

---

## SSH Setup

### Mac

Uses two identities via SSH config aliases:

- `github-personal` → personal key (`~/.ssh/id_ed25519`)
- `github-work` → work key (`~/.ssh/id_ed25519_work`)

Remote URLs use the alias, not `github.com`:

```bash
git remote set-url origin git@github-personal:mikejmz24/dotfiles_config.git
```

Add key to macOS Keychain (persists across reboots — no passphrase prompts):

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Linux

Single identity, no aliases needed:

```bash
# Remote uses github.com directly
git remote set-url origin git@github.com:mikejmz24/dotfiles_config.git
```

### Generate new SSH key (both platforms)

```bash
ssh-keygen -t ed25519 -C "YOUR_ID+mikejmz24@users.noreply.github.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
# Add to GitHub → Settings → SSH and GPG keys → New SSH key
ssh -T git@github.com  # or git@github-personal on Mac
```

> First connection: type `yes` for GitHub's fingerprint.
> Fingerprint: `SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`

---

## Global Gitignore

**Location:** `~/.gitignore_global` (managed by chezmoi, both platforms)

### macOS system files

| Pattern           | Why                               |
| ----------------- | --------------------------------- |
| `.DS_Store`       | Folder metadata created by Finder |
| `._*`             | macOS resource fork files         |
| `.Spotlight-V100` | Spotlight search index            |
| `.Trashes`        | macOS trash folder                |

### Credentials & secrets (CRITICAL)

| Pattern                    | Why                                    |
| -------------------------- | -------------------------------------- |
| `.gitconfig-work`          | Work git identity with real work email |
| `*.pem`, `*.key`           | Certificates and private keys          |
| `*.env`, `.env*`           | Environment files with secrets         |
| `secrets/`, `credentials/` | Sensitive directories                  |

### Editor & tooling

| Pattern                     | Why                                    |
| --------------------------- | -------------------------------------- |
| `.vscode/extensions/`       | Installed per machine, not per project |
| `*.swp`, `*.swo`            | Vim/Neovim swap files                  |
| `.idea/`                    | JetBrains IDE files                    |
| `__pycache__/`, `*.py[cod]` | Python bytecode                        |
| `.venv/`, `venv/`           | Virtual environments                   |
| `node_modules/`             | Node dependencies                      |
| `*.log`                     | Log files                              |

---

## Quick Start — Fresh Mac Install

```bash
git clone https://github.com/mikejmz24/dotfiles_config.git ~/dotfiles_config
bash ~/dotfiles_config/install-mac.sh
```

See `install-mac.sh` for full details. Install order matters:

1. Xcode CLI Tools → 2. Homebrew → 3. chezmoi → 4. `chezmoi.toml` (manual)
   → 5. SSH key (manual) → 6. `chezmoi apply` → 7. Oh My Zsh
   → 8. `brew bundle install` → 9. `rustup-init` → 10. Go tools
   → 11. Python tools → 12. `~/.gitconfig-work` (manual)

---

## Quick Start — Restoring an Existing Mac

```bash
chezmoi update
brew bundle install --file=~/Brewfile
# Update Brewfile to reflect current state
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

git clone https://github.com/mikejmz24/dotfiles_config.git ~/dotfiles_config
bash ~/dotfiles_config/install-linux.sh
```

After install, run GNOME settings:

```bash
bash ~/dotfiles_config/linux-gnome-settings.sh
```

---

## Updating Dotfiles

```bash
# Run validation checklist first (see above)
chezmoi add ~/.config/ghostty/config   # stage changed file
cd ~/.local/share/chezmoi
git add -A
git status                              # review before committing
git commit -m "describe your change"
git push
```

On another machine:

```bash
chezmoi update
```

---

## Tools Reference

### Shell & Terminal

| Tool          | What It Does                                     | Platform |
| ------------- | ------------------------------------------------ | -------- |
| **zsh**       | Shell — better completion, required by Oh My Zsh | Both     |
| **Oh My Zsh** | Zsh framework — robbyrussell theme, git plugin   | Both     |
| **Ghostty**   | GPU-accelerated terminal — fast, cross-platform  | Both     |

### File & Search Utilities

| Tool        | Command | What It Does                          | Notes                                                       |
| ----------- | ------- | ------------------------------------- | ----------------------------------------------------------- |
| **ripgrep** | `rg`    | Searches file contents fast           | Required by Telescope in Neovim                             |
| **fd**      | `fd`    | Finds files fast                      | Required by Telescope. Ubuntu: `fdfind` → symlinked to `fd` |
| **tree**    | `tree`  | Shows directory structure             | Project navigation                                          |
| **jq**      | `jq`    | Processes JSON                        | Required by jq-lsp in Neovim                                |
| **bat**     | `bat`   | Better `cat` with syntax highlighting | Mac only (in Brewfile)                                      |
| **xz**      | `xz`    | Decompresses .xz files                | Software extraction                                         |
| **wget**    | `wget`  | Downloads files                       | Alternative to curl                                         |

### Development Runtimes

| Tool              | Required By                                         | Platform |
| ----------------- | --------------------------------------------------- | -------- |
| **Go**            | gopls, gofumpt, goimports, sqls, jq-lsp, air, templ | Both     |
| **Node.js**       | html-lsp, css-lsp, prettier, pyright                | Both     |
| **Python 3.12**   | pyright, black, isort, pylint, sqlfluff             | Both     |
| **Rust (rustup)** | cargo, cargo-c — run `rustup-init` after install    | Mac      |

### Python Tools

| Tool           | What It Does                                             |
| -------------- | -------------------------------------------------------- |
| **pyright**    | Python type checker — used by Mason LSP                  |
| **virtualenv** | Virtual environment manager                              |
| **pipx**       | Installs Python CLIs in isolation                        |
| **poetry**     | Modern dependency management                             |
| **jupyterlab** | Web-based Python notebooks                               |
| **pynvim**     | Python provider for Neovim — required for `:checkhealth` |

### Go Tools

| Tool             | What It Does                             |
| ---------------- | ---------------------------------------- |
| **air**          | Live reload for Go apps                  |
| **go-blueprint** | Go project scaffolding                   |
| **godog**        | BDD testing (Cucumber for Go)            |
| **gopls**        | Official Go language server              |
| **sqls**         | SQL language server                      |
| **templ**        | Compile-time safe HTML templating for Go |

### Docker (Mac only)

| Tool               | What It Does                                            |
| ------------------ | ------------------------------------------------------- |
| **docker**         | Docker CLI (link:false — avoids conflicts with Desktop) |
| **docker-compose** | Multi-container orchestration                           |
| **docker-desktop** | Docker GUI + daemon — must be opened manually once      |

### Work Tools (Mac only)

| Tool        | What It Does                    | Notes                                               |
| ----------- | ------------------------------- | --------------------------------------------------- |
| **gh**      | GitHub CLI                      | `config.yml` committed, `hosts.yml` never committed |
| **VSCode**  | Code editor                     | Team onboarding. Dark Modern theme only.            |
| **nerdfix** | Fixes Nerd Font icon references | When font updates change codepoints                 |

### GUI Apps (Mac only)

| App               | What It Does                |
| ----------------- | --------------------------- |
| **Google Chrome** | Web browser                 |
| **Slack**         | Team messaging              |
| **WhatsApp**      | Messaging                   |
| **Postman**       | API development and testing |
| **MacTeX**        | LaTeX distribution          |

### Neovim LSPs (via Mason)

| LSP                   | Language | Runtime |
| --------------------- | -------- | ------- |
| `lua-language-server` | Lua      | bundled |
| `pyright`             | Python   | Node.js |
| `gopls`               | Go       | Go      |
| `html-lsp`            | HTML     | Node.js |
| `css-lsp`             | CSS      | Node.js |
| `htmx-lsp`            | HTMX     | Go      |
| `jq-lsp`              | jq       | Go      |
| `sqls`                | SQL      | Go      |

### Neovim Formatters & Linters

| Tool            | Type               | Language          |
| --------------- | ------------------ | ----------------- |
| `stylua`        | Formatter          | Lua               |
| `black`         | Formatter          | Python            |
| `isort`         | Formatter          | Python imports    |
| `prettier`      | Formatter          | HTML/CSS/Markdown |
| `gofumpt`       | Formatter          | Go                |
| `goimports`     | Formatter          | Go imports        |
| `sqlfluff`      | Formatter + Linter | SQL               |
| `pylint`        | Linter             | Python            |
| `golangci-lint` | Linter             | Go                |

---

## Ghostty Configuration

- **Config:** `~/.config/ghostty/config` (generated from `config.tmpl`)
- **Font:** Hack Nerd Font, with ligatures (calt, liga, ss13)
- **Theme:** Challenger Deep (built-in — no download needed)
- **Cursor:** Bar style, blinking, opacity 0.8, thickness 3
- **Background:** opacity 0.92

| Feature    | Mac             | Linux                 |
| ---------- | --------------- | --------------------- |
| Font size  | 18 (Retina)     | 16 (standard display) |
| Copy       | ⌘+C (`super+c`) | Ctrl+Shift+C          |
| Paste      | ⌘+V (`super+v`) | Ctrl+Shift+V          |
| Select All | ⌘+A (`super+a`) | Ctrl+Shift+A          |

> **Why different keybindings?** On Linux, the Super key is intercepted by
> the Wayland compositor (GNOME) before any terminal sees it. This is a
> fundamental GNOME/Wayland design limitation. `Ctrl+Shift+C/V` is the
> Linux terminal standard and works across all terminals.

> **Config file name:** Must be `config`, NOT `config.ghostty`.

---

## Neovim Configuration

- **Plugin manager:** lazy.nvim (auto-bootstraps on first launch)
- **LSP manager:** Mason
- **Version:** 0.12.2

**Critical: nvim-treesitter branch pinning**

`nvim-treesitter` was archived April 3, 2026 after a breaking API rewrite.
Both plugins pinned to `branch = "master"`. **Never run `:Lazy update` without
checking the treesitter changelog first.**

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
- **PATH additions:**
  - `$HOME/bin` — chezmoi (Linux only)
  - `$HOME/.local/bin` — fd symlink (Linux only)
  - `$HOME/go/bin` — Go tools (both)
  - `/Library/TeX/texbin` — MacTeX (Mac only)
  - `$HOME/.local/share/nvim/mason/bin` — Mason binaries (both)

---

## Linux Desktop Configuration

### GNOME Settings (`linux-gnome-settings.sh`)

Run after fresh install:

```bash
bash ~/dotfiles_config/linux-gnome-settings.sh
```

**What it does:**

- Frees `Super+A` from GNOME app drawer
- Frees `Super+V` from GNOME message tray
- Sets GNOME Terminal copy/paste keybindings
- Sets window management keybindings:
  - `Super+Up` — maximize window
  - `Super+F` — true fullscreen (hides everything)

### Auto-hide Top Bar

Install **"Hide Top Bar" by tuxor1337** via GNOME Extension Manager:

```bash
sudo apt install gnome-shell-extension-manager
extension-manager &
```

Search "hide top bar" → install the one by **tuxor1337** (NOT sonersg).

- Shows bar when mouse moves to top edge
- Hides automatically when any window is active
- Zero performance impact

> **Why tuxor1337 and not sonersg?** tuxor1337's version has the mouse
> hover option we need. sonersg's version has no settings at all.

### App Launcher

**Current solution: GNOME Activities (Super key)**

- Press `Super` → Activities opens with instant search
- Start typing immediately to find apps, files, settings
- Works natively on Wayland, no configuration needed

**What we tried and why it didn't work:**

- **Rofi** — fails with `no layer shell interface` on GNOME Wayland
- **Fuzzel** — same `no layer shell interface` error
- **Ulauncher** — not available in Ubuntu repos
- **pop-launcher** (System76) — moved to COSMIC desktop, no longer in system76-dev PPA

> GNOME Activities is good enough for daily use and requires zero configuration.

### System76 Driver

```bash
sudo apt install system76-driver
```

Confirmed hardware as `darp11` (Darter Pro 11). Provides better hardware
integration, power management, and firmware updates.

---

## Known Mac vs Linux Differences

| Feature       | Mac                               | Linux                                  |
| ------------- | --------------------------------- | -------------------------------------- |
| Copy          | ⌘+C                               | Ctrl+Shift+C                           |
| Paste         | ⌘+V                               | Ctrl+Shift+V                           |
| Select all    | ⌘+A                               | Ctrl+Shift+A                           |
| Font size     | 18                                | 16                                     |
| Fullscreen    | F11 / ⌘+F                         | Super+F                                |
| Maximize      | ⌘+Ctrl+F                          | Super+Up                               |
| App launcher  | Spotlight (⌘+Space)               | GNOME Activities (Super)               |
| Clipboard     | Native                            | wl-clipboard                           |
| Font install  | Brewfile                          | curl to `~/.local/share/fonts`         |
| Neovim        | `brew install neovim`             | `snap install nvim --classic`          |
| Ghostty       | Brewfile                          | `snap install ghostty --classic`       |
| chezmoi       | `brew install chezmoi`            | `sh -c "$(curl -fsLS get.chezmoi.io)"` |
| chezmoi PATH  | Automatic                         | Add `$HOME/bin` manually               |
| fd binary     | `fd`                              | `fdfind` → symlinked to `fd`           |
| SSH keychain  | `UseKeychain yes` (in SSH config) | Not supported — omitted via template   |
| SSH remotes   | `git@github-personal:...`         | `git@github.com:...`                   |
| Work identity | `~/.gitconfig-work` (manual)      | Not needed                             |
| bat           | Available                         | Not installed (Mac only)               |
| Docker        | Docker Desktop                    | Not installed                          |
| Top bar       | Native macOS                      | Auto-hidden via Hide Top Bar extension |

---

## Troubleshooting

### chezmoi not found on Linux

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

### Templates fail with "map has no entry for key 'os'"

`chezmoi.toml` is missing or missing the `os` variable:

```bash
nvim ~/.config/chezmoi/chezmoi.toml  # add os = "linux" or os = "mac"
```

### SSH fails with "Bad configuration option: usekeychain" on Linux

The Mac SSH config was deployed without going through the template:

```bash
chezmoi apply --force ~/.ssh/config
cat ~/.ssh/config  # verify UseKeychain is gone
```

### chezmoi refusing to apply (file changed since last write)

```bash
chezmoi apply --force ~/.ssh/config  # or whichever file
```

### Neovim Treesitter errors

```bash
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter-textobjects
# Inside nvim: :Lazy install
```

### Wrong git identity being used

```bash
# Must be inside an actual git repo to test includeIf
cd ~/Documents/work && git init test && cd test
git config user.email  # verify work email
cd ~ && rm -rf ~/Documents/work/test
```

### Mason LSPs failing

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

### Old Mac configs appearing in chezmoi on Linux

If `fish`, `gh`, `iterm2`, `uv`, `zed` appear in `~/.local/share/chezmoi/.config/`:

```bash
rm -rf ~/.local/share/chezmoi/.config/fish
rm -rf ~/.local/share/chezmoi/.config/gh
rm -rf ~/.local/share/chezmoi/.config/iterm2
rm -rf ~/.local/share/chezmoi/.config/uv
rm -rf ~/.local/share/chezmoi/.config/zed
```

These are Mac-only configs that should be excluded via `.chezmoiignore`.

### Oh My Zsh overwrote `.zshrc`

```bash
chezmoi apply ~/.zshrc
```

### Rust not available after install

```bash
source "$HOME/.cargo/env"
# Or add to ~/.zshrc permanently
```

### Docker CLI not working on Mac

Open Docker Desktop manually at least once to complete daemon setup.

### Push rejected (remote contains work not in local)

```bash
git pull --rebase
git push
```

### `.config` showing as symlink in chezmoi diff

Old dotfiles setup had `~/.config → ~/.dotfiles/.config`:

```bash
rm ~/.config && mkdir ~/.config
cp -r ~/.dotfiles/.config/* ~/.config/
```

### System76 PPA unavailable

```bash
sudo apt update 2>&1 | grep system76  # check if back online
```

---

## Hardware

- **Mac:** MacBook (ARM, Apple Silicon) — work machine
- **Linux:** System76 Darter Pro 11 (`darp11`), Ubuntu 24.04 LTS, GNOME/Wayland

---

## References

- [chezmoi docs](https://www.chezmoi.io/user-guide/setup/)
- [chezmoi templates](https://www.chezmoi.io/user-guide/templating/)
- [Ghostty docs](https://ghostty.org/docs)
- [lazy.nvim docs](https://lazy.folke.io/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [System76 Darter Pro](https://system76.com/laptops/darter)
- [Hide Top Bar extension](https://extensions.gnome.org/extension/545/hide-top-bar/)
- [nvim-treesitter archived (April 2026)](https://byteiota.com/nvim-treesitter-archived-13k-star-plugin-shut-down-2026/)
- [dotfiles.github.io](https://dotfiles.github.io/)
