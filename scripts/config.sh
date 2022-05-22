#!/bin/sh

if [ ! -e "/etc/owntone.conf.default" ]; then
    cp /etc/owntone.conf.orig /etc/owntone.conf.default
    sed -i \
        -e '/cache_path\ =/ s/# *//' \
        -e '/db_path\ =/ s/# *//' \
        -e s#ipv6\ =\ yes#ipv6\ =\ no#g \
        -e s#My\ Music\ on\ %h#Unraid\ Server#g \
        -e s#/srv/music#/music#g \
        -e 's/\(uid.*=\).*/\1 \"owntone\"/g' \
        -e s#/var/cache/owntone/cache.db#/config/cache.db#g \
        -e s#/var/cache/owntone/songs3.db#/config/songs3.db#g \
        -e s#/var/log/owntone.log#/config/owntone.log#g \
        /etc/owntone.conf.default
fi

[[ ! -f /config/owntone.conf ]] && \
    cp /etc/owntone.conf.default /config/owntone.conf
[[ ! -L /etc/owntone.conf && -f /etc/owntone.conf ]] && \
    rm /etc/owntone.conf
[[ ! -L /etc/owntone.conf ]] && \
    ln -s /config/owntone.conf /etc/owntone.conf