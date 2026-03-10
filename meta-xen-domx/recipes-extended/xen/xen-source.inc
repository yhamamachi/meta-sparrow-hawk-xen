# Upstream
SRC_URI = "git://github.com/xen-project/xen.git;protocol=https;branch=stable-4.21"
XEN_REL = "4.21"
# RELEASE 4.21.0
#SRCREV = "06af9ef22996cecc2024a2e6523cec77a655581e"
# 4.21.1-pre: Fix flask bug
SRCREV = "e10f3ad8694cde2c0e8a81c3825e32ecc630a51c"
LIC_FILES_CHKSUM = "file://COPYING;md5=d1a1e216f80b6d8da95fec897d0dbec9"

SRC_URI:append = "\
    file://421/0001-Adjust-guest-memory-map.patch \
    file://421/0002-flask-Use-use_device_iommu_nointremap-primitives-for.patch\
    file://421/0003-xen-Use-large-pages-for-MMIO-mappings-on-ARM.patch \
    file://421/0004-Revert-xen-arm-don-t-iomem_permit_access-for-reserve.patch \
    file://421/0005-makefile-add-support-for-_defconfig-targets.patch \
    file://421/0006-configs-introduce-xt_defconfig.patch \
    file://421/0007-libxl-Add-DTB-compatible-list-to-config-file.patch \
    file://421/0008-libxl-Add-DTB-passthrough-nodes-list.patch \
    file://421/0009-xsm-Configure-Flask-policy-for-DomD.patch \
    file://421/0010-ipmmu-vmsa-Power-on-some-PDs-and-perform-errata-main.patch \
    file://421/0011-libxl-arm-Insert-status-property-into-virtio-mmio-de.patch \
    file://421/0012-libxl-add-support-for-emulated-TPM-on-ARM.patch \
    file://421/0013-libxl-Pass-max_vcpus-to-Qemu-in-case-of-PVH-domain-A.patch \
    file://421/0014-libxl-Check-for-d_config-to-be-valid-in-device_model.patch \
    file://421/0015-libxl-Run-Qemu-if-there-is-at-least-one-virtio-backe.patch \
    file://421/0016-ioreq-Drop-Arm-restriction-for-buffered-ioreq.patch \
    file://421/0017-libxl-arm-Add-basic-virtio-pci-support.patch \
    file://421/0018-libxl-arm-Reuse-generic-PCI-IOMMU-bindings-for-virti.patch \
    file://421/0019-xen-arm-Emulate-level-for-legacy-PCI-interrupts-with.patch \
    file://421/0020-Revert-libxl-Run-Qemu-if-there-is-at-least-one-virti.patch \
    file://421/0021-libxl-Add-backend_type-property-for-the-Virtio-devic.patch \
    file://421/0022-iommu-ipmmu-vmsa-Skip-preinit-for-R8A779G0-as-well.patch \
"
