#!/bin/bash
# Version 20231213.1 (E2: OpenPLi release-8.3 branch)

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
	echo "Parameter 4       : image (Enigma=1/2 Neutrino=3/4 Titan=5/6)"
	echo "Parameter 5       : Enigma2 diff (0-5), Neutrino variant (1-6), Titan plugins (1=no, 2=yes)"
	echo "Parameter 6       : media Framework (Enigma2: 1-5; Neutrino: ignored, Titan: 1-2)"
	echo "Parameter 7       : external LCD (1=none, 2=graphlcd, 3=lcd4linux, 4=both)"
	echo "Parameter 8       : destination (1-3, 1=flash, 2=USB, 3=USB with built-in HDD)"
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
	LASTBOX=`grep -e "BOXTYPE=" ./config.old | awk '{print substr($0,9,length($0)-8)}'`
	LASTIMAGE1=`grep -e "enigma2" ./config.old | awk '{print substr($0,7,length($0)-6)}'`
	LASTIMAGE2=`grep -e "neutrino" ./config.old | awk '{print substr($0,7,length($0)-6)}'`
	LASTIMAGE3=`grep -e "titan" ./config.old | awk '{print substr($0,7,length($0)-6)}'`
	if [ $LASTIMAGE1 ]; then
		LASTDIFF=`grep -e "E2_DIFF=" ./config.old | awk '{print substr($0,9,length($0)-8)}'`
	fi
	rm -f ./config.old
fi

##############################################

# Select gcc version by uncommenting one line
#BS_GCC_VER="4.6.3" # Unpacks rpms, quick build
BS_GCC_VER="4.8.4" # Unpacks rpms, quick build
#BS_GCC_VER="4.9.4" # Builds gcc through crosstool-ng
echo "BS_GCC_VER=$BS_GCC_VER" >> config
export BS_GCC_VER

# basic ffmpeg version numbers
FFMPEG_VER2="2.8.21"
FFMPEG_VER3="3.4.3"
FFMPEG_VER42="4.2.2"
FFMPEG_VER43="4.3.2"
#FFMPEG_VER44="4.4.2"

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

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-9] | 4[0-3]) REPLY=$1;;
	*)
		echo "Target receivers:"
		echo
		echo "  Kathrein             Fortis"
		echo "    1)  UFS-910          8)  FS9000 / FS9200 (formerly Fortis HDbox)"
		echo "    2)  UFS-912          9)  HS9510 (formerly Octagon SF1008P)"
		echo "    3)  UFS-913         10*) HS8200 (bootloader 6.00, formerly Atevio AV7500)"
		echo "    4)  UFS-922         11)  HS7110 (bootloader 6.4X)"
		echo "    5)  UFC-960         12)  HS7119"
		echo "                        13)  HS7420 (bootloader 6.3X)"
		echo "  Fulan                 14)  HS7429"
		echo "    6)  Spark           15)  HS7810A (bootloader 6.2X)"
		echo "    7)  Spark7162       16)  HS7819"
		echo
		echo "  ABcom                Cuberevo"
		echo "   17)  IPBox 55HD      20)  id."
		echo "   18)  IPBox 99HD      21)  mini"
		echo "   19)  IPBox 9900HD    22)  mini2"
		echo "   20)  IPBox 9000HD    23)  250HD"
		echo "   21)  IPBox 900HD     24)  9500HD / 7000HD"
		echo "   22)  IPBox 910HD     25)  2000HD"
		echo "   23)  IPBox 91HD      26)  200HD / mini FTA"
		echo "                        27)  3000HD / Xsarius Alpha HD10"
		echo "  Edision"
		echo "   28)  argus VIP V1 [ 1 fixed tuner + 2 CI + 1.5 USB ]"
		echo "   29)  argus VIP V2 [ 1 plugin tuner + 2 CI + 1 USB ]"
		echo "   30)  argus VIP2   [ 2 plugin tuners + 1 USB ]"
		echo
		echo "  CreNova"
		echo "   31)  Atemio AM 520 HD / Sogno HD 800-V3 (untested)"
		echo "   32)  Opticum/Orton/Globo HD (TS) 9600 (experimental, kernel P0217 only)"
		echo "   33)  Opticum/Orton/Globo HD (TS) 9600 PRIMA (kernel P0217 only)"
		echo
		echo "  Various SH4-based receivers"
		echo "   34)  Topfield TF77X0 HDPVR"
		echo "   35)  SpiderBox HL-101"
		echo "   36)  ADB ITI-5800S(X) (nBox BSKA, BSLA, BXZB or BZZB)"
		echo "   37)  Showbox Vitamin HD5000 (256Mbyte flash version)"
		echo "   38)  SagemCom 88 series (untested)"
		echo "   39)  Ferguson Ariva @Link 200 (untested)"
		echo "   40)  Homecast HS8100 CI series (FTA only, experimental, kernel P0217 only)"
		echo
		read -p "Select target (1-40) ";;
esac

case "$REPLY" in
	 1) BOXTYPE="ufs910";;
	 2) BOXTYPE="ufs912";;
	 3) BOXTYPE="ufs913";;
	 4) BOXTYPE="ufs922";;
	 5) BOXTYPE="ufc960";;
	 6) BOXTYPE="spark";;
	 7) BOXTYPE="spark7162";;
	 8) BOXTYPE="fs9000";;
	 9) BOXTYPE="hs9510";;
#	10) BOXTYPE="hs8200";;
	11) BOXTYPE="hs7110";;
	12) BOXTYPE="hs7119";;
	13) BOXTYPE="hs7420";;
	14) BOXTYPE="hs7429";;
	15) BOXTYPE="hs7810a";;
	16) BOXTYPE="hs7819";;
	17) BOXTYPE="ipbox55";;
	18) BOXTYPE="ipbox99";;
	19) BOXTYPE="ipbox9900";;
	20) BOXTYPE="cuberevo";;
	21) BOXTYPE="cuberevo_mini";;
	22) BOXTYPE="cuberevo_mini2";;
	23) BOXTYPE="cuberevo_250hd";;
	24) BOXTYPE="cuberevo_9500hd";;
	25) BOXTYPE="cuberevo_2000hd";;
	26) BOXTYPE="cuberevo_mini_fta";;
	27) BOXTYPE="cuberevo_3000hd";;
	28) BOXTYPE="vip1_v1";;
	29) BOXTYPE="vip1_v2";;
	30) BOXTYPE="vip2";;
	31) BOXTYPE="atemio520";;
	32) BOXTYPE="opt9600";;
	33) BOXTYPE="opt9600prima";;
	34) BOXTYPE="tf7700";;
	35) BOXTYPE="hl101";;
	36) BOXTYPE="adb_box";;
	37) BOXTYPE="vitamin_hd5000";;
	38) BOXTYPE="sagemcom88";;
	39) BOXTYPE="arivalink200";;
	40) BOXTYPE="hchs8100";;
	41) BOXTYPE="opt9600mini";;
	42) BOXTYPE="pace7241";;
	43) BOXTYPE="adb_2850";;
	 *) BOXTYPE="hs8200";;
esac
echo "BOXTYPE=$BOXTYPE" >> config

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
	[1-6])	REPLY=$4;;
	*)	echo -e "\nWhich Image do you want to build:"
		echo "   1)  Enigma2"
		echo "   2*) Enigma2 (includes WLAN drivers)"
		echo "   3)  Neutrino"
		echo "   4)  Neutrino (includes WLAN drivers)"
		echo "   5)  Titan (in development)"
		echo "   6)  Titan (in development, includes WLAN drivers)"
		read -p "Select Image to build (1-6)? ";;
esac

case "$REPLY" in
	1) IMAGE="enigma2";;
#	2) IMAGE="enigma2-wlandriver";;
	3) IMAGE="neutrino";;
	4) IMAGE="neutrino-wlandriver";;
	5) IMAGE="titan";;
	6) IMAGE="titan-wlandriver";;
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
				echo "   5)  neutrino2"
				echo "   6)  neutrino2 + plugins"
				read -p "Select Neutrino variant to build (1-6)? ";;
		esac

		case "$REPLY" in
			[1-2]) FLAVOUR="neutrino-ddt";;
#			[3-4]) FLAVOUR="neutrino-tangos";;
			[5-6]) FLAVOUR="neutrino2";;
			*) FLAVOUR="neutrino-tangos";;
		esac

		echo "FLAVOUR=$FLAVOUR" >> config

		case "$REPLY" in
			[2,4,6]) PLUGINS_NEUTRINO="Yes";;
			*) PLUGINS_NEUTRINO="No";;
		esac
		echo "PLUGINS_NEUTRINO=$PLUGINS_NEUTRINO" >> config

		# Select ffmpeg version by uncommenting one line (used for internal player)
		#FFMPEG_VER=$FFMPEG_VER2
		#FFMPEG_VER=$FFMPEG_VER3
		#FFMPEG_VER=$FFMPEG_VER42
		FFMPEG_VER=$FFMPEG_VER43
		#FFMPEG_VER=$FFMPEG_VER44

		case "$FLAVOUR" in
			neutrino2*)
				case $6 in
					[1-2]) REPLY=$6;;
					*)	echo -e "\nMedia Framework:"
						echo "   1*) None (Neutrino uses it's built-in player based on ffmpeg)"
						echo "   2)  Gstreamer (Neutrino also uses gstreamer)"
						read -p "Select media framework (1-2)? ";;
				esac

				case "$REPLY" in
#					1) MEDIAFW="builtinplayer";;
					2) MEDIAFW="gstreamer";;
					*) MEDIAFW="builtinplayer";;
				esac;;
			neutrino*)
					MEDIAFW="builtinplayer";
		esac

		case "$FLAVOUR" in
			neutrino*)
				if [ $PLUGINS_NEUTRINO == "No" ]; then
					echo "make yaud-neutrino" >> $CURDIR/build
				else
					echo "make yaud-neutrino-plugins" >> $CURDIR/build
				fi;;
			neutrino2*)
				if [ $PLUGINS_NEUTRINO == "No" ]; then
					echo "  make yaud-neutrino2" >> $CURDIR/build
				else
					echo "  make yaud-neutrino2-plugins" >> $CURDIR/build
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
	tita*)
		case $5 in
			[1-2] ) REPLY=$5;;
			*)	echo -e "\nWhich Titan variant do you want to build?"
				echo "   1*) Titan without plugins"
				echo "   2)  Titan with plugins (not tested/finished yet)"
				read -p "Select Titan variant to build (1-2)? ";;
		esac

		case "$REPLY" in
			[2]) PLUGINS_TITAN="Yes";;
			*) PLUGINS_TITAN="No";;
		esac
		echo "PLUGINS_TITAN=$PLUGINS_TITAN" >> config

		if [ $PLUGINS_TITAN == "No" ]; then
			echo "  make yaud-titan" >> $CURDIR/build
		else
			echo "  make yaud-titan-plugins" >> $CURDIR/build
		fi

		case $6 in
			[1-2]) REPLY=$6;;
				*)	echo -e "\nMedia Framework:"
					echo "   1*) eplayer3"
					echo "   2)  eplayer3+gstreamer (not recommended and not tested)"
					read -p "Select media framework (1-2)? ";;
		esac

		case "$REPLY" in
#			1) MEDIAFW="eplayer3";;
			2) MEDIAFW="gst-eplayer3";;
			*) MEDIAFW="eplayer3";;
		esac
		# Titan is always built with ffmpeg version 3.X.X
#		MEDIAFW="eplayer3"
		FFMPEG_VER=$FFMPEG_VER3
		export FFMPEG_VER

		if [ "$OPTIMIZATIONS" == "small" ]; then
			OPTIMIZATIONS="size"
		fi

		if [ "$LASTIMAGE1" ] || [ "$LASTIMAGE2" ] || [ ! "$LASTBOX" == "$BOXTYPE" ]; then
			if [ -e ./.deps/ ]; then
				echo -n -e "\nSettings changed, performing distclean..."
				make distclean 2> /dev/null > /dev/null
				echo "[Done]"
			fi
		fi;;
#	enigma*)
	*)
		if [ "$OPTIMIZATIONS" == "small" ]; then
			MEDIAFW="builtinplayer"
		else
			case $6 in
				[1-5]) REPLY=$6;;
				*)	echo -e "\nMedia Framework:"
					echo "   1)  None (E2 is built without a player)"
					echo "   2)  eplayer3 (E2 player uses eplayer3 only)"
					echo "   3)  gstreamer (E2 player uses gstreamer only)"
					echo "   4*) gstreamer+eplayer3 (recommended, E2 player uses gstreamer + libeplayer3)"
#					echo "   5)  gstreamer/eplayer3 (E2 player is switchable between gstreamer & libeplayer3)"
					read -p "Select media framework (1-4)? ";;
			esac

			case "$REPLY" in
				1) MEDIAFW="builtinplayer";;
				2) MEDIAFW="eplayer3";;
				3) MEDIAFW="gstreamer";;
#				4) MEDIAFW="gst-eplayer3";;
				5) MEDIAFW="gst-eplayer3-dual";;
				*) MEDIAFW="gst-eplayer3";;
			esac
		fi

		# Select ffmpeg version by uncommenting one line (used with eplayer3, gst-eplayer3-dual and gst-eplayer3)
		#FFMPEG_VER=$FFMPEG_VER2
		#FFMPEG_VER=$FFMPEG_VER3
		#FFMPEG_VER=$FFMPEG_VER42
		FFMPEG_VER=$FFMPEG_VER43
		#FFMPEG_VER=$FFMPEG_VER44

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
				echo " 2*) Sun, 25 Jun 2023 13:10 - E2 OpenPLi  any framework  2d6416e"
				echo " 3)  Wed, 12 Apr 2023 21:13 - E2 OpenPLi  any framework  341315b"
				echo " 4)  Wed, 22 Feb 2023 22:14 - E2 OpenPLi  any framework  428face"
				echo " 5)  Thu, 22 Dec 2022 17:13 - E2 OpenPLi  any framework  55b82d7"
				echo "=================================================================================================="
				echo "Media Framework         : $MEDIAFW"
				echo
				read -p "Select Enigma2 revision : ";;
		esac

		case "$REPLY" in
			1)	DIFF="1"
				REVISION="local";;
			3)	DIFF="3"
				REVISION="341315b";;
			4)	DIFF="4"
				REVISION="428face";;
			5)	DIFF="5"
				REVISION="55b82d7";;
			0)	DIFF="0"
				REVISION="newest";;
			*)	DIFF="2"
				REVISION="2d6416e";;
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
export FFMPEG_VER
echo "FFMPEG_VER=$FFMPEG_VER" >> config

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
	[1-3])	REPLY=$8;;
	*)	echo -e "\nWhere will the image be running:"
		echo "   1*) Flash memory or hard disk"
		echo "   2)  USB stick (without built-in HDD)"
		echo "   3)  USB stick (with built-in HDD)"
		read -p "Select destination (1-3)? ";;
esac

case "$REPLY" in
#	1) DESTINATION="flash";;
	2) DESTINATION="USB";;
	3) DESTINATION="USB_HDD";;
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
