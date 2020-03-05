FROM debian:buster-slim

RUN apt update && apt install -y --no-install-recommends \
    ca-certificates \
    file \
    git \
    subversion \
    python3 \
    build-essential \
    gawk \
    unzip \
    libncurses5-dev \
    zlib1g-dev \
    libssl-dev \
    libelf-dev \
    wget \
    time \
    ecdsautils \
    lua-check \
    shellcheck \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -d /gluon gluon
USER gluon

VOLUME /gluon
WORKDIR /gluon
