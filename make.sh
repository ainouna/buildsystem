#!/bin/bash
# Version 20200314.1

##############################################

if [ "$(id -u)" = "0" ]; then
	echo ""
	echo "You are running as root. Do not do this, it is dangerous."
	echo "Aborting the build. Log in as a regular user and retry."
	echo ""
	exit 1
fi

##############################################

if [ "$1" == -h ] || [ "$1" == --help ]; then
	echo "Usage: $0 [-v | --verbose | -q | --quiet] [-b | --batchmode] [Parameter1 [Parameter2 ... [Parameter8]]]]]]]"
	echo
	echo "-v or --verbose   : verbose build (very noisy!)"
	echo "-q or --quiet     : quiet build, fastest, almost silent"
	echo "-b or --batchmode : batch mode; do not become interactive"
	echo "Parameter 1       : target system (1-39)"
	echo "Parameter 2       : kernel (1-2)"
	echo "Parameter 3       : optimization (1-5)"
	echo "Parameter 4       : image (Enigma=1/2 Neutrino=3/4 Tvheadend=5 (1-5)"
	echo "Parameter 5       : Neutrino variant (1-6) or Enigma2/Tvheadend diff (0-5)"
	echo "Parameter 6       : media Framework (Enigma2: 1-5; Neutrino, Tvheadend: ignored)"
	echo "Parameter 7       : external LCD (1=none, 2=graphlcd, 3=lcd4linux, 4=both)"
	echo "Parameter 8       : destination (1-2, 1=flash, 2=USB)"
	exit
fi

##############################################

echo "                    _ _             _      _    _"
echo "     /\            | (_)           (_)    | |  ( )"
echo "    /  \  _   _  __| |_  ___  ____  _  ___| | _|/ ___"
echo "   / /\ \| | | |/ _  | |/ _ \|  _ \| |/ _ \ |/ / / __|"
echo "  / ____ \ |_| | (_| | | (_) | | | | |  __/   <  \__ \\"
echo " /_/    \_\__,_|\__,_|_|\___/|_| |_|_|\___|_|\_\ |___/"
echo "                                                      "
echo "  _           _ _     _               _"
echo " | |         (_) |   | |             | |"
echo " | |__  _   _ _| | __| |___ _   _ ___| |_ ___ _ __ ___"
echo " |  _ \| | | | | |/ _  / __| | | / __| __/ _ \  _ v _ \\"
echo " | |_) | |_| | | | (_| \__ \ |_| \__ \ ||  __/ | | | | |"
echo " |_.__/\__,_\|_|_|\__,_|___/\__, |___/\__\___|_| |_| |_|"
echo "                             __/ |"
echo "                            |___/"

##############################################

# Determine image type and receiver model of the previous build, if any
if [ -e ./config ]; then
	cp ./config ./config.old
	LASTBOX=`grep -e "BOXTYPE=" ./config.old | awk '{print substr($0,9,length($0)-7)}'`
	LASTIMAGE1=`grep -e "enigma2" ./config.old | awk '{print substr($0,7,length($0)-7)}'`
	LASTIMAGE2=`grep -e "neutrino" ./config.old | awk '{print substr($0,7,length($0)-7)}'`
	LASTIMAGE3=`grep -e "tvheadend" ./config.old | awk '{print substr($0,7,length($0)-6)}'`
	if [ $LASTIMAGE1 ]; then
		LASTDIFF=`grep -e "E2_DIFF=" ./config.old | awk '{print substr($0,9,length($0)-7)}'`
	fi
	if [ $LASTIMAGE3 ]; then
		LASTDIFF=`grep -e "TVHEADEND_DIFF=" ./config.old | awk '{print substr($0,16,length($0)-7)}'`
	fi
	rm -f ./config.old
fi

##############################################

# Check for quiet / verbose argument
KBUILD_VERBOSE=normal
set="$@"
for i in $set;
do
	if [ $"$i" == -q ] || [ $"$i" == --quiet ]; then
		shift
		KBUILD_VERBOSE=quiet
		break
	elif [ $"$i" == -v ] || [ $"$i" == --verbose ]; then
		shift
		KBUILD_VERBOSE=verbose
		break
	fi
done
echo "KBUILD_VERBOSE=$KBUILD_VERBOSE" > config
export KBUILD_VERBOSE

#check for batch mode argument
for i in $set;
do
	if [ $"$i" == -b ] || [ $"$i" == --batchmode ]; then
		shift
		BATCHMODE="yes"
		break
	fi
done
export BATCHMODE

##############################################

CURDIR=`pwd`

if [ -e $CURDIR/build ]; then
	rm -f $CURDIR/build
fi
touch $CURDIR/build

##############################################

# Check if running on Gentoo
if `which lsb_release > /dev/null 2>&1`; then 
	if [ `lsb_release -s -i` == "Gentoo" ]; then
		echo "export WANT_AUTOMAKE=1.15" > $CURDIR/build
	fi
fi

##############################################

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-9]) REPLY=$1;;
	*)
		echo "Target receivers:"
		echo
		echo "  Kathrein             Fortis"
		echo "    1)  UFS-910          7)  FS9000 / FS9200 (formerly Fortis HDbox)"
		echo "    2)  UFS-912          8)  HS9510 (formerly Octagon SF1008P)"
		echo "    3)  UFS-913          9*) HS8200 (bootloader 6.00, formerly Atevio AV7500)"
		echo "    4)  UFS-922         10)  HS7110"
		echo "    5)  UFC-960         11)  HS7119"
		echo "                        12)  HS7420"
		echo "  Topfield              13)  HS7429"
		echo "    6)  TF77X0 HDPVR    14)  HS7810A"
		echo "                        15)  HS7819"
		echo
		echo "  AB IPBox             Cuberevo"
		echo "   16)  55HD            19)  id."
		echo "   17)  99HD            20)  mini"
		echo "   18)  9900HD          21)  mini2"
		echo "   19)  9000HD          22)  250HD"
		echo "   20)  900HD           23)  9500HD / 7000HD"
		echo "   21)  910HD           24)  2000HD"
		echo "   22)  91HD            25)  mini_fta / 200HD"
		echo "                        26)  3000HD / Xsarius Alpha"
		echo
		echo "  Fulan                Atemio"
		echo "   27)  Spark           29)  AM520"
		echo "   28)  Spark7162       30)  AM530"
		echo
		echo "  Various sh4-based receivers"
		echo "   31)  Edision Argus VIP1 V1 [ 1 tuner + 2 CI + 2 USB ]"
		echo "   32)  Edision Argus VIP1 V2 [ 1 fixedtuner + 2 CI + 1 USB + plugin tuner (DVB-S2/T/C) ]"
		echo "   33)  Edision Argus VIP2 V1 [ 2 plugin tuners ]"
		echo "   34)  SpiderBox HL-101"
		echo "   35)  ADB ITI-5800S(X) (nBox BSKA, BSLA, BXZB or BZZB)"
		echo "   36)  Vitamin HD5000"
		echo "   37)  SagemCom 88 series"
		echo "   38)  Ferguson Ariva @Link 200"
		echo "   39)  Pace HDS-7241 (kernel P0217 only)"
		echo
		read -p "Select target (1-39)? ";;
esac

case "$REPLY" in
	 1) BOXTYPE="ufs910";;
	 2) BOXTYPE="ufs912";;
	 3) BOXTYPE="ufs913";;
	 4) BOXTYPE="ufs922";;
	 5) BOXTYPE="ufc960";;
	 6) BOXTYPE="tf7700";;
	 7) BOXTYPE="fortis_hdbox";;
	 8) BOXTYPE="octagon1008";;
#	 9) BOXTYPE="atevio7500";;
	10) BOXTYPE="hs7110";;
	11) BOXTYPE="hs7119";;
	12) BOXTYPE="hs7420";;
	13) BOXTYPE="hs7429";;
	14) BOXTYPE="hs7810a";;
	15) BOXTYPE="hs7819";;
	16) BOXTYPE="ipbox55";;
	17) BOXTYPE="ipbox99";;
	18) BOXTYPE="ipbox9900";;
	19) BOXTYPE="cuberevo";;
	20) BOXTYPE="cuberevo_mini";;
	21) BOXTYPE="cuberevo_mini2";;
	22) BOXTYPE="cuberevo_250hd";;
	23) BOXTYPE="cuberevo_9500hd";;
	24) BOXTYPE="cuberevo_2000hd";;
	25) BOXTYPE="cuberevo_mini_fta";;
	26) BOXTYPE="cuberevo_3000hd";;
	27) BOXTYPE="spark";;
	28) BOXTYPE="spark7162";;
	29) BOXTYPE="atemio520";;
	30) BOXTYPE="atemio530";;
	31) BOXTYPE="hl101";;
	32) BOXTYPE="vip1_v2";;
	33) BOXTYPE="vip2_v1";;
	34) BOXTYPE="hl101";;
	35) BOXTYPE="adb_box";;
	36) BOXTYPE="vitamin_hd5000";;
	37) BOXTYPE="sagemcom88";;
	38) BOXTYPE="arivalink200";;
	39) BOXTYPE="pace7241";;
	 *) BOXTYPE="atevio7500";;
esac
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

echo -ne "\nChecking the .elf files in $CURDIR/root/boot..."
set='audio_7100 audio_7105 audio_7109 audio_7111 video_7100 video_7105 video_7109 video_7111'
ELFMISSING=0
for i in $set;
do
	if [ ! -e $CURDIR/root/boot/$i.elf ]; then
		echo -e -n "\n\033[31mERROR\033[0m: file $i.elf is missing in ./root/boot"
		ELFMISSING=1
	fi
done
if [ "$ELFMISSING" == "1" ]; then
	echo -e "\n"
	echo "Correct this and retry."
	echo
	exit
fi
echo " [OK]"
if [ -e $CURDIR/root/boot/put_your_elf_files_here ]; then
	rm $CURDIR/root/boot/put_your_elf_files_here
fi

##############################################
case $2 in
	[1-2]) REPLY=$2;;
	*)	echo -e "\nKernel:"
		echo "   1)  STM 24 P0209 [2.6.32.46]"
#		echo "   2)  STM 24 P0217 [2.6.32.61]"
		echo "   2*) STM 24 P0217 [2.6.32.71]"
		read -p "Select kernel (1-2)? ";;
esac

case "$REPLY" in
	1)  KERNEL_STM="p0209";;
#	2)  KERNEL_STM="p0217_61";;
#	3)  KERNEL_STM="p0217";;
	*)  KERNEL_STM="p0217";;
esac
echo "KERNEL_STM=$KERNEL_STM" >> config

##############################################

case $3 in
	[1-5]) REPLY=$3;;
	*)	echo -e "\nOptimization:"
		echo "   1)  optimization for smallest, very basic image (E2 only)"
		echo "   2*) optimization for size"
		echo "   3)  optimization normal"
		echo "   4)  Kernel debug"
		echo "   5)  debug (includes Kernel debug)"
		read -p "Select optimization (1-5)? ";;
esac

case "$REPLY" in
	1)  OPTIMIZATIONS="small";;
#	2)  OPTIMIZATIONS="size";;
	3)  OPTIMIZATIONS="normal";;
	4)  OPTIMIZATIONS="kerneldebug";;
	5)  OPTIMIZATIONS="debug";;
	*)  OPTIMIZATIONS="size";;
esac

##############################################

case $4 in
	[1-5])	REPLY=$4;;
	*)	echo -e "\nWhich Image do you want to build:"
		echo "   1)  Enigma2"
		echo "   2*) Enigma2 (includes WLAN drivers)"
		echo "   3)  Neutrino"
		echo "   4)  Neutrino (includes WLAN drivers)"
		echo "   5)  Tvheadend"
		read -p "Select Image to build (1-5)? ";;
esac

case "$REPLY" in
	1) IMAGE="enigma2";;
#	2) IMAGE="enigma2-wlandriver";;
	3) IMAGE="neutrino";;
	4) IMAGE="neutrino-wlandriver";;
	5) IMAGE="tvheadend";;
	*) IMAGE="enigma2-wlandriver";;
esac
echo "IMAGE=$IMAGE" >> config

case "$IMAGE" in
	neutrin*)
		case $5 in
			[1-6] ) REPLY=$5;;
			*)	echo -e "\nWhich Neutrino variant do you want to build?"
				echo "   1)  neutrino-ddt"
				echo "   2)  neutrino-ddt + plugins"
				echo "   3)  neutrino-tangos"
				echo "   4)  neutrino-tangos + plugins"
				echo "   5)  neutrino-hd2"
				echo "   6)  neutrino-hd2 + plugins"
				read -p "Select Neutrino variant to build (1-6)? ";;
		esac

		case "$REPLY" in
			[1-2]) FLAVOUR="neutrino-ddt";;
#			[3-4]) FLAVOUR="neutrino-tangos";;
			[5-6]) FLAVOUR="neutrino-hd2";;
			*) FLAVOUR="neutrino-tangos";;
		esac

		echo "FLAVOUR=$FLAVOUR" >> config

		case "$REPLY" in
			[2,4,6]) PLUGINS_NEUTRINO="Yes";;
			*) PLUGINS_NEUTRINO="No";;
		esac
		echo "PLUGINS_NEUTRINO=$PLUGINS_NEUTRINO" >> config

		case "$FLAVOUR" in
			neutrino-hd2*)
				case $6 in
					[1-2]) REPLY=$6;;
					*)	echo -e "\nMedia Framework:"
						echo "   1*) None (Neutrino uses it's built-in player based on ffmpeg)"
						echo "   2)  Gstreamer (Neutrino also uses gstreamer)"
						read -p "Select media framework (1-2)? ";;
				esac

				case "$REPLY" in
#					1) MEDIAFW="buildinplayer";;
					2) MEDIAFW="gstreamer";;
					*) MEDIAFW="buildinplayer";;
				esac;;
			neutrino*)
					MEDIAFW="buildinplayer";
		esac

		case "$FLAVOUR" in
			neutrino*)
				if [ $PLUGINS_NEUTRINO == "No" ]; then
					echo "make yaud-neutrino" >> $CURDIR/build
				else
					echo "make yaud-neutrino-plugins" >> $CURDIR/build
				fi;;
			neutrino-hd2*)
				if [ $PLUGINS_NEUTRINO == "No" ]; then
					echo "  make yaud-neutrino-hd2" >> $CURDIR/build
				else
					echo "  make yaud-neutrino-hd2-plugins" >> $CURDIR/build
				fi;;
		esac

		if [ "$OPTIMIZATIONS" == "small" ]; then
			OPTIMIZATIONS="size"
		fi

		if [ "$LASTIMAGE1" ] || [ "$LASTIMAGE3" ] || [ ! "$LASTBOX" == "$BOXTYPE" ]; then
			if [ -e ./.deps/ ]; then
				echo -n -e "\nSettings changed, performing distclean..."
				make distclean 2> /dev/null > /dev/null
				echo "[Done]"
			fi
		fi;;
	tvheadend)
		MEDIAFW="buildinplayer"
		# Determine the Tvheadend diff-level
		case $5 in
			[0-3])	REPLY=$5;;
			*)	echo
				echo "Please select one of the following Tvheadend revisions (default = 1):"
				echo "=================================================================================================="
				echo " 0)  Newest                 - Tvheadend  built-in player (CAUTION: may fail due to outdated patch)"
				echo "=================================================================================================="
				echo " 1)  Fri, 26 Jul 2019 18:46 - Tvheadend  built-in player  6c6e0e5103b874fdd926b0f1bcdaed4d7e8b464e"
				echo " 2)  Wed, 13 Dec 2017 22:23 - Tvheadend  built-in player  3b232b66e02fc46f1e7e97efb5ef48c6968cf779"
				echo " 3*) Fri, 24 Feb 2017 18:23 - Tvheadend  built-in player  4931c0544885371b85146efad4eacd9683ba3dad"
				echo "=================================================================================================="
				echo "Media Framework         : $MEDIAFW"
				read -p "Select Tvheadend revision : ";;
		esac

		case "$REPLY" in
			0)	DIFF="0"
				REVISION="newest";;
			1)	DIFF="1"
				REVISION="6c6e0e5103b874fdd926b0f1bcdaed4d7e8b464e";;
			2)	DIFF="2"
				REVISION="3b232b66e02fc46f1e7e97efb5ef48c6968cf779";;
			*)	DIFF="3"
				REVISION="4931c0544885371b85146efad4eacd9683ba3dad";;
		esac
		echo "TVHEADEND_DIFF=$DIFF" >> config
		echo "TVHEADEND_REVISION=$REVISION" >> config

		echo "make yaud-tvheadend" >> $CURDIR/build

		if [ "$OPTIMIZATIONS" == "small" ]; then
			OPTIMIZATIONS="size"
		fi

		if [ "$LASTIMAGE1" ] || [ "$LASTIMAGE2" ] || [ ! "$LASTBOX" == "$BOXTYPE" ]; then
			if [ -e ./.deps/ ]; then
				echo -n -e "\nSettings changed, performing distclean..."
				make distclean 2> /dev/null > /dev/null
				echo " [Done]"
			fi
		elif [ ! "$DIFF" == "$LASTDIFF" ]; then
			echo -n -e "\nDiff changed, Tvheadend will be rebuilt."
			rm -f ./.deps/tvheadend.do_prepare
		fi;;
#	enigma*)
	*)
		if [ "$OPTIMIZATIONS" == "small" ]; then
			MEDIAFW="buildinplayer"
		else
			case $6 in
				[1-5]) REPLY=$6;;
				*)	echo -e "\nMedia Framework:"
					echo "   1)  None (E2 is built without a player)"
					echo "   2)  eplayer3 (E2 player uses eplayer3 only)"
					echo "   3)  gstreamer (E2 player uses gstreamer only)"
					echo "   4*) gstreamer+eplayer3 (recommended, E2 player uses gstreamer + libeplayer3)"
					echo "   5)  gstreamer/eplayer3 (E2 player is switchable between gstreamer & libeplayer3)"
					read -p "Select media framework (1-5)? ";;
			esac

			case "$REPLY" in
				1) MEDIAFW="buildinplayer";;
				2) MEDIAFW="eplayer3";;
				3) MEDIAFW="gstreamer";;
#				4) MEDIAFW="gst-eplayer3";;
				5) MEDIAFW="gst-eplayer3-dual";;
				*) MEDIAFW="gst-eplayer3";;
			esac
		fi

		# Determine the OpenPLi diff-level
 		case $5 in
			[0-5])	REPLY=$5;;
			*)	echo
				echo "Please select one of the following Enigma2 revisions (default = 2):"
				echo "=================================================================================================="
				echo " 0)  Newest                 - E2 OpenPLi  any framework (CAUTION: may fail due to outdated patch)"
				echo "=================================================================================================="
				echo " 1)  Use your own Enigma2 git dir without patchfile"
				echo "=================================================================================================="
				echo " 2*) Tue, 28 Jan 2020 13:13 - E2 OpenPLi  any framework  9c55cf0b69c9beba43dd7e017186552f410f357e"
				echo " 3)  Fri, 29 Nov 2019 19:41 - E2 OpenPLi  any framework  4d853c931badcca8d7851209c75db0a6dfe47e67"
				echo " 4)  Sun, 29 Sep 2019 14:07 - E2 OpenPLi  any framework  bf5ceafdfc684ceafd40a7286da094b0f5cb276f"
				echo " 5)  Mon, 29 Jul 2019 21:38 - E2 OpenPLi  any framework  00bbffe27a09c274a5b0f7984034860ddf8bfd11"
				echo "=================================================================================================="
				echo "Media Framework         : $MEDIAFW"
				echo
				read -p "Select Enigma2 revision : ";;
		esac

		case "$REPLY" in
			1)	DIFF="1"
				REVISION="local";;
			3)	DIFF="3"
				REVISION="4d853c931badcca8d7851209c75db0a6dfe47e67";;
			4)	DIFF="4"
				REVISION="bf5ceafdfc684ceafd40a7286da094b0f5cb276f";;
			5)	DIFF="5"
				REVISION="00bbffe27a09c274a5b0f7984034860ddf8bfd11";;
			0)	DIFF="0"
				REVISION="newest";;
			*)	DIFF="2"
				REVISION="9c55cf0b69c9beba43dd7e017186552f410f357e";;
		esac

		echo "E2_DIFF=$DIFF" >> config
		echo "E2_REVISION=$REVISION" >> config

		echo "make yaud-enigma2" >> $CURDIR/build

		if [ "$LASTIMAGE2" ] || [ "$LASTIMAGE3" ] || [ ! "$LASTBOX" == "$BOXTYPE" ]; then
			if [ -e ./.deps/ ]; then
				echo -n -e "\nSettings changed, performing distclean..."
				make distclean 2> /dev/null > /dev/null
				echo " [Done]"
			fi
		elif [ ! "$DIFF" == "$LASTDIFF" ] && [ -e ./deps/enigma2.do-compile ]; then
			echo -n -e "\nDiff changed, OpenPli Enigma2 will be rebuilt."
			rm -f ./.deps/enigma2.do_prepare
			rm -f ./.deps/enigma2_networkbrowser
			rm -f ./.deps/enigma2_openwebif
		fi;;
	esac

echo "OPTIMIZATIONS=$OPTIMIZATIONS" >> config
echo "MEDIAFW=$MEDIAFW" >> config

##############################################

case $7 in
	[1-4]) REPLY=$7;;
	*)	echo -e "\nExternal LCD support:"
		echo "   1*) No external LCD"
		echo "   2)  graphlcd for external LCD"
		echo "   3)  lcd4linux for external LCD"
		echo "   4)  graphlcd and lcd4linux for external LCD (both)"
		read -p "Select external LCD support (1-4)? ";;
esac

case "$REPLY" in
#	1) EXTERNAL_LCD="none";;
	2) EXTERNAL_LCD="graphlcd";;
	3) EXTERNAL_LCD="lcd4linux";;
	4) EXTERNAL_LCD="both";;
	*) EXTERNAL_LCD="none";;
esac
echo "EXTERNAL_LCD=$EXTERNAL_LCD" >> config

##############################################

case $8 in
	[1-2])	REPLY=$8;;
	*)	echo -e "\nWhere will the image be running:"
		echo "   1*) Flash memory or hard disk"
		echo "   2)  USB stick"
		read -p "Select destination (1-2)? ";;
esac

case "$REPLY" in
#	1) DESTINATION="flash";;
	2) DESTINATION="USB";;
	*) DESTINATION="flash";;
esac

echo "DESTINATION=$DESTINATION" >> config

##############################################

chmod 755 $CURDIR/build

make printenv
##############################################
if [ ! "$BATCHMODE" == "yes" ]; then
	echo "Your build environment is ready :-)"
	echo
	read -p "Do you want to start the build now (Y*/n)? "

	case "$REPLY" in
		N|n|No|NO|no) echo -e "\nOK. To start the build, execute ./build in this directory.\n"
			exit;;
	  	*)	$CURDIR/build;;
	esac
else
	$CURDIR/build
fi
echo
# vim:ts=4
