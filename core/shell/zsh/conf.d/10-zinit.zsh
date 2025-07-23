#!/usr/bin/env zsh
# 10-zinit.zsh - Zinit plugin manager setup

# Zinit installation directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Install Zinit if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing %F{33}ZINIT%F{220} Plugin Manager...%f"
  command mkdir -p "$(dirname $ZINIT_HOME)"
  command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load essential plugins (no external downloads needed)
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

# History substring search
# Load the plugin and define the widgets
zinit ice wait lucid atload'
  zle -N history-substring-search-up
  zle -N history-substring-search-down
  bindkey "^[[A" history-substring-search-up
  bindkey "^[[B" history-substring-search-down
  bindkey "^P" history-substring-search-up
  bindkey "^N" history-substring-search-down'
zinit light zsh-users/zsh-history-substring-search

# Load Oh My Zsh libraries (without the bloat)
zinit snippet OMZL::history.zsh
zinit snippet OMZL::completion.zsh
zinit snippet OMZL::key-bindings.zsh

# Useful Oh My Zsh plugins (cherry-picked)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found