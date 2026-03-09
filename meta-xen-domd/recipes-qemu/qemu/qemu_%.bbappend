PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' vhost', '', d)}"
PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio wayland', ' gtk+', '', d)}"
PACKAGECONFIG:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' kvm', '', d)}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://qemu-wrapper \
"

# Install qemu binary wrapper
FILES:${PN}-aarch64:class-target += " ${bindir}/qemu-system-aarch64.bin"
do_install:append () {
    mv -f ${D}/${bindir}/qemu-system-aarch64 ${D}/${bindir}/qemu-system-aarch64.bin
    install -m 755 ${WORKDIR}/qemu-wrapper ${D}/${bindir}/qemu-system-aarch64
}

