#!/bin/sh

startmode="$1"
SWTYPE="$2"
model="$3"
if [ -e /mnt/config/titan.cfg ];then
	event=`cat /mnt/config/titan.cfg | grep rcdev= | tr '/' '\n' | tail -n1`
else
	event=`cat /etc/titan.restore/mnt/config/titan.cfg | grep rcdev= | tr '/' '\n' | tail -n1`
fi

SWTYPE=titan

#case $model in "") read model < /etc/model;; esac
read model < /etc/model

[[ -z $MDEV ]] && MDEV=$(basename $DEVNAME)

if [ -e /etc/.oebuild ];then
	MAINDIR=/media/autofs
	TMPDIR=/media
	LOG=$TMPDIR/hotplug.log
	MMC=mmc-oe
	USB=usb-oe
else
	MAINDIR=/autofs
	TMPDIR=/tmp
	LOG=$TMPDIR/hotplug.log
	MMC=mmc
	USB=usb
fi

case $model in "") read model < /etc/model;; esac

. /sbin/start-function

startRepairdev()
{
	echo "[$0] startRepairdev: device=$1" >> $LOG
	sync
	#make a second mount check
	sleep 2
	ls -d "$MAINDIR/$device" > /dev/null
	case $? in
		0) 
				echo "[$0] startRepairdev: second mount for $device ok, no fschk" >> $LOG
				sync;;
		*)
				killall -stop rcS
				killall -stop "$SWTYPE"			
				infobox 9999 "INFO" "Das Geraet /dev/$device konnte nicht eingebunden werden" "Soll ein Filesystemcheck durchgefuehrt werden ?" "In 30 Sek. wird automatisch ein Filesystemcheck durchgefuehrt" "" "OK = Filesystemcheck durchfuehren" "EXIT = kein Filesystemcheck" &
				echo "FSCK:$device ?" > /dev/vfd
				(sleep 30; killall abfrage) &
				pid=$!
				abfrage /dev/input/$event; ret=$?
				echo " " > /dev/vfd
				kill -9 $pid
				killall infobox
				case $ret in
					1)																	
						echo "FSCK: NO"
						echo "FSCK: NO" > /dev/vfd;;
					*)	
						echo "FSCK: $device"
						echo "FSCK: $device" > /dev/vfd
						startFsck "$device";;
				esac
				killall -cont "$SWTYPE"
				killall -cont rcS;;
	esac
}

startStickextensions() {
	echo "[$0] startStickextensions: device=$device label=$label type=$type" >> $LOG
	sync
	
	if [ "$1" != "/var/swap" ] && [ "$1" != "/mnt/swapextensions" ]; then
		echo "[$0] startStickextensions: parameter not ok ($1)"
		return
	fi
	
	if [ "$1" == "/var/swap" ]; then
		if [ ! -L "$1" ]; then
			echo "[$0] startStickextensions: $1 is not a link device=$device label=$label type=$type" >> $LOG
			sync
			return
		fi
	fi
	
	if [ ! -e "$1/etc" ]; then mkdir -p "$1/etc"; fi
	if [ ! -e "$1/bin" ]; then mkdir -p "$1/bin"; fi
	if [ ! -e "$1/lib/modules" ]; then mkdir -p "$1/lib/modules"; fi
	if [ ! -e "$1/keys" ]; then mkdir -p "$1/keys"; fi
	if [ ! -e "$1/boot" ]; then mkdir -p "$1/boot"; fi

	if [ ! -e "$1/usr/local/share/titan/saver" ]; then mkdir -p "$1/usr/local/share/titan/saver"; fi
	if [ ! -e "$1/usr/local/share/titan/picons" ]; then mkdir -p "$1/usr/local/share/titan/picons"; fi
	if [ ! -e "$1/usr/local/share/titan/skin" ]; then mkdir -p "$1/usr/local/share/titan/skin"; fi
	if [ ! -e "$1/usr/local/share/titan/plugins" ]; then mkdir -p "$1/usr/local/share/titan/plugins"; fi
	if [ ! -e "$1/usr/local/share/titan/imdbfolder" ]; then mkdir -p "$1/usr/local/share/titan/imdbfolder"; fi

	LIST=`ls -1 "$1/usr/local/share/titan/plugins"`
	for ROUND in $LIST; do
		if [ ! -e "/var/usr/local/share/titan/plugins/$ROUND" ]; then
			ln -s "$1/usr/local/share/titan/plugins/$ROUND" "/var/usr/local/share/titan/plugins/$ROUND"
		fi
	done

	LIST=`ls -1 "$1/lib/modules"`
	for ROUND in $LIST; do
		if [ ! -e "/var/lib/modules/$ROUND" ]; then
			ln -s "$1/lib/modules/$ROUND" "/var/lib/modules/$ROUND"
		fi
	done
}

startCheckdev()
{
	#in dieser funkton können device checks aufgerufen werden
	
	echo "[$0] startCheckdev: device=$device label=$label type=$type" >> $LOG
	sync
		
	test=`pidof automount`
	
	if [ ! -z $test ]; then
			case $device in
			*)
				ls -d "$MAINDIR/$device" >/dev/null
				case $? in 
					0)
						checkdev=0;;
					*)
						echo "[$0] startCheckdev: can not mount device=$device label=$label type=$type" >> $LOG
						sync
						startRepairdev "$device"
						#after repair we test if we can mount the device
						ls -d "$MAINDIR/$device" >/dev/null
						case $? in 
							0) checkdev=0;;
							*) checkdev=1;;
						esac;;						
				esac;;
		esac
	else
		echo "[$0] startCheckdev: can not check ... automount is not running" >> $LOG
		sync
		checkdev=1
	fi
}

startIsreadonly()
{
	echo "[$0] startIsreadonly: device=$device label=$label type=$type" >> $LOG
	sync
	if [ $(busybox | grep 'BusyBox v' | cut -d'.' -f2) -gt "30" ];then
		timeout -s 9 30 touch "$MAINDIR/$device/checkrw.aaf" > /dev/null 2>&1
	else
		timeout -t 30 -s 9 touch "$MAINDIR/$device/checkrw.aaf" > /dev/null 2>&1
	fi
	
	if [ $? -eq 0 ]; then
		rm -f "$MAINDIR/$device/checkrw.aaf"
		isreadonly=0
	else
		echo "[$0] startIsreadonly: found read only device=$device label=$label type=$type" >> $LOG
		sync
		isreadonly=1
	fi
}

startChangedev()
{
	#in dieser funktion können deviceinfos wie z.B. label geändert werden (wird bei jeder partition aufgerufen)
	
	echo "[$0] startChangedev: device=$device label=$label type=$type" >> $LOG
	sync
}

startNewdev()
{
	startconfig=/mnt/config/start-config
	if [ ! -e "$startconfig" ]; then startconfig="/etc/titan.restore/mnt/config/start-config"; fi

	. $startconfig

	blkidline=`echo -e "$blkid" | grep -m1 "^/dev/$device:"`
	
	fastgrep "$blkidline" "LABEL=";	fgr=${fgr/*LABEL=\"/}; fgr=${fgr/\"*/}; label=${fgr//[ -]/}
	fastgrep "$blkidline" "TYPE="; fgr=${fgr/*TYPE=\"/}; fgr=${fgr/\"*/}; type=${fgr//[ -]/}
	fastgrep "$blkidline" "UUID="; fgr=${fgr/*UUID=\"/}; fgr=${fgr/\"*/}; uuid=${fgr}
	
	echo "[$0] startNewdev: device=$device label=$label type=$type uuid=$uuid" >> $LOG
	sync

	case $label in
		"") smblabel="$device NONLABEL"
		    label="NONLABEL-$device";;
		*)  smblabel="$device $label"
		    label="$label-$device";;
	esac

	startChangedev
	
	if [ -z "$swapdir" ] && [ "$label" == "SWAPPART-$device" ]; then
		echo "[$0] startNewdev: found SWAPPART device=$device label=$label type=$type" >> $LOG
		sync
		echo "$device#$type#$label" > $TMPDIR/.swappartdev
		swapdir=1
		swap.sh "" "$SWTYPE" "$model"
	fi
	
	if [ "$type" != "vfat" ] && [ "$type" != "ext2" ] && [ "$type" != "ext3" ]  && [ "$type" != "ext4" ] && [ "$type" != "msdos" ] && [ "$type" != "jfs" ] && [ "$type" != "ntfs" ] && [ "$device" != "mtdblock5" ] && [ "$device" != "mtdblock4" ] && [ "$device" != "mtdblock6" ]; then
		echo "[$0] startNewdev: found unsupportet medium device=$device label=$label type=$type" >> $LOG
		sync
		return
	fi
	
	if [ "${device:0:8}" == "mmcblk" ]; then
#		rm -f "/media/$MMC/$label"
		if [ ! -e /media/$MMC ];then mkdir /media/$MMC; fi
		ln -sfn "$MAINDIR/$device" "/media/$MMC/$label"
	elif [ "${device:0:8}" != "mtdblock" ]; then
#		rm -rf "/media/$USB/$label"
		if [ ! -e /media/$USB ];then mkdir /media/$USB; fi
		ln -sfn "$MAINDIR/$device" "/media/$USB/$label"
	fi
	
	isreadonly=""
	
	if [ -z "$swapstick" ] && [ "$label" == "SWAP-$device" ]; then swapstick="$device"; fi
	if [ -z "$record" ] && [ "$label" == "RECORD-$device" ]; then
		startCheckdev
		if [ $checkdev -eq 0 ]; then
			record="$device"
		else
			return
		fi
	fi
	
	case $swapdir in
		"")
			if [ -d "$MAINDIR/$device/swapdir" ]; then
				case $isreadonly in "") startIsreadonly;; esac
				case $isreadonly in
					0)
						echo "[$0] startNewdev: found swapdir device=$device label=$label type=$type" >> $LOG
						sync
						echo "$device#$type#$label" > $TMPDIR/.swapdirdev
						swapdir=1
						if [ -L /var/swapdir ];then rm -f /var/swapdir; fi
						ln -sn "$MAINDIR/$device/swapdir" /var/swapdir
						swap.sh "" "$SWTYPE" "$model";;
					*)
						return;;
				esac
			fi;;
	esac

	case $backup in
		"")
			if [ -d "$MAINDIR/$device/backup" ]; then
				case $isreadonly in "") startIsreadonly;; esac
				case $isreadonly in
					0)
						echo "[$0] startNewdev: found backup device=$device label=$label type=$type" >> $LOG
						sync
						echo "$device#$type#$label" > $TMPDIR/.backupdev
						backup=1
						if [ -L /var/backup ];then rm -f /var/backup; fi
						ln -sn "$MAINDIR/$device/backup" /var/backup
						case $swap_max_sectors in
							240) ;;
							*)   echo "$swap_max_sectors" > "/sys/block/${device:0:3}/device/max_sectors" 2>/dev/null;;
						esac;;
					*)
						return;;
				esac
			fi;;
	esac

	case $swapextensions in
		"")	
			if [ -d "$MAINDIR/$device/swapextensions" ]; then
				case $isreadonly in "") startIsreadonly;; esac
				case $isreadonly in
					0)
						echo "[$0] startNewdev: found swapextensions device=$device label=$label type=$type" >> $LOG
						sync
						echo "$device#$type#$label" > $TMPDIR/.swapextensionsdev
						swapextensions=1
						if [ -L /var/swap ];then rm -f /var/swap; fi
						ln -sn "$MAINDIR/$device/swapextensions" /var/swap
						case $swap_max_sectors in
							240) ;;
							*)   echo "$swap_max_sectors" > "/sys/block/${device:0:3}/device/max_sectors" 2>/dev/null;;
						esac
						startStickextensions /var/swap &;;
					*)
						return;;
				esac
			fi;;
	esac

	# remove all device entrys
	sed -e '/./{H;$!d;}' -e "x;/$device/d;" -i /mnt/config/smb.conf
	sed -e '/./,/^$/!d' -i /mnt/config/smb.conf
	
	sed -e "s!$MAINDIR/$device.*!!g" -i /mnt/config/exports
	sed -e '/^ *$/d' -i /mnt/config/exports

	case $movie in
		"")
			if [ -d "$MAINDIR/$device/movie" ]; then
				case $isreadonly in "") startIsreadonly;; esac
				case $isreadonly in
					0)
						echo "[$0] startNewdev: found movie device=$device label=$label type=$type" >> $LOG
						sync
						echo "$device#$type#$label" > $TMPDIR/.moviedev
						movie=1
						if [ -L /media/hdd ];then rm -f /media/hdd; fi
						if [ -e /etc/.oebuild ] && [ -d /media/hdd ];then
							fuser -mk /media/hdd
							umount -f /media/hdd
							rmdir /media/hdd
						fi
						ln -sn "$MAINDIR/$device" /media/hdd

						#sed -e '/./{H;$!d;}' -e "x;/\[media\]/d;" -i /mnt/config/smb.conf

						if [ `cat /mnt/config/smb.conf | grep "$device" | wc -l` -eq 0 ];then
							if [ `cat /mnt/config/titan.cfg | grep "lang=po/de" | wc -l` -eq 1 ];then
								meta=Aufnahme 
							else
								meta=record 
							fi					
							echo "[$0] startNewdev: add dir: $MAINDIR/$device name: $meta to smb.conf"
							echo -e "\n" >> /mnt/config/smb.conf
							echo "[$meta]" >> /mnt/config/smb.conf
							echo "comment = Harddisk $MAINDIR/$device linked to /media/hdd" >> /mnt/config/smb.conf
							echo "path = $MAINDIR/$device" >> /mnt/config/smb.conf
							echo "read only = no" >> /mnt/config/smb.conf
							echo "public = yes" >> /mnt/config/smb.conf
							echo "guest ok = yes" >> /mnt/config/smb.conf
						fi

						sed -e "s!/media .*!!g" -i /mnt/config/exports
						if [ `cat /mnt/config/exports | grep "$device" | wc -l` -eq 0 ];then
							echo "$MAINDIR/$device *(rw,no_root_squash,no_subtree_check,sync)" >> /mnt/config/exports
						fi

						case $model in
							ipbox91|ipbox900|ipbox910|ipbox9000) vfdctl +music;;
							*)   vfdctl +hdd;;
						esac
				
						#echo "RECMOUNT: OK" > /dev/vfd
						case $record_max_sectors in
							240) ;;
							*)   echo "$record_max_sectors" > "/sys/block/${device:0:3}/device/max_sectors" 2>/dev/null;;
						esac;;
					*)
						return;;
				esac
			fi;;
	esac

	if [ "${device:0:8}" != "mtdblock" ] && [ `cat /mnt/config/smb.conf | grep "$device" | wc -l` -eq 0 ];then
		meta=`echo $smblabel | tr "/" "\n" | tail -n1` 
		echo "[$0] startNewdev: add dir: $MAINDIR/$device name: $meta to smb.conf"
		echo -e "\n" >> /mnt/config/smb.conf  
		echo "[$meta]" >> /mnt/config/smb.conf  
		echo "comment = Media Files on $label Drive" >> /mnt/config/smb.conf
		echo "path = $MAINDIR/$device" >> /mnt/config/smb.conf
		echo "read only = no" >> /mnt/config/smb.conf
		echo "public = yes" >> /mnt/config/smb.conf
		echo "guest ok = yes" >> /mnt/config/smb.conf
	fi

	if [ "${device:0:8}" != "mtdblock" ] && [ `cat /mnt/config/exports | grep "$device" | wc -l` -eq 0 ];then
		echo "$MAINDIR/$device *(rw,no_root_squash,no_subtree_check,sync)" >> /mnt/config/exports
	fi
}

startCheckRecordShare() {
	echo "[$0] startCheckRecordShare: start" >> $LOG
	if [ -e /mnt/network/.recordshare ]; then
		read recordshare < /mnt/network/.recordshare
		tmprecordshare=$recordshare
		
		echo "[$0] startCheckRecordShare: check $MAINDIR/$tmprecordshare/movie"
		if [ ! -z "$tmprecordshare" ] && [ ! -e "$MAINDIR/$tmprecordshare/movie" ];then
			echo "[$0] startCheckRecordShare: create $MAINDIR/$tmprecordshare/movie" >> $LOG
			sync
			if [ $(busybox | grep 'BusyBox v' | cut -d'.' -f2) -gt "30" ];then
				timeout -s 9 30 mkdir "$MAINDIR/$tmprecordshare/movie"
			else
				timeout -t 30 -s 9 mkdir "$MAINDIR/$tmprecordshare/movie"
			fi
		fi
		if [ -e "$MAINDIR/$tmprecordshare/movie" ];then
			echo "[$0] startCheckRecordShare: found $MAINDIR/$tmprecordshare/movie"
		fi
	fi

	sharelist=`awk '/(cifs,|nfs,|ftpfs,)/ { print $1 }' /mnt/network/auto.misc`

	fastgrep "$sharelist" "$recordshare"	
	if [ ! -z "$recordshare" ] && [ ! -z "$fgr" ]; then
		# used in NetworkBrowser hdd_replacement True this has prio
		device="$recordshare"; startIsreadonly
		case $isreadonly in
		0)
			echo "[$0] startCheckRecordShare: found NET movie device=$recordshare" >> $LOG
			sync
			echo "$recordshare" > $TMPDIR/.moviedev
			movie=1
			if [ -L /media/hdd ];then rm -f /media/hdd; fi
			if [ -e /etc/.oebuild ] && [ -d /media/hdd ];then
				fuser -mk /media/hdd
				umount -f /media/hdd
				rmdir /media/hdd
			fi
			echo "[$0] hRecordShare: linking /media/hdd > $MAINDIR/$recordshare" >> $LOG
			sync
			ln -sn "$MAINDIR/$recordshare" /media/hdd
			#echo "RECMOUNT: OK" > /dev/vfd
			;;
		*)
			recordshare="";;
			esac
	fi

	for share in $sharelist; do
		if [ "$tmprecordshare" == "$share" ] && [ -z "$recordshare" ]; then
			continue
		fi

		echo "[$0] startCheckRecordShare: linking /media/net/$share > $MAINDIR/$share" >> $LOG
		sync
#		rm -f "/media/net/$share"
		if [ ! -e /media/net ];then mkdir /media/net; fi
		ln -sfn "$MAINDIR/$share" "/media/net/$share"
	done
	echo "[$0] startCheckRecordShare: ende" >> $LOG
	sync
}

startCheckhanging()
{
	echo "[$0] startCheckhanging: start" >> $LOG
	sync
	
	sleep 60

	kill -9 "$1" 2>&1 >/dev/null
	if [ $? -eq 0 ]; then
		echo "[$0] startCheckhanging: timeout" >> $LOG
		sync
		> $TMPDIR/.hotplugready
	fi
	echo "[$0] startCheckhanging: ende" >> $LOG
	sync
}

startcifswork()
{
	echo "[$0] startcifswork"
    CIFSGUESTLIST=$(cat /mnt/network/auto.misc | grep cifs | grep guest | sed -nr 's!.*\t:([^:]+).*!\1!p')
    for ROUND in $CIFSGUESTLIST; do
        mkdir /tmp/tmpmount
        mount -o guest $ROUND /tmp/tmpmount
        sleep 3
        ls -al /media/net/
        umount -fl /tmp/tmpmount
        rmdir /tmp/tmpmount
    done
}

case $startmode in
	first)
		startCheckhanging $$ &

		if [ -e $TMPDIR/.swapdirdev ] || [ -e $TMPDIR/.swappartdev ]; then swapdir=1; fi
		if [ -e $TMPDIR/.backupdev ]; then backup=1; fi
		if [ -e $TMPDIR/.swapextensionsdev ]; then swapextensions=1; fi
		if [ -e $TMPDIR/.moviedev ]; then movie=1; fi

		ln -s $MAINDIR/sr0 /media/dvd

		# manche HDD werden nicht erkannt ohne diesen ls
		if [ $(busybox | grep 'BusyBox v' | cut -d'.' -f2) -gt "30" ];then
			timeout -s 9 2 ls $MAINDIR > /dev/null
		else
			timeout -t 2 -s 9 ls $MAINDIR > /dev/null
		fi
		ls /media/net > /dev/null
		ls /media/$USB > /dev/null

		# move nas als recmount
		startCheckRecordShare
		sdlist=`awk '/(sd[a-z])/ { print substr($0,14,4) }' /proc/diskstats`
		for ROUND in $sdlist;do
			if [ -e $MAINDIR/$ROUND ];then sdxlist="$sdxlist $ROUND"; fi
		done
		sdlist=`awk '/(sd[a-z][0-9])/ { print substr($0,14,4) }' /proc/diskstats`
		mmclist=`awk '/mmcblk[1-9]p[0-9]/ { print substr($0,14,9) }' /proc/diskstats`
		naslist=`awk '/(nfs)|(cifs)/ { print substr($2,19) }' /proc/mounts`
		devlist="$sdlist $sdxlist $mmclist $naslist"

		if [ "$devlist" != " " ]; then
			blkid=`blkid -w /dev/null -c /dev/null`

			for device in $devlist; do
				startNewdev
			done

			if [ ! -e /etc/.oebuild ];then
	#			if [ ! -z "$recordshare" ]; then
				for nasshare in $naslist; do
					if [ ! -z "$nasshare" ]; then
	#					das backup auf recordshare macht keinen sinn, da auch die .recordshare dort liegt
	# 				edit obi add nasshars this is better as recordshare, we can used backup/swapdir on nas
						case $backup in
							"")
								if [ -e "$MAINDIR/$nasshare/backup" ]; then
									echo "[$0] first: found NET backup device=$nasshare"
									echo "$nasshare" > $TMPDIR/.backupdev
									backup=1
									if [ -L /var/backup ];then rm -f /var/backup; fi
									ln -sn "$MAINDIR/$nasshare/backup" /var/backup
								fi;;
						esac
						if [ -e "$MAINDIR/$nasshare/swapextensions" ]; then
							echo "[$0] first: found NET swapextensions device=$nasshare"
							echo "$nasshare" > $TMPDIR/.swapextensionsdev
							if [ -L /var/swap ];then rm -f /var/swap; fi
							ln -sn "$MAINDIR/$nasshare/swapextensions" /var/swap
						fi
		#				swapfile on network only running with swapon on loop device
						case $swapdir in
							"")
								if [ -e "$MAINDIR/$nasshare/swapdir" ]; then
									echo "[$0] first: found NET swapdir device=$nasshare"
									echo "$nasshare" > $TMPDIR/.swapdirdev
									swapdir=1
									if [ -L /var/swapdir ];then rm -f /var/swapdir; fi
									ln -sn "$MAINDIR/$nasshare/swapdir" /var/swapdir
								fi;;
						esac
					fi
				done
			fi
			> $TMPDIR/.hotplugready
			case $loadpartition in
				y)
					for dev in sda sdb sdc sdd; do
						hdparm -z "/dev/$dev" > /dev/null 2>&1
					done;;
			esac
		else
			> $TMPDIR/.hotplugready
		fi
		if [ -e /etc/.oebuild ];then startcifswork; fi
		exit;;

	checkRecordShare)
		startCheckRecordShare
		exit;;
	startStickextensionsSWAP)
		startStickextensions /var/swap
		exit;;
	startStickextensionsMNT)
		startStickextensions /mnt/swapextensions
		exit;;	
	delRecord)
		if [ -L /media/hdd ];then rm -f /media/hdd; fi
		rm -f $TMPDIR/.moviedev
		exit;;
	delSwap)
		rm -f $TMPDIR/.swapdirdev
		swap.sh "swapfileoff" "$SWTYPE" "$model"
		if [ -L /var/swapdir ];then rm -f /var/swapdir; fi
		swap.sh "" "$SWTYPE" "$model"
		exit;;
	delSwapextensions)
		rm -f $TMPDIR/.swapextensionsdev
		if [ -L /var/swap ];then rm -f /var/swap; fi
		exit;;
	delBackup)
		if [ -L /var/backup ];then rm -f /var/backup; fi
		rm -f $TMPDIR/.backupdev
		exit;;
	mounthelper.sh)
		ACTION=$2
		MDEV=$3
		DEVPATH=$4
		DEVTYPE=$5
		exit;;
esac

case $ACTION in
	add|"")
		ACTION="add"
		device=${MDEV}

		echo "[$0] add: ACTION=add device=$device" >> $LOG
		sync

		if [ `mount | grep ^"tmpfs on /var/volatile" | wc -l` -eq 0 ];then
			echo "[$0] skiped >> found no tmpfs" >> $LOG
			sync
			exit
			return
		fi

		if [ ! -e /etc/.oebuild ];then
			if [ "${device:0:8}" != "mmcblk" ] && [ ${#device} -ne 4 ]; then exit; fi
		fi
		if [ ! -e /etc/.oebuild ];then
			startWaitfor "$TMPDIR/.hotplugready" 1000; rm -f $TMPDIR/.hotplugready
		fi

		if [ "${device:0:8}" == "mmcblk" ]; then
			ls -1 /media/$MMC/*-"$device" > /dev/null 2>&1
		else
			ls -1 /media/$USB/*-"$device" > /dev/null 2>&1
		fi

		if [ $? -eq 0 ]; then
			> $TMPDIR/.hotplugready
			exit
		fi

		blkid=`blkid -w /dev/null -c /dev/null "/dev/$device"`
		if [ -e $TMPDIR/.swapdirdev ] || [ -e $TMPDIR/.swappartdev ]; then swapdir=1; fi
		if [ -e $TMPDIR/.backupdev ]; then backup=1; fi
		if [ -e $TMPDIR/.swapextensionsdev ]; then swapextensions=1; fi
		if [ -e $TMPDIR/.moviedev ]; then movie=1; fi
		startNewdev
		> $TMPDIR/.hotplugready
		exit;;
	remove)
		device=${MDEV}
		if [ -e "/sys$DEVPATH" ]; then exit; fi
		if [ ! -e /etc/.oebuild ];then
			if [ "${device:0:8}" != "mmcblk" ] && [ ${#device} -ne 4 ]; then exit; fi
		fi

		if [ ! -e /etc/.oebuild ];then
			startWaitfor "$TMPDIR/.hotplugready" 1000; rm -f $TMPDIR/.hotplugready
		fi
		echo "[$0] remove: ACTION=remove device=$device" >> $LOG
		sync
	
		if [ -e $TMPDIR/.swappartdev ]; then
			tmpdev=""; read tmpdev < $TMPDIR/.swappartdev; fastcut "$tmpdev" "#" 1; tmpdev="$fcr"
			case $device in
				$tmpdev)
					rm -f $TMPDIR/.swappartdev
					swap.sh "" "$SWTYPE" "$model"
					> $TMPDIR/.hotplugready
					exit;;
			esac
		fi
	
		if [ "${device:0:8}" == "mmcblk" ]; then
			rm -f /media/$MMC/*-"$device" > /dev/null 2>&1
		else
			rm -f /media/$USB/*-"$device" > /dev/null 2>&1
		fi
# show only
#		sed -e '/./{H;$!d;}' -e "x;/-$device/!d;" -i /mnt/config/smb.conf
# remove only
		sed -e '/./{H;$!d;}' -e "x;/$device/d;" -i /mnt/config/smb.conf
		sed -e "s!$MAINDIR/$device.*!!g" -i /mnt/config/exports

		if [ `cat /mnt/config/smb.conf | grep "autofs" | wc -l` -eq 0 ];then
			echo "[$0] startNewdev: add mountdir $mountdir to smb.conf"
			meta=`echo media | tr "/" "\n" | tail -n1` 
			echo -e "\n" >> /mnt/config/smb.conf
			echo "[$meta]" >> /mnt/config/smb.conf
			echo "comment = Media Dir" >> /mnt/config/smb.conf
			echo "path = /media" >> /mnt/config/smb.conf
			echo "read only = no" >> /mnt/config/smb.conf
			echo "public = yes" >> /mnt/config/smb.conf
			echo "guest ok = yes" >> /mnt/config/smb.conf
		fi

		if [ `cat /mnt/config/exports | grep "autofs" | wc -l` -eq 0 ];then
			echo "/media *(rw,no_root_squash,no_subtree_check,sync)" >> /mnt/config/exports
		fi

		if [ -e $TMPDIR/.swapdirdev ]; then
			tmpdev=""; read tmpdev < $TMPDIR/.swapdirdev; fastcut "$tmpdev" "#" 1; tmpdev="$fcr"
			case $device in
				$tmpdev)
					rm -f $TMPDIR/.swapdirdev
					swap.sh "swapfileoff" "$SWTYPE" "$model"
					rm -f /var/swapdir
					swap.sh "" "$SWTYPE" "$model";;
			esac
		fi
		
		if [ -e $TMPDIR/.swapextensionsdev ]; then
			tmpdev=""; read tmpdev < $TMPDIR/.swapextensionsdev; fastcut "$tmpdev" "#" 1; tmpdev="$fcr"
			case $device in
				$tmpdev)
					if [ -L /var/swap ];then rm -f /var/swap; fi
					rm -f $TMPDIR/.swapextensionsdev;;
			esac
		fi
		
		if [ -e $TMPDIR/.backupdev ]; then
			tmpdev=""; read tmpdev < $TMPDIR/.backupdev; fastcut "$tmpdev" "#" 1; tmpdev="$fcr"
			case $device in
				$tmpdev)
					if [ -L /var/backup ];then rm -f /var/backup; fi
					rm -f $TMPDIR/.backupdev;;
			esac
		fi
		
		if [ -e $TMPDIR/.moviedev ]; then
			tmpdev=""; read tmpdev < $TMPDIR/.moviedev; fastcut "$tmpdev" "#" 1; tmpdev="$fcr"
			case $device in
				$tmpdev)
					if [ -L /media/hdd ];then rm -f /media/hdd; fi
					rm -f $TMPDIR/.moviedev
					
				case $model in
					ipbox91|ipbox900|ipbox910|ipbox9000) vfdctl -music;;
					*)   vfdctl -hdd;;
				esac;;
			esac
		fi
		
		> $TMPDIR/.hotplugready
		exit;;
esac
