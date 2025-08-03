#!/usr/bin/env zsh
# 30-aliases.zsh - Command aliases

# Safety first
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Editor shortcuts
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Modern replacements (only if installed)
command -v eza >/dev/null 2>&1 && {
  alias ls='eza --group-directories-first'
  alias ll='eza -l --group-directories-first'
  alias la='eza -la --group-directories-first'
  alias lt='eza --tree --level=2'
  alias tree='eza --tree'
}

command -v bat >/dev/null 2>&1 && {
  alias cat='bat -pp'
  alias less='bat'
}

command -v fd >/dev/null 2>&1 && {
  alias find='fd'
}

command -v rg >/dev/null 2>&1 && {
  alias grep='rg'
}

command -v zoxide >/dev/null 2>&1 && {
  alias zq='zoxide query -i'  # Interactive directory search
}

# Git shortcuts
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate'
alias gs='git status --short --branch'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Utility aliases
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias ports='netstat -tulanp'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# System-specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias brewup='brew update && brew upgrade && brew cleanup'
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
elif [[ -f /etc/fedora-release ]]; then
  alias dnfup='sudo dnf update -y'
fi

# Development aliases
alias serve='python3 -m http.server'
alias json='python3 -m json.tool'
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))"'
alias urldecode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))"'

# Docker aliases (if docker is installed)
command -v docker >/dev/null 2>&1 && {
  alias d='docker'
  alias dc='docker-compose'
  alias dps='docker ps'
  alias dpsa='docker ps -a'
  alias dimg='docker images'
  alias dex='docker exec -it'
}

# Reload shell configuration
alias reload='source ~/.zshrc'
alias zshconfig='${EDITOR:-nvim} ~/.zshrc'