do_install:append () {
    rm -rf ${D}${sysconfdir}/systemd/system/systemd-networkd.service.d/xenbr0-systemd-networkd.conf
}

