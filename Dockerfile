FROM node:22-slim

# Install dependencies + Himalaya + GitHub CLI + yt-dlp
RUN apt-get update && apt-get install -y git curl tini fuse3 unzip python3 python3-pip && rm -rf /var/lib/apt/lists/* \
    && pip3 install --break-system-packages yt-dlp \
    && curl https://rclone.org/install.sh | bash \
    && npm install -g openclaw@latest mcporter@latest \
    && curl -sSL https://github.com/pimalaya/himalaya/releases/download/v1.1.0/himalaya.x86_64-linux.tgz \
       | tar -xzC /usr/local/bin \
    && curl -sSL https://github.com/cli/cli/releases/download/v2.63.2/gh_2.63.2_linux_amd64.tar.gz \
       | tar -xzC /tmp && mv /tmp/gh_2.63.2_linux_amd64/bin/gh /usr/local/bin/

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

# Bake build metadata
COPY package.json ./
ARG GIT_SHA=unknown
ARG BUILD_ID=0
ENV GIT_SHA=${GIT_SHA}
ENV BUILD_ID=${BUILD_ID}

# Copy entrypoint
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Set state directory
ENV OPENCLAW_STATE_DIR=/app/.openclaw

EXPOSE 3000

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["./entrypoint.sh"]
