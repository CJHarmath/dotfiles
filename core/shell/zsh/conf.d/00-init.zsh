#!/usr/bin/env zsh
# 00-init.zsh - Core Zsh initialization

# Basic Zsh options
setopt AUTO_CD                # cd into directory by typing its name
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell
setopt HIST_IGNORE_DUPS      # Don't record duplicate commands
setopt HIST_IGNORE_SPACE     # Don't record commands starting with space
setopt HIST_REDUCE_BLANKS    # Remove extra blanks from commands
setopt SHARE_HISTORY         # Share history between sessions
setopt EXTENDED_HISTORY      # Save timestamp in history
setopt INC_APPEND_HISTORY    # Add commands immediately to history
setopt HIST_EXPIRE_DUPS_FIRST # Remove duplicates first when trimming
setopt HIST_FIND_NO_DUPS     # Don't display duplicates when searching

# History configuration
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000

# Enable zmv for batch renaming
autoload -U zmv

# Enable colors
autoload -U colors && colors

# Better word splitting (like bash)
setopt SH_WORD_SPLIT

# Completion system initialization (before zinit)
autoload -Uz compinit
# Only check for insecure directories once a day
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
  compinit -C
else
  compinit
fi