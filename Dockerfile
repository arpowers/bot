FROM node:22-slim

# Install tini for proper signal handling + git for skills + rclone for Google Drive sync
RUN apt-get update && apt-get install -y git curl tini rsync fuse3 && rm -rf /var/lib/apt/lists/* \
    && curl https://rclone.org/install.sh | bash \
    && npm install -g openclaw@latest

WORKDIR /app

# Copy everything needed
COPY openclaw.json ./
COPY config/ config/
COPY skills/ skills/
COPY workspace/ workspace/
COPY entrypoint.sh ./

RUN chmod +x entrypoint.sh \
    && mkdir -p /data/workspace /data/agents \
    && chown -R node:node /app /data

EXPOSE 3000

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["./entrypoint.sh"]
