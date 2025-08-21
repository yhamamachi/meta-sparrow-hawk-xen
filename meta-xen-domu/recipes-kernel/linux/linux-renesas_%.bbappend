FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = "\
    file://defconfig \
    file://dmatest.cfg \
"

SRC_URI:append:sparrow-hawk = " \
    file://r8a779g3-${MACHINE}-domu.dts;subdir=git/arch/${ARCH}/boot/dts/renesas \
    file://r8a779g0.cfg \
"
KERNEL_DEVICETREE:append:sparrow-hawk = " renesas/r8a779g3-${MACHINE}-domu.dtb"

# Ignore in-tree defconfig
KBUILD_DEFCONFIG = ""
KERNEL_DEVICETREE = "${XT_DOMU_DTB_NAME}"

do_deploy:append() {
    cd ${DEPLOYDIR}
    ln -sf Image-${MACHINE}.bin Image
}

