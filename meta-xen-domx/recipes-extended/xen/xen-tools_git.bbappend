require xen-source.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

FILES:${PN}-test = "\
    ${libdir}/xen/bin/test-xenstore \
    ${libdir}/xen/bin/test-resource \
"

# Remove the recommendation for Qemu for non-hvm x86 added in meta-virtualization layer
RRECOMMENDS:${PN}:remove = "qemu"

# Avoid redundant runtime dependency on python3-core
RDEPENDS:${PN}:remove:class-target = "${PYTHON_PN}-core"

DEPENDS:remove = "pixman virtual/libsdl"

SRC_URI:remove = "file://0001-arm-Change-GUEST_GICV3_ITS_BASE.patch"
SRC_URI:remove = "file://0001-pci-Add-support-for-V4H-pcie-host.patch"

SYSTEMD_SERVICE:xen-tools-xencommons:remove = 'var-lib-xenstored.mount'
FILES:${PN} += "/var/lib /usr/lib/xen/bin/* /boot/*"
