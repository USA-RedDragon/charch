#!/bin/bash
# Usage: generate-initramfs.sh <destination relative to pwd>

set -xe

CONTAINER_INITRAMFS_COPY=charch-initramfs
CONTAINER_INITRAMFS_KVER=charch-initramfs-kver

source `pwd`/scripts/funcs.sh

docker_stop_remove_container ${CONTAINER_INITRAMFS_COPY} || true
docker_stop_remove_container ${CONTAINER_INITRAMFS_KVER} || true

DEPLOY_KVER=$(docker run --name ${CONTAINER_INITRAMFS_KVER} jamcswain/charch:ahead pacman -Q linux | awk '{ print $2 }' | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+)\./\1-/gm')

docker_stop_remove_container ${CONTAINER_INITRAMFS_KVER}

docker run -v `pwd`:/ramout -t --name ${CONTAINER_INITRAMFS_COPY} jamcswain/charch:ahead mkinitcpio -g /ramout/${1} -k ${DEPLOY_KVER}

docker_stop_remove_container ${CONTAINER_INITRAMFS_COPY}

sha512sum ${1} > ${1}.sha512sum