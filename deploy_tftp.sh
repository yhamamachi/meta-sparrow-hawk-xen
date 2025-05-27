#!/bin/bash -eu

YAML_FILE=https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar-gen4/refs/heads/v4h_demo/prod-devel-rcar4.yaml
SCRIPT_DIR=$(cd `dirname $0` && pwd)
WORK_DIR=${SCRIPT_DIR}/work_v4hsbc_xen
mkdir -p ${WORK_DIR}

cd $WORK_DIR/yocto/build-domd/tmp/deploy/images/sparrow-hawk/
cp -f Image boot-tftp.uImage -t /tftp/v4hsbc_xen/
cp -f r8a779g3-sparrow-hawk-xen.dtb /tftp/v4hsbc_xen/xen.dtb
cp -f xen-uImage /tftp/v4hsbc_xen/xen
cp -f xenpolicy-sparrow-hawk /tftp/v4hsbc_xen/xenpolicy
cd $WORK_DIR/yocto/build-dom0/tmp/deploy/images/generic-armv8-xt/
cp -f uInitramfs -t /tftp/v4hsbc_xen/

