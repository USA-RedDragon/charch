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

RUN ufw default deny incoming \
    && ufw default allow outgoing \
    # SSH from LAN
    && ufw allow from 192.168.1.0/24 to any port 22 proto tcp \
    # DNS from LAN
    && ufw allow from 192.168.1.0/24 to any port 53 proto udp \
    # DHCP from LAN
    && ufw allow from 192.168.1.0/24 to any port 67 proto udp \
    # BGP from LAN
    && ufw allow from 192.168.1.0/24 to any port 179 proto tcp \
    # DHCPv6 from LAN
    && ufw allow from 192.168.1.0/24 to any port 546 proto udp \
    # DNS over TLS from LAN
    && ufw allow from 192.168.1.0/24 to any port 853 proto tcp \
    # Wireguard from WAN and LAN
    && ufw allow from any to any port 51820 proto udp

COPY configs/ /

RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

RUN systemctl enable sshd
RUN systemctl enable qemu-guest-agent
RUN systemctl enable ufw

RUN rm -rf /boot/*
