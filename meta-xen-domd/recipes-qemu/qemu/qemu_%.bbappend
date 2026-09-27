FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://qemu-wrapper \
    file://0001-virtio-input-add-BTN-touch-for-virtio-tablet.patch \
    file://0002-vhost-pass-xen-guest-domid-to-kernel-backend.patch \
    file://0003-hw-arm-xen-pvh-use-xenpv-machine-with-default-virtio.patch \
    file://0004-hw-xen-set-xenstore-node-owner-to-the-running-domain.patch \
    file://0005-hw-xen-xen-pvh-common-register-ioreq-server-before-i.patch \
    file://0006-hw-virtio-vhost-do-not-pass-the-Xen-grants-region-to.patch \
"

EXTRA_OECONF:append = " --enable-xen"

PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' vhost alsa', '', d)}"
PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio wayland', ' gtk+ pixman', '', d)}"
PACKAGECONFIG:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' kvm', '', d)}"

# Wrap qemu-system-aarch64 so the SDL/Wayland WM class follows -name.
# The real ELF is moved to ${libexecdir} (outside ${bindir}) so poky's dynamic
# do_split_packages (split_qemu_packages) does not carve it into its own
# package; the wrapper keeps the bindir name that the split uses to build the
# qemu-system-aarch64 subpackage. @LIBEXECDIR@ is substituted at build time.
do_install:append () {
    mkdir -p ${D}/${libexecdir}
    mv -f ${D}/${bindir}/qemu-system-aarch64 ${D}/${libexecdir}/qemu-system-aarch64.bin
    install -m 755 ${UNPACKDIR}/qemu-wrapper ${D}/${bindir}/qemu-system-aarch64
    sed -i "s|@LIBEXECDIR@|${libexecdir}|" ${D}/${bindir}/qemu-system-aarch64
    ln -sf qemu-system-aarch64.bin ${D}/${bindir}/qemu-xen
}

# meta-virtualization's qemu-package-split.inc creates qemu-aarch64 with
# FILES = "${bindir}/qemu-system-aarch64 ${bindir}/qemu-aarch64".
# We must add the libexec real binary and qemu-xen symlink there.
FILES:${PN}-aarch64:append:class-target = " ${libexecdir}/qemu-system-aarch64.bin ${bindir}/qemu-xen"
RDEPENDS:${PN}-aarch64:append:class-target = " bash"
INSANE_SKIP:${PN}-aarch64 = "file-rdeps"
ERROR_QA:remove = " patch-fuzz"
