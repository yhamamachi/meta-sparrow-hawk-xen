FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN}:append = " backend-ready"
# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domu.cfg"

SRC_URI:append = " \
    file://domu-set-root \
"

FILES:${PN}:append = " \
    ${libdir}/xen/bin/domu-set-root \
"

do_install:append() {
    # Install domu-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domu-set-root ${D}${libdir}/xen/bin

    # Call domu-set-root script before launching domain
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domu.service
    echo "ExecStartPre=${libdir}/xen/bin/domu-set-root" >> ${D}${systemd_unitdir}/system/domu.service
}

