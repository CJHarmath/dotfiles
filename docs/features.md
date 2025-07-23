# Dotfiles Features Documentation

This document provides a comprehensive walkthrough of all features configured in these dotfiles.

## Table of Contents

- [ZSH Configuration](#zsh-configuration)
  - [Plugin Management (Zinit)](#plugin-management-zinit)
  - [Custom Functions](#custom-functions)
  - [Aliases](#aliases)
  - [Key Bindings](#key-bindings)
  - [Tools Integration](#tools-integration)
- [Troubleshooting](#troubleshooting)

## ZSH Configuration

The ZSH configuration is modular and organized in `~/.config/zsh/conf.d/` with numbered files that load in order:

### Configuration Files Overview

- **00-init.zsh** - Initial setup and core configuration
- **10-zinit.zsh** - Plugin manager and plugin configuration
- **20-env.zsh** - Environment variables
- **30-aliases.zsh** - Command aliases
- **40-functions.zsh** - Custom shell functions
- **50-fzf.zsh** - Fuzzy finder integration
- **60-tools.zsh** - External tools configuration
- **70-keybindings.zsh** - Custom key bindings
- **99-completion.zsh** - Shell completion settings

### Plugin Management (Zinit)

We use [Zinit](https://github.com/zdharma-continuum/zinit) as the plugin manager for its speed and flexibility.

#### Installed Plugins

1. **fast-syntax-highlighting** - Provides syntax highlighting in the command line
2. **zsh-autosuggestions** - Shows command suggestions based on history
3. **zsh-completions** - Additional completion definitions
4. **zsh-history-substring-search** - Search history with partial strings
   - Use `↑`/`↓` arrows or `Ctrl+P`/`Ctrl+N` to search

#### Oh My Zsh Components

Selected OMZ components are loaded without the full framework:
- Git plugin (provides git aliases)
- Sudo plugin (press `Alt+S` to prepend sudo)
- Command-not-found plugin

### Custom Functions

Located in `40-functions.zsh`:

#### `gwt` - Git Worktree Helper
Enhanced git worktree management:
```bash
gwt new <branch>  # Create new worktree with branch
gwt list          # List all worktrees
gwt remove <path> # Remove a worktree
```

#### `serve` - Quick HTTP Server
Start a Python HTTP server in the current directory:
```bash
serve        # Starts on port 8000
serve 3000   # Starts on port 3000
```

#### `mkcd` - Make Directory and Enter
Create a directory and immediately cd into it:
```bash
mkcd new-project
```

#### `extract` - Universal Archive Extractor
Extract any archive format:
```bash
extract archive.tar.gz
extract file.zip
```

#### `backup` - Quick File Backup
Create timestamped backups:
```bash
backup important-file.conf
# Creates: important-file.conf.backup.20250723_184530
```

### Aliases

Common aliases configured in `30-aliases.zsh`:

#### Navigation
- `..` - Go up one directory
- `...` - Go up two directories
- `....` - Go up three directories
- `ll` - Detailed list with human-readable sizes
- `la` - List all including hidden files
- `lt` - Sort by modification time

#### Safety Aliases
- `cp`, `mv`, `rm` - Interactive mode by default
- `rmf` - Force remove (use with caution)

#### Git Aliases (via OMZ git plugin)
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git pull
- `gst` - git status
- `gco` - git checkout
- `gcb` - git checkout -b

### Key Bindings

Custom key bindings in `70-keybindings.zsh`:

#### Text Editing
- `Ctrl+A` - Beginning of line
- `Ctrl+E` - End of line
- `Ctrl+W` - Delete word backward
- `Alt+←/→` - Move by word

#### History
- `↑/↓` - History substring search
- `Ctrl+P/N` - Alternative history search
- `Ctrl+R` - Reverse history search (if fzf not available)

#### Special Functions
- `Alt+S` - Prepend sudo to command
- `Ctrl+X Ctrl+E` - Edit command in your editor

### Tools Integration

#### FZF (Fuzzy Finder)
If installed, provides enhanced search capabilities:
- `Ctrl+R` - Fuzzy history search
- `Ctrl+T` - Fuzzy file search
- `Alt+C` - Fuzzy directory change

#### Starship Prompt
Modern, customizable prompt with git integration and performance metrics.

## Troubleshooting

### Common Issues and Fixes

#### "defining function based on alias" Error
**Problem**: Function name conflicts with an existing alias
**Solution**: Already fixed by adding `unalias <name>` before function definitions

#### "unhandled ZLE widget" Error
**Problem**: Key bindings defined before widgets are loaded
**Solution**: Already fixed by defining widgets in the plugin's atload hook

#### Slow Shell Startup
**Problem**: Too many synchronous plugin loads
**Solution**: Zinit uses lazy loading (`wait` ice) for most plugins

#### Missing Commands
**Problem**: Tools like fzf or starship not installed
**Solution**: The configuration gracefully degrades - install tools as needed

### Performance Tips

1. **Lazy Loading**: Most plugins load asynchronously after prompt appears
2. **Compilation**: Zinit automatically compiles scripts for faster loading
3. **Minimal OMZ**: Only essential OMZ components are loaded

### Customization

To add your own customizations:

1. Create a new file in `~/.config/zsh/conf.d/` with appropriate number prefix
2. Or use `~/.zshrc.local` for machine-specific settings
3. Module-specific configs go in `~/.config/zsh/modules/`

### Debug Mode

To debug loading issues:
```bash
# Start zsh with verbose output
zsh -xv

# Or trace specific files
source ~/.config/zsh/conf.d/10-zinit.zsh
```