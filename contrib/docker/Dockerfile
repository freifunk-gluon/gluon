FROM debian/eol:buster-slim

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    file \
    git \
    subversion \
    python \
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
