FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domu.cfg"

do_install:append() {
    sed -i ${CFG_FILE} -e "s/vcpus = 2/vcpus = 4/"
    sed -i ${CFG_FILE} -e "s/memory = 512/memory = 1536/"
    sed -i ${CFG_FILE} -e 's/    "47fc9,2@37fc9",/   #"47fc9,2@37fc9",/'
    echo 'cpus="4-7"' >> ${CFG_FILE}
}

