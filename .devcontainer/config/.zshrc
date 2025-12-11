# =============================================================================
# Beanz Connect Team Zsh Configuration
# =============================================================================

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme - using a simple, fast theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    npm
    node
    fzf
    z
)

source $ZSH/oh-my-zsh.sh

# =============================================================================
# Environment Variables
# =============================================================================

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Editor
export EDITOR='nvim'
export VISUAL='code'

# History
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# =============================================================================
# Aliases
# =============================================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git shortcuts
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate -10'
alias gaa='git add -A'

# npm shortcuts
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrs='npm run start'

# Project navigation
alias beanz='cd /workspaces/beanz-connect'
alias client='cd /workspaces/beanz-connect/client'
alias lambdas='cd /workspaces/beanz-connect/lambdas'
alias shared='cd /workspaces/beanz-connect/shared'

# Tools
alias vim='nvim'
alias v='nvim'
alias vi='nvim'
alias y='yazi'
alias t='tmux'
alias ta='tmux attach'
alias tls='tmux list-sessions'
alias tks='tmux kill-session'

# Fuzzy finding with fzf
alias ff='fzf'
alias fv='nvim $(fzf)'
alias fcd='cd $(find . -type d | fzf)'

# Misc
alias c='clear'
alias h='history'
alias reload='source ~/.zshrc'

# =============================================================================
# Functions
# =============================================================================

# Create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find and edit
fe() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always {}' --preview-window=right:60%)
    [ -n "$file" ] && nvim "$file"
}

# Git commit with message
gcm() {
    git commit -m "$*"
}

# Quick git add, commit, push
gacp() {
    git add -A
    git commit -m "$*"
    git push
}

# Search in files with ripgrep and preview
rgs() {
    rg --color=always --line-number --no-heading --smart-case "${*:-}" |
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            --bind 'enter:become(nvim {1} +{2})'
}

# =============================================================================
# Tool Initialization
# =============================================================================

# Initialize zoxide (smarter cd)
eval "$(zoxide init zsh)"

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Source fzf keybindings if available
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# =============================================================================
# Auto-switch Node version when entering directory with .nvmrc
# =============================================================================
autoload -U add-zsh-hook
load-nvmrc() {
    local nvmrc_path
    nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
        local nvmrc_node_version
        nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

        if [ "$nvmrc_node_version" = "N/A" ]; then
            nvm install
        elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
            nvm use
        fi
    elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
        echo "Reverting to nvm default version"
        nvm use default
    fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# =============================================================================
# Welcome message
# =============================================================================
echo ""
echo "🫘 Beanz Connect Dev Environment"
echo "   Type 'beanz' to go to the project"
echo ""
