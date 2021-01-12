FROM debian:buster-slim

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    rsync \
    time \
    qemu-utils \
    ecdsautils \
    lua-check \
    shellcheck \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -d /gluon gluon
USER gluon

VOLUME /gluon
WORKDIR /gluon
