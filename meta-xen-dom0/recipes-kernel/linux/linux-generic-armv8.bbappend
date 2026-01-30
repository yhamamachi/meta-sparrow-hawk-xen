FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# From meta-sparrow-hawk
require recipes-kernel/linux/kernel_6.12.inc

SRC_URI = "\
    ${REPO};branch=${BRANCH};protocol=https \
    file://defconfig \
"

