FROM jamcswain/redwall as firewall

FROM archlinux:base

# Remove mkinitcpio hooks
RUN rm -rf \
    /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook \
    /usr/share/libalpm/scripts/mkinitcpio-remove \
    /usr/share/libalpm/hooks/90-mkinitcpio-install.hook \
    /usr/share/libalpm/scripts/mkinitcpio-install

COPY --chown=root:root configs/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist

RUN pacman -Syyvu \
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
        --needed --noconfirm \
    && rm -rf /var/cache/pacman/pkg/*

RUN unbound-anchor

RUN wget --no-hsts -O /usr/bin/dhcpd-leases-exporter \
        https://github.com/DRuggeri/dhcpd_leases_exporter/releases/download/v0.2.0/dhcpd_leases_exporter-v0.2.0-linux-amd64 \
    && chmod a+x /usr/bin/dhcpd-leases-exporter

RUN wget --no-hsts -O /usr/bin/adguard-exporter \
        https://github.com/ebrianne/adguard-exporter/releases/latest/download/adguard_exporter-linux-amd64 \
    && chmod a+x /usr/bin/adguard-exporter

RUN pacman -Sv go git make gcc --needed --noconfirm \
    && git clone https://github.com/prometheus/node_exporter.git /tmp/node_exporter \
    && cd /tmp/node_exporter \
    && git checkout v1.1.1 \
    && sed -i 's/diff --exit-code/diff/g' Makefile.common \
    && make \
    && pacman -Rv go git make gcc --unneeded --noconfirm \
    && mv ./node_exporter /usr/bin/node-exporter \
    && cd - \
    && rm -rf /tmp/node_exporter \
    && rm -rf /root/.cache \
    && rm -rf /root/go \
    && rm -rf /tmp/go-build* \
    && rm -rf /var/cache/pacman/pkg/*

COPY --chown=root:root --from=firewall /redwall /usr/bin/redwall
COPY --chown=root:root configs/ /

# Ensure init can be run
RUN chmod 755 /usr/bin/init \
    && chown root:root /usr/bin/init

RUN pacman -Sv base-devel linux-headers --needed --noconfirm \
    && mkdir /tmp/igb-patched \
    && cd /tmp/igb-patched \
    && wget --no-hsts -O igb.tgz https://downloads.sourceforge.net/project/e1000/igb%20stable/5.5.2/igb-5.5.2.tar.gz \
    && tar -xvf igb.tgz \
    && rm -f igb.tgz \
    && cd */src \
    && patch ./e1000_nvm.c /etc/igb_nocsum.patch \
    && make -j`nproc` install \
    && pacman -Rv base-devel linux-headers --unneeded --noconfirm \
    && rm -rf /tmp/igb-patched \
    && rm -rf /var/cache/pacman/pkg/*

RUN mkdir /tmp/adguard \
    && mkdir -p /var/lib/adguardhome/ \
    && groupadd adguardhome \
    && useradd -r -s /usr/bin/nologin -g adguardhome adguardhome \
    && wget --no-hsts -O /tmp/adguard/release.tgz https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz \
    && cd /tmp/adguard \
    && tar -xvf release.tgz \
    && mv AdGuardHome/AdGuardHome /var/lib/adguardhome/AdGuardHome \
    && cd - \
    && rm -rf /tmp/adguard \
    && chown -R adguardhome:adguardhome /var/lib/adguardhome

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
RUN systemctl enable adguardhome
RUN systemctl enable adguard-exporter
RUN systemctl enable unbound

RUN rm -rf /boot/*
