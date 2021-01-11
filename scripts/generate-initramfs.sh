#!/bin/bash

set -xe

docker stop -t 1 charch-initramfs || true
docker rm charch-initramfs || true

docker run -v `pwd`:/ramout -t --name charch-initramfs jamcswain/charch:ahead mkinitcpio -p linux -g /ramout/$1

docker stop -t 1 charch-initramfs
docker rm charch-initramfs
