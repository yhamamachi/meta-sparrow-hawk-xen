FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# From meta-sparrow-hawk
require recipes-kernel/linux/kernel_6.12.inc
# Workaround: Fix Kernel version sanity check error
LINUX_VERSION = "6.12.58"

SRC_URI = "\
    ${REPO};branch=${BRANCH};protocol=https \
    file://defconfig \
"

