#!/usr/bin/env zsh
# 70-keybindings.zsh - Key bindings configuration

# Use emacs key bindings by default
bindkey -e

# But add some vim-style bindings for convenience
# Ctrl+W to delete word (vim style)
bindkey '^W' backward-kill-word

# Better history search
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# Beginning/end of line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Alt+Left/Right to move by word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word

# Home/End keys
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Delete key
bindkey '^[[3~' delete-char

# Ctrl+R for history search (if fzf not available)
if ! command -v fzf >/dev/null 2>&1; then
  bindkey '^R' history-incremental-search-backward
fi

# Edit command line in editor with Ctrl+X Ctrl+E
autoload -z edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Quick sudo (Alt+S)
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N sudo-command-line
bindkey '^[s' sudo-command-line