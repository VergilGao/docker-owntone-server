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

[[ -e /var/run/avahi-daemon/pid ]] && \
    rm -f /var/run/avahi-daemon/pid

[[ -e /run/avahi-daemon/pid ]] && \
    rm -f /run/avahi-daemon/pid

until [[ -e /var/run/dbus/system_bus_socket ]]; do
    sleep 1s
done
avahi-daemon --no-chroot &