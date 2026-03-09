# Plepare cpio.gz
IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"

# Add Xen related packages
IMAGE_INSTALL:append = " xen-tools xen-tools-xencommons"
IMAGE_INSTALL:append = " ${XT_GUEST_INSTALL}"

DEPENDS += "u-boot-mkimage-native dtc-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
inherit deploy
inherit externalsrc
EXTERNALSRC_SYMLINKS = ""

generate_uboot_image() {
    uboot-mkimage -A arm64 -O linux -T ramdisk -C gzip -n "uInitramfs" \
        -d ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz  ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz.uInitramfs
    ln -sfr  ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz.uInitramfs ${DEPLOY_DIR_IMAGE}/uInitramfs
}

IMAGE_POSTPROCESS_COMMAND += " generate_uboot_image; "
IMAGE_ROOTFS_SIZE = "65535"
INITRAMFS_MAXSIZE = "262144"

# do_unpack is not supported with inherit core-image.
# Thus, we need to copy file manually.
BBAPPEND_FILE_PATH := "${THISDIR}"
do_copy_files () {
    cp -f ${BBAPPEND_FILE_PATH}/files/fit-image.its -t ${WORKDIR}/
    cp -f ${BBAPPEND_FILE_PATH}/files/boot.cmd -t ${WORKDIR}/
}
addtask do_copy_files before do_image_complete

generate_fit_image() {
    cd ${WORKDIR}
    cp -f ${DEPLOY_DIR_IMAGE}/Image ./Image
    cp -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz ./uInitramfs
    cp -f ${S}/xen-*.efi ./xen
    cp -f ${S}/xenpolicy-4.* ./xenpolicy
    cp -f ${S}/${XT_XEN_DTB_NAME} ./xen.dtb
    cp -f ${S}/bl31-*.bin ./bl31.bin
    mkimage -f ./fit-image.its ${DEPLOY_DIR_IMAGE}/fitImage
}

IMAGE_POSTPROCESS_COMMAND += " generate_fit_image"

