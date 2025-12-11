#!/bin/bash
# =============================================================================
# Post-Create Script for Beanz Connect Development Environment
# This script runs ONCE when the codespace is first created
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${GREEN}▶ $1${NC}"; echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; }

# =============================================================================
# Configuration
# =============================================================================
REPO_NAME="beanz-connect"
REPO_URL="https://github.com/brevilledigital/beanz-connect.git"
WORKSPACE_DIR="/workspaces"
PROJECT_DIR="${WORKSPACE_DIR}/${REPO_NAME}"

# Branch to checkout (can be set via Codespace secret BEANZ_BRANCH or defaults to main)
# Users can also create codespace with: ?devcontainer_path=.devcontainer&ref=feature-branch
TARGET_BRANCH="${BEANZ_BRANCH:-main}"

# =============================================================================
# Start Setup
# =============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                        ║"
echo "║   🫘 Beanz Connect Development Environment Setup                       ║"
echo "║                                                                        ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# =============================================================================
# Step 1: Setup shell configurations
# =============================================================================
log_step "Step 1/7: Configuring shell environment"

# Copy custom zsh config if it exists
if [ -f "/workspaces/.devcontainer/config/.zshrc" ]; then
    cp /workspaces/.devcontainer/config/.zshrc ~/.zshrc
    log_success "Custom .zshrc installed"
else
    log_info "Using default Oh My Zsh configuration"
fi

# Copy custom tmux config if it exists
if [ -f "/workspaces/.devcontainer/config/.tmux.conf" ]; then
    cp /workspaces/.devcontainer/config/.tmux.conf ~/.tmux.conf
    log_success "Custom .tmux.conf installed"
fi

# Source nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

log_success "Shell environment configured"

# =============================================================================
# Step 2: Authenticate with GitHub
# =============================================================================
log_step "Step 2/7: Checking GitHub authentication"

if gh auth status &>/dev/null; then
    log_success "GitHub CLI already authenticated"
else
    log_warn "GitHub CLI not authenticated"
    log_info "Your Codespaces token should auto-authenticate. If not, run: gh auth login"
fi

# Install GitHub Copilot CLI extension
log_info "Installing GitHub Copilot CLI extension..."
gh extension install github/gh-copilot 2>/dev/null || log_info "Copilot extension already installed or unavailable"

# =============================================================================
# Step 3: Clone the repository
# =============================================================================
log_step "Step 3/7: Cloning beanz-connect repository"

if [ -d "$PROJECT_DIR" ]; then
    log_info "Repository already exists at $PROJECT_DIR"
    cd "$PROJECT_DIR"
    git fetch --all
    log_success "Repository updated"
else
    log_info "Cloning from $REPO_URL..."
    cd "$WORKSPACE_DIR"
    gh repo clone brevilledigital/beanz-connect || git clone "$REPO_URL"
    log_success "Repository cloned successfully"
fi

cd "$PROJECT_DIR"

# =============================================================================
# Step 3b: Checkout target branch
# =============================================================================
log_info "Target branch: $TARGET_BRANCH"

if [ "$TARGET_BRANCH" != "main" ] && [ "$TARGET_BRANCH" != "master" ]; then
    log_info "Checking out branch: $TARGET_BRANCH"

    # Check if branch exists remotely
    if git ls-remote --heads origin "$TARGET_BRANCH" | grep -q "$TARGET_BRANCH"; then
        git checkout "$TARGET_BRANCH" || git checkout -b "$TARGET_BRANCH" "origin/$TARGET_BRANCH"
        log_success "Switched to branch: $TARGET_BRANCH"
    else
        log_warn "Branch '$TARGET_BRANCH' not found on remote, staying on default branch"
    fi
else
    log_info "Using default branch: $(git branch --show-current)"
fi

# =============================================================================
# Step 4: Setup Node.js version from .nvmrc
# =============================================================================
log_step "Step 4/7: Configuring Node.js version"

if [ -f ".nvmrc" ]; then
    NODE_VERSION=$(cat .nvmrc | tr -d '\n' | tr -d 'v')
    log_info "Found .nvmrc specifying Node.js v${NODE_VERSION}"

    # Install the required version
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"

    log_success "Node.js v${NODE_VERSION} installed and set as default"
else
    log_warn "No .nvmrc found, using default Node.js version"
fi

log_info "Node.js version: $(node --version)"
log_info "npm version: $(npm --version)"

# =============================================================================
# Step 5: Install project dependencies
# =============================================================================
log_step "Step 5/7: Installing project dependencies"

# Root dependencies
log_info "Installing root dependencies..."
npm install
log_success "Root dependencies installed"

# Shared package
if [ -d "shared" ]; then
    log_info "Installing shared package dependencies..."
    cd shared
    npm install
    log_info "Building shared package..."
    npm run build
    cd ..
    log_success "Shared package ready"
else
    log_warn "shared/ directory not found, skipping"
fi

# Lambdas
if [ -d "lambdas" ]; then
    log_info "Installing lambdas dependencies..."
    cd lambdas
    npm install

    # Setup .env from example if it doesn't exist
    if [ ! -f ".env" ] && [ -f ".env.example" ]; then
        cp .env.example .env
        log_warn "Created lambdas/.env from .env.example - PLEASE UPDATE WITH REAL VALUES"
    elif [ ! -f ".env" ]; then
        log_warn "No .env or .env.example found in lambdas/"
        log_info "You may need to create lambdas/.env manually"
    fi

    cd ..
    log_success "Lambdas dependencies installed"
else
    log_warn "lambdas/ directory not found, skipping"
fi

# Client
if [ -d "client" ]; then
    log_info "Installing client dependencies..."
    cd client
    npm install

    # Setup .env from example if it doesn't exist
    if [ ! -f ".env" ] && [ -f ".env.example" ]; then
        cp .env.example .env
        log_warn "Created client/.env from .env.example - PLEASE UPDATE WITH REAL VALUES"
    elif [ ! -f ".env" ]; then
        log_warn "No .env or .env.example found in client/"
        log_info "You may need to create client/.env manually"
    fi

    cd ..
    log_success "Client dependencies installed"
else
    log_warn "client/ directory not found, skipping"
fi

# =============================================================================
# Step 6: Setup Neovim/LazyVim
# =============================================================================
log_step "Step 6/7: Configuring Neovim with LazyVim"

# Run nvim headless to install plugins
log_info "Installing LazyVim plugins (this may take a moment)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || log_warn "LazyVim plugin sync had some issues, you can run :Lazy sync manually"

log_success "LazyVim configured"

# =============================================================================
# Step 7: Final setup
# =============================================================================
log_step "Step 7/7: Final configuration"

# Install tmux plugins
log_info "Installing tmux plugins..."
if [ -f ~/.tmux/plugins/tpm/bin/install_plugins ]; then
    ~/.tmux/plugins/tpm/bin/install_plugins || log_warn "tmux plugin installation had issues"
fi

# Initialize zoxide database
log_info "Initializing zoxide..."
zoxide init zsh > /dev/null 2>&1 || true

# Create useful aliases file
cat > ~/.bash_aliases << 'EOF'
# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -alF'
alias la='ls -A'

# Git shortcuts
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'

# npm shortcuts
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'

# Project navigation
alias beanz='cd /workspaces/beanz-connect'
alias client='cd /workspaces/beanz-connect/client'
alias lambdas='cd /workspaces/beanz-connect/lambdas'
alias shared='cd /workspaces/beanz-connect/shared'

# Tools
alias vim='nvim'
alias v='nvim'
alias y='yazi'
alias t='tmux'
alias ta='tmux attach'

# Fuzzy finding
alias ff='fzf'
alias fv='nvim $(fzf)'
EOF

log_success "Aliases configured"

# =============================================================================
# Complete!
# =============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                        ║"
echo "║   ✅ Setup Complete!                                                   ║"
echo "║                                                                        ║"
echo "║   Quick commands:                                                      ║"
echo "║   • beanz    - Navigate to project root                                ║"
echo "║   • client   - Navigate to client/                                     ║"
echo "║   • lambdas  - Navigate to lambdas/                                    ║"
echo "║   • v        - Open Neovim (with LazyVim)                              ║"
echo "║   • y        - Open Yazi file manager                                  ║"
echo "║   • t        - Start tmux                                              ║"
echo "║                                                                        ║"
echo "║   ⚠️  Don't forget to update your .env files!                          ║"
echo "║                                                                        ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""
