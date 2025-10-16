FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://0001-pci-pcie-rcar-gen4-Shut-down-controller-on-link-down.patch \
    file://0002-arm64-renesas-r8a779g3-Reset-PCIe-before-next-stage-.patch \
"

# Fix announce_and_cleanup function removes critical devices
do_compile:prepend() {
    cd ${S}
    BEFORE="dm_remove_devices_active();"
    AFTER="dm_remove_devices_flags(DM_REMOVE_ACTIVE_ALL | DM_REMOVE_NON_VITAL);"
    sed -i arch/arm/lib/bootm.c \
        -e "s/${BEFORE}/${AFTER}/"
}

