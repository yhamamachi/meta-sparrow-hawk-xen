DESCRIPTION = "AGL Cluster reference GUI"
LICENSE = "Apache-2.0"
VERSION = "1.0.0"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=5335066555b14d832335aa4660d6c376"

PACKAGE_ARCH = "${MACHINE_ARCH}"

S = "${WORKDIR}/git"
BRANCH = "master"
SRC_URI="git://git.automotivelinux.org/src/cluster-refgui;branch=${BRANCH};protocol=http"
SRCREV = "5c8f09d2c3c99f621b467ed5c1be4fac3a708e85"

SRC_URI:append = " \
    file://0001-Fix-deprecated-syntax.patch \
    file://cluster.service \
"
SYSTEMD_SERVICE:${PN} = "cluster.service"

do_install:append() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/cluster.service ${D}${systemd_unitdir}/system/
}

#inherit pkgconfig cmake cmake_qt5
inherit pkgconfig cmake qt6-cmake systemd

FILES:${PN}:append = " \
    /opt/apps/cluster \
"

DEPENDS:append = " \
    qttools-native \
    qtmultimedia \
    cluster-service \
"

RDEPENDS:${PN} = " \
    qtbase \
    qtdeclarative \
    qt3d \
    qtmultimedia \
    qtwayland \
    qt5compat \
"



