FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://qemu-wrapper \
    file://0001-virtio-input-add-BTN-touch-for-virtio-tablet.patch \
    file://0002-vhost-pass-xen-guest-domid-to-kernel-backend.patch \
    file://0003-arm-xen-add-xenpv-alias-for-xenpvh.patch \
    file://0004-arm-xen-add-pcie-bus-for-xenpvh.patch \
    file://0005-hw-xen-disable-buffered-ioreq-on-non-x86.patch \
    file://0006-hw-xen-set-xenstore-node-owner-to-the-running-domain.patch \
    file://0007-hw-arm-xen_arm-register-ioreq-server-before-initiali.patch \
"

EXTRA_OECONF:append = " --enable-xen"

PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' vhost alsa', '', d)}"
PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio wayland', ' gtk+', '', d)}"
PACKAGECONFIG:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' kvm', '', d)}"

# Wrap qemu-system-aarch64 so the SDL/Wayland WM class follows -name.
# The real ELF is moved to ${libexecdir} (outside ${bindir}) so poky's dynamic
# do_split_packages (split_qemu_packages) does not carve it into its own
# package; the wrapper keeps the bindir name that the split uses to build the
# qemu-system-aarch64 subpackage. @LIBEXECDIR@ is substituted at build time.
do_install:append () {
    mkdir -p ${D}/${libexecdir}
    mv -f ${D}/${bindir}/qemu-system-aarch64 ${D}/${libexecdir}/qemu-system-aarch64.bin
    install -m 755 ${WORKDIR}/qemu-wrapper ${D}/${bindir}/qemu-system-aarch64
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

SRC_URI:remove = " \
    file://0001-qemu-Add-addition-environment-space-to-boot-loader-q.patch \
    file://0003-apic-fixup-fallthrough-to-PIC.patch \
    file://0004-configure-Add-pkg-config-handling-for-libgcrypt.patch \
    file://0005-qemu-Do-not-include-file-if-not-exists.patch \
    file://0006-qemu-Add-some-user-space-mmap-tweaks-to-address-musl.patch \
    file://0007-qemu-Determinism-fixes.patch \
    file://0008-tests-meson.build-use-relative-path-to-refer-to-file.patch \
    file://0009-Define-MAP_SYNC-and-MAP_SHARED_VALIDATE-on-needed-li.patch \
    file://0010-hw-pvrdma-Protect-against-buggy-or-malicious-guest-d.patch \
    file://0002-linux-user-Replace-use-of-lfs64-related-functions-an.patch \
    file://4a8579ad8629b57a43daa62e46cc7af6e1078116.patch \
    file://0002-linux-user-loongarch64-Remove-TARGET_FORCE_SHMLBA.patch \
    file://0003-linux-user-Add-strace-for-shmat.patch \
    file://0004-linux-user-Rewrite-target_shmat.patch \
    file://0005-tests-tcg-Check-that-shmat-does-not-break-proc-self-.patch \
    file://0001-sched_attr-Do-not-define-for-glibc-2.41.patch \
    file://CVE-2024-8354.patch \
    file://CVE-2025-12464.patch \
    file://0011-linux-user-workaround-for-missing-MAP_FIXED_NOREPLAC.patch \
    file://0012-linux-user-workaround-for-missing-MAP_SHARED_VALIDAT.patch \
"
