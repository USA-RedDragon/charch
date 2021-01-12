# charch

## What is it

PXE-bootable Arch Linux-based OS setup for a home router

## Features

- Squashfs rootfs (zstd compress)
- Overlayfs root (diskless)
- Early firewall start
- UFW for easy firewall configuration
- OpenSSH configured for pubkey auth
- IPv6 compatible
- DNS over TLS (unbound, eventually)
- DHCPv6 (radvd, eventually)
- DHCPd (ISC, eventually)
- BGP (gobgpd, eventually)
- Wireguard (eventually)
- QEMU guest agent

## Requirements

- Docker
- About 1gb free in /tmp
- sha512sum
- A kernel and tooling that supports zstd compression
- awk, sed, and grep probably

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
