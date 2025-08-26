FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://enX0.network \
"

FILES:${PN}:append = " \
    ${sysconfdir}/systemd/network/enX0.network \
"

do_install:append() {
    install -m 0644 ${S}/enX0.network ${D}${sysconfdir}/systemd/network
}

