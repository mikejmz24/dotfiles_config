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

| Item                             | Reason                                                                                                     |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `~/.gitconfig-work`              | Contains work email — never commit. Create manually on Mac.                                                |
| `~/.config/gh/hosts.yml`         | Contains GitHub auth tokens — never commit.                                                                |
| `~/.ssh/id_*`                    | Private SSH keys — never commit. Generate fresh on each machine.                                           |
| `~/.ssh/known_hosts`             | Machine-specific host fingerprints — never commit.                                                         |
| `~/.config/monitors.xml`         | Per-monitor display layout & scale — tied to each display's connector/serial. Set by hand on each machine. |
| `.oh-my-zsh/`                    | Installed separately by its own installer.                                                                 |
| Nerd Fonts                       | Installed via Brewfile (Mac) or curl (Linux).                                                              |
| `~/.config/chezmoi/chezmoi.toml` | Machine-specific identity — never commit.                                                                  |
| `~/.config/fish/`                | Not actively used.                                                                                         |
| `~/.config/zed/`                 | Not actively used.                                                                                         |
| `~/.config/iterm2/`              | Replaced by Ghostty.                                                                                       |
| `~/.config/gh/hosts.yml`         | Auth tokens — never commit.                                                                                |

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

> **Display scaling note:** Ghostty is a native Wayland app, so it stays crisp
> at any fractional scale (e.g. 150% on the 4K external). See Linux Desktop
> Configuration → Display Scaling.

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
- **Plugins:**
  - `git` — git aliases and prompt info
  - `zsh-autosuggestions` — shows grey command suggestions from history, press `→` to accept
  - `zsh-syntax-highlighting` — colors commands green (valid) or red (invalid) as you type
- **Prompt:** `→ %F{cyan}%~%f `
- **PATH additions:**
  - `$HOME/bin` — chezmoi (Linux only)
  - `$HOME/.local/bin` — fd symlink (Linux only)
  - `$HOME/go/bin` — Go tools (both)
  - `/Library/TeX/texbin` — MacTeX (Mac only)
  - `$HOME/.local/share/nvim/mason/bin` — Mason binaries (both)

> **Installing Zsh plugins on a new machine:** Plugins must be cloned into
> the Oh My Zsh custom plugins directory before `chezmoi apply` so the
> `.zshrc` plugins array can find them:
>
> ```bash
> git clone https://github.com/zsh-users/zsh-autosuggestions \
>   ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
> git clone https://github.com/zsh-users/zsh-syntax-highlighting \
>   ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
> ```

---

## Linux Desktop Configuration

### GNOME Settings (`linux-gnome-settings.sh`)

Run after fresh install:

```bash
bash ~/dotfiles_config/linux-gnome-settings.sh
```

**What it does:**

- Enables fractional / per-monitor display scaling on Wayland
  (`scale-monitor-framebuffer` experimental flag — see Display Scaling below)
- Sets window management keybindings:
  - `Super+Up` — maximize window (keeps top bar visible)
  - `Super+F` — true fullscreen (hides everything including top bar)
- Disables `ubuntu-dock` and hides the GNOME built-in dash via Just Perfection
- Clears `Super+1-9` from the dash app launcher, then rebinds:
  - `Super+1-9` — switch to workspace N
  - `Super+Shift+1-9` — move window to workspace N

### Display Scaling (Fractional / Per-Monitor)

The Darter Pro panel is 16" 1920×1200 (~141 PPI). A 32" 4K external monitor
(3840×2160) is ~138 PPI, so at the default 100% scale everything on the external
renders far too small — and because a desktop monitor sits farther away than a
laptop, it feels smaller still.

GNOME on Wayland supports independent per-monitor scaling, but the fractional
steps (125% / 150% / 175%) are hidden behind an experimental flag, enabled by
`linux-gnome-settings.sh`:

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

After that, set the scale per monitor in **Settings → Displays**:

| Display                   | Resolution | Scale | Logical workspace |
| ------------------------- | ---------- | ----- | ----------------- |
| Built-in (`eDP-1`)        | 1920×1200  | 100%  | 1920×1200         |
| 32" external (`HDMI-A-1`) | 3840×2160  | 150%  | 2560×1440         |

150% is the comfortable sweet spot for a 32" 4K at desk distance; drop to 125%
(→ 3072×1728 logical) if more screen real estate is preferred.

> **Detecting native resolution per output:**
>
> ```bash
> for f in /sys/class/drm/*/modes; do
>   [ -s "$f" ] && echo "$(basename "$(dirname "$f")"): $(head -n1 "$f")"
> done
> ```
>
> First line of each connected output is its native resolution.

**Crispness:** GNOME does fractional scaling by rendering larger and downscaling.
Native Wayland apps stay sharp (Ghostty, Firefox). XWayland apps can look slightly
soft under fractional scaling — for Chrome/Chromium, launch with
`--ozone-platform-hint=auto` to render natively. The only persistently soft thing
is the windowed Steam _client_ UI, which is purely cosmetic.

**Streams & games are NOT affected:** fullscreen video and games bypass the
compositor's desktop scaling entirely and run at the monitor's native 3840×2160 —
no quality loss, no blur, no performance penalty. The scale percentage only
governs how large windows and UI chrome are drawn on the desktop.

> **Not tracked by chezmoi:** the per-monitor scale assignment lives in
> `~/.config/monitors.xml`, which is tied to each display's connector and serial
> number. Don't sync it — it won't match other machines. Only the enabling flag
> (in `linux-gnome-settings.sh`) is shared across machines.

### Bloat Removal (`install-linux.sh`)

Removed during fresh install to keep the system lean:

| Removed                                                    | Reason                                                                                    |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `cheese`, `totem`, `example-content`                       | Webcam app, video player, sample content — not needed                                     |
| `thunderbird*`                                             | Web-based email only. Shipped as Snap on Ubuntu 24.04 — removed via both `apt` and `snap` |
| `libreoffice*`                                             | Google Docs/Sheets/Slides used instead                                                    |
| CJK input methods (`ibus-chewing`, `ibus-libpinyin`, etc.) | English and Spanish only                                                                  |
| Non-ES/EN language packs                                   | Keeping EN and ES only                                                                    |
| Spell/hyphen/thesaurus for unused languages                | Same reason                                                                               |

### GNOME Extensions

Install Extension Manager first:

```bash
sudo apt install gnome-shell-extension-manager
extension-manager &
```

**1. Hide Top Bar (tuxor1337)**
Search "hide top bar" → install by **tuxor1337** (NOT sonersg — no settings).

- Auto-hides top bar when any window is active
- Shows bar when mouse moves to top edge
- Zero performance impact — no blur, no animations

**2. Just Perfection**
Search "just perfection" and install.
Configure via `dconf`:

```bash
dconf write /org/gnome/shell/extensions/just-perfection/dash false
dconf write /org/gnome/shell/extensions/just-perfection/dash-app-running false
dconf write /org/gnome/shell/extensions/just-perfection/dash-separator false
dconf write /org/gnome/shell/extensions/just-perfection/show-apps-button false
```

Required because disabling `ubuntu-dock` falls back to GNOME's built-in dash
which can only be hidden via this extension. Hides dock from Activities overview.

> **Install extensions BEFORE running `linux-gnome-settings.sh`** — the script
> uses `dconf` commands that require Just Perfection to be installed first.

### App Launcher

**Current solution: GNOME Activities (Super key)**

- Press `Super` → Activities opens with instant search
- Start typing immediately to find apps, files, settings
- Works natively on Wayland, no configuration needed

**What we tried and why it didn't work:**

- **Rofi** — fails with `no layer shell interface` on GNOME Wayland
- **Fuzzel** — same `no layer shell interface` error
- **Ulauncher** — not available in Ubuntu repos
- **pop-launcher** (System76) — moved to COSMIC desktop, no longer in PPA

### External Monitor

The Darter Pro 11 has **three** video-capable outputs:

- **Built-in HDMI port** — plug monitor directly, works immediately
- **Thunderbolt 4 USB-C port** (marked ⚡) — supports DisplayPort Alt Mode
- **Regular USB-C port** — data only, does NOT support video output

> Always use the Thunderbolt 4 port (⚡) for USB-C hubs with HDMI/DisplayPort.
> The regular USB-C port will not output video even with a compatible hub.

> **Scaling:** A 32" 4K external comes up on the `HDMI-A-1` output and looks
> too small at 100%. See Display Scaling above — set it to 150%.

### System76 Driver and Firmware

```bash
# Install driver (confirmed hardware as darp11)
sudo apt install system76-driver

# Check for and schedule firmware updates
sudo system76-firmware-cli schedule
# Then reboot — updater runs automatically and boots back to Ubuntu
```

Provides hardware integration, power management, keyboard backlight,
and battery extensions specific to the Darter Pro 11.

---

## Known Mac vs Linux Differences

| Feature           | Mac                               | Linux                                                    |
| ----------------- | --------------------------------- | -------------------------------------------------------- |
| Copy              | ⌘+C                               | Ctrl+Shift+C                                             |
| Paste             | ⌘+V                               | Ctrl+Shift+V                                             |
| Select all        | ⌘+A                               | Ctrl+Shift+A                                             |
| Font size         | 18                                | 16                                                       |
| Fullscreen        | F11 / ⌘+F                         | Super+F                                                  |
| Maximize          | ⌘+Ctrl+F                          | Super+Up                                                 |
| Workspace switch  | Mission Control (3-finger swipe)  | Super+1-9                                                |
| Move to workspace | —                                 | Super+Shift+1-9                                          |
| App launcher      | Spotlight (⌘+Space)               | GNOME Activities (Super)                                 |
| Clipboard         | Native                            | wl-clipboard                                             |
| Display scaling   | Automatic per-display (Retina)    | Fractional flag + per-monitor in Settings (monitors.xml) |
| Font install      | Brewfile                          | curl to `~/.local/share/fonts`                           |
| Neovim            | `brew install neovim`             | `snap install nvim --classic`                            |
| Ghostty           | Brewfile                          | `snap install ghostty --classic`                         |
| chezmoi           | `brew install chezmoi`            | `sh -c "$(curl -fsLS get.chezmoi.io)"`                   |
| External monitor  | Any USB-C/HDMI                    | HDMI port or Thunderbolt 4 (⚡) only                     |
| Zsh plugins       | Installed via Oh My Zsh           | Same — clone to `~/.oh-my-zsh/custom/plugins/`           |
| chezmoi PATH      | Automatic                         | Add `$HOME/bin` manually                                 |
| fd binary         | `fd`                              | `fdfind` → symlinked to `fd`                             |
| SSH keychain      | `UseKeychain yes` (in SSH config) | Not supported — omitted via template                     |
| SSH remotes       | `git@github-personal:...`         | `git@github.com:...`                                     |
| Work identity     | `~/.gitconfig-work` (manual)      | Not needed                                               |
| bat               | Available                         | Not installed (Mac only)                                 |
| Docker            | Docker Desktop                    | Not installed                                            |
| Top bar           | Native macOS                      | Auto-hidden via Hide Top Bar extension                   |

---

## Troubleshooting

### Zsh plugins not loading (autosuggestions/syntax-highlighting)

Plugins must be cloned before or after `chezmoi apply`:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
source ~/.zshrc
echo $plugins  # should show all three plugins
```

### Fractional scaling options missing in Settings → Displays

The experimental flag isn't set. Enable it and re-open Settings:

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
# Log out and back in if the 125/150/175% options still don't appear
```

### External monitor looks too small (everything tiny)

It's a HiDPI panel (e.g. 32" 4K) running at 100%. Enable fractional scaling
(above), then in **Settings → Displays** select the external and set Scale to
**150%** (or 125% for more space). Confirm its native resolution with:

```bash
for f in /sys/class/drm/*/modes; do
  [ -s "$f" ] && echo "$(basename "$(dirname "$f")"): $(head -n1 "$f")"
done
```

### Scaled apps look blurry

GNOME fractional scaling blurs XWayland apps. Run them natively in Wayland:

```bash
# Chrome / Chromium / Electron apps
google-chrome --ozone-platform-hint=auto
```

Ghostty and modern Firefox are already native Wayland and stay crisp. Fullscreen
video and games are unaffected — they run at native resolution.

### External monitor not detected on Linux

Only two ports support video on the Darter Pro 11:

- Built-in **HDMI port** — always works, plug directly
- **Thunderbolt 4 USB-C port** (marked ⚡) — supports DisplayPort Alt Mode
  The regular USB-C port is data-only — no video output regardless of hub.

### System76 firmware update

```bash
sudo system76-firmware-cli schedule
sudo reboot  # updater runs automatically, boots back to Ubuntu
```

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
  - Built-in display: 16" 1920×1200 (~141 PPI), Intel Arc graphics
  - External: 32" 4K (3840×2160) on `HDMI-A-1`, scaled to 150%

---

## Desktop Theming (Linux / Ubuntu 24.04)

### Theme: Nordic dark with Admiral accent `#2354a0`

Nordic is a dark GTK theme. We override its default teal accent with Admiral
navy `#2354a0` across all GTK layers, Nautilus, and Firefox.

### What `install-linux.sh` does automatically

1. Sets Nordic as the GTK theme via `gsettings`
2. Copies Nordic's `gtk.css` to `~/.config/gtk-4.0/gtk.css`
3. Fixes symlinks — `gtk-dark.css` and `assets` point to Nordic (not Graphite)
4. Fixes sidebar selected text — hardcoded `color: #2354a0` changed to `#ffffff`
5. Appends Nautilus sidebar + file grid selection overrides
6. Writes `~/.config/gtk-3.0/gtk.css` with selection color
7. Writes Firefox `userContent.css` for snap Firefox

### Firefox manual step (one-time)

After running `install-linux.sh`, open Firefox and go to `about:config`: `toolkit.legacyUserProfileCustomizations.stylesheets = true`
Restart Firefox. Text selection will now match the system navy accent.

### Key colors

| Element              | Color                    |
| -------------------- | ------------------------ |
| Admiral accent       | `#2354a0`                |
| Sidebar selected row | `#0f2347`                |
| File grid fill       | `rgba(35, 84, 160, 0.5)` |
| File grid outline    | `#2354a0`                |
| Selected text        | `#ffffff`                |

### Why so many layers needed patching

| Layer          | File                        | What it controls                     |
| -------------- | --------------------------- | ------------------------------------ |
| GTK3           | `~/.config/gtk-3.0/gtk.css` | Most native apps                     |
| GTK4           | `~/.config/gtk-4.0/gtk.css` | Modern GNOME apps including Nautilus |
| Firefox (snap) | `chrome/userContent.css`    | Firefox ignores all GTK layers       |

### Key fix: Nautilus sidebar selected text

The sidebar selected item text was Admiral blue instead of white. Root cause:
`.sidebar-pane placessidebar .navigation-sidebar > row:selected label.sidebar-label`
was hardcoded to `color: #2354a0` inside the Nordic CSS.

Also: `gtk-dark.css` and `assets` were symlinks pointing to old Graphite-blue-Dark.
Fixed to point to Nordic.

### How to test CSS changes live

Open Nautilus → press `Ctrl+Shift+D` → CSS tab → type rules live.
GTK Inspector injects CSS at highest priority — use it to verify selectors
before writing to files.

### Themes tried and rejected

| Theme                     | Reason                                    |
| ------------------------- | ----------------------------------------- |
| `Yaru-prussiangreen-dark` | Too green                                 |
| `Yaru-purple-dark`        | Too purple                                |
| `Yaru-blue-dark`          | Not deep enough                           |
| `Graphite-blue-Dark`      | Accent hardcoded as Google blue `#1A73E8` |
| `Nordic-darker`           | Kept as fallback variant                  |

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
