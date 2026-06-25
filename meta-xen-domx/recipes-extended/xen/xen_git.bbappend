require xen-source.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " \
    file://config.cfg \
"

# We are dropping TUNE_CCARGS from for Xen because it won't build for armv8.2, as
# it conflicts with -mcpu=generic provided by own Xen build system
HOST_CC_ARCH:remove="-march=armv8.2-a+crypto"
HOST_CC_ARCH:remove="-mcpu=cortex-a55"

DEPENDS += "u-boot-mkimage-native checkpolicy-native"

do_configure:append () {
    cd ${S}
    # Remove 3sec delay
    sed -i xen/common/warning.c \
        -e '/for ( i = 0; i < 3; i++ )/,+9d' \
        -e 's/, j//'
}

