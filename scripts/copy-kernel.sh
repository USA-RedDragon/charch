#!/bin/bash
# Usage: copy-kernel.sh <destination relative to pwd>

set -xe

CONTAINER_VMLINUX_COPY=charch-vmlinuz-copy
CONTAINER_VMLINUX_KVER=charch-vmlinuz-kver

source `pwd`/scripts/funcs.sh

docker_stop_remove_container ${CONTAINER_VMLINUX_COPY} || true
docker_stop_remove_container ${CONTAINER_VMLINUX_KVER} || true

DEPLOY_KVER=$(docker run --name ${CONTAINER_VMLINUX_KVER} jamcswain/charch:ahead pacman -Q linux | awk '{ print $2 }' | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+)\./\1-/gm')

docker_stop_remove_container ${CONTAINER_VMLINUX_KVER}

docker run -v `pwd`:/kernout -t --name ${CONTAINER_VMLINUX_COPY} jamcswain/charch:ahead cp -v /lib/modules/${DEPLOY_KVER}/vmlinuz /kernout/${1}

docker_stop_remove_container ${CONTAINER_VMLINUX_COPY}

sha512sum ${1} > ${1}.sha512sum
