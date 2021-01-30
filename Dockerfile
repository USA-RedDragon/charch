FROM jamcswain/redwall as firewall

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

RUN wget -O /usr/bin/dhcpd-leases-exporter \
        https://github.com/DRuggeri/dhcpd_leases_exporter/releases/download/v0.2.0/dhcpd_leases_exporter-v0.2.0-linux-amd64 \
    && chmod a+x /usr/bin/dhcpd-leases-exporter

RUN pacman -S go git make gcc --needed --noconfirm \
    && git clone https://github.com/prometheus/node_exporter.git /tmp/node_exporter \
    && cd /tmp/node_exporter \
    && make \
    && pacman -R go git make gcc --unneeded --noconfirm \
    && mv ./node_exporter /usr/bin/node-exporter \
    && cd - \
    && rm -rf /tmp/node_exporter

COPY --from=firewall /redwall /usr/bin/redwall
COPY configs/ /

RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

RUN systemctl enable sshd
RUN systemctl enable qemu-guest-agent
RUN systemctl enable systemd-networkd
RUN systemctl enable systemd-resolved
RUN systemctl enable dhcpd4@lan
# RUN systemctl enable dhcpd6@lan
# RUN systemctl enable radvd
RUN systemctl enable redwall
RUN systemctl enable dhcpd-exporter
RUN systemctl enable node-exporter

RUN rm -rf /boot/*
