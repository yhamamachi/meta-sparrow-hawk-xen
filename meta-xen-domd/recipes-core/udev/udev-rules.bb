SUMMARY = "udev rules for Driver domain"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://90-touchscreen.rules \
"

do_install () {
    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${WORKDIR}/90-touchscreen.rules ${D}${sysconfdir}/udev/rules.d/
}

