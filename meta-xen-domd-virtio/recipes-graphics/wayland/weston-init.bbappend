FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_install:prepend() {
    sed -i ${WORKDIR}/weston.ini \
        -e '$a shell=kiosk-shell.so' \
        -e '$a [output]' \
        -e '$a name=DP-1' \
        -e '$a app-ids=DomU' \
        -e '$a [output]' \
        -e '$a name=DSI-1' \
        -e '$a app-ids=DomA' \

    sed -i ${WORKDIR}/weston.service \
        -e 's|/usr/bin/weston|/usr/bin/weston --debug --log=/tmp/weston|'
}

