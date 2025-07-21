# 🚀 Modular Terminal Setup 2025+

> A flexible, reversible dotfiles system that grows with you.

## 🎯 Philosophy

This dotfiles system is built around **modularity** and **reversibility**:

- **Start Simple**: Install just the core tools you need
- **Add Gradually**: Enable modules as you need them
- **Easy Removal**: Uninstall modules without breaking your system
- **No Lock-in**: Always know what's installed and be able to undo it

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install core module (essential tools)
./dotfiles.sh install core

# Or choose modules interactively
./dotfiles.sh install
```

## 🏗️ Modular Architecture

```
~/.dotfiles/
├── dotfiles.sh             # Main CLI interface
├── core/                   # Essential terminal setup
│   ├── shell/             # Zsh + Starship
│   ├── editor/            # Neovim (LazyVim)
│   ├── terminal/          # WezTerm
│   ├── multiplexer/       # Zellij + tmux
│   ├── modern-cli/        # bat, eza, fd, ripgrep, etc.
│   └── git/               # Git with delta
├── modules/               # Optional add-ons
│   ├── devbox/           # Reproducible environments
│   ├── ai/               # AI-powered development
│   ├── languages/        # Language-specific tools
│   ├── cloud/            # Cloud CLI tools
│   └── security/         # Security tools
├── state/                 # Tracking & backups
│   ├── manifest.json     # What's installed
│   ├── symlinks.json     # Symlink tracking
│   └── backups/          # Automatic backups
└── scripts/               # Utilities
    └── utils.sh          # Common functions
```

## 📦 Available Modules

### Core Module (Essential)
- **Zsh** with Zinit plugin manager
- **Starship** prompt with git integration
- **Neovim** with LazyVim distribution
- **WezTerm** GPU-accelerated terminal
- **Zellij** modern terminal multiplexer
- **Modern CLI tools**: eza, bat, fd, ripgrep, delta, zoxide, atuin

### DevBox Module (Reproducible Environments)
- **Devbox** for isolated development environments
- **Direnv** for automatic environment switching
- **Just** for task automation
- **Mise** for polyglot version management

### AI Module (AI-Powered Development)
- **Shell-GPT** for command line AI assistance
- **Aider** for AI pair programming
- **Ollama** for local AI models
- **GitHub Copilot CLI** integration

## 🛠️ Usage

### Installing Modules

```bash
# Interactive installation
./dotfiles.sh install

# Install specific modules
./dotfiles.sh install core
./dotfiles.sh install core,devbox
./dotfiles.sh install all

# List available modules
./dotfiles.sh list
```

### Managing Your Setup

```bash
# Create a backup before making changes
./dotfiles.sh backup

# Update all installed modules
./dotfiles.sh update

# Remove a module
./dotfiles.sh uninstall devbox

# Health check
./dotfiles.sh doctor

# Restore from backup
./dotfiles.sh restore
```

### Backup and Restore

The system automatically creates backups before any changes:

```bash
# Manual backup with custom name
./dotfiles.sh backup pre-experiment

# List available backups
./dotfiles.sh restore

# Restore specific backup
./dotfiles.sh restore 20240115-143022-pre-experiment
```

## 🎨 Design Principles

### 1. **Always Reversible**
- Every operation can be undone
- Automatic backups before changes
- Original files are preserved
- Symlinks can be safely removed

### 2. **State Tracking**
- `state/manifest.json` tracks installed modules
- `state/symlinks.json` tracks all created symlinks
- `state/backups/` contains timestamped snapshots

### 3. **Modular by Design**
- Each module is self-contained
- Dependencies are clearly defined
- Modules can be mixed and matched

### 4. **Safe by Default**
- Backups created automatically
- Confirmation prompts for destructive operations
- Non-destructive installation process

## 🔧 Core Module Details

The core module provides a solid foundation with modern alternatives to standard Unix tools:

| Traditional | Modern Alternative | Description |
|-------------|-------------------|-------------|
| `ls` | `eza` | Better file listing with git integration |
| `cat` | `bat` | Syntax highlighting and line numbers |
| `find` | `fd` | Fast and user-friendly file finder |
| `grep` | `ripgrep` | Extremely fast text search |
| `cd` | `zoxide` | Smart directory jumping |
| `history` | `atuin` | SQLite-backed shell history |
| `diff` | `delta` | Beautiful git diffs |

## 🎯 Getting Started Guide

### 1. Install Prerequisites

```bash
# macOS
brew install git curl wget jq

# Fedora  
sudo dnf install git curl wget jq

# Ubuntu/Debian
sudo apt update && sudo apt install git curl wget jq
```

### 2. Clone and Install

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Start with just the essentials
./dotfiles.sh install core
```

### 3. Restart Your Shell

```bash
# Start a new shell session or
source ~/.zshrc
```

### 4. Add Modules Gradually

```bash
# Add reproducible development environments
./dotfiles.sh install devbox

# Add AI assistance
./dotfiles.sh install ai
```

## 🔍 Module Deep Dive

### DevBox Module

Perfect for developers who work on multiple projects:

```bash
# Create isolated environment for a project
cd my-project
devbox init
devbox add nodejs@18 python@3.11 go@1.21

# Environment automatically activates when you enter the directory
cd my-project  # Tools become available automatically
```

### AI Module

Bring AI assistance to your terminal:

```bash
# Get command suggestions
ai "how to find large files"

# AI-powered commit messages
git add .
aicommit

# Code review assistance
review myfile.py

# AI pair programming
aider  # Start AI pair programming session
```

## 🚨 Safety Features

### Automatic Backups
Every operation creates a backup:
- Before installing modules
- Before uninstalling modules
- Before major configuration changes

### Health Monitoring
```bash
./dotfiles.sh doctor
```
Checks for:
- Missing dependencies
- Broken symlinks
- Configuration conflicts
- System health

### Easy Recovery
```bash
# See what you can restore to
./dotfiles.sh restore

# Go back to any previous state
./dotfiles.sh restore 20240115-morning-backup
```

## 🎛️ Customization

### Local Overrides
Each tool supports local customization:
- `~/.zshrc.local` - Shell customizations
- `~/.config/nvim/lua/config/local.lua` - Neovim overrides
- `~/.config/wezterm/local.lua` - WezTerm overrides

### Module Development
Want to create your own module? Each module needs:
- `module.json` - Metadata and dependencies
- `install.sh` - Installation script
- `uninstall.sh` - Removal script
- Configuration files in subdirectories

## 🆘 Troubleshooting

### Common Issues

**Module won't install:**
```bash
./dotfiles.sh doctor  # Check system health
./dotfiles.sh backup  # Create backup first
```

**Want to start over:**
```bash
./dotfiles.sh restore  # Choose an earlier backup
# Or manually remove ~/.dotfiles and re-clone
```

**Symlinks broken:**
```bash
./dotfiles.sh doctor  # Identifies broken links
./dotfiles.sh restore # Restore to working state
```

### Getting Help

1. Run `./dotfiles.sh doctor` to check system health
2. Check logs in `state/logs/`
3. Review your backups with `./dotfiles.sh restore`
4. Open an issue with system info and error logs

## 📝 Contributing

This dotfiles system is designed to be:
- **Forkable** - Clone and modify for your needs
- **Modular** - Add your own modules easily
- **Safe** - Won't break existing setups

See `CONTRIBUTING.md` for module development guidelines.

---

## Quick Commands Reference

```bash
# Installation
./dotfiles.sh install           # Interactive
./dotfiles.sh install core      # Core only
./dotfiles.sh install core,ai   # Multiple modules

# Management  
./dotfiles.sh list             # Show status
./dotfiles.sh update           # Update all
./dotfiles.sh doctor           # Health check

# Safety
./dotfiles.sh backup           # Create backup
./dotfiles.sh restore          # Restore backup
./dotfiles.sh uninstall ai     # Remove module
```

**Remember**: This system is designed to be safe, reversible, and modular. Start small, add gradually, and always backup before experimenting.