#!/bin/bash

# Get Busybox source if necessary, compile it (statically linked).

GIT_BUSYBOX_REPO=https://git.busybox.net/busybox

git clone --depth=1 $GIT_BUSYBOX_REPO
cd busybox
make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' .config
make -j$(nproc) && make install
cd ..
