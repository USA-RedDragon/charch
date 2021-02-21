#!/bin/bash

exec qemu-system-x86_64 -m 8192 -nographic -cpu host -accel kvm -cdrom charchlive.iso
