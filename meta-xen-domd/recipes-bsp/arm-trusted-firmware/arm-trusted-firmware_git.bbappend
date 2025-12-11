FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE:append = "|sparrow-hawk"
SOC:r8a779g3 = "V4H"

SRC_URI:append:r8a779g3 = " \
    file://0001-v4h-Configure-IPMMU-registers.patch \
"

