FROM python:3.11-slim

# Install system deps + Node.js (for MCP npx servers + WhatsApp)
RUN apt-get update && apt-get install -y \
    git curl tini fuse3 unzip ripgrep ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && pip install --no-cache-dir yt-dlp \
    && curl https://rclone.org/install.sh | bash \
    && curl -sSL https://github.com/pimalaya/himalaya/releases/download/v1.2.0/himalaya.x86_64-linux.tgz \
       | tar -xzC /usr/local/bin \
    && curl -sSL https://github.com/cli/cli/releases/download/v2.88.1/gh_2.88.1_linux_amd64.tar.gz \
       | tar -xzC /tmp && mv /tmp/gh_2.88.1_linux_amd64/bin/gh /usr/local/bin/

# Install uv (fast Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Clone and install Hermes Agent
RUN git clone --recurse-submodules https://github.com/NousResearch/hermes-agent.git /opt/hermes-agent \
    && cd /opt/hermes-agent \
    && uv venv /opt/hermes-venv --python 3.11 \
    && VIRTUAL_ENV=/opt/hermes-venv uv pip install -e ".[all]" \
    && ln -sf /opt/hermes-venv/bin/hermes /usr/local/bin/hermes

# Ensure venv Python is available for entrypoint scripts
ENV PATH="/opt/hermes-venv/bin:$PATH"
ENV VIRTUAL_ENV="/opt/hermes-venv"

WORKDIR /app

# Copy Hermes config
COPY .hermes/ /root/.hermes/

# Copy skills
COPY skills/ /app/skills/

# Copy scripts
COPY scripts/ /app/scripts/

# Copy Himalaya config
COPY config/himalaya.toml /etc/himalaya/config.toml

# Create workspace mount point and config dirs
RUN mkdir -p /app/workspace /root/.config/himalaya \
    && ln -s /etc/himalaya/config.toml /root/.config/himalaya/config.toml

# Bake build metadata
COPY package.json ./
ARG GIT_SHA=unknown
ARG BUILD_ID=0
ENV GIT_SHA=${GIT_SHA}
ENV BUILD_ID=${BUILD_ID}

# Copy entrypoint
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Hermes uses ~/.hermes/ for state (already set up above)
# Set working dir for gateway sessions
ENV MESSAGING_CWD=/app

EXPOSE 3000

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["./entrypoint.sh"]
