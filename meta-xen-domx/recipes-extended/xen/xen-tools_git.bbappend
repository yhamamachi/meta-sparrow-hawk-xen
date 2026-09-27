FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

require xen-source.inc

# xen-source.inc overrides SRC_URI, so restore the networking files
# required by virt_networking.bbclass inherited in xen-tools.inc
SRC_URI += "file://10-ether.network \
            file://10-xenbr0.netdev \
            file://10-xenbr0.network"
# Do not install them: 10-ether.network bridges every ethernet port to
# xenbr0, which conflicts with our own network configuration
RDEPENDS:${PN}:remove = "${PN}-net-conf"

LIC_FILES_CHKSUM ?= "file://COPYING;md5=d1a1e216f80b6d8da95fec897d0dbec9"

FILES:${PN} = "\
    ${libdir}/xen/bin/test-* \
"

# Remove the recommendation for Qemu for non-hvm x86 added in meta-virtualization layer
RRECOMMENDS:${PN}:remove = "qemu"

RDEPENDS:${PN} += "${PN}-devd"
RDEPENDS:${PN}:remove = "${PN}-xendomains"

# WA for xen-init-dom0 service
do_install:append () {
    install -d 755 ${D}/${localstatedir}/lib/xen
}

# QEMU: Fix for aarch64
QEMU_HVM_DEFAULT = "qemu ${@bb.utils.contains('DISTRO_FEATURES', 'vmsep', 'qemu-system-i386', '', d)}"
QEMU = "${@bb.utils.contains('PACKAGECONFIG', 'hvm', '${QEMU_HVM_DEFAULT}', '', d)}"
QEMU:aarch64 = "qemu ${@bb.utils.contains('DISTRO_FEATURES', 'vmsep', 'qemu-system-aarch64', '', d)}"
QEMU_ARCH:aarch64 = "aarch64"
EXTRA_OECONF:remove = " --with-system-qemu=${bindir}/qemu-system-i386"
EXTRA_OECONF:append = " --with-system-qemu=${bindir}/qemu-system-${QEMU_ARCH}"

### START:  WA for Xen 4.21: from master branch of meta-virtualization
RDEPENDS:${PN} = "\
    ${PN}-libxenmanage \
"
FILES:${PN}-libxenmanage = "${libdir}/libxenmanage.so.*"
FILES:${PN}-libxenmanage-dev = " \
    ${libdir}/libxenmanage.so \
    ${libdir}/pkgconfig/xenmanage.pc \
    ${datadir}/pkgconfig/xenmanage.pc \
"
# libxenmanage is only in xen-4.21+
ALLOW_EMPTY:${PN}-libxenmanage = "1"

FILES:${PN}-test += "\
    ${libdir}/xen/tests/test-xenstore \
    ${libdir}/xen/tests/test-resource \
    ${libdir}/xen/tests/test-domid \
    ${libdir}/xen/tests/test-paging-mempool \
    ${libdir}/xen/tests/test_vpci \
    ${libdir}/xen/tests/test-pdx-mask \
    ${libdir}/xen/tests/test-pdx-offset \
    ${libdir}/xen/tests/test-rangeset \
    ${libdir}/xen/tests/test-mem-claim \
    ${libdir}/xen/tests/test-numa \
"

FILES:${PN}-xen-watchdog += "\
    ${systemd_unitdir}/system-sleep/xen-watchdog-sleep.sh \
"

FILES:${PN} += "\
    ${sysconfdir}/xen/auto \
    ${sysconfdir}/xen/cpupool \
"

### END:  WA for Xen 4.21: from master branch of meta-virtualization

