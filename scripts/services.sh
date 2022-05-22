#!/bin/sh

mkdir -p \
    /var/run/dbus \
    /run/dbus

[[ -e /var/run/dbus.pid ]] && \
    rm -f /var/run/dbus.pid

[[ -e /run/dbus/dbus.pid ]] && \
    rm -f /run/dbus/dbus.pid

dbus-uuidgen --ensure
dbus-daemon --system --nofork &

until [[ -e /var/run/dbus/system_bus_socket ]]; do
    sleep 1s
done
avahi-daemon --no-chroot &