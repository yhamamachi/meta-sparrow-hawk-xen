FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://61-vif-emu1.network \
    file://62-vif-emu2.network \
"

S = "${WORKDIR}"

FILES:${PN} += " \
    ${sysconfdir}/systemd/network/61-vif-emu1.network \
    ${sysconfdir}/systemd/network/62-vif-emu2.network \
"

XT_DOMA_FORWARD_DESTINATION = "192.168.2.4"
XT_DOMD_EXTERNAL_NETIF = "end0"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/61-vif-emu1.network ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/62-vif-emu2.network ${D}${sysconfdir}/systemd/network

    # Remove duplicated network file
    rm -f ${D}/${sysconfdir}/systemd/network/end0.network

    # Disable wait for network online
    sed -i -e 's|ExecStart=/|# ExecStart=/|' \
        ${D}${sysconfdir}/systemd/system/systemd-networkd-wait-online.service.d/systemd-networkd-wait-online.conf
}

