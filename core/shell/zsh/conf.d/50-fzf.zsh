#!/usr/bin/env zsh
# 50-fzf.zsh - FZF configuration

# Only configure if fzf is installed
if command -v fzf >/dev/null 2>&1; then
  
  # FZF default options
  export FZF_DEFAULT_OPTS="
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    --prompt='∼ ' --pointer='▶' --marker='✓'
    --layout=reverse --border=rounded --height=80%
    --preview-window=:hidden
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-u:preview-half-page-up'
    --bind='ctrl-d:preview-half-page-down'
  "
  
  # Use fd for file searching if available
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
  fi
  
  # Preview options
  if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
  fi
  
  if command -v eza >/dev/null 2>&1; then
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
  fi
  
  # Load fzf key bindings and completion
  # Try multiple possible locations
  local fzf_locations=(
    "/opt/homebrew/opt/fzf/shell"
    "/usr/local/opt/fzf/shell"
    "/usr/share/fzf"
    "$HOME/.fzf"
    "${XDG_DATA_HOME:-$HOME/.local/share}/fzf"
  )
  
  for location in $fzf_locations; do
    if [[ -f "$location/key-bindings.zsh" ]]; then
      source "$location/key-bindings.zsh"
      [[ -f "$location/completion.zsh" ]] && source "$location/completion.zsh"
      break
    fi
  done
  
  # Custom FZF functions
  
  # Fuzzy find and cd
  fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf +m) && cd "$dir"
  }
  
  # Fuzzy find and open in editor
  fe() {
    local file
    file=$(fzf --preview 'bat -n --color=always {}') && ${EDITOR:-nvim} "$file"
  }
  
  # Fuzzy find in history
  fh() {
    local cmd
    cmd=$(history -n 1 | fzf --tac +s --tiebreak=index --query="$1") && zle reset-prompt && LBUFFER="$cmd"
  }
  
  # Git branch switcher
  fbr() {
    local branches branch
    branches=$(git branch -a | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  }
  
fi