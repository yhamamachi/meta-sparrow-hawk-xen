FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://61-vif-emu1.network \
"

S = "${WORKDIR}"

FILES:${PN} += " \
    ${sysconfdir}/systemd/network/61-vif-emu1.network \
    ${sysconfdir}/systemd/system/systemd-networkd.service.d/wait-kernel-modules.conf \
"

XT_DOMA_FORWARD_DESTINATION = "192.168.2.4"
XT_DOMD_EXTERNAL_NETIF = "end0"
KERNEL_MODULE_CONF = "${D}/${sysconfdir}/systemd/system/systemd-networkd.service.d/wait-kernel-modules.conf"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/61-vif-emu1.network ${D}${sysconfdir}/systemd/network

    # Remove duplicated network file
    rm -f ${D}/${sysconfdir}/systemd/network/end0.network

    # Setup kernel module conf
    echo "[Service]" > ${KERNEL_MODULE_CONF}
    echo ExecStartPre=/usr/bin/modprobe xt_MASQUERADE >> ${KERNEL_MODULE_CONF}
}

