
PACKAGES:append = "\
    ${PN}-pcid \
"
FILES:${PN}-pcid = "\
    ${systemd_unitdir}/system/xenpcid.service \
    ${systemd_unitdir}/system/xenpcid.service.d/xenpcid-xenstore.conf \
"
SYSTEMD_SERVICE:${PN}-pcid = "xenpcid.service"
SYSTEMD_PACKAGES += "${PN}-pcid"
do_install:append() {
    install -d ${D}${systemd_unitdir}/system/xenpcid.service.d/
    echo '[Service]' > ${D}${systemd_unitdir}/system/xenpcid.service.d/xenpcid-xenstore.conf
    echo 'ExecStartPost=/usr/bin/xenstore-write drivers/pcid/status ready' >> ${D}${systemd_unitdir}/system/xenpcid.service.d/xenpcid-xenstore.conf
}

