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

## Customization

The `initrd` contains the whole OS, as it's ran from the RAM. This means any changes while running will not be saved. To customize it, you can create a directory (`rootfs` in the example below) and extract the `initrd` with the below commands:

```bash
cd rootfs
zstdcat ~/Downloads/initrd | cpio --extract --preserve-modification-time --make-directories
```

This command will take a few seconds. Once it's done the whole root filesystem is contained within. You can make any modifications you like, keeping file permissions and ownership in mind. Once this is done, you can repackage the `initrd` with the below example:

```bash
cd rootfs
find . | cpio -H newc -o | zstd > ../initrd
```

This will take a decent amount of time, as it will compress the whole rootfs. Once this is done, you have an `initrd` that any kernel compiled with zstd decompression support can use. You can optionally replace `zstd` above with `gzip` if planning to use with an older kernel.

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
