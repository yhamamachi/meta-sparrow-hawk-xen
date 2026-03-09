FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

require xen-source.inc
LIC_FILES_CHKSUM ?= "file://COPYING;md5=d1a1e216f80b6d8da95fec897d0dbec9"

FILES:${PN} = "\
    ${libdir}/xen/bin/test-* \
"

# Remove the recommendation for Qemu for non-hvm x86 added in meta-virtualization layer
RRECOMMENDS:${PN}:remove = "qemu"

RDEPENDS:${PN} += "${PN}-devd"
RDEPENDS:${PN}:remove = "${PN}-xendomains"

### START:  WA for Xen 4.21: from master branch of meta-virtualization
PACKAGES +=  " ${PN}-libxenmanage ${PN}-libxenmanage-dev"
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
"

FILES:${PN}-xen-watchdog += "\
    ${systemd_unitdir}/system-sleep/xen-watchdog-sleep.sh \
"

FILES:${PN} += "\
    ${sysconfdir}/xen/auto \
    ${sysconfdir}/xen/cpupool \
"

### END:  WA for Xen 4.21: from master branch of meta-virtualization

