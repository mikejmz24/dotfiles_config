# =============================================================================
# Brewfile — Mac Development Environment
# mikejmz24
#
# Usage:
#   brew bundle install --file=~/Brewfile
#
# To update this file after installing something new:
#   brew bundle dump --force --file=~/Brewfile
#
# This file is NOT managed by chezmoi — it lives at ~/Brewfile and is
# Mac-only. Linux uses install-linux.sh instead.
# =============================================================================

# =============================================================================
# TAPS — Third-party Homebrew repositories
# =============================================================================

tap "homebrew/bundle"       # Enables the 'brew bundle' command that reads this file
tap "homebrew/cask-fonts"   # Provides access to Nerd Font casks

# =============================================================================
# CORE DEVELOPMENT TOOLS
# =============================================================================

brew "git"          # Version control. Required by chezmoi, nvim plugins, and everything else.
brew "neovim"       # Hyperextensible text editor. Primary editor for all development work.
brew "ripgrep"      # (rg) Extremely fast file content search. Required by Telescope in Neovim.
brew "fd"           # Fast file finder. Required by Telescope for extended file search.
brew "tree"         # Displays directory structure as a visual tree.
brew "jq"           # Command-line JSON processor. Required by jq-lsp in Neovim.
brew "xz"           # Compression/decompression for .xz and .tar.xz files.
brew "wget"         # HTTP file downloader. Alternative to curl for downloading files.
brew "bat"          # Better version of 'cat' with syntax highlighting and line numbers.
brew "chezmoi"      # Dotfile manager. Manages configs across Mac and Linux via git.
brew "nerdfix"      # Fixes outdated/broken Nerd Font icon references in files.

# =============================================================================
# PROGRAMMING LANGUAGE RUNTIMES
# Required by Neovim's Mason LSP manager to install language servers.
# =============================================================================

brew "go"               # Go runtime. Required by gopls, gofumpt, goimports, sqls, jq-lsp.
brew "node"             # Node.js runtime. Required by html-lsp, css-lsp, prettier, pyright.
brew "python@3.12"      # Python interpreter. Required by pyright, black, isort, pylint, sqlfluff.

# Rust toolchain — installed via rustup for version management
brew "rustup"           # Rust toolchain installer and version manager.
                        # Manages stable/nightly/beta Rust versions.
                        # After install, run: rustup-init
brew "cargo-c"          # Cargo subcommand for building C-compatible libraries from Rust crates.

# =============================================================================
# PYTHON TOOLS
# =============================================================================

brew "pyright"      # Python type checker and LSP. Used by Mason's pyright install.
brew "virtualenv"   # Python virtual environment manager. Used for project isolation.
brew "pipx"         # Installs Python CLI tools in isolated environments. Better than pip for CLIs.
brew "poetry"       # Python dependency management and packaging tool. Alternative to pip+venv.
brew "jupyterlab"   # Web-based interactive Python notebook environment. Used for data analysis.

# =============================================================================
# GO TOOLS
# Installed via 'go install' but tracked here for reference.
# These are also available via Mason in Neovim.
# =============================================================================

go "github.com/cosmtrek/air"            # Live reload for Go apps during development.
go "github.com/melkeydev/go-blueprint"  # Go project scaffolding tool with best practices.
go "github.com/cucumber/godog/cmd/godog" # Go BDD testing framework (Cucumber for Go).
go "golang.org/x/tools/gopls"           # Official Go language server. Used by Neovim Mason.
go "github.com/sqls-server/sqls"        # SQL language server. Used by Neovim Mason.
go "github.com/a-h/templ/cmd/templ"     # HTML templating language for Go. Compile-time safe.

# =============================================================================
# TREE-SITTER
# Parsing framework used by Neovim for syntax highlighting.
# =============================================================================

brew "tree-sitter"      # Tree-sitter parsing library. Used internally by Neovim.
brew "tree-sitter-cli"  # CLI for developing/testing tree-sitter grammars.
brew "luarocks"         # Lua package manager. Used by some Neovim plugins.

# =============================================================================
# GO LINTING
# =============================================================================

brew "golangci-lint"    # Fast Go linter aggregator. Runs multiple linters in parallel.
                        # Used in Neovim via nvim-lint for Go diagnostics.

# =============================================================================
# DOCKER
# Container platform for development and deployment.
# =============================================================================

brew "docker", link: false  # Docker CLI. link:false prevents conflicts with Docker Desktop.
brew "docker-compose"       # Multi-container Docker application orchestration.
cask "docker-desktop"       # Docker GUI + daemon for Mac. Required to run containers locally.

# =============================================================================
# WORK TOOLS (Mac only — not needed on personal Linux machine)
# =============================================================================

brew "gh"           # GitHub CLI. Used for team onboarding at work.
                    # Config at ~/.config/gh/config.yml (managed by chezmoi, Mac-only).
                    # hosts.yml is NOT committed — contains authentication tokens.

# =============================================================================
# APPLICATIONS (GUI)
# =============================================================================

cask "ghostty"              # GPU-accelerated terminal emulator. Primary terminal on Mac and Linux.
cask "visual-studio-code"   # Code editor. Used for team onboarding documentation.
cask "google-chrome"        # Web browser.
cask "slack"                # Team messaging. Used for work communication.
cask "whatsapp"             # Messaging app.
cask "postman"              # API development and testing tool.
cask "mactex"               # LaTeX distribution for Mac. Used for document typesetting.

# =============================================================================
# VSCODE EXTENSIONS
# =============================================================================

vscode "ms-pyright.pyright"             # Python type checking
vscode "ms-python.black-formatter"      # Python formatting
vscode "ms-python.debugpy"              # Python debugging
vscode "ms-python.python"               # Core Python extension
vscode "ms-python.vscode-pylance"       # Python language server
vscode "ms-python.vscode-python-envs"   # Python environment management

# =============================================================================
# NERD FONTS
# All variants installed for flexibility. Only Hack Nerd Font is actively
# used in Ghostty config (font-family = Hack Nerd Font).
# On Linux, only Hack Nerd Font is installed manually via curl.
# =============================================================================

cask "font-hack-nerd-font"              # PRIMARY: Used in Ghostty config

# Additional fonts (available but not actively used):
cask "font-0xproto-nerd-font"
cask "font-3270-nerd-font"
cask "font-agave-nerd-font"
cask "font-anonymice-nerd-font"
cask "font-arimo-nerd-font"
cask "font-aurulent-sans-mono-nerd-font"
cask "font-bigblue-terminal-nerd-font"
cask "font-bitstream-vera-sans-mono-nerd-font"
cask "font-blex-mono-nerd-font"
cask "font-caskaydia-cove-nerd-font"
cask "font-caskaydia-mono-nerd-font"
cask "font-code-new-roman-nerd-font"
cask "font-comic-shanns-mono-nerd-font"
cask "font-commit-mono-nerd-font"
cask "font-cousine-nerd-font"
cask "font-d2coding-nerd-font"
cask "font-daddy-time-mono-nerd-font"
cask "font-dejavu-sans-mono-nerd-font"
cask "font-droid-sans-mono-nerd-font"
cask "font-envy-code-r-nerd-font"
cask "font-fantasque-sans-mono-nerd-font"
cask "font-fira-code-nerd-font"
cask "font-fira-mono-nerd-font"
cask "font-geist-mono-nerd-font"
cask "font-go-mono-nerd-font"
cask "font-gohufont-nerd-font"
cask "font-hasklug-nerd-font"
cask "font-heavy-data-nerd-font"
cask "font-hurmit-nerd-font"
cask "font-im-writing-nerd-font"
cask "font-inconsolata-go-nerd-font"
cask "font-inconsolata-lgc-nerd-font"
cask "font-inconsolata-nerd-font"
cask "font-intone-mono-nerd-font"
cask "font-iosevka-nerd-font"
cask "font-iosevka-term-nerd-font"
cask "font-iosevka-term-slab-nerd-font"
cask "font-jetbrains-mono-nerd-font"
cask "font-lekton-nerd-font"
cask "font-liberation-nerd-font"
cask "font-lilex-nerd-font"
cask "font-m+-nerd-font"
cask "font-martian-mono-nerd-font"
cask "font-meslo-lg-nerd-font"
cask "font-monaspice-nerd-font"
cask "font-monocraft-nerd-font"
cask "font-monofur-nerd-font"
cask "font-monoid-nerd-font"
cask "font-mononoki-nerd-font"
cask "font-noto-nerd-font"
cask "font-opendyslexic-nerd-font"
cask "font-overpass-nerd-font"
cask "font-profont-nerd-font"
cask "font-proggy-clean-tt-nerd-font"
cask "font-roboto-mono-nerd-font"
cask "font-sauce-code-pro-nerd-font"
cask "font-shure-tech-mono-nerd-font"
cask "font-space-mono-nerd-font"
cask "font-symbols-only-nerd-font"
cask "font-terminess-ttf-nerd-font"
cask "font-tinos-nerd-font"
cask "font-ubuntu-mono-nerd-font"
cask "font-ubuntu-nerd-font"
cask "font-victor-mono-nerd-font"
