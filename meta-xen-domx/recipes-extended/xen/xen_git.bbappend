require xen-source.inc

# We are dropping TUNE_CCARGS from for Xen because it won't build for armv8.2, as
# it conflicts with -mcpu=generic provided by own Xen build system
HOST_CC_ARCH:remove="-march=armv8.2-a+crypto"
HOST_CC_ARCH:remove="-mcpu=cortex-a55"

DEPENDS += "u-boot-mkimage-native"

do_deploy:append () {
    if [ -f ${D}/boot/xen ]; then
        uboot-mkimage -A arm64 -C none -T kernel -a 0x78080000 -e 0x78080000 -n "XEN" -d ${D}/boot/xen ${DEPLOYDIR}/xen-${MACHINE}.uImage
        ln -sfr ${DEPLOYDIR}/xen-${MACHINE}.uImage ${DEPLOYDIR}/xen-uImage
    fi
}

SRC_URI:remove = "file://0001-arm-Change-GUEST_GICV3_ITS_BASE.patch"
SRC_URI:remove = "file://0001-pci-Add-support-for-V4H-pcie-host.patch"

do_configure:append () {
    cd ${S}
    # Remove 3sec delay
    sed -i xen/common/warning.c \
        -e '/for ( i = 0; i < 3; i++ )/,+9d' \
        -e 's/, j//'
}
