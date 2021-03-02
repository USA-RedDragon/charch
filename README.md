# charch

[![Build Status](https://github.com/USA-RedDragon/charch/actions/workflows/release.yaml/badge.svg)](https://github.com/USA-RedDragon/charch/actions/workflows/release.yaml)

## What is it

PXE-bootable Arch Linux-based OS setup for a home router

## Features

- Lives in initramfs. No need for a persistent disk.
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
- cpio

## Building

A set of artifacts and their sha512 checksums including:

- the rootfs
- the initramfs
- and the kernel

will be generated in the artifacts folder by running `sudo ./build.sh`

## Booting

This can be iPXE booted via:

```ipxe
#!ipxe

set squash_url ${local_assets}/charch/rootfs-ahead.zstd.sqfs

kernel ${local_assets}/charch/vmlinuz-ahead squashfs=${squash_url} root=/dev/ram0 rw rdinit=/sbin/init console=ttyS0 lan_hwaddr=MAC_ADDR_OF_LAN wan_hwaddr=MAC_ADDR_OF_WAN
initrd ${local_assets}/charch/initramfs-ahead.zstd.img
boot

exit 0
```

## TODO

- Wireguard
- Fail2Ban
- DNS (unbound)
- IPv6 compatible
