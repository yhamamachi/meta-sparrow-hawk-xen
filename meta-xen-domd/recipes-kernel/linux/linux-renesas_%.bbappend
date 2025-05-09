FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

COMPATIBLE_MACHINE:append = "|sparrow-hawk"

SRC_URI:append:r8a779g3 = " \
    file://r8a779g0.cfg \
"

# Get from github.com/morimoto/linux branch=renesas-lts/v6.12.22-2025-04-09-sparrow-hawk-test
SRC_URI:append = " \
    file://r8a779g3-sparrow-hawk.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
"

SRC_URI:append = " \
    file://r8a779g3-xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
"

SRC_URI:append = " \
    file://0001-Draft-FIXME-Force-DSC-clock-on.patch \
"

do_compile:prepend() {
    sed -i ${S}/arch/arm64/boot/dts/renesas/r8a779g0-whitehawk.dts \
        -e "/linux,cr_region@60000000/,+3d"
    sed -i ${S}/arch/arm64/boot/dts/renesas/r8a779g0-domd.dts \
        -e "/cr_region/d" -e "/linux,cma@80000000/,+6d"
}

FILESEXTRAPATHS:prepend:sparrow-hawk = "${TOPDIR}/../../../firmware:"
SRC_URI:append:sparrow-hawk = " \
    file://renesas_defconfig_sparrow_hawk_20250508.cfg \
    file://rcar_gen4_pcie.bin;subdir=git/ \
    file://renesas_usb_fw.mem;subdir=git/ \
    file://disable.cfg \
    file://firmware.cfg \
    file://append_modules.cfg \
"

