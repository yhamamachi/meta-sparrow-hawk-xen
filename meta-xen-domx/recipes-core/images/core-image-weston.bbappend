IMAGE_INSTALL:append = " \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-tools-xencommons \
    xen-network \
    dnsmasq \
"

# For Xen-network
IMAGE_INSTALL:append = " \
    kernel-module-xt-masquerade \
    kernel-module-xt-nat \
    kernel-module-xt-tcpudp \
"

IMAGE_INSTALL:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' qemu-system-aarch64 qemu-keymaps', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'lisot', '', d)} \
"

