#!/bin/sh

USER=owntone

echo "---Setup Timezone to ${TZ}---"
echo "${TZ}" > /etc/timezone
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
groupmod -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Setup audio devices permissions---"
/opt/scripts/fix-audio-permission.sh

echo "---Setup config file if not exits---"
mkdir -p \
    /config \
    /owntone-pidfolder

/opt/scripts/config.sh

echo "---Taking ownership of data...---"
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${UID}:${GID} /music /config /owntone-pidfolder
chmod -R ${DATA_PERM} /music /config

echo "---Starting owntone server...---"
/opt/scripts/services.sh

term_handler() {
	kill -SIGTERM $(pidof owntone)
	wait "$killpid" -f 2>/dev/null
	exit 143;
}
trap 'kill ${!}; term_handler' SIGTERM

/opt/scripts/watchdog.sh &
gosu ${USER} /usr/sbin/owntone -f -P /owntone-pidfolder/owntone.pid &

killpid="$!"
while true
do
	wait $killpid
	exit 0;
done