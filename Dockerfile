FROM ubuntu:noble

ENV DEBIAN_FRONTEND="noninteractive"

ARG uid
ARG branch=master
ENV branch=$branch

ARG NUMPROC

ENV PACKAGES \
    alsa-utils \
    autoconf \
    automake \
    autopoint \
    bash \
    bc \
    binfmt-support \
    bison \
    bsdmainutils \
    build-essential \
    bzip2 \
    ccache \
    chrpath \
    clang \
    cmake \
    curl \
    debhelper \
    diffutils \
    doxygen \
    flex \
    fuse \
    gawk \
    gettext \
    git \
    gnupg \
    gnupg2 \
    gperf \
    gzip \
    intltool \
    less \
    libtool \
    libtool-bin \
    libxml-parser-perl \
    lld \
    llvm \
    lsb-release \
    lzip \
    lzop \
    make \
    meson \
    nasm \
    ninja-build \
    nsis \
    p7zip-full \
    patch \
    patchutils \
    perl \
    pkg-config \
    python3 \
    python3-mako \
    python3-setuptools \
    python3-sphinx \
    python3-yaml \
    qemu-user-static \
    ruby \
    sed \
    sudo \
    sunxi-tools \
    swig \
    tar \
    texinfo \
    u-boot-tools \
    unzip \
    wayland-protocols \
    wget \
    xfonts-utils \
    xsltproc \
    xz-utils \
    yasm

RUN set -eux; \
    apt-get -y update; \
    apt-get -y install -y unzip; \
    useradd -d /developer -m developer; \
    chown -R developer:developer /developer

RUN set -eux; \
    apt-get update -y; \
    apt-get -y install $PACKAGES; \
    apt-get -y autoremove; \
    apt-get -y clean; \
    rm -rf /var/lib/apt/lists/*

COPY sysroot /
ENV CC=/sysroot/libretro-cc
ENV CXX=/sysroot/libretro-c++
ENV LD=/usr/bin/ld.lld
ENV AR=/usr/bin/llvm-ar
ENV AS=/usr/bin/llvm-as
ENV NM=/usr/bin/llvm-nm
ENV OBJCOPY=/usr/bin/llvm-objcopy
ENV OBJDUMP=/usr/bin/llvm-objdump
ENV RANLIB=/usr/bin/llvm-ranlib
ENV STRIP=/usr/bin/llvm-strip
ENV STRINGS=/usr/bin/llvm-strings

RUN echo "developer:developer" | chpasswd && adduser developer sudo

ENV HOME=/developer
ENV QT_SELECT=qt5

USER root
WORKDIR /developer

CMD /bin/bash
