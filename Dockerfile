FROM node:22-slim

# Install dependencies
RUN apt-get update && apt-get install -y git curl tini fuse3 unzip && rm -rf /var/lib/apt/lists/* \
    && curl https://rclone.org/install.sh | bash \
    && npm install -g openclaw@latest

WORKDIR /app

# Copy OpenClaw state/config
COPY .openclaw/ .openclaw/

# Copy skills
COPY skills/ skills/

# Create workspace mount point
RUN mkdir -p workspace

# Copy entrypoint
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Set state directory
ENV OPENCLAW_STATE_DIR=/app/.openclaw

EXPOSE 3000

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["./entrypoint.sh"]
