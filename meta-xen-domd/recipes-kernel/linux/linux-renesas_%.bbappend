FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://r8a779g3-xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://append.cfg \
    file://0001-Fix-build-error-for-kernel-6.12.34.patch \
"

SRC_URI:remove = "file://0002-PCIe-MSI-support.sparrow-hawk.patch"
SRC_URI:remove = "file://0003-xen-pciback-allow-compiling-on-other-archs-than-x86.patch"

do_compile:prepend:sparrow-hawk () {
    # WA for Xen DomD
    sed -i -e "s/1, 0, 1, 4/1, -1, 1, 4/" ${S}/drivers/gpu/drm/renesas/rcar-du/rcar_mipi_dsi.c
}

