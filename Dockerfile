FROM archlinux:base

RUN pacman -Sy \
        reflector \
        --needed --noconfirm \
    && reflector --country US --age 12 --protocol https --ipv4 --ipv6 --sort rate --save /etc/pacman.d/mirrorlist 

RUN pacman -Syyu \
        unbound \
        openresolv \
        dhcp \
        dhcpcd \
        nftables \
        wireguard-tools \
        radvd \
        squashfs-tools \
        curl \
        mkinitcpio \
        mkinitcpio-nfs-utils \
        linux \
        linux-firmware \
        wget \
        pv \
        openssh \
        qemu-guest-agent \
        nano \
        --needed --noconfirm

RUN mkdir /tmp/bgp \
    && curl -fSsL https://github.com/osrg/gobgp/releases/download/v2.23.0/gobgp_2.23.0_linux_amd64.tar.gz -o - | tar -xz -C /tmp/bgp \
    && mv -v /tmp/bgp/gobgp /usr/bin/gobgp \
    && mv -v /tmp/bgp/gobgpd /usr/bin/gobgpd \
    && rm -rf /tmp/bgp
    
COPY configs/ /

RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

RUN systemctl enable sshd
RUN systemctl enable qemu-guest-agent
RUN systemctl enable systemd-networkd
RUN systemctl enable systemd-resolved
RUN systemctl enable dhcpd4@lan
RUN systemctl enable dhcpd6@lan
RUN systemctl enable radvd

RUN rm -rf /boot/*
