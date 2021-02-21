#!/bin/bash

exec qemu-system-x86_64 -m 8192 -nographic -cpu host -accel kvm -initrd artifacts/image/live/initrd -kernel artifacts/image/live/vmlinuz -append "root=/dev/ram0 rw rdinit=/sbin/init console=ttyS0 lan_hwaddr=00:1b:22:76:28:02 wan_hwaddr=00:1b:22:76:28:03"
