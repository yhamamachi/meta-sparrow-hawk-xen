FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PACKAGECONFIG:append = " \
    xsm \
"

FILES:${PN}-flask = " \
    /boot/xenpolicy-${XEN_REL}* \
"

###
# TEMPORARY HACK
SRC_URI:append = " file://hack-xdg_runtime_dir.conf"
FILES:${PN}-devd += " ${sysconfdir}/systemd/system/xendriverdomain.service.d/hack-xdg_runtime_dir.conf"
do_install:append() {
    # Install drop-in file to define required environment variable
    install -d ${D}${sysconfdir}/systemd/system/xendriverdomain.service.d/
    install -m 0644 ${WORKDIR}/hack-xdg_runtime_dir.conf ${D}${sysconfdir}/systemd/system/xendriverdomain.service.d
}
# END OF TEMPORARY HACK
###

