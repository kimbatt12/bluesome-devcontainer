FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    xz-utils \
    tini \
    libatomic1 \
    python3 \
    build-essential \
    chromium \
    ripgrep \
    fonts-liberation \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    bubblewrap \
    && useradd --create-home --shell /bin/bash hermes \
    && ln -s /usr/bin/chromium /usr/local/bin/google-chrome \
    && ln -s /usr/bin/chromium /usr/local/bin/chrome \
    && command -v tini \
    && command -v chromium \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_PATH=/usr/bin/chromium \
    CHROMIUM_PATH=/usr/bin/chromium \
    BROWSER_PATH=/usr/bin/chromium \
    AGENT_BROWSER_EXECUTABLE_PATH=/usr/bin/chromium \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
    PATH="/home/hermes/.local/bin:${PATH}"

USER hermes
WORKDIR /home/hermes

RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER hermes
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]
