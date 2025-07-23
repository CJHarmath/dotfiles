#!/usr/bin/env zsh
# Modular Zsh Configuration
# This file sources drop-in configurations from ~/.config/zsh/conf.d/

# Enable Powerlevel10k instant prompt (if using p10k instead of starship)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configuration directory
ZDOTDIR="${ZDOTDIR:-$HOME}"
ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
ZSH_CONF_DIR="$ZSH_CONFIG_DIR/conf.d"

# Create config directory if it doesn't exist
mkdir -p "$ZSH_CONF_DIR"

# Source all drop-in configurations in order
# Files are sourced in alphabetical order, so use prefixes like:
# 00-init.zsh, 10-env.zsh, 20-aliases.zsh, etc.
if [[ -d "$ZSH_CONF_DIR" ]]; then
  for conf in "$ZSH_CONF_DIR"/*.zsh(N); do
    source "$conf"
  done
fi

# Source local overrides if they exist
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Source module-specific configurations
# These are added by modules when installed
if [[ -d "$ZSH_CONFIG_DIR/modules" ]]; then
  for module_conf in "$ZSH_CONFIG_DIR/modules"/*.zsh(N); do
    source "$module_conf"
  done
fi

# CJ custom
alias keychain='security unlock-keychain ~/Library/Keychains/login.keychain-db'
