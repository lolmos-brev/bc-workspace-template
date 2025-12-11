# Beanz Connect Development Environment

A standardized GitHub Codespaces development environment for the Breville Digital squad.

## Quick Start

1. **Create a Codespace** from this repository
2. Wait for the setup to complete (you'll see progress in the terminal)
3. Update your `.env` files (see [Environment Setup](#environment-setup))
4. Start coding!

## Working with Branches

### Option 1: Create Codespace for a Specific Branch (Recommended)

Use a deep link URL to create a Codespace that auto-checkouts a specific branch:

```
https://codespaces.new/brevilledigital/bc-workspace-template?devcontainer_path=.devcontainer%2Fdevcontainer.json&ref=YOUR_BRANCH_NAME
```

Replace `YOUR_BRANCH_NAME` with your target branch in beanz-connect (e.g., `feature/new-feature`).

**Example for feature branch:**
```
https://codespaces.new/brevilledigital/bc-workspace-template?ref=feature/login-page
```

### Option 2: Use a Codespace Secret

Set a personal or repo-level secret to always checkout a specific branch:

1. Go to GitHub → Settings → Codespaces → Secrets
2. Add a new secret:
   - **Name**: `BEANZ_BRANCH`
   - **Value**: Your branch name (e.g., `develop` or `feature/my-feature`)
3. Create a new Codespace - it will auto-checkout that branch

### Option 3: Switch Branch After Creation

Once inside the Codespace:

```bash
cd /workspaces/beanz-connect
git fetch --all
git checkout feature/your-branch
npm install  # If dependencies changed
```

### For PR Reviews

To review a specific PR, use the PR number:

```bash
gh pr checkout 123
```

## What's Included

### Core Tools

| Tool | Purpose | Command |
|------|---------|---------|
| **nvm** | Node.js version manager | `nvm use`, `nvm install` |
| **zsh + Oh My Zsh** | Modern shell with plugins | Default shell |
| **Neovim + LazyVim** | Modern Vim experience | `v` or `nvim` |
| **tmux** | Terminal multiplexer | `t` or `tmux` |
| **yazi** | Terminal file manager | `y` or `yazi` |
| **fzf** | Fuzzy finder | `ff`, `fv`, `Ctrl+R` |
| **zoxide** | Smart directory jumper | `z <directory>` |
| **ripgrep** | Fast code search | `rg <pattern>` |
| **fd** | Fast file finder | `fd <pattern>` |
| **gh** | GitHub CLI | `gh pr`, `gh issue` |
| **Claude Code** | AI coding assistant | `claude` |

### Media & Preview Tools

| Tool | Purpose |
|------|---------|
| ffmpeg | Video thumbnails |
| 7-Zip | Archive extraction |
| jq | JSON processing |
| poppler | PDF preview |
| resvg | SVG preview |
| ImageMagick | Image processing |

### VS Code Extensions

- **Git**: GitLens, Git Graph, Git Blame
- **AI**: GitHub Copilot, GitHub Copilot Chat
- **Code Quality**: Error Lens, ESLint, Prettier, Code Spell Checker
- **Productivity**: npm Intellisense, Auto Rename Tag, Tailwind CSS

## Quick Commands

### Navigation

```bash
beanz     # Go to project root
client    # Go to client/
lambdas   # Go to lambdas/
shared    # Go to shared/
```

### Development

```bash
nrd       # npm run dev
nrb       # npm run build
nrt       # npm run test
ni        # npm install
```

### Git

```bash
gs        # git status
gp        # git pull
gco       # git checkout
glog      # git log (pretty)
gacp "msg" # git add, commit, push (all in one)
```

### Tools

```bash
v         # Open Neovim (LazyVim)
y         # Open Yazi file manager
t         # Start tmux
ta        # Attach to existing tmux session
ff        # Fuzzy find files
fv        # Fuzzy find and open in nvim
rgs       # Search with ripgrep + preview
z <dir>   # Jump to recent directory
```

## Environment Setup

### Step 1: Copy Example Files

The setup script automatically copies `.env.example` files, but you need to fill in the values:

```bash
# Check if .env files exist
ls -la client/.env lambdas/.env

# If missing, copy from examples
cp /workspaces/env-examples/client.env.example client/.env
cp /workspaces/env-examples/lambdas.env.example lambdas/.env
```

### Step 2: Update Values

Edit each `.env` file and replace placeholder values:

```bash
v client/.env    # Edit client environment
v lambdas/.env   # Edit lambdas environment
```

### Getting Credentials

Contact your team lead for:
- AWS credentials
- API keys
- Database connection strings
- Third-party service keys

> **Security Note**: Never commit `.env` files. They are already in `.gitignore`.

## Tool Guides

### Neovim (LazyVim)

LazyVim is a modern Neovim configuration with sensible defaults.

**Basic Navigation:**
- `<Space>` - Leader key (opens command menu)
- `<Space>ff` - Find files
- `<Space>fg` - Live grep (search in files)
- `<Space>e` - File explorer
- `<Space>gg` - Open LazyGit

**Learning Resources:**
- [LazyVim Documentation](https://www.lazyvim.org/)
- Run `:Tutor` in Neovim for a built-in tutorial

### tmux

tmux lets you create multiple terminal sessions.

**Basic Commands (prefix is `Ctrl+a`):**
- `Ctrl+a |` - Split pane vertically
- `Ctrl+a -` - Split pane horizontally
- `Ctrl+a h/j/k/l` - Navigate panes
- `Ctrl+a c` - New window
- `Ctrl+a ,` - Rename window
- `Ctrl+a d` - Detach (keeps session running)

**Session Management:**
```bash
t           # Start new session
ta          # Attach to existing session
tls         # List sessions
tks         # Kill session
```

### Yazi

Yazi is a blazing fast terminal file manager.

**Basic Navigation:**
- `h/j/k/l` or Arrow keys - Navigate
- `Enter` - Open file/directory
- `q` - Quit
- `Space` - Select file
- `d` - Delete
- `y` - Copy (yank)
- `p` - Paste
- `/` - Search

### fzf + zoxide

**Fuzzy Finding:**
```bash
ff              # Find files
fv              # Find and open in nvim
fcd             # Find directory and cd
Ctrl+R          # Search command history
Ctrl+T          # Find file in terminal
Alt+C           # cd to directory
```

**Smart Directory Jumping:**
```bash
z project       # Jump to most frecent "project" directory
z client        # Jump to client/
zi              # Interactive directory selection
```

## Customization

### Adding Your Dotfiles

If you have personal dotfiles you want to use:

1. Fork this repo or create a personal dotfiles repo
2. After codespace creation, clone your dotfiles
3. Use [stow](https://www.gnu.org/software/stow/) to manage symlinks:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh    # Symlinks zsh config
stow nvim   # Symlinks nvim config
```

### Team Dotfiles (Future)

> **TODO**: A shared team dotfiles repository will be available at `brevilledigital/team-dotfiles`

### Adding tmux Plugins

Edit `~/.tmux.conf` and add plugins:

```bash
# Add to plugin list
set -g @plugin 'plugin-author/plugin-name'
```

Then press `Ctrl+a I` to install.

## Troubleshooting

### Node version wrong

```bash
# Check current version
node --version

# Read .nvmrc and switch
nvm use

# If version not installed
nvm install
```

### GitHub CLI not authenticated

```bash
# Check status
gh auth status

# Login (usually automatic in Codespaces)
gh auth login
```

### tmux plugins not installing

```bash
# Manually trigger TPM install
~/.tmux/plugins/tpm/bin/install_plugins
```

### LazyVim plugins failing

```bash
# Open nvim and run
:Lazy sync
```

### Container build failed

1. Check Dockerfile syntax
2. Review build logs in Codespaces
3. Try rebuilding: Command Palette → "Codespaces: Rebuild Container"

## Contributing

1. Test changes locally using VS Code Dev Containers
2. Create a feature branch
3. Submit a PR with description of changes
4. Get review from team lead

## Resources

- [GitHub Codespaces Docs](https://docs.github.com/en/codespaces)
- [Dev Container Spec](https://containers.dev/)
- [LazyVim](https://www.lazyvim.org/)
- [Oh My Zsh](https://ohmyz.sh/)
- [tmux Cheat Sheet](https://tmuxcheatsheet.com/)
