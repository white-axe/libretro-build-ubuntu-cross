FROM ubuntu:noble

ENV DEBIAN_FRONTEND="noninteractive"

ARG uid
ARG branch=master
ENV branch=$branch

ARG NUMPROC

ENV PACKAGES \
    autoconf \
    automake \
    autopoint \
    bash \
    bc \
    bison \
    ccache \
    clang \
    cmake \
    curl \
    flex \
    gawk \
    gettext \
    git \
    intltool \
    libtool-bin \
    lld \
    llvm \
    make \
    meson \
    ninja-build \
    patch \
    pkg-config \
    sed \
    sudo \
    tar \
    unzip \
    wget

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
ENV CMAKE_TOOLCHAIN_FILE=/sysroot/libretro.cmake
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
