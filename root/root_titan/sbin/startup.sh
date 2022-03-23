#!/bin/sh
# update by obi

STARTUPLIST=$(ls -a /boot/STARTUP_* | sed 's!/boot/!!g')
bootup=$(cat /boot/STARTUP)
for ROUND in $STARTUPLIST; do
	startup=$(cat /boot/$ROUND)
	if [ "$bootup" == "$startup" ];then
		label=$ROUND
	fi
done

if [ -z "$1" ];then
	echo $label
else
	echo $label | sed 's/STARTUP_/Startup_/' | sed 's/_LINUX_/_/' | sed 's/_BOXMODE_/_B/'
fi
