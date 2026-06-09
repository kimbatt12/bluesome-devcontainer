FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive PYTHONUNBUFFERED=1 \
    NPM_CONFIG_PREFIX=/home/bluesome-agent/.npm-global \
    PATH="/home/bluesome-agent/.npm-global/bin:/home/bluesome-agent/.local/bin:${PATH}"

RUN groupadd -r bluesome-agent && useradd -m -g bluesome-agent -s /bin/bash bluesome-agent && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3 curl git ca-certificates gnupg build-essential xvfb \
    # Added noVNC infrastructure packages
    x11vnc fluxbox novnc websockify \
    fonts-liberation fonts-noto-cjk fonts-noto-color-emoji && \
    mkdir -p /etc/apt/keyrings && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /opt/bluesome/scripts && chown -R bluesome-agent:bluesome-agent /opt/bluesome && \
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

WORKDIR /home/bluesome-agent
USER bluesome-agent

RUN npm install -g chrome-devtools-mcp@latest && curl -LsSf https://astral.sh/uv/install.sh | sh

COPY --chown=bluesome-agent:bluesome-agent scripts/entrypoint.sh /opt/bluesome/scripts/entrypoint.sh
RUN chmod +x /opt/bluesome/scripts/entrypoint.sh

# Expose 6080 for noVNC Web UI
EXPOSE 6080

CMD ["bash", "/opt/bluesome/scripts/entrypoint.sh"]
