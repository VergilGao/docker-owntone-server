#!/bin/sh

until [[ $(ps aux | grep dbus-daemon | grep -v grep | wc -l) -eq 0 ]]; do
    if [ $(ps aux | grep avahi-daemon | grep -v grep | wc -l) -eq 0 ]; then
        avahi-daemon --no-chroot &
    fi
    sleep 3s
done

kill $(pidof owntone)