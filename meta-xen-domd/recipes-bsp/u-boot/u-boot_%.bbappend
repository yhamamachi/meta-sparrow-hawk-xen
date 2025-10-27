FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://0001-pci-pcie-rcar-gen4-Shut-down-controller-on-link-down.patch \
    file://0002-arm64-renesas-r8a779g3-Reset-PCIe-before-next-stage-.patch \
"

