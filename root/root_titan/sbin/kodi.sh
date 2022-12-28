#!/bin/sh -x

clean=0

if [ "$1" == "remove" ];then
	opkg remove kodi --force-removal-of-dependent-packages
	exit
fi

# work
touch /tmp/progress
mount --bind /tmp/progress /proc/progress

sleep 2
opkg update
if [ -e "/var/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" ];then
	infobox 100 "progressbar#/var/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" 85 85 &
elif [ -e "/mnt/swapextensions/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" ];then
	infobox 100 "progressbar#/mnt/swapextensions/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" 85 85 &
elif [ -e "/var/swap/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" ];then
	infobox 100 "progressbar#/var/swap/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" 85 85 &
fi

echo 5 > /proc/progress
check1=`opkg list_installed stb-kodi-* | wc -l`
if [ "$check1" == 0 ];then
	echo 10 > /proc/progress
	opkg install kodi --force-reinstall
	echo 20 > /proc/progress
	clean=1
fi

# fixt dns check
rm /etc/resolv.conf
cp -a /mnt/network/resolv.conf /etc/resolv.conf

echo "#!/bin/sh -x" > /tmp/kodistarter.sh
echo "init 2" >> /tmp/kodistarter.sh
if [ "$clean" == 0 ];then
	echo "fuser -k 80/tcp" >> /tmp/kodistarter.sh
fi
oldfb=$(cat /proc/stb/video/videomode)

if [ -e "/var/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" ];then
	echo 'infobox 100 "progressbar#/var/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" 85 85 &' >> /tmp/kodistarter.sh
elif [ -e "/mnt/swapextensions/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" ];then
	echo 'infobox 100 "progressbar#/mnt/swapextensions/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" 85 85 &' >> /tmp/kodistarter.sh
elif [ -e "/var/swap/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" ];then
	echo 'infobox 100 "progressbar#/var/swap/usr/local/share/titan/plugins/kodistarter/skin/background.jpg" 85 85 &' >> /tmp/kodistarter.sh
fi
echo "sleep 3" >> /tmp/kodistarter.sh
echo "echo 50 > /proc/progress" >> /tmp/kodistarter.sh
echo "echo 720p50 > /proc/stb/video/videomode" >> /tmp/kodistarter.sh
echo "kodi" >> /tmp/kodistarter.sh
echo "echo $oldfb > /proc/stb/video/videomode" >> /tmp/kodistarter.sh
echo "umount /proc/progress" >> /tmp/kodistarter.sh
echo "init 3" >> /tmp/kodistarter.sh
echo "exit 0" >> /tmp/kodistarter.sh
chmod 755 /tmp/kodistarter.sh
echo "[kodistarter.sh] cmd: start-stop-daemon -S -b -n kodistarter.sh -x /tmp/kodistarter.sh"
start-stop-daemon -S -b -n kodistarter.sh -x /tmp/kodistarter.sh
exit
