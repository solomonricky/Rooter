#!/bin/sh 

ROOTER=/usr/lib/rooter
ROOTER_LINK="/tmp/links"

log() {
	modlog "PostConnect $CURRMODEM" "$@"
}

CURRMODEM=$1
idV=$(uci -q get modem.modem$CURRMODEM.idV)
idP=$(uci -q get modem.modem$CURRMODEM.idP)
CPORT=$(uci get modem.modem$CURRMODEM.commport)

log "Running PostConnect script"

if [ -e /usr/lib/scan/emailchk.sh ]; then
	/usr/lib/scan/emailchk.sh &
fi

#script by Abi Darwish

IPVAR=$(uci -q get modem.modeminfo$CURRMODEM.pdptype)
if [ ${IPVAR} = "IP" ] || [ ${IPVAR} = "0" ]; then
	echo 1 >/proc/sys/net/ipv6/conf/all/disable_ipv6
	sed -i 's/net.ipv6.conf.default.forwarding/#net.ipv6.conf.default.forwarding/' /etc/sysctl.d/10-default.conf
	sed -i 's/net.ipv6.conf.all.forwarding/#net.ipv6.conf.all.forwarding/' /etc/sysctl.d/10-default.conf
	sysctl -e -q -p /etc/sysctl.d/*.conf
	uci -q batch <<-EOF >/dev/null
		delete network.globals.ula_prefix
		delete network.lan.ip6assign
		delete network.wan6
		delete dhcp.lan.ra
		delete dhcp.lan.ra_management
		delete dhcp.lan.dhcpv6
		delete dhcp.lan.ndp
		set network.@device[0].ipv6='0'
		commit network
		commit dhcp
	EOF
	ifup lan
	log "IPv6 disabled"
else
	echo 0 >/proc/sys/net/ipv6/conf/all/disable_ipv6
	sed -i 's/#net.ipv6.conf.default.forwarding/net.ipv6.conf.default.forwarding/' /etc/sysctl.d/10-default.conf
	sed -i 's/#net.ipv6.conf.all.forwarding/net.ipv6.conf.all.forwarding/' /etc/sysctl.d/10-default.conf
    sysctl -e -q -p /etc/sysctl.d/*.conf

	[ "$(uci -q get network.globals.ula_prefix)" != "auto" ]
	r1=$(dd if=/dev/urandom bs=1 count=1 |hexdump -e '1/1 "%02x"')
	r2=$(dd if=/dev/urandom bs=2 count=1 |hexdump -e '2/1 "%02x"')
	r3=$(dd if=/dev/urandom bs=2 count=1 |hexdump -e '2/1 "%02x"')

	uci -q batch <<-EOF >/dev/null
		set dhcp.lan.ra='server'
		set dhcp.lan.dhcpv6='server'
		add_list dhcp.lan.ra_flags='managed-config'
		add_list dhcp.lan.ra_flags='other-config'
		set network.globals.ula_prefix=fd$r1:$r2:$r3::/48
		set network.lan.ip6assign='64'
		set network.@device[0].ipv6='1'
		add_list network.lan.ip6class='wan1'
		commit network
		commit dhcp
	EOF
	ifup lan
	log "IPv6 enable"
fi

DNS1=$(uci -q get modem.modeminfo$CURRMODEM.dns1)
if [ ! -z ${DNS1} ]; then
	log "Set Public Nameserver"
	echo -e "nameserver ${DNS1}" >/tmp/resolv.conf.d/resolv.conf.auto
	log "Nameserver ${DNS1}"
fi
DNS2=$(uci -q get modem.modeminfo$CURRMODEM.dns2)
if [ ! -z ${DNS2} ]; then
	echo -e "nameserver ${DNS2}" >>/tmp/resolv.conf.d/resolv.conf.auto
	log "Nameserver ${DNS2}"
fi
DNS3=$(uci -q get modem.modeminfo$CURRMODEM.dns3)
if [ ! -z ${DNS3} ]; then
	echo -e "nameserver ${DNS3}" >>/tmp/resolv.conf.d/resolv.conf.auto
	log "Nameserver ${DNS3}"
fi
DNS4=$(uci -q get modem.modeminfo$CURRMODEM.dns4)
if [ ! -z ${DNS4} ]; then
	echo -e "nameserver ${DNS4}" >>/tmp/resolv.conf.d/resolv.conf.auto
	log "Nameserver ${DNS4}"
fi
