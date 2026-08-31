# Upstream
SRC_URI = "git://github.com/xen-project/xen.git;protocol=https;branch=stable-4.22"
XEN_REL = "4.22"
SRCREV = "d45d5687f1441495f4ee20d5e9940066c5fa5beb"

LIC_FILES_CHKSUM = "file://COPYING;md5=d1a1e216f80b6d8da95fec897d0dbec9"

SRC_URI:append = "\
    file://422/0002-xen-arm-ignore-spurious-interrupts-from-virtual-time.patch \
    file://422/0003-Adjust-guest-memory-map.patch \
    file://422/0004-xsm-Configure-Flask-policy-for-DomD.patch \
    file://422/0005-flask-Use-use_device_iommu_nointremap-primitives-for.patch \
    file://422/0006-libxl-Add-DTB-passthrough-nodes-list.patch \
    file://422/0007-libxl-Pass-max_vcpus-to-Qemu-in-case-of-PVH-domain-A.patch \
    file://422/0008-libxl-arm-Add-basic-virtio-pci-support.patch \
    file://422/0009-libxl-arm-Reuse-generic-PCI-IOMMU-bindings-for-virti.patch \
    file://422/0010-xen-arm-Emulate-level-for-legacy-PCI-interrupts-with.patch \
    file://422/0011-libxl-Add-backend_type-property-for-the-Virtio-devic.patch \
    file://422/0012-libxl-Update-xl-devd-to-also-spawn-Qemu-for-Virtio-d.patch \
    file://422/0013-libxl-Wait-for-Qemu-spawned-by-xl-devd-to-be-ready-b.patch \
    file://422/0014-libxl-arm-adjust-vpci-IRQ-map-according-to-vgic-conf.patch \
    file://422/0015-libxl-arm-Rework-virtio-pci-support-for-dynamic-PCI-.patch \
    file://422/0016-xen-arm-Update-emulation-of-level-for-legacy-PCI-int.patch \
    file://422/0017-libxl-Allow-virtio-pci-backends-from-different-domai.patch \
    file://422/0018-Revert-xen-arm-don-t-iomem_permit_access-for-reserve.patch \
    file://422/0019-xen-extend-XEN_DOMCTL_memory_mapping-to-handle-cache.patch \
    file://422/0020-libxc-introduce-xc_domain_memory_mapping_cache-to-ha.patch \
    file://422/0021-libxl-xl-add-cacheability-option-to-iomem.patch \
    file://422/0022-Fix-machine-type.patch \
"
