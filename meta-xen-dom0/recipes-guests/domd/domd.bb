SUMMARY = "Set of files to run a Driver domain"
DESCRIPTION = "A config file, kernel, dtb and scripts for a Driver domain"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit externalsrc systemd

EXTERNALSRC_SYMLINKS = ""

SRC_URI = "\
    file://${XT_DOMD_CONFIG_NAME} \
    file://domd.service \
"

FILES:${PN} = " \
    ${sysconfdir}/xen/domd.cfg \
    ${libdir}/xen/boot/domd.dtb \
    ${libdir}/xen/boot/linux-domd \
    ${systemd_unitdir}/system/domd.service \
"

SYSTEMD_SERVICE:${PN} = "domd.service"

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot
    install -m 0644 ${WORKDIR}/${XT_DOMD_CONFIG_NAME} ${D}${sysconfdir}/xen/domd.cfg
    install -m 0644 ${S}/${XT_DOMD_DTB_NAME} ${D}${libdir}/xen/boot/domd.dtb
    install -m 0644 ${S}/Image ${D}${libdir}/xen/boot/linux-domd

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/domd.service ${D}${systemd_unitdir}/system/
}

RDEPENDS:append:sparrow-hawk = " dtc"

SRC_URI:append = "\
    file://domd-set-root \
"
FILES:${PN}:append = " \
    ${libdir}/xen/bin/domd-set-root \
    ${libdir}/xen/boot/initramfs-domd.cpio.gz \
    ${libdir}/xen/boot/*.dtbo \
"

CFG_FILE="${D}${sysconfdir}/xen/domd.cfg"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'true', 'false', d)}; then
        echo "" >> ${CFG_FILE}
        echo "driver_domain = 1" >> ${CFG_FILE}

        if ${@bb.utils.contains('XT_GUEST_INSTALL', 'doma', 'true', 'false', d)}; then
            sed -i "s/\[VIRTIO_EXTRA_PARAMETERS\]/ vhost_xen.nogrant=1/g" ${CFG_FILE}
        else
            sed -i "s/\[VIRTIO_EXTRA_PARAMETERS\]/ vhost_xen.nogrant=0/g" ${CFG_FILE}
        fi
    else
        sed -i "s/\[VIRTIO_EXTRA_PARAMETERS\]//" ${CFG_FILE}
    fi

    # Install domd-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domd-set-root ${D}${libdir}/xen/bin

    # Call domd-set-root script before launching domain
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domd.service
    echo "ExecStartPre=${libdir}/xen/bin/domd-set-root" >> ${D}${systemd_unitdir}/system/domd.service

    # Add initramfs
    install -m 0644 ${S}/initramfs-domd.cpio.gz ${D}${libdir}/xen/boot/initramfs-domd.cpio.gz

    # install dtbo for DomD
    for f in ${S}/*.dtbo; do
        [ -e "$f" ] || continue
        install -m 0644 "$f" ${D}${libdir}/xen/boot/
    done
}

