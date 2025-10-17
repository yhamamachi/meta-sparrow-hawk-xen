require xen-source.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://config.cfg \
"

SRC_URI:append = " ${@bb.utils.contains('XEN_REV', '2011e6c6fd35f564444983331296f5df7d154373', '', ' \
    file://0001-iommu-ipmmu-vmsa-Add-Renesas-R8A779G0-R-Car-V4H-supp.patch \
    file://0001-iommu-ipmmu-vmsa-Skip-preinit-for-R8A779G0-as-well.patch \
    file://0001-pci-Add-support-for-V4H-pcie-host.patch \
', d)}"

# We are dropping TUNE_CCARGS from for Xen because it won't build for armv8.2, as
# it conflicts with -mcpu=generic provided by own Xen build system
HOST_CC_ARCH:remove="-march=armv8.2-a+crypto"
HOST_CC_ARCH:remove="-mcpu=cortex-a55"

DEPENDS += "u-boot-mkimage-native"

SRC_URI:remove = "file://0001-arm-Change-GUEST_GICV3_ITS_BASE.patch"
SRC_URI:remove = "file://0001-pci-Add-support-for-V4H-pcie-host.patch"

do_configure:append () {
    cd ${S}
    # Remove 3sec delay
    sed -i xen/common/warning.c \
        -e '/for ( i = 0; i < 3; i++ )/,+9d' \
        -e 's/, j//'
}

