FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN}:append = " backend-ready"

SRC_URI:append = " \
    file://doma-set-root \
"
FILES:${PN}:append = " \
     ${libdir}/xen/bin/doma-set-root \
"

do_install:append() {
    # Install domu-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/doma-set-root ${D}${libdir}/xen/bin

    # Call doma-set-root script before launching domain
    echo "[Service]" >> ${D}${systemd_unitdir}/system/doma.service
    echo "ExecStartPre=${libdir}/xen/bin/doma-set-root" >> ${D}${systemd_unitdir}/system/doma.service
}

