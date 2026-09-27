FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

COMPATIBLE_MACHINE = "(generic-armv8-xt)"

SRC_URI:append = "\
    file://defconfig \
"


