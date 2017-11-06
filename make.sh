#!/bin/bash
# Version 20171106.1

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
	echo "Usage: $0 [-v | --verbose | -q | --quiet] [Parameter1 Parameter2 ... Parameter9]"
	echo
	echo "-v or --verbose : verbose build (very noisy!)"
	echo "-q or --quiet   : quiet build, fastest, almost silent"
	echo "Parameter 1     : target system (1-37)"
	echo "Parameter 2     : kernel (1-2)"
	echo "Parameter 3     : optimization (1-4)"
	echo "Parameter 4     : image (Enigma=1/2 Neutrino=3/4 Tvheadend=5 (1-5)"
	echo "Parameter 5     : Neutrino variant (1-0) or Enigma2/Tvheadend diff (0-5)"
	echo "Parameter 6     : media Framework (1-3, Enigma2 only))"
	echo "Parameter 7     : destination (1-2, 1=flash, 2=USB)"
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

if [ "$1" == -q ] || [ "$1" == --quiet ]; then
	shift
	KBUILD_VERBOSE=quiet
elif [ "$1" == -v ] || [ "$1" == --verbose ]; then
	shift
	KBUILD_VERBOSE=verbose
else
	KBUILD_VERBOSE=normal
fi
export KBUILD_VERBOSE
echo "KBUILD_VERBOSE=$KBUILD_VERBOSE" > config

##############################################

CURDIR=`pwd`

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-8]) REPLY=$1;;
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
		echo "   13)  91HD            25)  mini_fta / 200HD"
		echo "                        26)  3000HD / Xsarius Alpha"
		echo
		echo "  Fulan                Atemio"
		echo "   27)  Spark           29)  AM520"
		echo "   28)  Spark7162       30)  AM530"
		echo
		echo "  Various"
		echo "   31)  Edision Argus VIP1 v1 [ single tuner + 2 CI + 2 USB ]"
		echo "   32)  SpiderBox HL-101"
		echo "   33)  B4Team ADB 5800S"
		echo "   34)  Vitamin HD5000"
		echo "   35)  SagemCom 88 series"
		echo "   36)  Ferguson Ariva @Link 200"
		echo "   37)  Mutant HD51"
		echo "   38)  VU Solo 4k"
		echo
		read -p "Select target (1-38)? ";;
esac

case "$REPLY" in
	 1) BOXARCH="sh4";BOXTYPE="ufs910";;
	 2) BOXARCH="sh4";BOXTYPE="ufs912";;
	 3) BOXARCH="sh4";BOXTYPE="ufs913";;
	 4) BOXARCH="sh4";BOXTYPE="ufs922";;
	 5) BOXARCH="sh4";BOXTYPE="ufc960";;
	 6) BOXARCH="sh4";BOXTYPE="tf7700";;
	 7) BOXARCH="sh4";BOXTYPE="fortis_hdbox";;
	 8) BOXARCH="sh4";BOXTYPE="octagon1008";;
#	 9) BOXARCH="sh4";BOXTYPE="atevio7500";;
	10) BOXARCH="sh4";BOXTYPE="hs7110";;
	11) BOXARCH="sh4";BOXTYPE="hs7119";;
	12) BOXARCH="sh4";BOXTYPE="hs7420";;
	13) BOXARCH="sh4";BOXTYPE="hs7429";;
	14) BOXARCH="sh4";BOXTYPE="hs7810a";;
	15) BOXARCH="sh4";BOXTYPE="hs7819";;
	16) BOXARCH="sh4";BOXTYPE="ipbox55";;
	17) BOXARCH="sh4";BOXTYPE="ipbox99";;
	18) BOXARCH="sh4";BOXTYPE="ipbox9900";;
	19) BOXARCH="sh4";BOXTYPE="cuberevo";;
	20) BOXARCH="sh4";BOXTYPE="cuberevo_mini";;
	21) BOXARCH="sh4";BOXTYPE="cuberevo_mini2";;
	22) BOXARCH="sh4";BOXTYPE="cuberevo_250hd";;
	23) BOXARCH="sh4";BOXTYPE="cuberevo_9500hd";;
	24) BOXARCH="sh4";BOXTYPE="cuberevo_2000hd";;
	25) BOXARCH="sh4";BOXTYPE="cuberevo_mini_fta";;
	26) BOXARCH="sh4";BOXTYPE="cuberevo_3000hd";;
	27) BOXARCH="sh4";BOXTYPE="spark";;
	28) BOXARCH="sh4";BOXTYPE="spark7162";;
	29) BOXARCH="sh4";BOXTYPE="atemio520";;
	30) BOXARCH="sh4";BOXTYPE="atemio530";;
	31) BOXARCH="sh4";BOXTYPE="hl101";;
	32) BOXARCH="sh4";BOXTYPE="hl101";;
	33) BOXARCH="sh4";BOXTYPE="adb_box";;
	34) BOXARCH="sh4";BOXTYPE="vitamin_hd5000";;
	35) BOXARCH="sh4";BOXTYPE="sagemcom88";;
	36) BOXARCH="sh4";BOXTYPE="arivalink200";;
	37) BOXARCH="arm";BOXTYPE="hd51";;
	38) BOXARCH="arm";BOXTYPE="vusolo4k";;
	 *) BOXARCH="sh4";BOXTYPE="atevio7500";;
esac
echo "BOXARCH=$BOXARCH" >> config
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

if [ $BOXARCH == "sh4" ]; then
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
#			echo "   2)  STM 24 P0217 [2.6.32.61]"
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
fi

##############################################

case $3 in
	[1-4]) REPLY=$3;;
	*)	echo -e "\nOptimization:"
		echo "   1*) optimization for size"
		echo "   2)  optimization normal"
		echo "   3)  Kernel debug"
		echo "   4)  debug (includes Kernel debug)"
		read -p "Select optimization (1-4)? ";;
esac

case "$REPLY" in
#	1)  OPTIMIZATIONS="size";;
	2)  OPTIMIZATIONS="normal";;
	3)  OPTIMIZATIONS="kerneldebug";;
	4)  OPTIMIZATIONS="debug";;
	*)  OPTIMIZATIONS="size";;
esac
echo "OPTIMIZATIONS=$OPTIMIZATIONS" >> config

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
			[0-9])	REPLY=$5;;
			*)	echo -e "\nWhich Neutrino variant do you want to build?"
				echo "   1)  Neutrino mp"
				echo "   2)  Neutrino mp + plugins"
				echo "   3)  Neutrino mp (cst-next)"
				echo "   4)  Neutrino mp (cst-next) + plugins"
				echo "   5)  Neutrino mp (cst-next-ni)"
				echo "   6)  Neutrino mp (cst-next-ni) + plugins"
				echo "   7)  Neutrino HD2 exp"
				echo "   8)  Neutrino HD2 exp + plugins"
				echo "   9)  Neutrino mp (Tangos)"
				echo "   0*) Neutrino mp (Tangos) + plugins"
#				echo "   B)  Neutrino mp (martii-github)"
				read -p " Select Neutrino variant (1-0)? ";;
		esac
		case "$REPLY" in
			1)	echo "make yaud-neutrino-mp" > $CURDIR/build
				NEUTRINO_VAR=mp;;
			2)	echo "make yaud-neutrino-mp-plugins" > $CURDIR/build
				NEUTRINO_VAR="mp + plugins";;
			3)	echo "make yaud-neutrino-next" > $CURDIR/build
				NEUTRINO_VAR=mp-cst-next;;
			4)	echo "make yaud-neutrino-mp-cst-next-plugins" > $CURDIR/build
				NEUTRINO_VAR="mp-cst-next + plugins";;
			5)	echo "make yaud-neutrino-mp-cst-next-ni" > $CURDIR/build
				NEUTRINO_VAR="mp-cst-next-ni";;
			6)	echo "make yaud-neutrino-mp-cst-next-ni-plugins" > $CURDIR/build
				NEUTRINO_VAR="mp-cst-next-ni + plugins";;
			7)	echo "make yaud-neutrino-hd2" > $CURDIR/build
				NEUTRINO_VAR="neutrino-hd2";;
			8)	echo "make yaud-neutrino-hd2-plugins" > $CURDIR/build
				NEUTRINO_VAR="neutrino-hd2 + plugins";;
			9)	echo "make yaud-neutrino-mp-tangos" > $CURDIR/build
				NEUTRINO_VAR=mp-tangos;;
			*)	echo "make yaud-neutrino-mp-tangos-plugins" > $CURDIR/build
				NEUTRINO_VAR="mp-tangos + plugins";;
		esac
		echo "NEUTRINO_VARIANT=$NEUTRINO_VAR" >> config
		MEDIAFW="buildinplayer"

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
			[0-1])	REPLY=$5;;
			*)	echo
				echo "Please select one of the following Tvheadend revisions (default = 1):"
				echo "=================================================================================================="
				echo " 0)  Newest                 - Tvheadend  built-in player (CAUTION: may fail due to outdated patch)"
				echo "=================================================================================================="
				echo " 1*) Fri, 24 Feb 2017 18:23 - Tvheadend  built-in player  4931c0544885371b85146efad4eacd9683ba3dad"
#				echo " 2)  Mon, 17 May 2016 22:46 - Tvheadend  built-in player  577fa5ab7d5f0f83f18d625b547d148e93cf27d3"
#				echo " 3)  Thu, 31 Mar 2016 21:52 - Tvheadend  built-in player  7d63bf16e99741f0a5798b84a3688759317eecb3"
#				echo " 4)  Mon, 17 Aug 2015 07:08 - Tvheadend  built-in player  cd5505a4b8aba823334032bb6fd7901557575455"
				echo "=================================================================================================="
				echo "Media Framework         : $MEDIAFW"
				read -p "Select Tvheadend revision : ";;
		esac

		case "$REPLY" in
			0)	DIFF="0"
				REVISION="newest";;
			*)	DIFF="1"
				REVISION="4931c0544885371b85146efad4eacd9683ba3dad";;
		esac
		echo "TVHEADEND_DIFF=$DIFF" >> config
		echo "TVHEADEND_REVISION=$REVISION" >> config

		echo "make yaud-tvheadend" > $CURDIR/build

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
		if [ $BOXARCH == "sh4" ]; then
			case $6 in
				[1-3]) REPLY=$6;;
				*)	echo -e "\nMedia Framework:"
					echo "   1)  eplayer3"
					echo "   2)  gstreamer"
					echo "   3*) gstreamer+eplayer3 (recommended)"
					read -p "Select media framework (1-3)? ";;
			esac

			case "$REPLY" in
				1) MEDIAFW="eplayer3";;
				2) MEDIAFW="gstreamer";;
			#	3) MEDIAFW="gst-eplayer3";;
				*) MEDIAFW="gst-eplayer3";;
			esac
		else
				MEDIAFW="gstreamer"
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
				echo " 2*) Fri, 24 Feb 2017 18:23 - E2 OpenPLi  any framework  ff98b15d49fa629c1b4e98698008602e5b4233be"
				echo " 3)  Mon, 17 May 2016 22:46 - E2 OpenPLi  any framework  577fa5ab7d5f0f83f18d625b547d148e93cf27d3"
				echo " 4)  Thu, 31 Mar 2016 21:52 - E2 OpenPLi  any framework  7d63bf16e99741f0a5798b84a3688759317eecb3"
				echo " 5)  Mon, 17 Aug 2015 07:08 - E2 OpenPLi  any framework  cd5505a4b8aba823334032bb6fd7901557575455"
				echo "=================================================================================================="
				echo "Media Framework         : $MEDIAFW"
				read -p "Select Enigma2 revision : ";;
		esac

		case "$REPLY" in
			1)	DIFF="1"
				REVISION="local";;
			3)	DIFF="3"
				REVISION="577fa5ab7d5f0f83f18d625b547d148e93cf27d3";;
			4)	DIFF="4"
				REVISION="7d63bf16e99741f0a5798b84a3688759317eecb3";;
			5)	DIFF="5"
				REVISION="cd5505a4b8aba823334032bb6fd7901557575455";;
			0)	DIFF="0"
				REVISION="newest";;
			*)	DIFF="2"
				REVISION="ff98b15d49fa629c1b4e98698008602e5b4233be";;
		esac
		echo "E2_DIFF=$DIFF" >> config
		echo "E2_REVISION=$REVISION" >> config

		echo "make yaud-enigma2" > $CURDIR/build

		if [ "$LASTIMAGE2" ] || [ "$LASTIMAGE3" ] || [ ! "$LASTBOX" == "$BOXTYPE" ]; then
			if [ -e ./.deps/ ]; then
				echo -n -e "\nSettings changed, performing distclean..."
				make distclean 2> /dev/null > /dev/null
				echo " [Done]"
			fi
		elif [ ! "$DIFF" == "$LASTDIFF" ]; then
			echo -n -e "\nDiff changed, OpenPli Enigma2 will be rebuilt."
			rm -f ./.deps/enigma2.do_prepare
			rm -f ./.deps/enigma2_networkbrowser
			rm -f ./.deps/enigma2_openwebif
		fi;;
	esac

echo "MEDIAFW=$MEDIAFW" >> config

##############################################

case "$BOXTYPE" in
	hs7110|hs7119|hs7420|hs7429|hs7810a|hs7819)
		case $7 in
			[1-2])	REPLY=$7;;
			*)	echo -e "\nWhere will the image be running:"
				echo "   1*) Flash memory or hard disk"
				echo "   2)  USB stick"
				read -p "Select destination (1-2)? ";;
		esac

		case "$REPLY" in
#			1) DESTINATION="flash";;
			2) DESTINATION="USB";;
			*) DESTINATION="flash";;
		esac
		echo "DESTINATION=$DESTINATION" >> config;;
	*)
		;;
esac

##############################################

chmod 755 $CURDIR/build

make printenv
##############################################
echo "Your build environment is ready :-)"
echo
read -p "Do you want to start the build now (Y*/n)? "

case "$REPLY" in
	N|n|No|NO|no) echo -e "\nOK. To start the build, execute ./build in this directory.\n"
		exit;;
  	*)	$CURDIR/build;;
esac
echo

