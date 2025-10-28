#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
cd /dev/shm

# Wait for DomA network is active, then connect ADB via TCP
DOMA_IP="192.168.2.4"
while ! ping -c 1 -W 1 $DOMA_IP; do
    echo "Waiting for $DOMA_IP to be reachable..."
    sleep 1
done
adb connect $DOMA_IP:5555

for apk in $(ls /usr/bin/apks/*.apk); do
    adb install $apk
done
adb shell sync

echo "apk files are installed"

