# Breville Beanz Connect Development Container
# Base image: Ubuntu with common dev tools
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

LABEL maintainer="Breville Digital Squad"
LABEL description="Development environment for beanz-connect monorepo"

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ============================================
# System packages
# ============================================
RUN apt-get update && apt-get install -y \
    # Core utilities
    curl \
    wget \
    git \
    unzip \
    zip \
    build-essential \
    software-properties-common \
    locales \
    # Required tools from your list
    ffmpeg \
    p7zip-full \
    p7zip-rar \
    jq \
    poppler-utils \
    fd-find \
    ripgrep \
    xclip \
    xsel \
    # ImageMagick (for Font, HEIC, JPEG XL preview)
    imagemagick \
    # For building some tools from source
    cmake \
    pkg-config \
    libssl-dev \
    # tmux
    tmux \
    # Python (needed for some tools)
    python3 \
    python3-pip \
    # Fonts support
    fontconfig \
    # zsh
    zsh \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for fd (Ubuntu names it fdfind)
RUN ln -sf $(which fdfind) /usr/local/bin/fd

# ============================================
# Install Rust (needed for some tools)
# ============================================
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# ============================================
# Install resvg (SVG preview)
# ============================================
RUN cargo install resvg

# ============================================
# Install fzf (>= 0.53.0)
# ============================================
RUN FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | jq -r .tag_name | sed 's/v//') \
    && curl -fLo /tmp/fzf.tar.gz "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz" \
    && tar -xzf /tmp/fzf.tar.gz -C /usr/local/bin \
    && rm /tmp/fzf.tar.gz

# ============================================
# Install zoxide (directory navigation)
# ============================================
RUN curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# ============================================
# Install yazi (terminal file manager)
# ============================================
RUN YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | jq -r .tag_name) \
    && curl -fLo /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip" \
    && unzip /tmp/yazi.zip -d /tmp/yazi \
    && mv /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/ \
    && mv /tmp/yazi/yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin/ \
    && rm -rf /tmp/yazi /tmp/yazi.zip

# ============================================
# Install Neovim (latest stable)
# Note: Asset name changed to nvim-linux-x86_64.tar.gz in recent releases
# ============================================
RUN curl -fLo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
    && tar -xzf /tmp/nvim.tar.gz -C /opt \
    && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

# ============================================
# Install GitHub CLI
# ============================================
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Install Nerd Fonts (JetBrainsMono recommended)
# ============================================
RUN mkdir -p /usr/share/fonts/nerd-fonts \
    && curl -fLo /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
    && unzip /tmp/JetBrainsMono.zip -d /usr/share/fonts/nerd-fonts \
    && fc-cache -fv \
    && rm /tmp/JetBrainsMono.zip

# ============================================
# Switch to vscode user for remaining setup
# ============================================
USER vscode
WORKDIR /home/vscode

# ============================================
# Install nvm and Node.js
# ============================================
ENV NVM_DIR="/home/vscode/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install 20.19.2 \
    && nvm alias default 20.19.2 \
    && nvm use default

# ============================================
# Install Oh My Zsh
# Using RUNZSH=no and CHSH=no to prevent interactive prompts
# ============================================
RUN RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true

# ============================================
# Install zsh plugins
# ============================================
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# ============================================
# Install TPM (Tmux Plugin Manager)
# ============================================
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# ============================================
# Install LazyVim
# ============================================
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim \
    && rm -rf ~/.config/nvim/.git

# ============================================
# Copy Rust binaries to vscode user path
# ============================================
USER root
RUN cp /root/.cargo/bin/* /usr/local/bin/ 2>/dev/null || true

USER vscode

# Set zsh as default shell
ENV SHELL=/bin/zsh

# Set PATH for nvm
ENV PATH="/home/vscode/.nvm/versions/node/v20.19.2/bin:${PATH}"
