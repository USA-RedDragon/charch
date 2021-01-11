#!/bin/bash

set -xe

CONTAINER_ROOTFS_EXPORT=charch-rootfs-sleep

rm -rf artifacts/
mkdir -p ./artifacts
chmod a+r ./artifacts

source `pwd`/scripts/funcs.sh

docker_stop_remove_container ${CONTAINER_ROOTFS_EXPORT} || true

docker build -t jamcswain/charch:ahead .

docker run -d --name ${CONTAINER_ROOTFS_EXPORT} jamcswain/charch:ahead sleep infinity

docker export -o artifacts/charch-rootfs-ahead.tar ${CONTAINER_ROOTFS_EXPORT}

docker_stop_remove_container ${CONTAINER_ROOTFS_EXPORT}

FS_TMP_DIR=$(mktemp -d)
tar -C ${FS_TMP_DIR} -xf artifacts/charch-rootfs-ahead.tar
mksquashfs ${FS_TMP_DIR} artifacts/charch-rootfs-ahead.zstd.sqfs -comp zstd -exit-on-error -progress
rm -rf ${FS_TMP_DIR} artifacts/charch-rootfs-ahead.tar
sha512sum artifacts/charch-rootfs-ahead.zstd.sqfs > artifacts/charch-rootfs-ahead.zstd.sqfs.sha512sum

./scripts/generate-initramfs.sh artifacts/charch-initramfs-ahead.zstd.img
./scripts/copy-kernel.sh artifacts/charch-vmlinuz-ahead

echo 'Artifact generation complete. Enjoy :)'