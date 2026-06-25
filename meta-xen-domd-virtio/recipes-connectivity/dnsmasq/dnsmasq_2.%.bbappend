XT_DOMA_ETH0_MAC = "02:15:b2:00:00:00"
XT_DOMA_ETH1_MAC = "08:00:27:ff:cb:ce"

do_install:append() {
    # Make dnsmasq listen only on bridge interface
    echo "interface=xenbr0" >> ${D}${sysconfdir}/dnsmasq.conf

    # Define DHCP leases range. Upper part of subnet can be used
    # for static configuration.
    echo "dhcp-range=192.168.0.2,192.168.0.150,12h" >> ${D}${sysconfdir}/dnsmasq.conf

    # Configure IP addresses for DomA, DomU.
    # MAC addresses are defined in /etc/xen/domX.cfg
    if ${@bb.utils.contains('XT_GUEST_INSTALL', 'doma', 'true', 'false', d)}; then
        echo "dhcp-host=${XT_DOMA_ETH0_MAC},doma,192.168.0.4,infinite" >> ${D}${sysconfdir}/dnsmasq.conf
    fi
    if ${@bb.utils.contains('XT_GUEST_INSTALL', 'domu', 'true', 'false', d)}; then
        echo "dhcp-host=08:00:27:ff:cb:cf,domu,192.168.0.5,infinite" >> ${D}${sysconfdir}/dnsmasq.conf
    fi

    if ${@bb.utils.contains('XT_GUEST_INSTALL', 'doma', 'true', 'false', d)}; then
        echo "interface=vif-emu1" >> ${D}${sysconfdir}/dnsmasq.conf
        echo "dhcp-range=192.168.2.5,192.168.2.10,12h" >> ${D}${sysconfdir}/dnsmasq.conf
        echo "dhcp-host=${XT_DOMA_ETH1_MAC},doma,192.168.2.4,infinite" >> ${D}${sysconfdir}/dnsmasq.conf
    fi
}
