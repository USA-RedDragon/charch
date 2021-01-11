FROM archlinux:base

RUN pacman -Sy \
        reflector \
        --needed --noconfirm \
    && reflector --country US --age 12 --protocol https --ipv4 --ipv6 --sort rate --save /etc/pacman.d/mirrorlist 

RUN pacman -Syyu \
        unbound \
        openresolv  \
        dhcp \
        ufw \
        wireguard-tools \
        radvd \
        squashfs-tools \
        curl \
        mkinitcpio \
        mkinitcpio-nfs-utils \
        make \
        linux \
        linux-firmware \
        --needed --noconfirm \
    && mkdir /tmp/squashfs \
    && curl -fSsL https://github.com/RegalisTechnologies/mkinitcpio-squashfs/archive/master.tar.gz -o - | tar -xz -C /tmp/squashfs \
    && make -C /tmp/squashfs/mkinitcpio-squashfs-master install DESTDIR=/ \
    && rm -rf /tmp/squashfs \
    && pacman -Rs \
        make \
        --unneeded --noconfirm

RUN mkdir /tmp/bgp \
    && curl -fSsL https://github.com/osrg/gobgp/releases/download/v2.23.0/gobgp_2.23.0_linux_amd64.tar.gz -o - | tar -xz -C /tmp/bgp \
    && mv -v /tmp/bgp/gobgp /usr/bin/gobgp \
    && mv -v /tmp/bgp/gobgpd /usr/bin/gobgpd \
    && rm -rf /tmp/bgp

COPY configs/mkinitcpio.conf /etc/mkinitcpio.conf

RUN rm -rf /boot/*
