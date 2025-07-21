#!/usr/bin/env zsh
# 20-env.zsh - Environment variables

# Editor
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"

# Pager
export PAGER="less"
export LESS="-R"

# Use bat for man pages if available
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export BAT_THEME="Catppuccin-mocha"
fi

# Language
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# XDG Base Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Path additions
typeset -U path  # Remove duplicates
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "/usr/local/bin"
  $path
)

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Homebrew
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Go
export GOPATH="${GOPATH:-$HOME/go}"
[[ -d "$GOPATH/bin" ]] && path+=("$GOPATH/bin")

# Node
export NODE_REPL_HISTORY="${XDG_DATA_HOME}/node_repl_history"

# Python
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc"
export PYTHONDONTWRITEBYTECODE=1