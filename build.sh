#!/bin/bash -eu

YAML_FILE=https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar-gen4/refs/heads/v4h_demo/prod-devel-rcar4.yaml
SCRIPT_DIR=$(cd `dirname $0` && pwd)
WORK_DIR=${SCRIPT_DIR}/work_v4hsbc_xen
mkdir -p ${WORK_DIR}

# GFX package
GFX_DRV="https://github.com/renesas-rcar/rcar-gfx/raw/refs/heads/V4Hx/v1.3.1-2/gfxdrv/GSX_KM_V4H.tar.bz2"
GFX_LIB="https://github.com/renesas-rcar/rcar-gfx/raw/refs/heads/V4Hx/v1.3.1-2/opengl/r8a779g0_linux_gsx_binaries_gles.tar.bz2"
mkdir -p ${SCRIPT_DIR}/prop; cd ${SCRIPT_DIR}/prop
wget -c ${GFX_DRV}
wget -c ${GFX_LIB}
cp -f ./GSX_KM_V4H.tar.bz2 ${WORK_DIR}/GSX_KM_V4H_DDK23.3_v2.tar.bz2
cp -f ./r8a779g0_linux_gsx_binaries_gles.tar.bz2 ${WORK_DIR}/r8a779g0_linux_gsx_binaries_gles_vz_DDK23.3_v2.tar.bz2

cd ${WORK_DIR}
curl -LO https://raw.github.com/xen-troops/meta-xt-prod-devel-rcar-gen4/v4h_demo/prod-devel-rcar4.yaml
sed -i -e "s/4.17.0+git%/4.19.0+git%/" prod-devel-rcar4.yaml
# Remove MACHINE parameter because it is contained append yaml file.
sed -i '/^  MACHINE/,+39d' prod-devel-rcar4.yaml
sed -i -e 's/wayland//' -e 's/opengl//' prod-devel-rcar4.yaml
sed -i -e 's/- \[MACHINE_FEATURES:remove, " gsx"\]//' prod-devel-rcar4.yaml
sed -i -e 's/rcar-image-adas/core-image-weston/' prod-devel-rcar4.yaml
cat prod-devel-rcar4.yaml ../add_meta_test.yaml > prod-devel-rcar4_new.yaml

moulin prod-devel-rcar4_new.yaml \
    --MACHINE sparrow-hawk \
    --ENABLE_DOMU no \
    --ADD_META_TEST yes \

ninja fetch-domd
git -C yocto/meta-xt-prod-devel-rcar-gen4 reset --hard
# Change to use xen 4.19
cat << EOS > yocto/meta-xt-prod-devel-rcar-gen4/meta-xt-domx-gen4/recipes-extended/xen/xen-source.inc
SRC_URI = "git://github.com/xen-troops/xen.git;protocol=https;branch=xen-4.19-xt0.2"
XEN_REL = "4.19"
XEN_REV = "8d17019373ad2d0928dfe9ce1ee4e3805209fc6c"
LIC_FILES_CHKSUM = "file://COPYING;md5=d1a1e216f80b6d8da95fec897d0dbec9"
EOS
sed -i yocto/meta-xt-prod-devel-rcar-gen4/meta-xt-domx-gen4/recipes-extended/xen/xen-tools_git.bbappend -e 's/^SYSTEMD_SERVICE:${PN}-pcid/#SYSTEMD_SERVICE:${PN}-pcid/'
sed -i -e "7,8d" yocto/meta-xt-prod-devel-rcar-gen4/meta-xt-driver-domain-gen4/recipes-extended/xen/xen_git.bbappend
echo "SYSTEMD_SERVICE:xen-tools-xencommons:remove = 'var-lib-xenstored.mount'" >> yocto/meta-xt-prod-devel-rcar-gen4/meta-xt-domx-gen4/recipes-extended/xen/xen-tools_git.bbappend
echo 'FILES:${PN} += "/var/lib /usr/lib/xen/bin/*"' >> yocto/meta-xt-prod-devel-rcar-gen4/meta-xt-domx-gen4/recipes-extended/xen/xen-tools_git.bbappend
sed -i -e "7,9d" yocto/meta-xt-prod-devel-rcar-gen4/meta-xt-prod-devel-rcar-control-gen4/recipes-extended/xen/xen-tools_git.bbappend

# Remove xen boot delay 3sec
sed -i yocto/meta-xt-prod-devel-rcar-gen4/meta-xt-domx-gen4/recipes-extended/xen/xen_git.bbappend -e "/do_configure:append/,+6d"
cat << 'EOS' >> yocto/meta-xt-prod-devel-rcar-gen4/meta-xt-domx-gen4/recipes-extended/xen/xen_git.bbappend
do_configure:append () {
    cd ${S}
    # Remove 3sec delay
    sed -i xen/common/warning.c \
        -e '/for ( i = 0; i < 3; i++ )/,+9d' \
        -e 's/, j//'
}
EOS

# Remove unused memory assign
#cat << 'EOS' >> yocto/meta-xt-prod-devel-rcar-gen4/meta-xt-domd-gen4/recipes-kernel/linux/linux-renesas_%.bbappend
#do_compile:prepend() {
#    sed -i ${S}/arch/arm64/boot/dts/renesas/r8a779g0-whitehawk.dts \
#        -e "/linux,cr_region@60000000/,+3d"
#    sed -i ${S}/arch/arm64/boot/dts/renesas/r8a779g0-domd.dts \
#        -e "/cr_region/d" -e "/linux,cma@80000000/,+6d"
#}
#EOS

ninja
ninja full.img.gz
ninja boot_artifacts
# 
# cd yocto/build-domd/tmp/deploy/images/sparrow-hawk/
# cp -f Image boot-tftp.uImage -t /tftp/v4hsbc_xen/
# cp -f r8a779g3-sparrow-hawk-xen.dtb /tftp/v4hsbc_xen/xen.dtb
# cp -f xen-sparrow-hawk /tftp/v4hsbc_xen/xen
# cp -f xenpolicy-sparrow-hawk /tftp/v4hsbc_xen/xen-policy
# cd $WORK_DIR/yocto/build-dom0/tmp/deploy/images/generic-armv8-xt/
# cp -f uInitramfs -t /tftp/v4hsbc_xen/

