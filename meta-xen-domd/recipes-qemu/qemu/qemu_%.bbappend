PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' vhost', '', d)}"
PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio wayland', ' gtk+', '', d)}"
PACKAGECONFIG:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' kvm', '', d)}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://qemu-wrapper \
    file://0001-virtio-input-hid-send-BTN_TOUCH-event-for-virtio-tab.patch \
    file://0002-hw-arm-xen_arm-disable-vTPM-wiring-GUEST_TPM_BASE-r.patch \
    file://0003-hw-xen-disable-buffered-ioreq-on-non-x86.patch \
    file://0004-hw-arm-xen_arm-create-virtio-mmio-devices-only-witho.patch \
"

# Install qemu binary wrapper
FILES:${PN}-aarch64:class-target += " ${bindir}/qemu-system-aarch64.bin"
do_install:append () {
    mv -f ${D}/${bindir}/qemu-system-aarch64 ${D}/${bindir}/qemu-system-aarch64.bin
    install -m 755 ${WORKDIR}/qemu-wrapper ${D}/${bindir}/qemu-system-aarch64
}

