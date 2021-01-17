#!/bin/bash

set -xe

CONTAINER_ROOTFS_EXPORT=charch-rootfs-sleep

rm -rf artifacts/ charchlive.iso
mkdir -p ./artifacts
chmod a+r ./artifacts

source `pwd`/scripts/funcs.sh

docker_stop_remove_container ${CONTAINER_ROOTFS_EXPORT} || true

docker build -t jamcswain/charch:ahead .

docker run -d --name ${CONTAINER_ROOTFS_EXPORT} jamcswain/charch:ahead sleep infinity

docker export -o artifacts/charch-rootfs-ahead.tar ${CONTAINER_ROOTFS_EXPORT}

docker_stop_remove_container ${CONTAINER_ROOTFS_EXPORT}

rm -rf artifacts/image
mkdir -p artifacts/image/isolinux
mkdir -p artifacts/image/live

FS_TMP_DIR=$(mktemp -d)
tar -C ${FS_TMP_DIR} -xf artifacts/charch-rootfs-ahead.tar
rm -rf ${FS_TMP_DIR}/etc/resolv.conf
ln -sf /run/systemd/resolve/resolv.conf ${FS_TMP_DIR}/etc/resolv.conf
mksquashfs ${FS_TMP_DIR} artifacts/image/live/filesystem.squashfs -comp zstd -Xcompression-level 22 -exit-on-error -progress
rm -rf ${FS_TMP_DIR} artifacts/charch-rootfs-ahead.tar
# sha512sum artifacts/charch-rootfs-ahead.zstd.sqfs > artifacts/charch-rootfs-ahead.zstd.sqfs.sha512sum

./scripts/generate-initramfs.sh artifacts/image/live/initrd
./scripts/copy-kernel.sh artifacts/image/live/vmlinuz

cat << __EOF__ > artifacts/image/isolinux/isolinux.cfg
UI menu.c32

prompt 0
timeout 1

menu title Charch

label Charch
    menu label ^Charch
    menu default
    kernel /live/vmlinuz
    append initrd=/live/initrd boot=live overlayroot squashfs_copy=true squashfs=/dev/sr0:AUTO lan_hwaddr=00:1b:22:76:28:02 wan_hwaddr=00:1b:22:76:28:03
__EOF__

cp /usr/lib/syslinux/bios/* artifacts/image/isolinux/
xorriso -as mkisofs -r -J -joliet-long -l -cache-inodes -isohybrid-mbr /usr/lib/syslinux/bios/isohdpfx.bin -partition_offset 16 -A "Charch" -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o charchlive.iso artifacts/image

echo 'Artifact generation complete. Enjoy :)'