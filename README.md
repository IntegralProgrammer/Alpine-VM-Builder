# Alpine-VM-Builder

Builds a x86 64-bit image of Alpine Linux based on a Dockerfile and an
*entrypoint* script.

Dependencies (Ubuntu/Debian)
----------------------------

Installation of the following packages is required for the execution of
this script:

- docker.io
- e2fsprogs
- e2tools
- gzip
- cpio
- tar
- qemu-system-x86
- xorriso
- grub-common

Usage
-----

1. Populate the Dockerfile with required packages and files.
2. Populate *entrypoint.sh* with the required startup commands.
3. Build the image with `./build_vm_image.sh`
4. Enjoy the customized Alpine Linux image *(alpine.img)* and GRUB bootloader *(grub-bootloader.iso)*.


Use Cases
---------

- A Linux container with its own kernel and virtualized hardware.
- Automated trace generation.
- Automated virtual machine performance evaluation.
