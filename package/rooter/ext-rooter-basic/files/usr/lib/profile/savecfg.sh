#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Save" "$@"
}

PKI_DIR="/www"
cd ${PKI_DIR}
mkdir -p package
cd ..
chmod -R 0777 ${PKI_DIR}/package

echo "***Profile***" > ${PKI_DIR}/package/profilecfg.profile
state=$(cat /etc/config/profile)
echo "$state" >> ${PKI_DIR}/package/profilecfg.profile

log "Restart modem"
ATCMDD="AT+CFUN=1,1"
ROOTER=/usr/lib/rooter
CURRMODEM=$(uci get modem.general.miscnum)
COMMPORT="/dev/ttyUSB"$(uci get modem.modem$CURRMODEM.commport)
OX=$($ROOTER/gcom/gcom-locked "$COMMPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
echo "$OX"