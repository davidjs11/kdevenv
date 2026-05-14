#!/bin/bash

# Get Linux source if necessary, configure it and compile it.

GIT_LINUX_REPO=https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

git clone --depth=1 $GIT_LINUX_REPO
cd linux
make defconfig
cat >> .config << 'EOF'
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_VIRTIO_PCI=y
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_KERNEL=y
EOF
make olddefconfig
make -j$(nproc)
cd ..
