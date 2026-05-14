#!/bin/bash

# Run the kernel on QEMU.

KERNEL=./linux/arch/x86/boot/bzImage
INITRD=./initramfs.cpio.gz

# Host directory visible in guest as /mnt/host.
SHARED=./shared
mkdir -p "$SHARED"

# Run QEMU (512MiB of RAM, 4 cores, serial output).
qemu-system-x86_64                       \
  -kernel $KERNEL                        \
  -initrd $INITRD                        \
  -append "console=ttyS0 nokaslr" \
  -m 512M                                \
  -smp 4                                 \
  -nographic                             \
  -virtfs local,path="./modules",mount_tag=host,security_model=mapped-xattr
