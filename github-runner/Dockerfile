FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-pip \
    python3-venv \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    sudo \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create runner user
RUN useradd -m -s /bin/bash runner && \
    usermod -aG sudo runner && \
    usermod -aG docker runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to runner user
USER runner
WORKDIR /home/runner

# Download GitHub Actions Runner based on architecture
ARG TARGETPLATFORM
ARG RUNNER_VERSION=2.319.1

RUN set -x && \
    if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        export RUNNER_ARCH=arm64; \
        export RUNNER_SHA=38c74ee95c8076818d8894fc29bb07b21b7e5ac036fbccd9b07c0b80bb8ce4a2; \
    else \
        export RUNNER_ARCH=x64; \
        export RUNNER_SHA=3f6efb7488a183e291fc2c62876e14c9ee732864173734facc85a1bfb1744464; \
    fi && \
    curl -o actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz -L \
        https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    echo "${RUNNER_SHA}  actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" | shasum -a 256 -c && \
    tar xzf ./actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

# Install additional dependencies
RUN sudo ./bin/installdependencies.sh

# Create scripts directory
RUN mkdir -p /home/runner/scripts

# Copy configuration and start scripts
COPY --chown=runner:runner scripts/ /home/runner/scripts/
RUN chmod +x /home/runner/scripts/*.sh

# Copy supervisor configuration
USER root
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose Docker daemon (if needed)
EXPOSE 2376

# Set working directory
WORKDIR /home/runner

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
