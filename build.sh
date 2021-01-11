#!/bin/bash

set -xe

rm -rf charch-rootfs-ahead.tar charch-rootfs-ahead.zstd.sqfs charch-initramfs-ahead.zstd.img charch-vmlinuz-ahead
docker stop -t 1 charch-rootfs-sleep || true
docker rm charch-rootfs-sleep || true

docker build -t jamcswain/charch:ahead .

docker run -d --name charch-rootfs-sleep jamcswain/charch:ahead sleep infinity

docker export -o charch-rootfs-ahead.tar charch-rootfs-sleep

docker stop -t 1 charch-rootfs-sleep
docker rm charch-rootfs-sleep

FS_TMP_DIR=$(mktemp -d)
tar -C ${FS_TMP_DIR} -xf charch-rootfs-ahead.tar
mksquashfs ${FS_TMP_DIR} charch-rootfs-ahead.zstd.sqfs -comp zstd -exit-on-error -progress
rm -rf ${FS_TMP_DIR}

./scripts/generate-initramfs.sh charch-initramfs-ahead.zstd.img
./scripts/copy-kernel.sh charch-vmlinuz-ahead
