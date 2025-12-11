#!/bin/bash
# =============================================================================
# Post-Start Script for Beanz Connect Development Environment
# This script runs EVERY TIME the codespace starts (including rebuilds)
# =============================================================================

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

PROJECT_DIR="/workspaces/beanz-connect"

echo ""
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║   🫘 Starting Beanz Connect Development Environment                    ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# Source nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Ensure correct Node version if .nvmrc exists
if [ -f "$PROJECT_DIR/.nvmrc" ]; then
    cd "$PROJECT_DIR"
    nvm use 2>/dev/null || log_warn "Could not switch Node version"
fi

# Source aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# Display status
echo ""
log_info "Environment Status:"
echo "  • Node.js: $(node --version 2>/dev/null || echo 'not available')"
echo "  • npm: $(npm --version 2>/dev/null || echo 'not available')"
echo "  • Git: $(git --version 2>/dev/null | cut -d' ' -f3 || echo 'not available')"
echo "  • Neovim: $(nvim --version 2>/dev/null | head -1 || echo 'not available')"
echo ""

# Check for .env files
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Environment File Status:"

    if [ -f "lambdas/.env" ]; then
        log_success "lambdas/.env exists"
    else
        log_warn "lambdas/.env missing - copy from .env.example and update values"
    fi

    if [ -f "client/.env" ]; then
        log_success "client/.env exists"
    else
        log_warn "client/.env missing - copy from .env.example and update values"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
log_success "Development environment ready!"
echo ""
echo "Quick tips:"
echo "  • Type 'beanz' to navigate to the project root"
echo "  • Type 'v' to open Neovim with LazyVim"
echo "  • Type 'y' to open Yazi file manager"
echo "  • Type 't' to start tmux"
echo ""
