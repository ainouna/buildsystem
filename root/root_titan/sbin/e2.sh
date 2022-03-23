#!/bin/sh -x

clean=0

if [ "$1" == "remove" ];then
	opkg remove openatv-enigma2 --force-removal-of-dependent-packages
	opkg remove enigma2-locale-meta --force-removal-of-dependent-packages
	opkg remove enigma2-plugin-settings-defaultsat --force-removal-of-dependent-packages
	opkg remove tuxbox-common --force-removal-of-dependent-packages
	opkg remove enigma2-plugin-systemplugins-wirelesslan --force-removal-of-dependent-packages
	opkg remove enigma2 --force-removal-of-dependent-packages
	exit
fi

# work
touch /tmp/progress
mount --bind /tmp/progress /proc/progress

sleep 2
opkg update

if [ -e "/var/usr/local/share/titan/plugins/e2starter/skin/background.jpg" ];then
	infobox 100 "progressbar#/var/usr/local/share/titan/plugins/e2starter/skin/background.jpg" 85 85 &
elif [ -e "/mnt/swapextensions/usr/local/share/titan/plugins/e2starter/skin/background.jpg" ];then
	infobox 100 "progressbar#/mnt/swapextensions/usr/local/share/titan/plugins/e2starter/skin/background.jpg" 85 85 &
elif [ -e "/var/swap/usr/local/share/titan/plugins/e2starter/skin/background.jpg" ];then
	infobox 100 "progressbar#/var/swap/usr/local/share/titan/plugins/e2starter/skin/background.jpg" 85 85 &
fi

echo 5 > /proc/progress
check1=`opkg list_installed openatv-enigma2 | wc -l`
check2=`opkg list_installed enigma2-locale-meta | wc -l`
check3=`opkg list_installed enigma2-plugin-settings-defaultsat | wc -l`
check4=`opkg list_installed tuxbox-common | wc -l`
check5=`opkg list_installed enigma2-plugin-systemplugins-wirelesslan | wc -l`
check6=`opkg list_installed enigma2 | wc -l`
if [ "$check1" == 0 ] || [ "$check2" == 0 ] || [ "$check3" == 0 ] || [ "$check4" == 0 ] || [ "$check5" == 0 ] || [ "$check6" == 0 ];then
	opkg install openatv-enigma2 --force-reinstall
	echo 10 > /proc/progress
	opkg install enigma2-locale-meta --force-reinstall
	echo 15 > /proc/progress
	opkg install enigma2-plugin-settings-defaultsat --force-reinstall
	echo 20 > /proc/progress
	opkg install tuxbox-common --force-reinstall
	echo 25 > /proc/progress
	opkg install enigma2-plugin-systemplugins-wirelesslan --force-reinstall
	echo 30 > /proc/progress
	opkg install enigma2 --force-reinstall
	rm -rf /usr/lib/enigma2/python/Plugins/Extensions/OpenWebif
	echo 35 > /proc/progress
	clean=1
fi

echo "#!/bin/sh -x" > /tmp/e2starter.sh
echo "init 2" >> /tmp/e2starter.sh
if [ "$clean" == 0 ];then
	echo "fuser -k 80/tcp" >> /tmp/e2starter.sh
fi
if [ -e "/var/usr/local/share/titan/plugins/e2starter/skin/background.jpg" ];then
	echo 'infobox 100 "progressbar#/var/usr/local/share/titan/plugins/e2starter/skin/background.jpg" 85 85 &' >> /tmp/kodistarter.sh
elif [ -e "/mnt/swapextensions/usr/local/share/titan/plugins/e2starter/skin/background.jpg" ];then
	echo 'infobox 100 "progressbar#/mnt/swapextensions/usr/local/share/titan/plugins/e2starter/skin/background.jpg" 85 85 &' >> /tmp/kodistarter.sh
elif [ -e "/var/swap/usr/local/share/titan/plugins/e2starter/skin/background.jpg" ];then
	echo 'infobox 100 "progressbar#/var/swap/usr/local/share/titan/plugins/e2starter/skin/background.jpg" 85 85 &' >> /tmp/kodistarter.sh
fi
echo "sleep 3" >> /tmp/e2starter.sh
echo "echo 50 > /proc/progress" >> /tmp/e2starter.sh
echo "enigma2.sh" >> /tmp/e2starter.sh
echo "umount /proc/progress" >> /tmp/e2starter.sh
echo "init 3" >> /tmp/e2starter.sh
echo "exit 0" >> /tmp/e2starter.sh
chmod 755 /tmp/e2starter.sh
echo "[e2starter.sh] cmd: start-stop-daemon -S -b -n e2starter.sh -x /tmp/e2starter.sh"
start-stop-daemon -S -b -n e2starter.sh -x /tmp/e2starter.sh
exit
