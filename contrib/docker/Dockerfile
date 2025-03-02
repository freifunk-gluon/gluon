FROM debian:bookworm-slim

ARG TARGETOS
ARG TARGETARCH

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    ecdsautils \
    file \
    gawk \
    git \
    libelf-dev \
    libncurses5-dev \
    libnss-unknown \
    libssl-dev \
    llvm \
    lua-check \
    openssh-client \
    python3 \
    python3-dev \
    python3-pyelftools \
    python3-setuptools \
    qemu-utils \
    rsync \
    shellcheck \
    swig \
    time \
    unzip \
    wget \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /tmp/ec &&\
    wget -O /tmp/ec/ec-${TARGETOS}-${TARGETARCH}.tar.gz https://github.com/editorconfig-checker/editorconfig-checker/releases/download/2.7.0/ec-${TARGETOS}-${TARGETARCH}.tar.gz &&\
    tar -xvzf /tmp/ec/ec-${TARGETOS}-${TARGETARCH}.tar.gz &&\
    mv bin/ec-${TARGETOS}-${TARGETARCH} /usr/local/bin/editorconfig-checker &&\
    rm -rf /tmp/ec

RUN useradd -m -d /gluon -u 100 -g 100 -o gluon
USER gluon

VOLUME /gluon
WORKDIR /gluon
