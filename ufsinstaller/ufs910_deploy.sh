#!/bin/sh
# Version 20210714.1
echo "------------------------------------------------------------"
echo "deploy.sh version V0.13 (version for Kathrein UFS910)"
#echo
#echo "V0.13: Fix keepsettings mechanism; add neutrino settings."
#echo "V0.12: sfdisk parameters rewritten to use sector (512 byte)"
#echo "       as unit instead of megabytes; use blockdev to read"
#echo "       disk size and force partition table re-read."
#echo "V0.11: Fixed: non-jfs RECORD partion was always formatted in"
#echo "       ext2, even with useext2e2=0"
#echo "V0.10: Try to mount USB stick several times if mount fails"
#echo "V0.09: Log installation to boot medium removed again because"
#echo "       it caused problems"
#echo "V0.08: Log installation to boot medium"
#echo "V0.07: Do not install E2 if disk is not partitioned"
#echo "       and parameter partition is set to 0"
#echo "V0.06: Added EXT2 option for E2 and MINI partitions"
#echo "V0.05: Added JFS option for RECORD partition"
#echo "V0.04: Changed ini File format"
#echo "V0.03: Suppress meaningless tar errors during save settings"
#echo "V0.02: Format Mini partitions with Ext3 instead of Ext2"
#echo "V0.01: New parameter CREATEMINI and cleanup of KEEPSETTINGS"
echo "------------------------------------------------------------"

# default installation device
HDD=/dev/sda

# Check if the correct MTD setup has been used
if [ -z "`cat /proc/mtd | grep mtd8 | grep 'miniUboot'`" ]
then
  echo "MTD ERROR" > /dev/vfd
  echo "MTD ERROR "
  exit 1
fi


# Give the system a chance to recognize the USB stick
echo
echo "<- Mounting USB stick ->"
echo "9 MNT USB STICK" > /dev/vfd

sleep 5
mkdir /instsrc

i=1
while (true) do
  mount -t vfat /dev/sdb1 /instsrc
  if [ $? -ne 0 ]; then
    mount -t vfat /dev/sdb /instsrc
    if [ $? -eq 0 ]; then
      break
    fi
  else
    break
  fi

  if [ $i -gt 5 ]; then
    echo "NO USB STICK" > /dev/vfd
    exit
  fi
  
  echo "USB RETRY $i" > /dev/vfd
  sleep 5
  i=`expr $i + 1`
done

if [ -f /instsrc/kathrein/ufs910/uImage_ ]; then
  echo "Installation"  /dev/vfd
  sleep 3
  echo "already done"  /dev/vfd
  sleep 3
  echo "Remove stick"  /dev/vfd
  sleep 10
  reboot -f
  exit
fi

# If the file topfield.tfd is located on the stick, flash it (normal topfield update)
#if [ -f /instsrc/topfield.tfd ]; then
#  echo "1 FLASH" > /dev/vfd
#
#  echo
#  echo "Please stand by. This will take about 1.5 minutes..."
#  echo "After the reboot of the box, it may take another 2 or"
#  echo "3 minutes until the picture comes back."
#  echo
#
#  cat /instsrc/topfield.tfd | tfd2mtd > /dev/mtdblock5
#  mv /instsrc/topfield.tfd /instsrc/topfield.tfd_
#  dd if=/dev/zero of=/dev/sda bs=512 count=64
#  umount /instsrc

#  echo
#  echo "<- Job done, rebooting... ->"
#  echo "   0" > /dev/fpsmall
#  echo "0 REBOOT" > /dev/vfd
#  sleep 2
#  reboot -f
#  exit
#fi

mkdir /instdest

eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
    -e 's/;.*$//' \
    -e 's/[[:space:]]*$//' \
    -e 's/^[[:space:]]*//' \
    -e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
   < /instsrc/Image_Installer.ini \
    | sed -n -e "/^\[parameter\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`

export startingLine0=`grep -m 1 -n "\[settings_enigma2]" /instsrc/Image_Installer.ini | awk -F: '{ print $1 + 1 }' 2>/dev/null`
export startingLine1=`grep -m 1 -n "\[settings_neutrino\]" /instsrc/Image_Installer.ini | awk -F: '{ print $1 + 1 }' 2>/dev/null`
export startingLine2=`grep -m 1 -n "\[ownsettings\]" /instsrc/Image_Installer.ini | awk -F: '{ print $1 + 1 }' 2>/dev/null`
export startingLine3=`grep -m 1 -n "keepsettings=1" /instsrc/Image_Installer.ini | awk -F: '{ print $1 }' 2>/dev/null`

if [ "$startingLine3" ]; then
  if [ -z "$startingLine0" -a -z "$startingLine1" -a -z "$startingLine2" ]; then
#  if [ -z "$startingLine1" -a -z "$startingLine2"]; then
    echo "Setting keepsettings=1 found, but no"
    echo "no specification(s) for KEEP SETTINGS detected."
  else
    if [ ! -z "$startingLine0" ]; then
      echo "Specification for KEEP SETTINGS E2 detected at line $startingLine0."
    elif [ ! -z "$startingLine1" ]; then
      echo "Specification for KEEP SETTINGS Neutrino detected at line $startingLine1."
    fi
    if [ ! -z "$startingLine2" ]; then
      echo "Specification for additional KEEP SETTINGS detected at line $startingLine2."
    fi
  fi
fi

if [ -z "$startingLine0" ]; then
  export set startingLine0=9999
fi

if [ -z "$startingLine1" ]; then
  export set startingLine1=9999
fi

if [ -z "$startingLine2" ]; then
  export set startingLine2=9999
fi

#if [ "$startingLine0" -gt "$startingLine2" ] && [ "$startingLine1" -gt "$startingLine2" ]; then
if [ "$startingLine1" -gt "$startingLine2" ]; then
  export set startingLine="$startingLine2"
else
  export set startingLine="$startingLine1"
fi

echo "-------------------------------------"
echo "Using the following settings:"
echo 
echo "partition    :" "$partition"
echo "createmini   :" "$createmini"
echo "keepsettings :" "$keepsettings"
echo "keepbootargs :" "$keepbootargs"
echo
echo "usejfs       :" "$usejfs"
echo "useext2e2    :" "$useext2e2"
echo
echo "usbhdd       :" "$usbhdd"
echo "format       :" "$format"
echo "update       :" "$update"
echo "-------------------------------------"

# Undocumented feature for testing: abort shell script
#CONSOLE=666
if [ "$CONSOLE" == "666" ]; then
  echo "CONSOLE" > /dev/vfd
  echo "Entering console mode"
  exit
fi

if [ "$usbhdd" == "1" ]; then
  HDD=/dev/sdb
fi

ROOTFS=$HDD"1"
SWAPFS=$HDD"2"
DATAFS=$HDD"3"

# If the keyword 'keepsettings' has been specified, save some config files to the disk
if [ "$keepsettings" == "1" ]; then
  echo
  echo "<- Saving settings ->"
  echo "SAVE SETTINGS" > /dev/vfd
  if [ ! -d /instsrc/settings ] || [ ! -f /instsrc/settings/backup.tar.gz ]; then
    export set savFile="backup.tar.gz"
  else
    export set savFile="backup-new.tar.gz"
    echo "Settings are already on the stick. Saving current settings to backup-new.tar.gz but will use backup.tar.gz to restore."
  fi

  if [ ! -d /instsrc/settings ]; then
    mkdir /instsrc/settings
  fi
  mount $ROOTFS /instdest
  cd /instdest

# Determine image already present
  if [ -f etc/tuxbox/satellites.xml ]; then
    IMAGE=Enigma2
    export set startingLine="$startingLine0"
  elif [ -f var/tuxbox/config/satellites.xml ]; then
    IMAGE=Neutrino
    export set startingLine="$startingLine1"
  else
    IMAGE=Unknown
  fi
  if [ ! "$IMAGE" == "Unknown" ]; then
    echo "Using $IMAGE settings in file /instsrc/Image_Installer.ini, starting at line "$startingLine
    tar cvzf "/instsrc/settings/$savFile" `tail /instsrc/Image_Installer.ini -n +$startingLine | grep -v "^#"` 2>/dev/null
  fi
  count=`tail /instsrc/Image_Installer.ini -n +$startingLine2 | grep -v "^#" | wc -l`
  if [ ! "$count" == "0" ]; then
    if [ -f /instsrc/settings/$savFile ]; then
      echo "Using additional own settings in file /instsrc/Image_Installer.ini, starting at line "$startingLine2
      tar vzf "/instsrc/settings/$savFile" `tail /instsrc/Image_Installer.ini -n +$startingLine2 | grep -v "^#"` 2>/dev/null
    else
      echo "Using own settings in file /instsrc/Image_Installer.ini, starting at line "$startingLine2
      tar cvzf "/instsrc/settings/$savFile" `tail /instsrc/Image_Installer.ini -n +$startingLine2 | grep -v "^#"` 2>/dev/null
    fi
  fi
  cd /
  sync
  sleep 3
  umount /instdest
fi

#if [ "$usbhdd" == "1" ]; then
#  # the following is only executed when usbhdd is selected
#  echo
#  echo "<- Preparing installation on USB HDD ->"
#  mkdir /instsrc1
#  if [ -d /initsrc/settings ]; then
#    cp -r /instsrc/settings /instsrc1
#  fi
#  cp /instsrc/rootfs.tar.gz /instsrc1
#  if [ $? != 0 ]; then
#    echo "!! Error copying files to RAM disk !!"
#    echo "RAMDISK FAIL" > /dev/vfd
#    exit
#  fi
#
#  # remount the RAM disk
#  umount /instsrc
#  mv /instsrc /instsrc_
#  mv /instsrc1 /instsrc

#  echo "<- Waiting for USB stick to be detached ->"
#  echo "DETACH STICK" > /dev/vfd

#  while (true) do
#    if [ "`grep sdb /proc/diskstats`" == "" ]; then
#      break
#    fi
#    sleep 1
#  done

#  echo "<- USB stick detached ->"
#  echo "ATTACH USB HDD" > /dev/vfd

#  while (true) do
#    if [ "`grep sda /proc/diskstats`" != "" ]; then
#      break
#    fi
#    sleep 1
#  done
#
#  echo "<- USB HDD attached ->"
#fi


# Skip formatting if the keyword 'format' is not specified in the control file
if [ $format == "1" ]; then
#  echo
#  echo "<- Checking HDD ->"
#  echo " 8 HDD CHK" > /dev/vfd
#
#  fsck.ext3 -y $ROOTFS
#  if [ "$usejfs" = "1" ]; then
#    fsck.jfs -p $DATAFS
#  else
#    fsck.ext2 -y $DATAFS
#  fi
#else
  if [ "$partition" == "1" ]; then
    echo
    echo "<- Partitioning HDD ->"
    echo "8 HDD PART" > /dev/vfd
#   format=1, partition=1
    dd if=/dev/zero of=$HDD bs=512 count=64 2> /dev/null
#   sfdisk --re-read -L -q $HDD
    blockdev --rereadpt $HDD
    if [ "$createmini" != "1" ]; then
    # Erase the disk and create 3 partitions
    #  1:   2GB Linux
    #  2: 256MB Swap
    #  3: remaining space RECORD
    # NOTE: 1 MB is 2048 sectors
    sfdisk $HDD << EOF
,4194304,L,*
,524288,S
,,L
EOF
    else # createmini=1
#     export set recsize=$((`sfdisk -s $HDD`/1024-2048-256-1024-1024-1024-1024))
      export set recsize=$((blockdev --getsz $HDD))
      echo "Recording partition size is $recsize MB"
      # Erase the disk and create 8 partitions
      #  1:   2GB Linux
      #  2: 256MB Swap
      #  3: remaining space RECORD
      #  4: Extended Partition
      #  5: 1GB  LINUX
      #  6: 1GB  LINUX
      #  7: 1GB  LINUX
      #  8: 1GB  LINUX
      # NOTE: 1 MB is 2048 sectors
      sfdisk $HDD << EOF
,4194304,L,*
,524288,S
,$recsize,L
,,E
,2097152,L
,2097152,L
,2097152,L
,,L
EOF
    fi # createmini
  else # partition=0
    echo
    echo "<- Skipping partitioning of the HDD ->"
    # Check if the RECORD Partition is there already. If not, cancel the installation
    fpart=`fdisk -l "$HDD" | grep -c "$HDD"3`
    if [ $fpart == 0 ]; then
      echo "REC PART ERROR" > /dev/vfd
      echo "Error. HDD not partitioned yet. Installation canceled."
      halt
    else
      echo "OK, HDD already partitioned."
    fi
  fi #partition
fi #format

# Format Linux rootfs partitions
echo
echo "<- Formatting HDD (rootfs) ->"
echo "7 FORMAT ROOT" > /dev/vfd
#ln -s /proc/mounts /etc/mtab
  
fs="ext3"
if [ "$useext2e2" == "1" ]; then
  fs="ext2"
fi
  
mkfs.$fs -F -L ROOTFS $ROOTFS

if [ "$partition" == "1" ]; then
  if [ "$createmini" == "1" ]; then
    echo "CREATE MINI" > /dev/vfd
    mknod $HDD"5" b 8 5
    mknod $HDD"6" b 8 6
    mknod $HDD"7" b 8 7
    mknod $HDD"8" b 8 8
    mkfs.$fs -L MINI1 $HDD"5"
    mkfs.$fs -L MINI2 $HDD"6"
    mkfs.$fs -L MINI3 $HDD"7"
    mkfs.$fs -L MINI4 $HDD"8"
  fi
  # Initialise the swap partition
  echo
  echo "<- Formatting HDD (swap) ->"
  echo "6 FORMAT SWAP" > /dev/vfd
  mkswap $SWAPFS
  echo "SWAPPART" > /deploy/swaplabel
  dd if=/deploy/swaplabel of="$SWAPFS" seek=1052 bs=1 count=8 2> /dev/null
  echo
fi

if [ $format == "1" ]; then
  echo
  echo "<- Formatting HDD (record) ->"
  if [ "$usejfs" == "1" ]; then
    echo "5 FORMAT REC JFS"  > /dev/vfd
    mkfs.jfs -q -L RECORD $DATAFS
  else
    if [ "$useext2e2" == "1" ]; then
       echo "5 FORMT REC EXT2"  > /dev/vfd
    else
       echo "5 FORMT REC EXT3"  > /dev/vfd
    fi
    mkfs.$fs -F -L RECORD $DATAFS
  fi
fi

# Skip rootfs installation if 'update=0' is specified in the control file
if [ "$update" == "1" ]; then
  echo
  echo -n "<- Installing root file system: "
  echo "4 COPY ROOT FS" > /dev/vfd
  mount $ROOTFS /instdest
  cd /instdest
  gunzip -c /instsrc/rootfs.tar.gz | tar -x
  if [ "$usbhdd" == "1" ]; then
    sed -e "s#sda#sdb#g" etc/fstab > fstab1
    mv fstab1 etc/fstab
    sed -e "s#sda#sdb#g" etc/init.d/rcS > rcS1
    mv rcS1 etc/init.d/rcS
    chmod 744 etc/init.d/rcS
  fi
#  chown -R root:root .
#  chmod -R u=rwx,g=rw,o=r . 
  cd ..
  sync
  umount /instdest
  echo "done ->"
else
  echo "<- Skipping installation of root file system ->"
fi

# Restore the settings
if [ "$keepsettings" == "1" ]; then
  echo
  echo -n "<- Restoring settings: "
  echo "RSTR SETTINGS" > /dev/vfd
  mount $ROOTFS /instdest
  cd /instdest
  tar xzf "/instsrc/settings/backup.tar.gz"
  cd /
  sync
  sleep 3
  umount /instdest
  echo "done ->"
fi

# Make sure that the data partition contains subdirectories
mkdir -p /mnt
mount $DATAFS /mnt
mkdir -p /mnt/movie
mkdir -p /mnt/music
mkdir -p /mnt/picture
#Needed for Neutrino
mkdir -p /mnt/epg
mkdir -p /mnt/timeshift
mkdir -p /mnt/plugins
mkdir -p /mnt/logos
sync
umount /mnt

# Write U-Boot settings into the flash
#echo
#echo -n "<- Flashing U-Boot settings: "
#echo "3 LOADER" > /dev/vfd
#dd if=/deploy/u-boot.mtd1 of=/dev/mtdblock1 2> /dev/null
#if [ $? -ne 0 ]; then  
#  echo "FAIL" > /dev/fpsmall  
#  exit  
#fi 
#sleep 3
#echo "done ->"

ls -l /usr/sbin

# Skip Flash of MTD7 if 'keepbootargs=1' is specified in the control file
if [ "$keepbootargs" != "1" ]; then
  echo -n "<- Flashing U-Boot args: "
  echo "3 SET BOOTARGS" > /dev/vfd
#  if [ "$usbhdd" == "1" ]; then
#    dd if=/deploy/U-Boot_Settings_usb.mtd7 of=/dev/mtdblock7 2> /dev/null
#  else
#    dd if=/deploy/U-Boot_Settings_hdd.mtd7 of=/dev/mtdblock7 2> /dev/null
#  fi
#  if [ $? -ne 0 ]; then
#    echo "FAIL" > /dev/vfd
#    exit
#  fi
  /usr/sbin/fw_setenv bootcmd_6 'run bootargs_6; bootm a0040000'
  sleep 1
  /usr/sbin/fw_setenv bootargs_6 'set bootargs console=ttyAS0,115200 root=/dev/sda1 rw ip=192.168.178.119:192.168.178.101:192.168.178.1:255.255.255.0:kathrein:eth0:off mem=64m coprocessor_mem=4m@0x10000000,4m@0x10400000 rootdelay=6 nwhwconf=device:eth0,hwaddr:${ethaddr} init=/bin/devinit'
  sleep 1
  /usr/sbin/fw_setenv bootdesc_6 '-----HDD-----'
  sleep 1
  /usr/sbin/fw_setenv bootdesc_default '6'
  sleep 1
  echo "done ->"
else
  echo "Skipped setting bootargs on user request."
fi

# write the kernel to flash
echo
echo -n "<- Flashing kernel: "
echo "2 FLASH KERNEL" > /dev/vfd
dd if=/instsrc/kathrein/ufs910/uImage of=/dev/mtdblock1 2> /dev/null
if [ $? -ne 0 ]; then
  echo "ERROR KRNL FLASH" > /dev/vfd
  exit
fi
echo "done ->"
#mount $ROOTFS /instdest

# unmount and check the file system
echo
echo "<- Checking HDD rootfs ->"
echo "1 FSCK ROOT" > /dev/vfd
#umount /instdest
rmdir /instdest
fsck.ext3 -f -y $ROOTFS
sleep 2

# rename uImage to avoid infinite installation loop
if [ "$usbhdd" != "1" -a -f /instsrc/uImage ]; then
  mv -f /instsrc/kathrein/ufs910/uImage /instsrc/kathrein/ufs910/uImage_
  sync
  umount /instsrc
fi

# Reboot
echo
echo "<- Job done... ->"
echo "0 REBOOT" > /dev/vfd
echo "Rebooting..."
sleep 2
reboot -f
