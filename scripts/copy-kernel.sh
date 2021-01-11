#!/bin/bash

docker stop -t 1 charch-vmlinuz-copy || true
docker rm charch-vmlinuz-copy || true

docker run -t --name charch-vmlinuz-copy jamcswain/charch:ahead cat /usr/lib/modules/*/vmlinuz > $1

docker stop -t 1 charch-vmlinuz-copy
docker rm charch-vmlinuz-copy
