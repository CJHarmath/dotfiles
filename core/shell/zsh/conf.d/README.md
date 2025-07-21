# Zsh Configuration Drop-ins

This directory contains modular Zsh configuration files that are automatically sourced by the main `.zshrc`.

## File Naming Convention

Files are sourced in alphabetical order, so use numeric prefixes to control load order:

- `00-09` - Core initialization (options, history, etc.)
- `10-19` - Plugin managers and frameworks
- `20-29` - Environment variables
- `30-39` - Aliases
- `40-49` - Functions
- `50-59` - Tool-specific configurations
- `60-69` - Tool integrations (must be loaded after tools are in PATH)
- `70-79` - Key bindings
- `80-89` - Module-specific configs (added by modules)
- `90-99` - Final configurations (completions, etc.)

## Current Files

- `00-init.zsh` - Core Zsh options and initialization
- `10-zinit.zsh` - Zinit plugin manager setup
- `20-env.zsh` - Environment variables
- `30-aliases.zsh` - Command aliases
- `40-functions.zsh` - Utility functions
- `50-fzf.zsh` - FZF configuration
- `60-tools.zsh` - Tool integrations (starship, zoxide, atuin, etc.)
- `70-keybindings.zsh` - Custom key bindings
- `99-completion.zsh` - Completion system configuration

## Adding Custom Configurations

To add your own configurations:

1. Create a new file with appropriate numeric prefix
2. Make it executable: `chmod +x my-config.zsh`
3. It will be automatically sourced on next shell start

## Module Integration

Modules can add their own configuration files to `~/.config/zsh/modules/` which are sourced after all conf.d files.

## Local Overrides

For machine-specific configurations, use `~/.zshrc.local` which is sourced at the very end.