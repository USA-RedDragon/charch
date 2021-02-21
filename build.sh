#!/bin/bash

set -xe

CONTAINER_ROOTFS_EXPORT=charch-rootfs-sleep

rm -rf artifacts/ charchlive.iso
mkdir -p ./artifacts
chmod a+r ./artifacts

source `pwd`/scripts/funcs.sh

docker_stop_remove_container ${CONTAINER_ROOTFS_EXPORT} || true

docker build -t jamcswain/charch:ahead . --no-cache

docker run -d --name ${CONTAINER_ROOTFS_EXPORT} jamcswain/charch:ahead sleep infinity

docker export -o artifacts/charch-rootfs-ahead.tar ${CONTAINER_ROOTFS_EXPORT}

docker_stop_remove_container ${CONTAINER_ROOTFS_EXPORT}

rm -rf artifacts/image
mkdir -p artifacts/image/isolinux
mkdir -p artifacts/image/live

FS_TMP_DIR=$(mktemp -d)
OLDPWD=$(pwd)
tar -C ${FS_TMP_DIR} -xf artifacts/charch-rootfs-ahead.tar

# Fix DNS resolution from Docker back to systemd
rm -rf ${FS_TMP_DIR}/etc/resolv.conf
ln -sf /run/systemd/resolve/resolv.conf ${FS_TMP_DIR}/etc/resolv.conf

cd ${FS_TMP_DIR}
# Size hint is better overesitmated than underestimated, and we can't easily
# calculate the overhead from cpio, just add 0.2%

# Sizes around this commit, not sure why DU is higher than the cpio file size
# cpio 1505546240
# du   1512420613
SIZE_HINT=$(du -sb | awk '{ print $1 }' | awk '{print int($1*1.02)}')

# Use fast compression on my laptop
# High compression elsewhere
ZSTD_COMPRESSION="--ultra -22"
if [ $(hostname) = "EdgeOfAges" ]; then
    ZSTD_COMPRESSION="--fast"
fi

find . | cpio -H newc -o | zstd -T0 -v ${ZSTD_COMPRESSION} --exclude-compressed --size-hint=${SIZE_HINT} > ${OLDPWD}/artifacts/image/live/initrd
cd ${OLDPWD}
sha512sum artifacts/image/live/initrd > artifacts/image/live/initrd.sha512sum

rm -rf ${FS_TMP_DIR} artifacts/charch-rootfs-ahead.tar

./scripts/copy-kernel.sh artifacts/image/live/vmlinuz
sha512sum artifacts/image/live/vmlinuz > artifacts/image/live/vmlinuz.sha512sum

cat << __EOF__ > artifacts/image/isolinux/isolinux.cfg
UI menu.c32

prompt 0
timeout 1

menu title Charch

label Charch
    menu label ^Charch
    menu default
    kernel /live/vmlinuz
    append initrd=/live/initrd root=/dev/ram0 rw rdinit=/sbin/init console=ttyS0 lan_hwaddr=00:1b:22:76:28:02 wan_hwaddr=00:1b:22:76:28:03
__EOF__

cp /usr/lib/syslinux/bios/* artifacts/image/isolinux/
xorriso -as mkisofs -r -J -joliet-long -l -cache-inodes -isohybrid-mbr /usr/lib/syslinux/bios/isohdpfx.bin -partition_offset 16 -A "Charch" -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o charchlive.iso artifacts/image
sha512sum charchlive.iso > charchlive.iso.sha512sum

echo 'Artifact generation complete. Enjoy :)'
