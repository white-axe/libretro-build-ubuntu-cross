#!/bin/sh

set -e

if [ "$(id -u)" != '0' ]
then echo 'This script must be run as root' >&2; exit 1
fi

version=xenial

packages='
    gcc-9
    g++-9
    mesa-common-dev
'

packages=$(echo $packages)

target="$1"

if [ "$target" = 'arm-linux-gnueabihf' ]
then arch='armhf'
elif [ "$target" = 'aarch64-linux-gnu' ]
then arch='arm64'
elif [ "$target" = 'powerpc64le-linux-gnu' ]
then arch='ppc64el'
elif [ "$target" = 'riscv64-linux-gnu' ]
then arch='riscv64'
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
curl -Lo sysroot.tar.xz https://cloud-images.ubuntu.com/${version}/current/${version}-server-cloudimg-${arch}-root.tar.xz
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
    apt-get update
    apt-get -y install $packages
    apt-get -y autoremove
    apt-get -y clean
    rm -rf /var/lib/apt/lists/*
    cp /usr/lib/$target/libm.so /usr/lib/$target/libm.a
"

umount sysroot/sysroot/dev/full
umount sysroot/sysroot/dev/null
umount sysroot/sysroot/dev/random
umount sysroot/sysroot/dev/urandom
umount sysroot/sysroot/dev/zero

echo '#!/bin/sh' > sysroot/sysroot/libretro-cc
echo 'exec /usr/bin/clang --target='$target' --sysroot=/sysroot --start-no-unused-arguments -fuse-ld=lld --end-no-unused-arguments "$@"' >> sysroot/sysroot/libretro-cc
echo '#!/bin/sh' > sysroot/sysroot/libretro-c++
echo 'exec /usr/bin/clang++ --target='$target' --sysroot=/sysroot --start-no-unused-arguments -fuse-ld=lld --end-no-unused-arguments "$@"' >> sysroot/sysroot/libretro-c++
chmod +x sysroot/sysroot/libretro-cc
chmod +x sysroot/sysroot/libretro-c++
