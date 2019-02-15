#!/bin/bash

echo "Building Docker image..."
docker build -t alpine-tmpbuild .

echo "Creating a blank 4G HDD image..."
dd if=/dev/zero of=alpine.img bs=1M count=4000

echo "Creating an ext4 filesystem in this image..."
mkfs.ext4 -F alpine.img

echo "Creating an instance of the alpine-tmpbuild Docker image..."
mycontainerid=$(docker create alpine-tmpbuild)

echo "Exporting the alpine-tmpbuild instance to a TAR archive..."
docker export -o alpine_fs.tar $mycontainerid

echo "Removing the no longer required container..."
docker rm $mycontainerid

echo "Extracting the Linux Kernel..."
tar -xvf alpine_fs.tar boot/vmlinuz-vanilla

echo "Extracting the Initramfs..."
tar -xvf alpine_fs.tar boot/initramfs-vanilla

echo "Creating the root Alpine Linux filesystem..."
e2cp alpine_fs.tar alpine.img:/

echo "Creating a modified version of the Initramfs..."
cd boot/
mkdir mod-initramfs
cd mod-initramfs
cp ../initramfs-vanilla .
cat initramfs-vanilla | gzip -d | cpio -idmv
rm initramfs-vanilla
mv init real_init
cat real_init | sed -e s/"echo \"initramfs emergency recovery shell launched. Type 'exit' to continue boot\""/"modprobe ext4; mount \/dev\/sda \/sysroot; cd \/sysroot; tar -xvf alpine_fs.tar; rm alpine_fs.tar; cd ..; umount \/sysroot; poweroff -f"/g > init
chmod +x init
find . | sort | cpio --quiet -o -H newc | gzip -9 > ../startup-initramfs-vanilla
cd ..
cd ..

echo "Creating the QEMU initialize script..."
echo '#!/bin/bash' > init_image.sh
echo 'qemu-system-x86_64 -drive format=raw,file=alpine.img -kernel boot/vmlinuz-vanilla -initrd boot/startup-initramfs-vanilla -append "rootfstype=ext4" -net none -m 4096' >> init_image.sh
chmod u+x init_image.sh

echo "Initializing the image..."
./init_image.sh

echo "Configuring GRUB..."
mkdir -p iso/boot/grub
cp grub.cfg iso/boot/grub
grub-mkrescue -o grub-bootloader.iso iso

echo "Cleaning up..."
rm alpine_fs.tar
rm -rf boot/
rm -rf iso/
rm init_image.sh

echo "Done!"
