FROM ubuntu:noble

ENV DEBIAN_FRONTEND="noninteractive"

ARG uid
ARG branch=master
ENV branch=$branch

ARG NUMPROC

ENV NATIVE_PACKAGES \
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
    libxml-parser-perl \
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
    apt-get -y install $NATIVE_PACKAGES; \
    apt-get -y autoremove; \
    apt-get -y clean; \
    rm -rf /var/lib/apt/lists/*

ENV PACKAGES \
    gcc-9 \
    g++-9 \
    libaio-dev \
    libasound2-dev \
    libass-dev \
    libavdevice-dev \
    libbz2-dev \
    libcaca-dev \
    libdrm-dev \
    libffi-dev \
    libflac-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libgbm-dev \
    libgdbm-dev \
    libgdk-pixbuf2.0-dev \
    libglib2.0-dev \
    libglm-dev \
    libglu1-mesa-dev \
    libgtk-3-dev \
    libgtk2.0-dev \
    libjack-jackd2-dev \
    libjson-perl \
    libltdl-dev \
    liblua5.3-dev \
    liblzma-dev \
    libmbedtls-dev \
    libminiupnpc-dev \
    libmpv-dev \
    libncurses5-dev \
    libopenal-dev \
    libosmesa6-dev \
    libpcap-dev \
    libreadline-dev \
    libroar-dev \
    libsdl2-dev \
    libsixel-dev \
    libslang2-dev \
    libssl-dev \
    libsystemd-dev \
    libtool \
    libtool-bin \
    libusb-1.0-0-dev \
    libv4l-dev \
    libvulkan-dev \
    libwayland-dev \
    libwxgtk3.0-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxcb-shm0-dev \
    libxkbcommon-dev \
    libxml2-dev \
    mesa-common-dev \
    qtbase5-dev \
    uuid-dev \
    x11proto-xext-dev \
    zlib1g-dev

# Possible values:
#   "arm-linux-gnueabihf" (32-bit ARM)
#   "aarch64-linux-gnu" (64-bit ARM)
#   "powerpc64le-linux-gnu" (64-bit little-endian PowerPC)
#   "s390x-linux-gnu" (s390x)
#   "i386-linux-gnu" (x86)
#   "x86_64-linux-gnu" (x86-64)
ARG TARGET

RUN set -eux; \
    if [ "$TARGET" = 'arm-linux-gnueabihf' ]; \
    then arch='armhf'; \
    elif [ "$TARGET" = 'aarch64-linux-gnu' ]; \
    then arch='arm64'; \
    elif [ "$TARGET" = 'powerpc64le-linux-gnu' ]; \
    then arch='ppc64el'; \
    elif [ "$TARGET" = 's390x-linux-gnu' ]; \
    then arch='s390x'; \
    elif [ "$TARGET" = 'i386-linux-gnu' ]; \
    then arch='i386'; \
    elif [ "$TARGET" = 'x86_64-linux-gnu' ]; \
    then arch='amd64'; \
    else echo "Invalid target '$TARGET'" >&2; exit 1; \
    fi; \
    mkdir sysroot; \
    curl -Lo sysroot.tar.xz https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-$arch-root.tar.xz; \
    tar -xJf sysroot.tar.xz -C sysroot --exclude 'dev/*'; \
    chmod 777 sysroot/tmp/; \
    rm -f sysroot/etc/resolv.conf; \
    cp /etc/resolv.conf sysroot/etc/; \
    touch sysroot/dev/full; \
    touch sysroot/dev/null; \
    touch sysroot/dev/random; \
    touch sysroot/dev/urandom; \
    touch sysroot/dev/zero

RUN \
    --mount=type=bind,source=full,target=sysroot/dev/full \
    --mount=type=bind,source=null,target=sysroot/dev/null \
    --mount=type=bind,source=random,target=sysroot/dev/random \
    --mount=type=bind,source=urandom,target=sysroot/dev/urandom \
    --mount=type=bind,source=zero,target=sysroot/dev/zero \
    set -eux; \
    PATH=/usr/sbin:/usr/bin:/sbin:/bin chroot sysroot /bin/bash -e -c " \
        add-apt-repository -y ppa:ubuntu-toolchain-r/test; \
        apt-get update; \
        apt-get install -y $PACKAGES; \
        apt-get -y autoremove; \
        apt-get -y clean; \
        rm -rf /var/lib/apt/lists/*; \
        cp /usr/lib/$TARGET/libm.so /usr/lib/$TARGET/libm.a; \
    "

RUN echo "developer:developer" | chpasswd && adduser developer sudo

ENV HOME=/developer
ENV QT_SELECT=qt5

USER root
WORKDIR /developer

CMD /bin/bash
