#!/bin/bash

set -xe

docker stop -t 1 charch-vmlinuz-copy || true
docker rm charch-vmlinuz-copy || true

docker run -v `pwd`:/kernout -t --name charch-vmlinuz-copy jamcswain/charch:ahead cp -v /usr/lib/modules/*/vmlinuz /kernout/$1

docker stop -t 1 charch-vmlinuz-copy
docker rm charch-vmlinuz-copy
