Container images for cross-compiling GNU/Linux libretro cores for 32-bit ARM (arm-linux-gnueabihf), 64-bit ARM (aarch64-linux-gnu), 64-bit little-endian PowerPC (powerpc64le-linux-gnu), s390x (s390x-linux-gnu), x86 (i386-linux-gnu) and x86-64 (x86_64-linux-gnu). The target platform targeted by the cross compiler is Ubuntu 16.04 (Xenial) with GCC 9, which is the same as that of the container images for native GNU/Linux builds in the libretro infrastructure.

The images can be downloaded from the GitHub container registry:

```sh
docker pull ghcr.io/white-axe/libretro-build-ubuntu-cross:arm-linux-gnueabihf
docker pull ghcr.io/white-axe/libretro-build-ubuntu-cross:aarch64-linux-gnu
docker pull ghcr.io/white-axe/libretro-build-ubuntu-cross:powerpc64le-linux-gnu
docker pull ghcr.io/white-axe/libretro-build-ubuntu-cross:s390x-linux-gnu
docker pull ghcr.io/white-axe/libretro-build-ubuntu-cross:i386-linux-gnu
docker pull ghcr.io/white-axe/libretro-build-ubuntu-cross:x86_64-linux-gnu
```

To build a libretro core that uses Make, just run Make normally, but don't set the CC or CXX variables since those are already set correctly in the container image to use the cross compiler.

```sh
MAKEFILE_PATH='.'
MAKEFILE='Makefile.libretro'
make -C "$MAKEFILE_PATH" -f "$MAKEFILE"
```

To build a libretro core that uses CMake, just run CMake normally, since the toolchain file is already set up to use the cross compiler.

```sh
BUILD_DIR='build'
CMAKE_SOURCE_ROOT='.'
cmake -DCMAKE_BUILD_TYPE=Release "$CMAKE_SOURCE_ROOT" -B "$BUILD_DIR"
cmake --build "$BUILD_DIR" --config Release
```

Once the libretro core is built, you can use `llvm-strip` to strip the libretro core if needed. *Do not use `strip`*, it won't work since it can only handle native binaries. Only `llvm-strip` is able to handle cross-compiled binaries.
