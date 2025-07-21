#!/usr/bin/env zsh
# 40-functions.zsh - Useful shell functions

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.tar.xz) tar xJf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.rar) unrar e "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.tbz2) tar xjf "$1" ;;
      *.tgz) tar xzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find process by name
psgrep() {
  if [[ -n "$1" ]]; then
    ps aux | grep -v grep | grep -i "$1"
  else
    echo "Usage: psgrep <process_name>"
  fi
}

# Kill process by name
pskill() {
  if [[ -n "$1" ]]; then
    local pid=$(ps aux | grep -v grep | grep -i "$1" | awk '{print $2}')
    if [[ -n "$pid" ]]; then
      echo "Killing process: $1 (PID: $pid)"
      kill $pid
    else
      echo "No process found matching: $1"
    fi
  else
    echo "Usage: pskill <process_name>"
  fi
}

# Quick backup of a file
backup() {
  if [[ -f "$1" ]]; then
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backup created: $1.backup.$(date +%Y%m%d_%H%M%S)"
  else
    echo "File not found: $1"
  fi
}

# Git worktree helper
gwt() {
  local cmd=$1
  shift
  
  case "$cmd" in
    new)
      if [[ -z "$1" ]]; then
        echo "Usage: gwt new <branch-name>"
        return 1
      fi
      local branch=$1
      local path="../${PWD##*/}-$branch"
      git worktree add "$path" -b "$branch"
      cd "$path"
      ;;
    list)
      git worktree list
      ;;
    remove)
      if [[ -z "$1" ]]; then
        echo "Usage: gwt remove <branch-name>"
        return 1
      fi
      git worktree remove "$1"
      ;;
    *)
      echo "Usage: gwt {new|list|remove} [args]"
      ;;
  esac
}

# Quick HTTP server with directory listing
serve() {
  local port="${1:-8000}"
  if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server "$port"
  elif command -v python >/dev/null 2>&1; then
    python -m SimpleHTTPServer "$port"
  else
    echo "Python not found"
  fi
}

# Weather in terminal
weather() {
  local location="${1:-}"
  curl -s "https://wttr.in/${location}?format=3"
}

# Cheat sheet
cheat() {
  if [[ -z "$1" ]]; then
    echo "Usage: cheat <command>"
    return 1
  fi
  curl -s "https://cheat.sh/$1"
}

# Quick calculator
calc() {
  echo "$*" | bc -l
}

# Show directory sizes
dsize() {
  du -sh "${1:-.}"/* | sort -h
}