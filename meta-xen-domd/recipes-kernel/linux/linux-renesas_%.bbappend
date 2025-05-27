FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

COMPATIBLE_MACHINE:append = "|sparrow-hawk"

LINUX_VERSION:sparrow-hawk ?= "6.12.27"
REPO:sparrow-hawk = "git://github.com/morimoto/linux.git"
BRANCH:sparrow-hawk = "renesas-lts/v6.12.27-2025-05-08-sparrow-hawk"
SRCREV:sparrow-hawk = "46846f6ec3dcc724c93e8b17a5dc60cdb30bd305"
SRC_URI:sparrow-hawk = "${REPO};branch=${BRANCH};protocol=https"

SRC_URI:remove:sparrow-hawk = " \
    file://init_disassemble_info-signature-changes-causes-compile-failures.patch \
    file://0002-PCIe-MSI-support.sparrow-hawk.patch \
    file://0003-xen-pciback-allow-compiling-on-other-archs-than-x86.patch \
"

SRC_URI:append:sparrow-hawk = " \
    file://0001-Draft-FIXME-Force-DSC-clock-on_612.patch \
"

SRC_URI:append = " \
    file://r8a779g3-xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
"

KBUILD_DEFCONFIG:sparrow-hawk = "renesas_defconfig"
FILESEXTRAPATHS:prepend:sparrow-hawk = "${TOPDIR}/../../../firmware:"
SRC_URI:append:sparrow-hawk = " \
    file://rcar_gen4_pcie.bin;subdir=git/ \
    file://renesas_usb_fw.mem;subdir=git/ \
    file://disable.cfg \
    file://firmware.cfg \
    file://append_modules.cfg \
"

