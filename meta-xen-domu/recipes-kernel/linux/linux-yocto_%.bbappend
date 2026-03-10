FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

COMPATIBLE_MACHINE = "(generic-armv8-xt)"

S = "${WORKDIR}/git"

SRC_URI:append = "\
    file://defconfig \
"


