# Claude Code Devcontainer
# Based on Microsoft devcontainer image for better devcontainer integration
FROM ghcr.io/astral-sh/uv:0.10@sha256:10902f58a1606787602f303954cea099626a4adb02acbac4c69920fe9d278f82 AS uv
FROM mcr.microsoft.com/devcontainers/base:ubuntu24.04@sha256:4bcb1b466771b1ba1ea110e2a27daea2f6093f9527fb75ee59703ec89b5561cb

ARG TZ
ENV TZ="$TZ"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install additional system packages (base image already includes git, curl, sudo, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
  # Sandboxing support for Claude Code
  bubblewrap \
  socat \
  # Modern CLI tools
  bat \
  btop \
  fd-find \
  ripgrep \
  tmux \
  xdg-utils \
  zsh \
  # Build tools
  build-essential \
  # Utilities
  jq \
  nano \
  unzip \
  vim \
  # Network tools (for security testing)
  dnsutils \
  ipset \
  iptables \
  iproute2 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# bat is installed as "batcat" on Ubuntu — symlink to "bat"
RUN ln -s /usr/bin/batcat /usr/local/bin/bat

# Install git-delta
ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  curl -fsSL "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" -o /tmp/git-delta.deb && \
  dpkg -i /tmp/git-delta.deb && \
  rm /tmp/git-delta.deb

# Install uv (Python package manager) via multi-stage copy
COPY --from=uv /uv /usr/local/bin/uv

# Install fzf from GitHub releases (newer than apt, includes built-in shell integration)
ARG FZF_VERSION=0.70.0
RUN ARCH=$(dpkg --print-architecture) && \
  case "${ARCH}" in \
    amd64) FZF_ARCH="linux_amd64" ;; \
    arm64) FZF_ARCH="linux_arm64" ;; \
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-${FZF_ARCH}.tar.gz" | tar -xz -C /usr/local/bin

# Install neovim from GitHub release tarball (AppImage needs FUSE, unavailable in Docker)
ARG NEOVIM_VERSION=0.12.0
RUN ARCH=$(dpkg --print-architecture) && \
  case "${ARCH}" in \
    amd64) NVIM_ARCH="x86_64" ;; \
    arm64) NVIM_ARCH="arm64" ;; \
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz" | tar -xz -C /opt && \
  ln -s /opt/nvim-linux-${NVIM_ARCH}/bin/nvim /usr/local/bin/nvim

# Install yazi file manager + ya CLI
ARG YAZI_VERSION=26.1.22
RUN ARCH=$(dpkg --print-architecture) && \
  case "${ARCH}" in \
    amd64) YAZI_ARCH="x86_64-unknown-linux-gnu" ;; \
    arm64) YAZI_ARCH="aarch64-unknown-linux-gnu" ;; \
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-${YAZI_ARCH}.zip" -o /tmp/yazi.zip && \
  unzip -q /tmp/yazi.zip -d /tmp/yazi && \
  mv /tmp/yazi/yazi-${YAZI_ARCH}/yazi /usr/local/bin/yazi && \
  mv /tmp/yazi/yazi-${YAZI_ARCH}/ya /usr/local/bin/ya && \
  rm -rf /tmp/yazi /tmp/yazi.zip

# Install eza (modern ls replacement)
ARG EZA_VERSION=0.23.4
RUN ARCH=$(dpkg --print-architecture) && \
  case "${ARCH}" in \
    amd64) EZA_ARCH="x86_64-unknown-linux-gnu" ;; \
    arm64) EZA_ARCH="aarch64-unknown-linux-gnu" ;; \
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_${EZA_ARCH}.tar.gz" | tar -xz -C /usr/local/bin

# Install lazygit
ARG LAZYGIT_VERSION=0.60.0
RUN ARCH=$(dpkg --print-architecture) && \
  case "${ARCH}" in \
    amd64) LG_ARCH="x86_64" ;; \
    arm64) LG_ARCH="arm64" ;; \
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz" | tar -xz -C /usr/local/bin lazygit

# Install glow (terminal markdown renderer)
ARG GLOW_VERSION=2.1.1
RUN ARCH=$(dpkg --print-architecture) && \
  case "${ARCH}" in \
    amd64) GLOW_ARCH="x86_64" ;; \
    arm64) GLOW_ARCH="arm64" ;; \
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL "https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/glow_${GLOW_VERSION}_Linux_${GLOW_ARCH}.tar.gz" | tar -xz --strip-components=1 -C /usr/local/bin "glow_${GLOW_VERSION}_Linux_${GLOW_ARCH}/glow"

# Install zoxide (smart cd)
ARG ZOXIDE_VERSION=0.9.9
RUN ARCH=$(dpkg --print-architecture) && \
  case "${ARCH}" in \
    amd64) ZOX_ARCH="x86_64-unknown-linux-musl" ;; \
    arm64) ZOX_ARCH="aarch64-unknown-linux-musl" ;; \
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL "https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/zoxide-${ZOXIDE_VERSION}-${ZOX_ARCH}.tar.gz" | tar -xz -C /usr/local/bin zoxide

# Install starship prompt
ARG STARSHIP_VERSION=1.24.2
RUN ARCH=$(dpkg --print-architecture) && \
  case "${ARCH}" in \
    amd64) STAR_ARCH="x86_64-unknown-linux-musl" ;; \
    arm64) STAR_ARCH="aarch64-unknown-linux-musl" ;; \
    *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL "https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/starship-${STAR_ARCH}.tar.gz" | tar -xz -C /usr/local/bin starship

# Create directories and set ownership (combined for fewer layers)
RUN mkdir -p /commandhistory /workspace /home/vscode/.claude /opt && \
  touch /commandhistory/.bash_history && \
  touch /commandhistory/.zsh_history && \
  chown -R vscode:vscode /commandhistory /workspace /home/vscode/.claude /opt

# Set environment variables
ENV DEVCONTAINER=true
ENV SHELL=/bin/zsh
ENV EDITOR=nvim
ENV VISUAL=nvim

WORKDIR /workspace

# Switch to non-root user for remaining setup
USER vscode

# Set PATH early so claude and other user-installed binaries are available
ENV PATH="/home/vscode/.local/bin:$PATH"

# Install Claude Code natively with marketplace plugins
RUN curl -fsSL https://claude.ai/install.sh | bash && \
  claude plugin marketplace add anthropics/skills && \
  claude plugin marketplace add trailofbits/skills && \
  claude plugin marketplace add trailofbits/skills-curated

# Install Python 3.13 via uv (fast binary download, not source compilation)
RUN uv python install 3.13 --default

# Install ast-grep (AST-based code search)
RUN uv tool install ast-grep-cli

# Install fnm (Fast Node Manager) and Node 22
ARG NODE_VERSION=22
ENV FNM_DIR="/home/vscode/.fnm"
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$FNM_DIR" --skip-shell && \
  export PATH="$FNM_DIR:$PATH" && \
  eval "$(fnm env)" && \
  fnm install ${NODE_VERSION} && \
  fnm default ${NODE_VERSION}

# Install rustup + rust-analyzer
ENV RUSTUP_HOME="/home/vscode/.rustup"
ENV CARGO_HOME="/home/vscode/.cargo"
ENV PATH="${CARGO_HOME}/bin:${PATH}"
RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal --no-modify-path && \
  rustup component add rust-analyzer

# Install Oh My Zsh
ARG ZSH_IN_DOCKER_VERSION=1.2.1
RUN sh -c "$(curl -fsSL https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -x

# Copy zsh configuration
COPY --chown=vscode:vscode .zshrc /home/vscode/.zshrc.custom

# Append custom zshrc to the main one
RUN echo 'source ~/.zshrc.custom' >> /home/vscode/.zshrc

# Copy post_install script
COPY --chown=vscode:vscode post_install.py /opt/post_install.py

# ── Personal dev environment configs ────────────────────────────────

# Copy tool configs to ~/.config/
COPY --chown=vscode:vscode configs/nvim/ /home/vscode/.config/nvim/
COPY --chown=vscode:vscode configs/yazi/ /home/vscode/.config/yazi/
COPY --chown=vscode:vscode configs/lazygit/config.yml /home/vscode/.config/lazygit/config.yml
COPY --chown=vscode:vscode configs/lazygit/base-config.yml /home/vscode/.config/lazygit/base-config.yml
COPY --chown=vscode:vscode configs/bat/config /home/vscode/.config/bat/config
COPY --chown=vscode:vscode configs/delta/catppuccin.gitconfig /home/vscode/.config/delta/catppuccin.gitconfig
COPY --chown=vscode:vscode configs/btop/ /home/vscode/.config/btop/
COPY --chown=vscode:vscode configs/starship.toml /home/vscode/.config/starship.toml

# Copy themes (theme script expects ~/dotfiles/themes/)
COPY --chown=vscode:vscode themes/ /home/vscode/dotfiles/themes/

# Copy theme script
COPY --chown=vscode:vscode scripts/theme /home/vscode/.local/bin/theme

# Apply Catppuccin Mocha as default theme
RUN mkdir -p /home/vscode/.config/eza /home/vscode/.config/fzf /home/vscode/.config/bat/themes /home/vscode/.config/delta && \
  cp /home/vscode/dotfiles/themes/catppuccin-mocha/eza-theme.yml /home/vscode/.config/eza/theme.yml && \
  cp /home/vscode/dotfiles/themes/catppuccin-mocha/fzf-theme.sh /home/vscode/.config/fzf/theme.sh && \
  cp /home/vscode/dotfiles/themes/catppuccin-mocha/bat.tmTheme "/home/vscode/.config/bat/themes/Catppuccin Mocha.tmTheme" && \
  cp /home/vscode/dotfiles/themes/catppuccin-mocha/delta.gitconfig /home/vscode/.config/delta/theme.gitconfig && \
  echo "catppuccin-mocha" > /home/vscode/dotfiles/themes/current && \
  bat cache --build

# Install yazi plugins (faster-piper, piper for markdown preview)
RUN ya pkg install

# Headless neovim: install plugins, treesitter parsers, and Mason LSPs
# fnm env must be sourced so Mason can find Node for LSP installs
RUN export PATH="$FNM_DIR:$PATH" && \
  eval "$(fnm env)" && \
  nvim --headless "+Lazy! restore" +qa && \
  nvim --headless "+TSInstallSync lua vim vimdoc bash python javascript typescript rust markdown markdown_inline" +qa && \
  nvim --headless "+MasonInstall lua-language-server typescript-language-server pyright ruff" +qa
