IMAGE_INSTALL:append = " \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-tools-xencommons \
    xen-network \
    dnsmasq \
    nftables \
    weston-notification \
"

# For Xen-network
IMAGE_INSTALL:append = " \
    kernel-module-xt-masquerade \
    kernel-module-xt-nat \
    kernel-module-xt-tcpudp \
"

IMAGE_INSTALL:append = " \
    glmark2 \
    coreutils \
"

IMAGE_INSTALL:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' qemu-system-aarch64 qemu-keymaps', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio wayland', ' virglrenderer libsdl2', '', d)} \
"

# Add package if DomA is available
IMAGE_INSTALL:append = " \
    ${@bb.utils.contains('XT_GUEST_INSTALL', 'doma', ' android-tools install-files-doma', '', d)} \
"

# Add extra storage for disk test
## 1G: 1048576, 4G: 4194304, 6G: 6291456
IMAGE_ROOTFS_EXTRA_SPACE = "6291456"

