FROM debian:buster-slim

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

RUN mkdir /tmp/ec &&\
  wget -O /tmp/ec/ec-linux-amd64.tar.gz https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.3.5/ec-linux-amd64.tar.gz &&\
  tar -xvzf /tmp/ec/ec-linux-amd64.tar.gz &&\
  mv bin/ec-linux-amd64 /usr/local/bin/ec &&\
  rm -rf /tmp/ec

RUN useradd -d /gluon gluon
USER gluon

VOLUME /gluon
WORKDIR /gluon
