FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = "\
    file://domd-set-root \
"
FILES:${PN}:append = " \
    ${libdir}/xen/bin/domd-set-root \
    ${libdir}/xen/boot/initramfs-domd.cpio.gz \
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
}

