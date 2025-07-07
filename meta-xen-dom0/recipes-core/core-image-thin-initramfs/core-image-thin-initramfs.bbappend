DEPENDS += "u-boot-mkimage-native dtc-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
inherit deploy
inherit externalsrc
EXTERNALSRC_SYMLINKS = ""

# do_unpack is not supported with inherit core-image.
# Thus, we need to copy file manually.
BBAPPEND_FILE_PATH := "${THISDIR}"
do_copy_files () {
    cp -f ${BBAPPEND_FILE_PATH}/files/fit-image.its -t ${WORKDIR}/
}
addtask do_copy_files before do_image_complete

generate_fit_image() {
    cd ${WORKDIR}
    cp -f ${DEPLOY_DIR_IMAGE}/Image ./Image
    cp -f ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.cpio.gz ./uInitramfs
    cp -f ${S}/xen-*.efi ./xen
    cp -f ${S}/xenpolicy-4.* ./xenpolicy
    cp -f ${S}/${XT_XEN_DTB_NAME} ./xen.dtb
    cp -f ${S}/bl31-*.bin ./bl31.bin
    mkimage -f ./fit-image.its ${DEPLOY_DIR_IMAGE}/fitImage
}

IMAGE_POSTPROCESS_COMMAND += " generate_fit_image"

