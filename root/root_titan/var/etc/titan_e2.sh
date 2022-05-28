#!/bin/sh

insmod /lib/modules/e2_proc.ko; ret=$?

if [ $ret -ne 17 ]; then
	if [ $ret -ne 0 ]; then
		#workaround Kernel
		if [ ! -d /lib/modules_org ]; then 
			mv /lib/modules /lib/modules_org
		else
			rm /lib/modules
		fi
		cp -RP /var/flash/lib/modules /lib
	fi
fi
sync
/etc/init.d/rcS
sync

	