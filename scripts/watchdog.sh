#!/bin/sh

# wait for avahi first startup
until [[ $(ps aux | grep dbus-daemon | grep -v grep | wc -l) -gt 0 ]]; do
    sleep 1s
done

until [[ $(ps aux | grep dbus-daemon | grep -v grep | wc -l) -eq 0 ]] || [[ $(ps aux | grep avahi-daemon | grep -v grep | wc -l) -eq 0 ]]; do
    sleep 3s
done

kill $(pidof owntone)