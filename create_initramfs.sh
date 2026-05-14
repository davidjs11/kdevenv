#!/bin/bash

# Create an initramfs image using busybox's binaries.

# Assemble rootfs.
mkdir -p rootfs/{bin,sbin,etc,dev,proc,sys,mnt/host}
cp -a busybox/_install/* rootfs/

# Write init script.
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

# Pack everything.
(cd rootfs && find . | cpio -H newc -o | gzip > ../initramfs.cpio.gz) 2> /dev/null
