FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE:append = "|sparrow-hawk"
SOC:r8a779g3 = "V4H"

# Use upstream implementation
PV:rcar-gen4:sparrow-hawk = "v2.13+renesas+git${SRCPV}"
BRANCH:rcar-gen4:sparrow-hawk = "master"
SRC_URI = "git://github.com/ARM-software/arm-trusted-firmware.git;branch=${BRANCH};protocol=https"
SRCREV:rcar-gen4:sparrow-hawk = "7a0a320dfeb88a6a5ae1b801c0394b7d199c0893"

SRC_URI:append:r8a779g3 = " \
    file://0001-v4h-Configure-IPMMU-registers.patch \
    file://0002-fix-rcar4-assure-SCIF-and-HSCIF-clock-are-always-ena.patch \
"

