# charch


[![Build Status](https://drone.mcswain.dev/api/badges/USA-RedDragon/charch/status.svg)](https://drone.mcswain.dev/USA-RedDragon/charch)


## What is it

PXE-bootable Arch Linux-based OS setup for a home router

## Features

- Squashfs rootfs (zstd compress)
- Overlayfs root (diskless)
- Early firewall start
- UFW for easy firewall configuration
- OpenSSH configured for pubkey auth
- DNS over TLS (unbound, eventually)
- DHCPv6 (radvd, eventually)
- DHCPd (ISC)
- BGP (gobgpd, eventually)
- Wireguard (eventually)
- QEMU guest agent
- Live ISO booting
- DDNS
- Dynamic Firewall (for NAT reflection) <https://github.com/USA-RedDragon/redwall>

## Requirements

- Docker
- About 1gb free in /tmp
- sha512sum
- A kernel and tooling that supports zstd compression
- awk, sed, and grep probably
- xorriso
- syslinux

## Building

A set of artifacts and their sha512 checksums including:

* the rootfs
* the initramfs
* and the kernel

will be generated in the artifacts folder by running `sudo ./build.sh`

## Booting

This can be iPXE booted via:

```ipxe
#!ipxe

set squash_url ${local_assets}/charch/rootfs-ahead.zstd.sqfs

kernel ${local_assets}/charch/vmlinuz-ahead squashfs=${squash_url} ip=dhcp overlayroot
initrd ${local_assets}/charch/initramfs-ahead.zstd.img
boot

exit 0
```

## TODO

- Wireguard
- Fail2Ban
- DNS (unbound)
- IPv6 compatible
