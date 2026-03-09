SUMMARY = "Set of files to run a generic guest domain"
DESCRIPTION = "A config file, kernel, dtb and scripts for a guest domain"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit externalsrc systemd

EXTERNALSRC_SYMLINKS = ""

SRC_URI = "\
    file://domu-vdevices.cfg \
    file://domu.service \
"

python () {
    if d.getVar('XT_DOMU_CONFIG_NAME'):
        d.appendVar('SRC_URI', ' file://${XT_DOMU_CONFIG_NAME}')
}

FILES:${PN} = " \
    ${sysconfdir}/xen/domu.cfg \
    ${libdir}/xen/boot/domu.dtb \
    ${libdir}/xen/boot/linux-domu \
    ${systemd_unitdir}/system/domu.service \
"

SYSTEMD_SERVICE:${PN} = "domu.service"

# Set path to dtb file to empty value in case it was not defined before.
# In this case dtb will not be installed in 'do_install'.
# This is usefull in case if precompiled dtb is not needed and only one
# provided by xen will be used.
XT_DOMU_DTB_NAME ??= ""

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot
    install -m 0644 ${WORKDIR}/${XT_DOMU_CONFIG_NAME} ${D}${sysconfdir}/xen/domu.cfg
    if [ -n "${XT_DOMU_DTB_NAME}" ]; then
        install -m 0644 ${S}/${XT_DOMU_DTB_NAME} ${D}${libdir}/xen/boot/domu.dtb
    fi
    install -m 0644 ${S}/Image ${D}${libdir}/xen/boot/linux-domu

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/domu.service ${D}${systemd_unitdir}/system/
}


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

