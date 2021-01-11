#!/bin/bash

docker stop -t 1 charch-initramfs || true
docker rm charch-initramfs || true

docker run -t --name charch-initramfs jamcswain/charch:ahead mkinitcpio -p linux -g /dev/stdout > $1

docker stop -t 1 charch-initramfs
docker rm charch-initramfs
