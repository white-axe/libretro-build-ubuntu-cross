#!/bin/sh

set -e

if [ "$(id -u)" != '0' ]
then echo 'This script must be run as root' >&2; exit 1
fi

packages='
    gcc-9
    g++-9
    libaio-dev
    libasound2-dev
    libass-dev
    libavdevice-dev
    libbz2-dev
    libcaca-dev
    libdrm-dev
    libffi-dev
    libflac-dev
    libfreetype6-dev
    libfribidi-dev
    libgbm-dev
    libgdbm-dev
    libgdk-pixbuf2.0-dev
    libglib2.0-dev
    libglm-dev
    libglu1-mesa-dev
    libgtk-3-dev
    libgtk2.0-dev
    libjack-jackd2-dev
    libjson-perl
    libltdl-dev
    liblua5.3-dev
    liblzma-dev
    libmbedtls-dev
    libminiupnpc-dev
    libmpv-dev
    libncurses5-dev
    libopenal-dev
    libosmesa6-dev
    libpcap-dev
    libreadline-dev
    libroar-dev
    libsdl2-dev
    libsixel-dev
    libslang2-dev
    libssl-dev
    libsystemd-dev
    libusb-1.0-0-dev
    libv4l-dev
    libvulkan-dev
    libwayland-dev
    libwxgtk3.0-dev
    libx11-dev
    libx11-xcb-dev
    libxcb-shm0-dev
    libxkbcommon-dev
    libxml2-dev
    mesa-common-dev
    qtbase5-dev
    uuid-dev
    x11proto-xext-dev
    zlib1g-dev
'

packages=$(echo $packages)

target="$1"

if [ "$target" = 'arm-linux-gnueabihf' ]
then arch='armhf'
elif [ "$target" = 'aarch64-linux-gnu' ]
then arch='arm64'
elif [ "$target" = 'powerpc64le-linux-gnu' ]
then arch='ppc64el'
elif [ "$target" = 's390x-linux-gnu' ]
then arch='s390x'
elif [ "$target" = 'i386-linux-gnu' ]
then arch='i386'
elif [ "$target" = 'x86_64-linux-gnu' ]
then arch='amd64'
else echo "Invalid target '$target'" >&2; exit 1
fi

mkdir sysroot
mkdir sysroot/sysroot
curl -Lo sysroot.tar.xz https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-$arch-root.tar.xz
tar -xJf sysroot.tar.xz -C sysroot/sysroot --exclude 'dev/*'

touch sysroot/sysroot/dev/full
touch sysroot/sysroot/dev/null
touch sysroot/sysroot/dev/random
touch sysroot/sysroot/dev/urandom
touch sysroot/sysroot/dev/zero
mount --bind /dev/full sysroot/sysroot/dev/full
mount --bind /dev/null sysroot/sysroot/dev/null
mount --bind /dev/random sysroot/sysroot/dev/random
mount --bind /dev/urandom sysroot/sysroot/dev/urandom
mount --bind /dev/zero sysroot/sysroot/dev/zero
chmod 777 sysroot/sysroot/tmp/
rm -f sysroot/sysroot/etc/resolv.conf
cp /etc/resolv.conf sysroot/sysroot/etc/

PATH=/usr/sbin:/usr/bin:/sbin:/bin chroot sysroot/sysroot /bin/bash -e -c "
    add-apt-repository -y ppa:ubuntu-toolchain-r/test
    apt update
    apt install -y $packages
    cp /usr/lib/$target/libm.so /usr/lib/$target/libm.a
"

umount sysroot/sysroot/dev/full
umount sysroot/sysroot/dev/null
umount sysroot/sysroot/dev/random
umount sysroot/sysroot/dev/urandom
umount sysroot/sysroot/dev/zero

echo '#!/bin/sh'$'\n''exec /usr/bin/clang --target='$target' --sysroot=/sysroot --start-no-unused-arguments -fuse-ld=lld --end-no-unused-arguments "$@"' > sysroot/sysroot/libretro-cc
echo '#!/bin/sh'$'\n''exec /usr/bin/clang++ --target='$target' --sysroot=/sysroot --start-no-unused-arguments -fuse-ld=lld --end-no-unused-arguments "$@"' > sysroot/sysroot/libretro-c++
chmod +x sysroot/sysroot/libretro-cc
chmod +x sysroot/sysroot/libretro-c++
