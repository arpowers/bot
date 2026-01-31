FROM node:22-slim

# Install dependencies: tini, git, rclone, fuse
RUN apt-get update && apt-get install -y git curl tini fuse3 unzip && rm -rf /var/lib/apt/lists/* \
    && curl https://rclone.org/install.sh | bash \
    && npm install -g openclaw@latest

WORKDIR /app

# Copy configs
COPY openclaw.json openclaw-prod.json ./

# Copy skills
COPY skills/ skills/

# Create empty workspace (will be mounted from Google Drive)
RUN mkdir -p /app/workspace

# Copy entrypoint
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["./entrypoint.sh"]
