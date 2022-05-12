#!/bin/sh

#todo
#in fastgrep ein break beim if
#logto aus start-config weg
#mkdir (1), uname (1), rm (2), grep (3), awk (1), ifconfig (1), hostname (1)

startconfig=/mnt/config/start-config
if [ ! -e "$startconfig" ]; then startconfig="/etc/titan.restore/mnt/config/start-config"; fi

. $startconfig
. /sbin/start-function

insmod=xinsmod
#insmod=insmod

INPUT="$1"
REBOOT="$2"
SWTYPE="$3"
model="$4"
imagetype="$5"
linuxver="$6"

if [ -e "/etc/.debug" ]; then debug=full; fi

debug=full

CMD="[start.sh]"
titanfirststart=0

#debug=full
#cat /proc/mtd

case $debug in
	on|full)
		echo "$CMD [$INPUT] start"
		case $debug in full) set -x;; esac;;
esac

SWTYPE="titan"
player="191"

case $model in "") read model < /etc/model;; esac
case $model in ipbox910|ipbox900|ipbox91|ipbox9000)	ipbox="1";; esac

if [ -e "/var/etc/.firstnet" ]; then firstnet="1"; fi

case $INPUT in
	"")
		echo "$CMD use start.sh <first|last|reboot> <reboot> <swtype> <model> <imagetype> <linuxver>"
		exit;;
esac

startup_progress() {
	# dummy funktion
	progress_skip=1
}

startConfig()
{
	echo "$CMD [$INPUT] startConfig"

	case $model in
		atevio700)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xb9211000:136:set2 mailbox1=0xb9212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:1024:0xa4000000:0x10000000"
			display="stx7109c3.ko"
			avs="type=avs_none"
			mmeName="MPEG2_TRANSFORMER1"
			ci="cimax.ko"
			tuner="avl2108.ko"
			front="nuvoton.ko"
			case $noaudiosync in y) usenoaudiosync="noaudiosync=1";; esac
			case $oldaudiofw in y) useoldaudiofw="useoldaudiofw=1";; esac;;
		atevio7000)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xb9211000:136:set2 mailbox1=0xb9212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:1024:0xa4000000:0x10000000"
			display="stx7109c3.ko"
			avs="type=stv6412"
			mmeName="MPEG2_TRANSFORMER1"
			if [ -z "$extmoduldetect" ]; then extmoduldetect=0; fi
			ci="starci.ko extmoduldetect=$extmoduldetect"
			tuner="stv090x.ko"
			front="nuvoton.ko"
			case $noaudiosync in y) usenoaudiosync="noaudiosync=1";; esac;;
		atemio7600)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xfe211000:136:set2 mailbox1=0xfe212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0x40000000:0x10000000"
			display="sti7105.ko"
			avs="type=stv6418"
      		if [ -z "$extmoduldetect" ]; then extmoduldetect=0; fi
			ci="starci.ko extmoduldetect=$extmoduldetect"
			tuner="avl2108.ko"
			front="nuvoton.ko";;
		atemio510)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xfe211000:136:set2 mailbox1=0xfe212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0x40000000:0x10000000"
			display="sti7111.ko"
			avs="type=avs_none"
			if [ -z "$extmoduldetect" ]; then extmoduldetect=0; fi
			# neutrino hs7110.ko
			ci="hs711x.ko extmoduldetect=$extmoduldetect"
			if [ -z "$bbgain" ]; then bbgain=10; fi
			tuner="stv090x.ko bbgain="$bbgain""
			front="nuvoton.ko waitTime=0";;
		atemio520|atemio530)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xfe211000:136:set2 mailbox1=0xfe212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0x40000000:0x10000000"
			display="sti7111.ko"
			avs="type=avs_none"
			if [ -z "$extmoduldetect" ]; then extmoduldetect=0; fi
			ci="cnbox_cic.ko extmoduldetect=$extmoduldetect"
			if [ -z "$bbgain" ]; then bbgain=10; fi
			tuner="stv090x.ko bbgain="$bbgain""
			front="cn_micom.ko paramDebug=200";;
		ufs910)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xb9211000:136:set2 mailbox1=0xb9212000:137:set2"
			embxshm="mailbox0=shm:0:7:0x60000000:0:16:16:0:1024:0xa4000000:0x10000000"
			display="stx7100.ko"
			avs=""
			case $ufs910avs in n) avs="type=avs_none";; esac
			mmeName="MPEG2_TRANSFORMER0"
			ci="cimax.ko"
			front="vfd.ko"
			tuner="cx24116.ko useUnknown=0"
			case $useUnknown910 in 1) tuner="cx24116.ko useUnknown=1";; esac
			case $HighSR in y) useHighSR="highSR=1";; esac
			case $swts in y) useswts="swts=1";; esac
			case $noaudiosync in y) usenoaudiosync="noaudiosync=1";; esac;;
		ufs912)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xfe211000:136:set2 mailbox1=0xfe212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0x40000000:0x10000000"
			display="sti7111.ko"
			avs="type=stv6417"
			mmeName=""
			ci="ufs912_cic.ko"
			if [ -z "$bbgain" ]; then bbgain=10; fi
			tuner="stv090x.ko bbgain="$bbgain""
			front="micom.ko"
			case $HighSR in y) useHighSR="highSR=1";; esac
			case $swts in y) useswts="swts=1";; esac
			case $oldvideofw in y) useoldvideofw="useoldvideofw=1";; esac;;
		ufs913)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xfe211000:136:set2 mailbox1=0xfe212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0x40000000:0x10000000"
			display="sti7105.ko"
			avs="type=stv6417"
			mmeName=""
			ci="ufs913_cic.ko"
			if [ -z "$bbgain" ]; then bbgain=10; fi
			tuner="avl6222.ko"
			front="micom.ko paramDebug=0"
			case $HighSR in y) useHighSR="highSR=1";; esac
			case $swts in y) useswts="swts=1";; esac
			case $oldvideofw in y) useoldvideofw="useoldvideofw=1";; esac;;
		ufs922)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xb9211000:136:set2 mailbox1=0xb9212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0xa4000000:0x10000000"
			mmeName="MPEG2_TRANSFORMER1"
			display="stx7109c3.ko"
			avs="type=stv6412"
			ci="ufs922_cic.ko"
			tuner="avl2108.ko"
			tunersec="cx21143.ko"
			front="micom.ko"
			case $noaudiosync in y) usenoaudiosync="noaudiosync=1";; esac;;
		ufc960)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xb9211000:136:set2 mailbox1=0xb9212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0xa4000000:0x10000000"
			mmeName="HW_MPEG2_TRANSFORMER"
			display="stx7109c3.ko"
			avs="type=stv6412"
			ci="ufc960_cic.ko"
			if [ -z "$bbgain" ]; then bbgain=10; fi
			tuner="tda10023.ko"
			front="micom.ko"
			case $noaudiosync in y) usenoaudiosync="noaudiosync=1";; esac;;
		spark)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xfe211000:136:set2 mailbox1=0xfe212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0x40000000:0x10000000"
			display="sti7111.ko"
			avs="type=avs_pio"
			mmeName=""
			ci=""
			if [ -z "$bbgain" ]; then bbgain=10; fi
			tuner="stv090x.ko"
			front="aotom.ko"
			case $HighSR in y) useHighSR="highSR=1";; esac
			case $swts in y) useswts="swts=1";; esac
			case $oldvideofw in y) useoldvideofw="useoldvideofw=1";; esac;;
	spark7162)
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xfe211000:136:set2 mailbox1=0xfe212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0x40000000:0x10000000"
			display="sti7105.ko"
			avs="type=avs_none"
			mmeName=""
			ci=""
			if [ -z "$bbgain" ]; then bbgain=10; fi
			if [ `cat /mnt/config/titan.cfg | grep ^"hypridtuner=" | cut -d "=" -f2 | wc -l` -eq 1 ]; then
				hypridtuner=`cat /mnt/config/titan.cfg | grep ^"hypridtuner=" | cut -d "=" -f2`
			else
				hypridtuner=c
			fi
			tuner="spark7162.ko UnionTunerType=$hypridtuner"
			front="aotom.ko"
			case $HighSR in y) useHighSR="highSR=1";; esac
			case $swts in y) useswts="swts=1";; esac
			case $oldvideofw in y) useoldvideofw="useoldvideofw=1";; esac;;
		*)		
			#ipbox91/900/910/9000
			pal="pal"
			hdmi="50:12m"
			embxmailbox="mailbox0=0xb9211000:136:set2 mailbox1=0xb9212000:0"
			embxshm="mailbox0=shm:0:7:0x60000000:0:256:256:0:512:0xa4000000:0x10000000"
			mmeName="MPEG2_TRANSFORMER1"
			display="stx7109c3.ko"
			case $model in
				ipbox91) avs="type=fake_avs";;
				*)  avs="type=stv6412";;
			esac
			ci="starci.ko"
			tuner="cx24116.ko"
			front="micom.ko"
			case $HighSR in y) useHighSR="highSR=1";; esac
			case $swts in y) useswts="swts=1";; esac
			case $noaudiosync in y) usenoaudiosync="noaudiosync=1";; esac;;
	esac

	if grep -q "^firststart=1" /mnt/config/titan.cfg; then
		titanfirststart=1
	fi
	if grep -q -e "^av_videomode=576i50" -e "^av_videomode=pal" /mnt/config/titan.cfg; then
		res=720x576-32
	else
		res=1280x720-32
	fi
}

startVfd()
{
	echo "$CMD [$INPUT] startVfd"
	$insmod /lib/modules/e2_proc.ko

	if [ "$model" != "atemio520" ]; then	
		$insmod /lib/modules/$front
	fi

	case $model in 
		atemio7600|atevio700|atevio7000|ufs922|ufs912|ufs913)
			echo "** Atemio **" > /dev/vfd;;
		atemio530|atemio520aus|ipbox91|spark) 
			startDigit4Display &;;
		atemio510) ;;
		*)
			echo "** AAF **" > /dev/vfd;;
	esac
	case $model in ufs922) $insmod /lib/modules/fan_ctrl.ko;; esac
	case $model in
		atevio7000|atemio7600)
			if grep -q "^at7000frontrun=" /mnt/config/titan.cfg; then
				LEDB=`grep "^at7000frontrun=" /mnt/config/titan.cfg | cut -d= -f2`
			else
				LEDB=15
			fi
			fp_control -P $LEDB;;
	 esac
}

startCpufreq()
{
	case $model in
		ufs910|ufs912|ufs913|ufs922)
			if [ -e "/lib/modules/cpu_frequ.ko" ]; then
				case $debug in on|full)	echo "$CMD [$INPUT] startCpufreq";;	esac
				$insmod /lib/modules/cpu_frequ.ko
				case $pll0_ndiv_mdiv in
					0) ;;
					*) echo $pll0_ndiv_mdiv > /proc/cpu_frequ/pll0_ndiv_mdiv;;
				esac
				case $pll1_ndiv_mdiv in
					0) ;;
					*) echo $pll1_ndiv_mdiv > /proc/cpu_frequ/pll1_ndiv_mdiv;;
				esac
				case $pll1_fdma_bypass in 1) echo 1 > /proc/cpu_frequ/pll1_fdma_bypass;; esac
			fi;;
	esac
}

startAvs()
{
	echo "$CMD [$INPUT] startAvs"
	$insmod /lib/modules/avs.ko $avs
	if [ "$model" = "ipbox910" ] && [ `lsmod | grep -c "avs"` -eq 0 ]; then
		$insmod /lib/modules/avs.ko type=avs_pio
	fi
}

startFrameBuffer()
{
	echo "$CMD [$INPUT] init stmfb"
	$insmod /lib/modules/stmcore-display-$display
	# git used :pal:cvbs:yuv;	
	# try later
	FBCHECK="insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":rgb:rgb"
	$insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":rgb:rgb;
	echo "$CMD [$INPUT] enable HDMI"

	if [ -e /var/etc/.scart ];then
		echo "$CMD [$INPUT] enable SCART (576i)"
		res=720x576-32
		hdmi=`echo $hdmi | cut -d: -f1`"i:"`echo $hdmi | cut -d: -f2`
		rmmod stmfb.ko
		FBCHECK="insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":cvbs"
		$insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":cvbs
	elif [ "$titanfirststart" == "1" ]; then
		tmpread=""; read tmpread < /sys/class/stmcoredisplay/display0/hdmi0.0/name
		if [ "$tmpread" == "SAFEMODE" ]; then
			echo "$CMD [$INPUT] enable SCART (576i)"
			res=720x576-32
			hdmi=`echo $hdmi | cut -d: -f1`"i:"`echo $hdmi | cut -d: -f2`
			rmmod stmfb.ko
			FBCHECK="insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":cvbs"
			$insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":cvbs
			> /var/etc/.scart
		else
			tmpread=""; read tmpread < /sys/class/stmcoredisplay/display0/hdmi0.0/name
			if [ "$tmpread" == "UNKNOWN" ]; then
				case $ipbox in
					1)
						/bin/eeprom tvmode
						TVMODE=$?
						case "$TVMODE" in
						0) echo "SD-PAL"
							rmmod stmfb.ko
							res=720x576-32
							hdmi=`echo $hdmi | cut -d: -f1`"i:"`echo $hdmi | cut -d: -f2`
							$insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":rgb:rgb
							FBCHECK="insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":rgb:rgb"
							> /var/etc/.scart;;
						1) echo "SD-NTSC";;
						2) echo "720P-50";;
						3) echo "720P-60";;
						4) echo "1080I-50";;
						5) echo "1080I-60";;
						*) echo "Use default SD-PAL"
							rmmod stmfb.ko
							res=720x576-32
							hdmi=`echo $hdmi | cut -d: -f1`"i:"`echo $hdmi | cut -d: -f2`
							$insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":rgb:rgb
							FBCHECK="insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":rgb:rgb"
							> /var/etc/.scart;;
						esac;;
					*)
						echo "$CMD [$INPUT] HDMI UNKNOWN"
						echo "$CMD [$INPUT] enable SCART (576i)"
						res=720x576-32
						hdmi=`echo $hdmi | cut -d: -f1`"i:"`echo $hdmi | cut -d: -f2`
						rmmod stmfb.ko
						$insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":cvbs
						FBCHECK="insmod /lib/modules/stmfb.ko display0="$res"@"$hdmi":"$pal":cvbs"
						> /var/etc/.scart;;
				esac
			fi
		fi
	fi
	echo $FBCHECK > /tmp/framebuffer.log

	# enable premultiplied blend mode
	stfbset -p

	$insmod /lib/modules/stm_v4l2.ko
}

startPlayer()
{
	echo "$CMD [$INPUT] init embx"
	$insmod /lib/modules/embxshell.ko
	$insmod /lib/modules/embxmailbox.ko $embxmailbox
	$insmod /lib/modules/embxshm.ko $embxshm
	$insmod /lib/modules/mme_host.ko transport0=shm
	$insmod /lib/modules/mmelog.ko

	echo "$CMD [$INPUT] init player 191"

	case $model in
		at7500|ufs912|ufs913|spark|spark7162|atemio7600) echo "$CMD [$INPUT] skip mpeg2hw.ko";;
		*) $insmod /lib/modules/mpeg2hw.ko mmeName=$mmeName;;
	esac

	$insmod /lib/modules/p2div64.ko
	$insmod /lib/modules/ksound.ko
	$insmod /lib/modules/pseudocard.ko

 	if [ -e "/lib/modules/lnb.ko" ]; then
#	 	if [ "$model" = "atemio510" ] || [ "$model" = "spark" ];then
#			$insmod /lib/modules/lnb.ko type=a8293
#		else
#			$insmod /lib/modules/lnb.ko type=pio
#		fi

		case $model in
			ufc960) echo "skip lnb";;
			atemio510|spark|spark7162)	$insmod /lib/modules/lnb.ko type=a8293;;
			*)	$insmod /lib/modules/lnb.ko type=pio;;esac
 	fi

	if [ -e "/lib/modules/frontend_platform.ko" ]; then
		$insmod /lib/modules/frontend_platform.ko
		$insmod /lib/modules/socket.ko
		$insmod /lib/modules/lnbh221.ko
		$insmod /lib/modules/lnb_pio.ko

		if [ -e "/lib/modules/lnb_a8293.ko" ]; then $insmod /lib/modules/lnb_a8293.ko; fi
		if [ -e "/lib/modules/dvb-pll.ko" ]; then $insmod /lib/modules/dvb-pll.ko; fi
		if [ -e "/lib/modules/cx24116.ko" ]; then $insmod /lib/modules/cx24116.ko; fi
		if [ -e "/lib/modules/tda10023.ko" ]; then $insmod /lib/modules/tda10023.ko; fi
		if [ -e "/lib/modules/zl10353.ko" ]; then $insmod /lib/modules/zl10353.ko; fi
		if [ -e "/lib/modules/stv0288.ko" ]; then $insmod /lib/modules/stv0288.ko; fi
		if [ -e "/lib/modules/tda10024.ko" ]; then $insmod /lib/modules/tda10024.ko; fi
		if [ -e "/lib/modules/cxd2820.ko" ]; then $insmod /lib/modules/cxd2820.ko; fi
		if [ -e "/lib/modules/stv090x.ko" ]; then $insmod /lib/modules/stv090x.ko; fi
		if [ -e "/lib/modules/stv0367.ko" ]; then $insmod /lib/modules/stv0367.ko; fi
	elif [ -e "/lib/modules/avl2108_platform.ko" ]; then
		$insmod /lib/modules/avl2108_platform.ko
	fi

	case $model in
		ipbox91|ipbox910|ipbox900|ipbox9000)
			echo "skip insmod tuner=$tuner";;
		ufs922)
			$insmod /lib/modules/$tuner
			$insmod /lib/modules/$tunersec;;
		*)
			$insmod /lib/modules/$tuner;;
	esac

	$insmod /lib/modules/$ci

	if [ "$camrouting" == 1 ];then
		touch /tmp/.camrouting
	fi

	if [ "$model" == "ufs910" ] && [ $camrouting ];then
#		$insmod /lib/modules/pti.ko camRouting=$camrouting
		$insmod /lib/modules/pti.ko
	else
		$insmod /lib/modules/pti.ko waitMS=20 videoMem=4096 
	fi
	
	$insmod /lib/modules/stm_monitor.ko
	$insmod /lib/modules/stmsysfs.ko
	$insmod /lib/modules/stmdvb.ko $useHighSR $useswts camRouting=$camrouting
# for old player2
#	$insmod /lib/modules/stmdvb.ko $useHighSR $useswts
	$insmod /lib/modules/player2.ko $usenoaudiosync discardlateframe=0 $useoldaudiofw

	$insmod /lib/modules/sth264pp.ko
	$insmod /lib/modules/stmalloc.ko
	$insmod /lib/modules/platform.ko
	$insmod /lib/modules/silencegen.ko
	$insmod /lib/modules/bpamem.ko
}

startBootlogo()
{
	echo "$CMD [$INPUT] startBootlogo"

	#fix green bootpicture
	case $bootrgbfix in y) echo rgb > /proc/stb/avs/0/colorformat;; esac

	if [ "$bootlogo" == 'y' ]; then
	 	if [ -e /mnt/swapextensions/etc/boot/bootlogo.jpg ]; then
			infobox 200 "nobox#/mnt/swapextensions/etc/boot/bootlogo.jpg" &
		else
			if [ -e /var/etc/boot/bootlogo.jpg ]; then
				infobox 200 "nobox#/var/etc/boot/bootlogo.jpg" &
			fi
		fi
	fi
}

startFrontpanel()
{
	echo "$CMD [$INPUT] startFrontpanel"
	if [ -e "/lib/modules/clk.ko" ]; then
		$insmod /lib/modules/clk.ko
	fi

	case $model in
		ufs912|ufs913|at7500|skysat|atemio510|spark|spark7162|atemio7600|atemio530|atemio520)
			echo "$CMD [$INPUT] skip init frontpanel";;
		*)
			echo "$CMD [$INPUT] init frontpanel"
			$insmod /lib/modules/boxtype.ko;;
	esac

	if [ -e "/lib/modules/simu_button.ko" ]; then
		$insmod /lib/modules/simu_button.ko
	fi
  
	case $model in
		spark)
			echo "$CMD [$INPUT] init frontpanel"
			$insmod /lib/modules/aotom.ko
			$insmod /lib/modules/encrypt.ko;;
	esac
}

startReader()
{
	echo "$CMD [$INPUT] startReader $SWTYPE $model"
	if [ -e "/lib/modules/smartcard.ko" ]; then
		$insmod /lib/modules/smartcard.ko
	fi
}

startEvremote()
{
	echo "$CMD [$INPUT] startEvremote $SWTYPE $model"

	if [ "$model" = "atemio520" ]; then
		echo "$CMD [$INPUT] sleep 10"
		sleep 10
		date +%s
		echo "$CMD [$INPUT] $insmod /lib/modules/$front"
		$insmod /lib/modules/$front
		date +%s
	fi

	case $model in
		ufs910)
			read var < /proc/boxtype
			case $var in
				0)   echo "$CMD [$INPUT] 1W boxtype";;
				1|3) echo "$CMD [$INPUT] 14W boxtype"
					 echo "$CMD [$INPUT] init lircd"
					 mkdir -p /var/run/lirc
					 /usr/bin/lircd
					 $insmod /lib/modules/button.ko
					 $insmod /lib/modules/led.ko;;
				*)   echo "$CMD [$INPUT] unknown boxtype use 14W"
					 mkdir -p /var/run/lirc
					 /usr/bin/lircd
					 $insmod /lib/modules/button.ko
					 $insmod /lib/modules/led.ko;;
			esac
			/bin/evremote2 &;;
		ufs922)
			/bin/evremote2 0 0 10 120 &;;
		atemio520|atemio530)
			/bin/evremote2 150 10 &;;
		ipbox910|ipbox900|ipbox91|ipbox9000)
			/bin/evremote2 10 140 &;;
		spark|spark7162)
			mkdir -p /var/run/lirc
			/etc/init.d/lircd start
#			/usr/bin/lircd
#			/usr/bin/time.sh & 
#			/bin/evremote2 10 120 &
			;;
		ufs913)
			fp_control -c
			/bin/evremote2 10 120 &;;
		*)
			/bin/evremote2 10 120 &;;
	esac
}

startDownmix()
{
	case $model in
		at700|atevio700)
			echo "$CMD [$INPUT] startDownmix $SWTYPE $model"
			if [ -e /var/etc/.downmix ]; then
				echo downmix > /proc/stb/audio/ac3
				echo downmix > /proc/stb/audio/ac3_choice
			fi;;
	esac
}

startDisplaySystem()
{
	case $model in
		atemio510|atemio530|atemio520|ipbox91) ;;
		*)
			echo "$SWTYPE" > /dev/vfd;;
	esac	
}

startLoadmodules() {
	case $debug in on|full) echo "$CMD [$INPUT] load Module";; esac
	MEM=$IFS; IFS=$"\012"
	[ -z "`grep -v ^# /var/etc/blacklist-modules`" ] && BLK_LIST="" || BLK_LIST=`grep -v ^# /var/etc/blacklist-modules`
	IFS=$MEM
	LIST=`ls -1 /var/lib/modules`
	for ROUND in $LIST; do
		WHITE=1
		if [ ! -z "$BLK_LIST" ]; then
			for BLK_MOD in $BLK_LIST; do
				[ "$ROUND" == "$BLK_MOD" ] && WHITE=0 && break
			done
		fi
		[ $WHITE -ne 0 ] && insmod /var/lib/modules/"$ROUND"
	done
}

startSamba() {
	case $sambaserver in
		y)
			export PATH=$PATH:/var/swap/bin:/mnt/swapextensions/bin:/var/bin
			export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/var/swap/lib:/mnt/swapextensions/lib:/var/lib
			case $debug in on|full) echo "$CMD [$INPUT] start samba";; esac
			smbd -D -s /mnt/config/smb.conf
			sleep 1
			nmbd -D -s /mnt/config/smb.conf;;
	esac
}

startNfs() {
	if [ ! -e /mnt/config/exports ]; then cp /var/etc/exports /mnt/config/exports; fi
	case $nfsserver in
		y)
			case $debug in on|full) echo "$CMD [$INPUT] start startNfs";; esac
			/etc/init.d/portmap start &
			/etc/init.d/nfs-kernel-server start &;;
	esac
}

checkEmu() {
	emuret=`emu.sh check | grep "checkemu running emu="`
	if [ -z "$emuret" ]; then
		startEmu
	fi
}

startNetmodule() {
	case $debug in on|full) echo "$CMD [$INPUT] start Load Netmodule";; esac
	if [ -e /lib/modules/fuse.ko ]; then
		case $debug in on|full) echo "$CMD [$INPUT] Load fuse.ko modul";; esac
		$insmod /lib/modules/fuse.ko
	fi
	if [ -e /lib/modules/ntfs.ko ]; then
		case $debug in on|full)	echo "$CMD [$INPUT] Load ntfs.ko modul";; esac
		$insmod /lib/modules/ntfs.ko
	fi
	if [ -e /lib/modules/jfs.ko ]; then
		case $debug in on|full)	echo "$CMD [$INPUT] Load jfs.ko modul";; esac
		$insmod /lib/modules/jfs.ko
	fi
	if [ -e /lib/modules/cifs.ko ]; then
		case $debug in on|full) echo "$CMD [$INPUT] Load cifs.ko modul";; esac
		$insmod /lib/modules/cifs.ko
	fi
	if [ -e /lib/modules/nfs_acl.ko ]; then
		case $debug in on|full) echo "$CMD [$INPUT] Load nfs_acl.ko modul";; esac
		$insmod /lib/modules/nfs_acl.ko
	fi
	if [ -e /lib/modules/exportfs.ko ]; then
		case $debug in on|full) echo "$CMD [$INPUT] Load exportfs.ko modul";; esac
		$insmod /lib/modules/exportfs.ko
	fi
	if [ -e /lib/modules/nfsd.ko ]; then
		case $debug in on|full) echo "$CMD [$INPUT] Load nfsd.ko modul";; esac
		$insmod /lib/modules/nfsd.ko
	fi
}

startRcreboot() {
	case $rcreboot in
		y)
			case $debug in on|full) echo "$CMD [$INPUT] start RC-Reboot";; esac
			RCDEV=`grep "rcdev=" /mnt/config/titan.cfg | cut -d "=" -f 2`
			awk -f /etc/init.d/getfb_old.awk $RCDEV &
	esac
}

startFonts() {
	if [ ! -e /var/usr/share/fonts/default.ttf ]; then
		case $debug in on|full) echo "$CMD [$INPUT] restore default fonts";; esac
		cp /var/usr/share/fonts/backup-default.ttf /var/usr/share/fonts/default.ttf
	fi
}

startWlan() {
	case $wlan in
		y)
			if [ -f /var/etc/autostart/wlan ]; then
				WLAN_LOG=/tmp/wlan.log
				> $WLAN_LOG
				WLAN_STARTMODE=load
				. /var/etc/autostart/wlan
			else
				echo "$CMD [$INPUT] wireless plugin not installed"
			fi;;
	esac
}

startSystemdown() {
	start_sec.sh 2 /sbin/fuser -k /dev/dvb/adapter0/frontend0
	start_sec.sh 2 pkill tuxtxt
	start_sec.sh 2 pkill -9 tuxtxt
	start_sec.sh 10 sync
	case $debug in on|full) echo "$CMD [$INPUT] Swapoff";; esac
	start_sec.sh 10 swap.sh swapfileoff "$SWTYPE" "$model"
	case $debug in on|full) echo "$CMD [$INPUT] Stop Emu";; esac
	start_sec.sh 2 emu.sh stop
}

startReboot() {
	case $model in tf7700) /bin/tffpctl --setgmtoffset;; esac

	echo [start.sh] startReboot $REBOOT >/tmp/log
	case $REBOOT in
		1)
			echo "$CMD [$INPUT] $SWTYPE SHUTDOWN"
			case $model in
				atemio530|atemio520|ipbox91|spark) startDigit4Display &;;
			*)
				echo "SHUTDOWN" > /dev/vfd;;
			esac
			startTimefix
			#case $model in ufs922) fp_control -ww;; esac #write only wakeUp File
			startSystemdown
			startRemoveLeds
			init 0;;
		2)
			echo "$CMD [$INPUT] $SWTYPE REBOOT"
			case $model in
				atemio530|atemio520|ipbox91|spark) startDigit4Display &;;
			*)
				echo "REBOOT" > /dev/vfd;;
			esac
			#case $model in ufs922) fp_control -ww;; esac #write only wakeUp File
			startSystemdown
			startRemoveLeds
			init 6;;
		3)
			echo "$CMD [$INPUT] $SWTYPE RESTART"
			start_sec.sh 2 /sbin/fuser -k /dev/dvb/adapter0/frontend0
			case $model in
				atemio530|atemio520|ipbox91|spark) startDigit4Display &;;
			*)
				echo "RESTART" > /dev/vfd;;
			esac
			start_sec.sh 2 pkill tuxtxt
			start_sec.sh 2 pkill -9 tuxtxt;;
		*)
			sleep $errorstop
			startRemoveLeds
			echo "$CMD [$INPUT] ERROR $SWTYPE REBOOT"
			case $model in
				atemio530|atemio520|ipbox91|spark) startDigit4Display &;;
			*)
				echo "ERROR REBOOT" > /dev/vfd;;
			esac
			echo "$CMD [$INPUT] ERROR $SWTYPE touch /var/etc/.erasemtd"

			startSystemdown
			init 6;;
	esac
}

startDelflagfiles() {
	case $debug in on|full) echo "$CMD [$INPUT] Remove first and other";; esac
	if [ "$firstnet" == "1" ]; then rm -f /var/etc/.firstnet; fi
}

startCpufreqstop() {
	case $model in
		ufs910|ufs912|ufs913|ufs922)
			case $only_boot_overclock in
				y)
					case $debug in on|full) echo "$CMD [$INPUT] startCpufreqstop";; esac
					echo 15110 > /proc/cpu_frequ/pll0_ndiv_mdiv # 531MHZ
					echo 34057 > /proc/cpu_frequ/pll1_ndiv_mdiv # 399MHZ
					echo 0 > /proc/cpu_frequ/pll1_fdma_bypass;;
			esac;;
	esac
}

startSysctl() {
	case $debug in on|full) echo "$CMD [$INPUT] startSysctl";; esac
	echo 0 > /proc/sys/net/ipv4/tcp_timestamps
	echo 0 > /proc/sys/net/ipv4/tcp_sack
	echo 207936 > /proc/sys/net/core/rmem_max
	echo 207936 > /proc/sys/net/core/wmem_max
}

startTimefix() {
	case $model in
		*)	case $debug in on|full) echo "$CMD [$INPUT] startTimefix last";; esac
			#date=`date "+%H:%M:%S %m-%d-%Y"`
			date=`date "+%H:%M:%S %d-%m-%Y"`
			echo "$CMD [$INPUT] current Date : $date"
			/bin/fp_control -s $date;;
	esac
}

startPowerLed() {
	case $model in
		atevio7000)
			echo "$CMD [$INPUT] startPowerLed"
			if grep -q "^at7000frontrun=" /mnt/config/titan.cfg; then
				level=`grep "^at7000frontrun=" /mnt/config/titan.cfg | cut -d= -f2`
			fi
			case $level in
				"") fp_control -P 15;;
				*)  fp_control -P "$level";;
			esac;;
	esac
}

startFirmware() {
	# instead of loading FW in rcS to mount swapstick before loading optional audio.elf
	case $debug in on|full) echo "$CMD [$INPUT] startFirmware";; esac

	# mme bug workaround
	case $model in
		ufs910)
			dd if=/dev/zero of=/dev/st231-0 bs=1024 count=4096
			dd if=/dev/zero of=/dev/st231-1 bs=1024 count=4096;;
	esac
	# end mme bug wa

	# ext firmware workaround for smal swap mtd boxes
	case $model in
		ufs910|ufs922|atevio700|atevio7000)
			FIRMWAREDEV=`blkid -w /dev/null -c /dev/null -s LABEL | grep -m1 "SWAP" | cut -d ":" -f1`
			if [ ! -z "$FIRMWAREDEV" ]; then
				mkdir /var/firmware
				mount "$FIRMWAREDEV" /var/firmware
				if [ -e /var/firmware/swapextensions ]; then
					rm -rf /var/swap
					ln -sn /var/firmware/swapextensions /var/swap
				fi
			fi
	esac
	# end ext firmware for smal swap mtd boxes workaround

	echo "swappath: "`readlink /var/swap` > /tmp/.firmware.log 

	audioelf="/boot/audio.elf"
	videoelf="/boot/video.elf"

  if [ -e /mnt/swapextensions/bin/video.elf ]; then
		videoelf="/mnt/swapextensions/bin/video.elf"
		useoldvideofw="useoldvideofw=1"
	elif [ -e /var/swap/bin/video.elf ]; then
		videoelf="/var/swap/bin/video.elf"
		useoldvideofw="useoldvideofw=1"
	elif [ -e /var/bin/video.elf ]; then
		videoelf="/var/bin/video.elf"
		useoldvideofw="useoldvideofw=1"
	fi
	
	if [ -e /mnt/swapextensions/bin/audio.elf ]; then
		audioelf="/mnt/swapextensions/bin/audio.elf"
		useoldaudiofw="useoldaudiofw=1"
	elif [ -e /var/swap/bin/audio.elf ]; then
		audioelf="/var/swap/bin/audio.elf"
		useoldaudiofw="useoldaudiofw=1"
	elif [ -e /var/bin/audio.elf ]; then
		audioelf="/var/bin/audio.elf"
		useoldaudiofw="useoldaudiofw=1"
	fi

	echo "$CMD [$INPUT] load audio firmware ($audioelf)"
	/bin/ustslave /dev/st231-1 "$audioelf"
	if [ $? -ne 0 ]; then
		audioelf="/boot/audio.elf"
		useoldaudiofw=""
		echo "$CMD [$INPUT] error load default audio firmware ($audioelf)"
		/bin/ustslave /dev/st231-1 "$audioelf"
	fi

	echo "$CMD [$INPUT] load video firmware"
	/bin/ustslave /dev/st231-0 "$videoelf"
	if [ $? -ne 0 ]; then
		videoelf="/boot/video.elf"
		echo "$CMD [$INPUT] error load default video firmware ($videoelf)"
		/bin/ustslave /dev/st231-0 "$videoelf"
	fi

	echo "video: $videoelf" >> /tmp/.firmware.log
	echo "audio: $audioelf" >> /tmp/.firmware.log
}

startSetled()
{
	case $model in
		ufs910)
			case $debug in on|full) echo "$CMD [$INPUT] startSetled";; esac
			echo "B" > /dev/ttyAS1;;
	esac
	if [ "$model" != "atemio510" ] && [ -e /tmp/.moviedev ]; then
		case $debug in on|full) echo "$CMD [$INPUT] startSetled";; esac
		case $model in
			ipbox91|ipbox900|ipbox910|ipbox9000) vfdctl +music;;
			*) vfdctl +hdd;;
		esac
	fi
}

startSwap() {
	case $debug in on|full) echo "$CMD [$INPUT] startSwap";; esac
	if [ ! -e /tmp/.swapdirdev ]; then
		case $debug in
			on|full) swap.sh "showInfoDirect" "$SWTYPE" "$model";;
			*) swap.sh "" "$SWTYPE" "$model";; esac
	fi
}

startUsercmd() {
	case $debug in on|full) echo "$CMD [$INPUT] startUsercmd";; esac
	if [ -e /mnt/config/usercmd.sh ]; then
		/mnt/config/usercmd.sh
	fi
}

startVPN() {
	case $debug in on|full) echo "$CMD [$INPUT] startVPN";; esac
	if [ -e /var/bin/vpn.sh ]; then
		/var/bin/vpn.sh
	fi
}

startInaDyn() {
	case $debug in on|full) echo "$CMD [$INPUT] startInaDyn";; esac
	case $inadyn in
		y)
			inadyn --input_file /mnt/config/inadyn.conf &
		;;
	esac
}

startDLNA() {
	case $debug in on|full) echo "$CMD [$INPUT] startDLNA";; esac
	case $dlna in
		y)
			if [ -e /var/swap/usr/local/share/titan/plugins/dlna/dlna.sh ]; then
				/var/swap/usr/local/share/titan/plugins/dlna/dlna.sh start /var/swap/etc/minidlna.conf &
			elif [ -e /mnt/swapextensions/usr/local/share/titan/plugins/dlna/dlna.sh ]; then
			  /mnt/swapextensions/usr/local/share/titan/plugins/dlna/dlna.sh start /mnt/swapextensions/etc/minidlna.conf &
			fi
		;;
	esac
}

startRemoveLeds()
{
	if [ "$model" != "atemio510" ]; then
		vfdctl -usb -hd -hdd -lock -bt -mp3 -music -dd -mail -mute -play -pause -ff -fr -rec -clock

		case $model in
			ufs910)
				fp_control -l 2 1 > /dev/null
				fp_control -led 1 > /dev/null;;
			ufs912|ufs913)
				fp_control -l 3 1 > /dev/null
				fp_control -led 1 > /dev/null;;
		esac
	fi
}

startSetLeds()
{
	case $model in
		ufs910)
			fp_control -l 1 1 > /dev/null;;
		ufs912)
			fp_control -l 2 1 > /dev/null;;
		ufs913)
			fp_control -l 2 1 > /dev/null
			fp_control -led 80 > /dev/null;;
		ipbox91|ipbox900|ipbox910|ipbox9000)
			fp_control -l 0 1 > /dev/null;;
	esac
}

startSATASwitch() {
	case $model in
		at7500|atemio7600)
			case $debug in on|full) echo "$CMD [$INPUT] startSATASwitch";; esac
			$insmod /lib/modules/sata.ko
			case $sataswitch in
				0)
					echo 0 > /proc/sata/sata_switch;;
				1)
					echo 1 > /proc/sata/sata_switch;;
			esac;;
	esac
}

startCEC() {
	case $model in
		atemio510|ufs912|ufs913|at7500|atemio7600|atemio530|atemio520|spark|spark7162)
			case $debug in on|full) echo "$CMD [$INPUT] startCEC";; esac
			$insmod /lib/modules/cec.ko activemode=1;;
	esac
}

#Workaround for Kernel p211 to get mac
restartET0()
{
	ifconfig eth0 up
}
	
startAutofs()
{
	echo "$CMD [$INPUT] start autofs"

	rm -f /media/net/*
	rm -f /media/usb/*
	if [ -L /var/backup ] || [ -e /var/backup ]; then rm -rf /var/backup; fi
	if [ -L /var/swapdir ] || [ -e /var/swapdir ]; then rm -rf /var/swapdir; fi
	if [ -L /var/swap ] || [ -e /var/swap ]; then rm -rf /var/swap; fi
	if [ -L /media/hdd ] || [ -e /media/hdd ]; then rm -rf /media/hdd; fi

	echo "$CMD [$INPUT] start load autofs"
	echo "$CMD [$INPUT] start automount 1"
	/etc/init.d/autofs start
	if [ $? -ne 0 ]; then
		echo "$CMD [$INPUT] start automount 2"
		/etc/init.d/autofs start
		if [ $? -ne 0 ]; then
			echo "$CMD [$INPUT] start automount 3"
			/etc/init.d/autofs start
			if [ $? -ne 0 ]; then
				echo "$CMD [$INPUT] start automount 4"
				/etc/init.d/autofs start
				if [ $? -ne 0 ]; then
					echo "$CMD [$INPUT] autofs... error automount not started"
				fi
			fi
		fi
	fi
}

startHotplug()
{
	echo "$CMD [$INPUT] start hotplug.sh first $SWTYPE $model"
	/sbin/hotplug.sh first "$SWTYPE" "$model"
}

startHostname()
{
	if [ -f /etc/hostname ]; then
		hostname -F /etc/hostname
	fi
}

startNetwork()
{
	echo "$CMD [$INPUT] startNetwork: start"

	iface="eth0"
	if [ ! -z "$1" ]; then iface=$1; fi

	if [ "$iface" == "eth0" ]; then
		if grep -q "nfs" /proc/cmdline; then 
			echo "$CMD [$INPUT] startNetwork: Booting from nfs, don't set network"
		else
			if [ "$model" = "ufs913" ]; then
				HWADDR=`strings /dev/mtdblock2 | tail -n 1`
				ifconfig eth0 down
				ifconfig eth0 hw ether ${HWADDR}
				ifconfig eth0 up
			fi

#			if [ `gotnetlink eth0 | grep 'Link detected: yes' | head -n1 | wc -l` -eq 1 ];then
				/etc/init.d/networking -i "$iface" -s "$showip" start
				if [ "$model" = "ufs910" ]; then
					echo 1 > /proc/smsc911x/setspeed; echo 10 > /proc/smsc911x/deas; echo 0 > /proc/smsc911x/tx_pio
				fi
#			fi
		fi
	else
		/etc/init.d/networking -i "$iface" -s "$showip" start
	fi
}

startInetd()
{
	echo "$CMD [$INPUT] start inetd"
#	if [ ! -e /etc/.debug ];then
#		rm -rf /dev/ttyAS0
#	else
		/usr/sbin/inetd
#	fi
}

startMakeDevs()
{
	case $debug in on|full) echo "$CMD [$INPUT] startMakeDevs";; esac
	if [ "$ipbox" == "1" ]; then
		if [ -e /dev/ttyAS1 ]; then	rm -f /dev/ttyAS1;	fi
	fi
}

startPl2303()
{
	if [ "$pl2303" = "y" ] && [ -e "/lib/modules/usbserial.ko" ] && [ -e /lib/modules/pl2303.ko ]; then
		case $debug in on|full) echo "$CMD [$INPUT] Load pl2303 modul";; esac

		echo "$CMD [$INPUT] insmod usbserial"
		$insmod /lib/modules/usbserial.ko

		echo "$CMD [$INPUT] insmod pl2303"
		$insmod /lib/modules/pl2303.ko
	fi
}

startFtdi()
{
	if [ "$ftdi" = "y" ] && [ -e "/lib/modules/usbserial.ko" ] && [ -e /lib/modules/ftdi_sio.ko ]; then
		case $debug in on|full) echo "$CMD [$INPUT] Load Ftdi modul";; esac

		echo "$CMD [$INPUT] insmod usbserial"
		$insmod /lib/modules/usbserial.ko

		echo "$CMD [$INPUT] insmod ftdi"
		$insmod /lib/modules/ftdi_sio.ko
	fi
}

startDropcaches() 
{
	echo "$CMD [$INPUT] startDropcaches"
	echo 3 > /proc/sys/vm/drop_caches
}

startMountSwap()
{
	case $imagetype in
		flash)
			if [ -e /var/swap/.erasemtd ] ||  [ -e /var/etc/.erasemtd ] || [ ! -e /mnt/swapextensions ]; then
				if [ -e /var/swap/.erasemtd ];then
					rm /var/swap/.erasemtd
				fi		
				mtd=4
				if [ "$model" = "ufs912" ] || [ "$model" = "atemio520" ] || [ "$model" = "atemio530" ] || [ "$model" = "ipbox91" ] || [ "$model" = "ipbox910" ] || [ "$model" = "ipbox900" ] || [ "$model" = "ipbox9000" ]; then
					mtd=5
				fi
				if [ "$model" = "ufs913" ];then
					mtd=10
				fi
				if [ "$model" = "spark" ] || [ "$model" = "spark7162" ];then
					mtd=7
				fi
				if [ -e /var/etc/.backupmtd ]; then
					echo "$CMD [$INPUT] backupmtd (MTD$mtd)"
					mkdir /tmp/backupmtd
					cp -a /mnt/settings /tmp/backupmtd
					cp -a /mnt/config /tmp/backupmtd
					cp -a /mnt/network /tmp/backupmtd
					cp -a /mnt/script /tmp/backupmtd
					mkdir /tmp/backupmtd/swapextensions
					cp -a /mnt/swapextensions/player /tmp/backupmtd/swapextensions
					echo "$CMD [$INPUT] backuptpk (MTD$mtd)"
					backuptpk
				fi

				echo "$CMD [$INPUT] umount SWAP-FLASH (MTD$mtd)"
				umount -fl /mnt
				echo "$CMD [$INPUT] erase SWAP-FLASH (MTD$mtd)"
				cp -aL /dev/vfd /tmp/vfd
				flash_eraseall -l "Lösche: SWAP" -x "$model" /dev/mtd"$mtd"
				echo "$CMD [$INPUT] mount SWAP-FLASH (MTD$mtd)"
				infobox 9999 INFO "Formatiere und Initialisiere SWAP" "" "Receiver bitte nicht ausschalten" &
				busybox mount -n -t jffs2 -o rw,noatime,nodiratime /dev/mtdblock"$mtd" /mnt
				echo "$CMD [$INPUT] create swapextensions folder SWAP-FLASH (MTD$mtd)"
				mkdir /mnt/swapextensions
				mkdir /mnt/bin
				echo "$CMD [$INPUT] hotplug.sh startStickextensions SWAP-FLASH (MTD$mtd)"
				hotplug.sh startStickextensionsMNT

				if [ -e /var/etc/.backupmtd ]; then
					echo "$CMD [$INPUT] restoretpk (MTD$mtd)"
					restoretpk
					echo "$CMD [$INPUT] backupmtd (MTD$mtd)"
					rm -rf /mnt/settings
					rm -rf /mnt/config
					rm -rf /mnt/network
					rm -rf /mnt/script
					rm -rf /mnt/swapextensions/player
					cp -a /tmp/backupmtd/* /mnt
				else
					mkdir /mnt/tpk
					mkdir /mnt/script
					reset.sh
				fi
				
				rm -r /var/etc/.erasemtd
				rm -r /var/etc/.backupmtd
				
				killall infobox
				infobox 9999 INFO "Formatiere und Initialisiere SWAP" "" "Receiver kann nun ausgeschalten werden,"  "sollte er nicht automatisch neu booten" &
				sleep 2
				#without loading firmware reboot not working
				startFirmware 
				reboot 
			fi;;
	esac
}

startNtpdate()
{
	case $ntpdate in
		y)
			case $debug in on|full) echo "[$0] [$INPUT] startDate: start";; esac
			ntpdate -b ptbtime1.ptb.de &
	esac
}

startSetTime()
{
          if [ -e "/mnt/script/settime.sh" ]; then
                  /mnt/script/settime&
          fi
}

startDigit4Display() 
{
	echo "$CMD [$INPUT] startDigit4Display"

	a=0
	touch /tmp/.bootvfd
	echo "    " > /dev/vfd
	
	while [ $a -lt 120 ]
	do
		echo $a
		a=`expr $a + 1`

		if [ ! -e /tmp/.bootvfd ]; then	break;	fi		
		echo "o   " > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo "oo" > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo "ooo" > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo "oooo" > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo " ooo" > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo "  oo" > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo "   o" > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo "  oo" > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo " ooo" > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo "oooo" > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo "ooo " > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		echo "oo  " > /dev/vfd
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
		sleep 1
#		if [ ! -e /tmp/.bootvfd ]; then	break;	fi
	done
	echo "    " > /dev/vfd
}

startReHotplug()
{
	if [ -e "/mnt/network/.recordshare" ];then
		echo "$CMD [$INPUT] mount Nas Record Share"
		echo "$CMD [$INPUT] start hotplug.sh first $SWTYPE $model &"
		/sbin/hotplug.sh first "$SWTYPE" "$model" &
	fi
}

startAsound()
{
	if [ -e "/usr/bin/amixer" ] || [ -e "/mnt/swapextensions/bin/amixer" ] || [ -e "/mnt/swap/bin/amixer" ];then
		sound=`cat /mnt/config/titan.cfg | grep vol_playerstop | cut -d '=' -f2`
		if [ -z "$sound" ];then
			sound=70
		fi
		export PATH=$PATH:/var/swap/bin:/mnt/swapextensions/bin:/var/bin
		export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/var/swap/lib:/mnt/swapextensions/lib:/var/lib
		amixer -c 1 set Analog playback "$sound%" unmute &
		amixer -c 1 set SPDIF playback "$sound%" unmute &
		amixer -c 1 set HDMI playback "$sound%" unmute &
		touch /tmp/.asound.mixer.running
		#/usr/bin/amixer -c 1 set Master 70% unmute & ... nicht noetig wird durch volume der Box gesetzt.
	fi
}

startCheckPIN() {
	case $PinOn in
		y)
			echo "PIN - Eingabe" > /dev/vfd
			if [ $Pin ]; then
				w1=`echo $Pin | cut -c1`
				w2=`echo $Pin | cut -c2`
				w3=`echo $Pin | cut -c3`
				w4=`echo $Pin | cut -c4`
				pin $w1 $w2 $w3 $w4; ret=$?
			else
				pin 1 2 3 4; ret=$?
			fi

			case $ret in
				1)
					echo "ERROR" > /dev/vfd
					sync
					reboot;;
				*)
					echo "PIN --> OK" > /dev/vfd
					> /tmp/.pinok;;
			esac;;
	esac
}

startXUPNPD() {
	case $debug in on|full) echo "$CMD [$INPUT] startXUPNPD";; esac
	case $xupnpd in
		y)
			if [ -e /var/usr/local/share/titan/plugins/xupnpd/xupnpd.sh ]; then
				/var/usr/local/share/titan/plugins/xupnpd/xupnpd.sh start /var/etc/xupnpd &
			elif [ -e /var/swap/usr/local/share/titan/plugins/xupnpd/xupnpd.sh ]; then
				/var/swap/usr/local/share/titan/plugins/xupnpd/xupnpd.sh start /var/swap/etc/xupnpd &
			elif [ -e /mnt/swapextensions/usr/local/share/titan/plugins/xupnpd/xupnpd.sh ]; then
			  /mnt/swapextensions/usr/local/share/titan/plugins/xupnpd/xupnpd.sh start /mnt/swapextensions/etc/xupnpd &
			fi
		;;
	esac
}

startDebug() {
	if [ -e "/mnt/swapextensions" ] && [ "$debug" = "high" ];then
		cat /proc/kmsg > /mnt/bootlog.log
	fi  
}

startUsbImage() 
{
	if [ `lsmod | grep stmfb | wc -l` -gt 0 ]; then
		return
	fi
	if [ ! -f /var/etc/.multirun ]; then
	  return
	fi
	sleep 5
	mkdir /var/test
	ls /var
	titan_multi=xxx

	if [ $titan_multi == "xxx" ];then
		if [ `cat /proc/partitions | grep sda1 | wc -l` -gt 0 ]; then
			mount /dev/sda1 /var/test
			if [ `ls /var/test/titan_multi | wc -l` -gt 0 ]; then
				titan_multi=sda1
			fi
			umount /var/test
		fi
	fi
	if [ $titan_multi == "xxx" ];then
		if [ `cat /proc/partitions | grep sdb1 | wc -l` -gt 0 ]; then
			mount /dev/sdb1 /var/test
			if [ `ls /var/test/titan_multi | wc -l` -gt 0 ]; then
				titan_multi=sdb1
			fi
			umount /var/test
		fi
	fi
	echo "***** $titan_multi"
	if [ $titan_multi != "xxx" ];then
		echo "multi found"
		mkdir /var/multi
		multidev="/dev/"$titan_multi
		mount $multidev /var/multi
		BAHOME=/var/multi/titan_multi
		#TARGET=/test1

		startConfig
		startFrameBuffer
		startVfd
		startFrontpanel
		startEvremote
		

		TARGET=`cat $BAHOME/.multi_image`
		if [ -z $TARGET ]; then
			TARGET=Flash
		fi
		images=`ls $BAHOME | while read m 
		do
		 echo $m" " 
		done` 
		images="Flash "$images
		
		imagenum=1
		i=0
		for test in $images
		do
			i=`expr $i + 1`
  		if [ $test == $TARGET ]; then
				imagenum=$i
  			break
 			fi
		done
		if [ $imagenum -eq 1 ]; then
			TARGET=Flash
		fi
		
		(sleep 10; killall infobox) &
		pid=$!
		infobox GUI#$imagenum "MultiImage" $images; ret=$?
		kill -9 $pid
		if [ $ret != "0" ]; then
			TARGET=`echo $images | cut -d" " -f$ret` 
		fi
		if [ -z $TARGET ]; then
			TARGET=Flash
		fi
		echo -n $TARGET > $BAHOME/.multi_image
		infobox 1 "Info" "Image $TARGET startet"
		
		killall evremote2
		rmmod stm_v4l2.ko
		rmmod stmfb.ko
		rmmod stmcore-display-$display
		rmmod $front
		rmmod e2_proc.ko
		rmmod simu_button.ko
		rmmod boxtype.ko
		rmmod simu_button.ko
		
		if [ $TARGET == "Flash" ]; then
			return
		fi 		
		
		mkdir $BAHOME/$TARGET/sys
		mkdir $BAHOME/$TARGET/proc
		mkdir $BAHOME/$TARGET/dev
		mkdir $BAHOME/$TARGET/tmp
		mkdir $BAHOME/$TARGET/var/flash
		#cp /usr/bin/dummy.sh $BAHOME/$TARGET/usr/sbin/nandwrite
		cp /var/etc/titan_e2.sh $BAHOME/$TARGET/var/etc/titan_e2.sh
		if [ ! -f $BAHOME/$TARGET/var/etc/titan_e2.sh ]; then
			echo "Image $TARGET nicht ok.... reboot"
			reboot
		fi
		chmod 755 $BAHOME/$TARGET/var/etc/titan_e2.sh
		mount -o bind /proc "$BAHOME/$TARGET/proc"
		mount -o bind /dev "$BAHOME/$TARGET/dev"
		mount -o bind /sys "$BAHOME/$TARGET/sys"
		mount -o bind /tmp "$BAHOME/$TARGET/tmp"
		mount -o bind / "$BAHOME/$TARGET/var/flash"
		touch $BAHOME/$TARGET/etc/.usbimg
		kernelv=`uname -r`
		echo $kernelv > $BAHOME/$TARGET/etc/.kernelwirt
		exec chroot "$BAHOME/$TARGET" /var/etc/titan_e2.sh
		echo "***** Multiimage ended"
		reboot
	fi
}		

case $1 in
	first)
		if [ ! -e /etc/.usbimg ]; then
			startUsbImage
		fi
		startDebug &
		startUserSettings
		restartET0
		startSATASwitch
		( echo "$CMD Thread 1 start"
		  startCpufreq
		  startInetd
		  startNetmodule
		  startFonts
		  #startTimefix
		  echo "$CMD Thread 1 end" ) &
		#startBlkid
		startAutofs
		startHotplug
		startConfig
		startFrameBuffer
		startBootlogo			#startFrameBuffer
		startVfd					#startConfig
		startFrontpanel
		if [ "$model" != "atemio520" ]; then startEvremote; fi
		startSetLeds
#		if [ "$model" != "ufc960"  ]; then startMountSwap; fi
		startMountSwap
		startHostname
		startNetwork			#startVfd
		startWlan
		startReHotplug
		startNtpdate
		startSetTime
		startAvs
		startFirmware
		startPlayer				#startConfig, startFirmware
		startReader
		( echo "$CMD Thread 3 start"
		  startPowerLed
		  startDisplaySystem	#startVfd
		  startDownmix			#startPlayer
		  startCEC
		  startRcreboot			#startEvremote
		  startFtdi
		  startPl2303
		  echo "$CMD Thread 3 end" ) &
		startAsound
		startCheckPIN
		if [ "$model" != "ufs922" ]; then startEmu; fi
		if [ "$model" == "atemio520" ]; then
			startEvremote &
		fi
		startHotplug
		;;
	last)
		if [ "$model" == "ufs922"  ]; then startEmu; fi
		startMakeDevs
		startNetmodule
		startSetled
		startCpufreqstop
		startSwap
		sleep 10
		checkEmu
		startInaDyn
		startDLNA
		startXUPNPD
		startTimefix last
		startDelflagfiles
		startLoadmodules &
		startSamba &
		startNfs
		startSysctl
		startVPN
		startUsercmd
		sleep 10
		startHotplug
		;;
	reboot)
		startDropcaches
		startReboot;;
esac

exit
