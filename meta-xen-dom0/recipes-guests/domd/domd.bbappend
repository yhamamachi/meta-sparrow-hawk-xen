FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domd.cfg"

do_install:append() {
    # sed -i ${CFG_FILE} -e "s/vcpus = 4/vcpus = 8/"
    sed -i ${CFG_FILE} -e "s/memory = 1024/memory = 756/"
    sed -i ${CFG_FILE} -e 's/    "47fc7,2@37fc7",/   #"47fc7,2@37fc7"/'
    echo 'cpus="0-3"' >> ${CFG_FILE}
}

