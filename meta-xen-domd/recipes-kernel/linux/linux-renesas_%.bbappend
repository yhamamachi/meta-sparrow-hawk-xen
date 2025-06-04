FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://r8a779g3-xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://append.cfg \
    file://0001-Fix-xt-passthrough.patch \
"

SRC_URI:remove = "file://0002-PCIe-MSI-support.sparrow-hawk.patch"
SRC_URI:remove = "file://0003-xen-pciback-allow-compiling-on-other-archs-than-x86.patch"

do_compile:prepend:sparrow-hawk () {
    sed -i -e "s/CAM_J2 1/CAM_J2 0/" ${S}/arch/arm64/boot/dts/renesas/r8a779g3-sparrow-hawk.dts

    # WA for Xen DomD
    sed -i -e "s/1, 0, 1, 4/1, -1, 1, 4/" ${S}/drivers/gpu/drm/renesas/rcar-du/rcar_mipi_dsi.c
}

