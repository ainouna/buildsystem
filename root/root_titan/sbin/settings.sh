#!/bin/sh

#----------------------- USAGE -------------------------------------------------
# /sbin/settings restore        -> restore settings on startup
# /sbin/settings backup         -> settings backup without touching .firstrun file (only backup your settings)
# GREETZ Civer
#-------------------------------------------------------------------------------

TYPE=$1
ret=0

boxtype=`cat /etc/model`

if [ -e /etc/.oebuild ];then
	TMPDIR=/media
	LOG=$TMPDIR/hotplug.log
	MAINDIR=$2
	backpath="$MAINDIR/$boxtype"
else
	TMPDIR=/tmp
	LOG=$TMPDIR/hotplug.log
	backpath="/var/backup"
fi

ocp()
{
	if [ -e "$1" ]; then
		mkdir -p "$2"
		if [ `ls -l "$1" | wc -l` == "0" ]; then return; fi
		cp -a "$1"/* "$2"
		if [ $? -ne 0 ]; then ret=1; fi
	fi
}

ocpdir()
{
	if [ -e "$1" ]; then
		mkdir -p "$2"
		cp -RP "$1" "$2"
		if [ $? -ne 0 ]; then ret=1; fi
	fi
}	

### backup ###
if [ "$TYPE" == "backup" ]; then
	if [ -e /etc/.oebuild ];then
		if [ ! -e $MAINDIR ]; then exit 1; fi
	else
		if [ ! -e $TMPDIR/.backupdev ]; then exit 1; fi
	fi
	echo "[settings.sh] Backup your settings to $backpath!"

	if [ ! -e /etc/.oebuild ];then
		if [ ! -d "$backpath/settings" ]; then rm -f "$backpath/settings"; mkdir -p "$backpath/settings"; fi
		if [ ! -d "$backpath/config" ]; then rm -f "$backpath/config"; mkdir -p "$backpath/config"; fi
		if [ ! -d "$backpath/network" ]; then rm -f "$backpath/network"; mkdir -p "$backpath/network"; fi
		if [ ! -d "$backpath/script" ]; then rm -f "$backpath/script"; mkdir -p "$backpath/script"; fi
		if [ ! -d "$backpath/tpk" ]; then rm -f "$backpath/tpk"; mkdir -p "$backpath/tpk"; fi
		if [ ! -d "$backpath/keys" ]; then rm -f "$backpath/keys"; mkdir -p "$backpath/keys"; fi
		if [ ! -d "$backpath/player" ]; then rm -f "$backpath/player"; mkdir -p "$backpath/player"; fi
		if [ ! -d "$backpath/boot" ]; then rm -f "$backpath/player"; mkdir -p "$backpath/boot"; fi

		rm -rf "$backpath"/settings/*
		rm -rf "$backpath"/config/*
		rm -rf "$backpath"/network/*
		rm -rf "$backpath"/script/*
		rm -rf "$backpath"/tpk/*
		rm -rf "$backpath"/keys/* 
		rm -rf "$backpath"/player/* 
	fi

	if [ ! -e /etc/.oebuild ];then		
		ocp /mnt/settings "$backpath/settings"
		ocp /mnt/config "$backpath/config"
		ocp /mnt/network "$backpath/network"
		ocp /mnt/script "$backpath/script"
		ocp /mnt/tpk "$backpath/tpk"
		ocp /mnt/swapextensions/keys "$backpath/keys" 
		ocp /mnt/swapextensions/player "$backpath/player" 
	else
		rm -r "$backpath"
		mkdir -p "$backpath/boot"
		mkdir -p "$backpath/etc/samba/private"
		ocp /mnt "$backpath"
		cp /usr/share/*.mvi "$backpath"/boot/
		cp /etc/samba/private/smbpasswd "$backpath"/etc/samba/private
		cp /etc/passwd "$backpath"/etc
		cp /etc/shadow "$backpath"/etc
		cp /etc/ipsec.conf "$backpath"/etc
		cp /etc/ipsec.secrets "$backpath"/etc
		cp /etc/vtuner.conf "$backpath"/etc
	fi
	

	#set version of tpk to 0, so we can update all tpk
	sed "s/Version:.*/Version: 0/" -i "$backpath"/tpk/*/control

	if [ -e /etc/.oebuild ];then
		BACKUPTIME=`date "+%Y%m%d"`
		echo "$BACKUPTIME > $backpath/.last"
		echo "$BACKUPTIME" > $backpath/.last
		rm $backpath/.last.restored
	fi

	sync
	exit $ret
fi

### restore ###
if [ "$TYPE" == "restore" ]; then
	if [ -e /etc/.oebuild ];then
		if [ ! -e $MAINDIR ]; then exit 1; fi
	else
		if [ ! -e $TMPDIR/.backupdev ]; then exit 1; fi
	fi

	echo "[settings.sh] Restoring your settings from $backpath!"

	if [ ! -e /etc/.oebuild ];then	
		ocp "$backpath/settings" /mnt/settings/
		ocp "$backpath/config" /mnt/config/
		ocp "$backpath/network" /mnt/network/
		ocp "$backpath/script" /mnt/script/
		ocp "$backpath/tpk" /mnt/tpk/
		ocp "$backpath/keys" /mnt/swapextensions/keys/ 
		ocp "$backpath/player" /mnt/swapextensions/player/ 
	else
		rm -r /mnt
		ocp "$backpath" /mnt/ 
		cp "$backpath"/boot/* /usr/share/
		cp -a "$backpath"/etc/* /etc/
	fi

	chmod 664 /mnt/network/*

	if [ ! -e /etc/.oebuild ];then
		sync-start-config.sh
		sync-titan-config.sh
	fi

	if [ -e /etc/.oebuild ];then
		mv -f $backpath/.last $backpath/.last.restored
	fi

	sync
	exit $ret
fi

echo "[settings.sh] not used...."
