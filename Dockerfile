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
        ufw \
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
RUN systemctl enable ufw

RUN ufw default deny incoming \
    && ufw default allow outgoing \
    # SSH from LAN
    && ufw allow in on lan proto tcp to 127.0.0.1 port 22 \
    # DNS from LAN
    && ufw allow in on lan proto udp to 127.0.0.1 port 53 \
    # DHCP from LAN
    && ufw allow in on lan proto udp to 127.0.0.1 port 67 \
    # BGP from LAN
    && ufw allow in on lan proto tcp to 127.0.0.1 port 179 \
    # DHCPv6 from LAN
    && ufw allow in on lan proto udp to 127.0.0.1 port 546 \
    # DNS over TLS from LAN
    && ufw allow in on lan proto tcp to 127.0.0.1 port 853 \
    # Wireguard from WAN and LAN
    && ufw allow in on wan proto udp to 127.0.0.1 port 51820 \
    && ufw allow in on lan proto udp to 127.0.0.1 port 51820

RUN rm -rf /boot/*
