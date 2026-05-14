#!/bin/bash

set -e

# -- config --------------------------------------------------------------------
LINUX_REPO=https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
BUSYBOX_REPO=https://git.busybox.net/busybox
SHARED=./shared
KERNEL=./linux/arch/x86/boot/bzImage
INITRD=./initramfs.cpio.gz
QEMU_MEM=512M
QEMU_SMP=4

# -- tasks ---------------------------------------------------------------------
get_linux() {
    [ -d linux ] && echo "linux/ already exists, skipping clone." && return
    git clone --depth=1 $LINUX_REPO
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
    cd ..
}

build_linux() {
    cd linux && make -j$(nproc) && cd ..
}

get_busybox() {
    [ -d busybox ] && echo "busybox/ already exists, skipping clone." && return
    git clone --depth=1 $BUSYBOX_REPO
    cd busybox
    make defconfig
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
    sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' .config
    cd ..
}

build_busybox() {
    cd busybox && make -j$(nproc) && make install && cd ..
}

create_initramfs() {
    mkdir -p rootfs/{bin,sbin,etc,dev,proc,sys,mnt/host}
    cp -a busybox/_install/* rootfs/
    cat > rootfs/init << 'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t 9p -o trans=virtio,version=9p2000.L host /mnt/host
echo "*** kernel module dev env ready ***"
exec /bin/sh
EOF
    chmod +x rootfs/init
    (cd rootfs && find . | cpio -H newc -o | gzip > ../initramfs.cpio.gz) 2>/dev/null
    echo "initramfs.cpio.gz created."
}

run() {
    mkdir -p "$SHARED"
    qemu-system-x86_64          \
        -kernel $KERNEL         \
        -initrd $INITRD         \
        -append "console=ttyS0,115200 earlyprintk=serial,ttyS0,115200 nokaslr" \
        -m $QEMU_MEM            \
        -smp $QEMU_SMP          \
        -nographic              \
        -virtfs local,path="$SHARED",mount_tag=host,security_model=mapped-xattr
}

# -- entrypoint ----------------------------------------------------------------
usage() {
    echo "Usage: $0 <command>"
    echo ""
    echo "  setup   Clone + configure linux and busybox."
    echo "  build   Compile linux and busybox."
    echo "  initrd  Build the initramfs image."
    echo "  run     Launch QEMU."
    echo "  all     Setup + build + initrd + run."
    exit 1
}

case "${1:-}" in
    setup)  get_linux && get_busybox ;;
    build)  build_linux && build_busybox ;;
    initrd) create_initramfs ;;
    run)    run ;;
    all)    get_linux &&        \
            get_busybox &&      \
            build_linux &&      \
            build_busybox &&    \
            create_initramfs && \
            run ;;
    help)   usage ;;
    *)      usage ;;
esac
