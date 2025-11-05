
PACKAGECONFIG:append = " libnftnl"
do_install:append() {
        rm -f ${D}${sysconfdir}/ethertypes
}

