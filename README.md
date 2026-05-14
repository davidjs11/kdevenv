# kdevenv

A script that setups a Linux kernel development environment.
It's capabilities are:
- Download, configure and compile the kernel.
- Download, configure and compile busybox.
- Build an initramfs image.
- Run QEMU with the compiled kernel and initramfs, with a shared directory
  (accessed through ```/mnt/host``` on the gest).

For info on how to use it, run ```./kdevenv.sh help```:

```
Usage: ./kdevenv.sh <command>

  setup   Clone + configure linux and busybox.
  build   Compile linux and busybox.
  initrd  Build the initramfs image.
  run     Launch QEMU.
  all     Setup + build + initrd + run.
```
