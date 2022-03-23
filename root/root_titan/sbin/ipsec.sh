#!/bin/sh -x

clean=0
ARCH=$(cat /etc/.arch)

if [ "$1" == "remove" ];then
	opkg remove strongswan --force-removal-of-dependent-packages
	opkg remove kernel-module-aes-generic --force-removal-of-dependent-packages
	opkg remove kernel-module-sha1-generic --force-removal-of-dependent-packages
	opkg remove iptables --force-removal-of-dependent-packages
	exit
fi

if [ "$1" == "install" ];then
	# work
	touch /tmp/progress
	mount --bind /tmp/progress /proc/progress

	sleep 2
	opkg update

	if [ -e "/var/usr/local/share/titan/plugins/ipsecstarter/skin/background.jpg" ];then
		infobox 100 "progressbar#/var/usr/local/share/titan/plugins/ipsecstarter/skin/background.jpg" 85 85 &
	elif [ -e "/mnt/swapextensions/usr/local/share/titan/plugins/ipsecstarter/skin/background.jpg" ];then
		infobox 100 "progressbar#/mnt/swapextensions/usr/local/share/titan/plugins/ipsecstarter/skin/background.jpg" 85 85 &
	elif [ -e "/var/swap/usr/local/share/titan/plugins/ipsecstarter/skin/background.jpg" ];then
		infobox 100 "progressbar#/var/swap/usr/local/share/titan/plugins/ipsecstarter/skin/background.jpg" 85 85 &
	fi

	echo 5 > /proc/progress
	check1=`opkg list_installed strongswan | wc -l`
	check2=`opkg list_installed iptables | wc -l`
	if [ "$check1" == 0 ] || [ "$check2" == 0 ];then
		opkg install strongswan --force-reinstall
		echo 10 > /proc/progress
		opkg install kernel-module-aes-generic --force-reinstall
		echo 15 > /proc/progress
		opkg install kernel-module-sha1-generic --force-reinstall
		echo 20 > /proc/progress
		opkg install iptables --force-reinstall
		opkg install iptables-module-xt-policy --force-reinstall
		echo 35 > /proc/progress
		if [ "$ARCH" == "sh4" ];then /etc/init.d/networking restart; fi
		clean=1
	fi
fi

if [ "$1" == "start" ];then
	opkg update
	check1=`opkg list_installed strongswan | wc -l`
	check2=`opkg list_installed iptables | wc -l`
	if [ "$check1" == 0 ] || [ "$check2" == 0 ];then
		opkg install strongswan --force-reinstall
#		opkg install kernel-module-aes-generic --force-reinstall
#		opkg install kernel-module-sha1-generic --force-reinstall
		opkg install iptables --force-reinstall
		if [ "$ARCH" == "sh4" ];then /etc/init.d/networking restart; fi
	fi
	if [ -e /mnt/network/ipsec.conf ];then cp /mnt/network/ipsec.conf /etc;fi
	if [ -e /mnt/network/ipsec.secrets ];then cp /mnt/network/ipsec.secrets /etc;fi

echo ipsec start
	ipsec start
echo sleep 5

sleep 5
	#route=$(ifconfig | sed 's/^$/#/g' | tr '\n' ' ' | tr '#' '\n' | grep Bcast: | awk '{ DEV=$1;gsub(/.*Bcast:/, "", $a); gsub(/.255 .*/, ".0/24 dev " DEV, $a); print $a}')
	route=$(route | grep -v 'default\|Destination\|Kernel' | awk '{ print $1 "/24 dev " $8}')
echo ip route add table 220 $route
	ip route add table 220 $route
echo sleep 5
sleep 5

	name=$(cat /etc/ipsec.conf | grep conn | grep -v %default | awk '{ print $2 }')
echo ipsec up $name

	ipsec up $name
fi

if [ "$1" == "stop" ];then
	name=$(cat /etc/ipsec.conf | grep conn | grep -v %default | awk '{ print $2 }')
	ipsec down $name
	ipsec stop
fi

if [ "$1" == "restart" ];then
	ipsec restart
fi
