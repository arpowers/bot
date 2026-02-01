FROM node:22-slim

# Install dependencies + Himalaya for email
# OpenClaw 2026.1.30 - bust cache for updates
RUN apt-get update && apt-get install -y git curl tini fuse3 unzip && rm -rf /var/lib/apt/lists/* \
    && curl https://rclone.org/install.sh | bash \
    && npm install -g openclaw@latest mcporter@latest \
    && curl -sSL https://github.com/pimalaya/himalaya/releases/download/v1.1.0/himalaya.x86_64-linux.tgz \
       | tar -xzC /usr/local/bin

WORKDIR /app

# Copy OpenClaw state/config
COPY .openclaw/ .openclaw/

# Copy skills
COPY skills/ skills/

# Copy scripts
COPY scripts/ scripts/

# Copy Himalaya config
COPY config/himalaya.toml /etc/himalaya/config.toml

# Create workspace mount point and config dir
RUN mkdir -p workspace config /root/.config/himalaya \
    && ln -s /etc/himalaya/config.toml /root/.config/himalaya/config.toml

# Copy entrypoint
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Set state directory
ENV OPENCLAW_STATE_DIR=/app/.openclaw

EXPOSE 3000

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["./entrypoint.sh"]
