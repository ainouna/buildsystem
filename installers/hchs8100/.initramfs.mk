# This is a very simple, default initramfs

# A mini dev directory
dir   /dev            0755 0 0
dir   /dev/vc         0755 0 0
nod   /dev/console    0600 0 0 c   5   1
nod   /dev/fb0        0744 0 0 c  29   0
nod   /dev/fb1        0744 0 0 c  29   1
nod   /dev/fb2        0744 0 0 c  29   2
nod   /dev/fpc        0755 0 0 c  62   0
nod   /dev/loop0      0644 0 0 b   7   0
nod   /dev/null       0644 0 0 c   1   3
nod   /dev/mtd0       0664 0 0 c  90   0
nod   /dev/mtd1       0664 0 0 c  90   1
nod   /dev/mtd2       0664 0 0 c  90   2
nod   /dev/mtd3       0664 0 0 c  90   3
nod   /dev/mtd4       0664 0 0 c  90   4
nod   /dev/mtd5       0664 0 0 c  90   5
nod   /dev/mtd6       0664 0 0 c  90   6
nod   /dev/mtd7       0777 0 0 c  90   7
nod   /dev/mtd8       0777 0 0 c  90   8
nod   /dev/mtdblock0  0664 0 0 b  31   0
nod   /dev/mtdblock1  0664 0 0 b  31   1
nod   /dev/mtdblock2  0664 0 0 b  31   2
nod   /dev/mtdblock3  0664 0 0 b  31   3
nod   /dev/mtdblock4  0664 0 0 b  31   4
nod   /dev/mtdblock5  0664 0 0 b  31   5
nod   /dev/mtdblock6  0664 0 0 b  31   6
nod   /dev/mtdblock7  0664 0 0 b  31   7
nod   /dev/mtdblock8  0664 0 0 b  31   8
nod   /dev/ram0       0755 0 0 b   1   1
nod   /dev/rc         0755 0 0 c 147   1
nod   /dev/sda        0744 0 0 b   8   0
nod   /dev/sda1       0744 0 0 b   8   1
nod   /dev/sda2       0744 0 0 b   8   2
nod   /dev/sda3       0744 0 0 b   8   3
nod   /dev/sda4       0744 0 0 b   8   4
nod   /dev/sda5       0744 0 0 b   8   5
nod   /dev/sda6       0744 0 0 b   8   6
nod   /dev/sda7       0744 0 0 b   8   7
nod   /dev/sda8       0744 0 0 b   8   8
nod   /dev/sda9       0744 0 0 b   8   9
nod   /dev/sdb        0744 0 0 b   8  16
nod   /dev/sdb1       0744 0 0 b   8  17
nod   /dev/sdb2       0744 0 0 b   8  18
nod   /dev/sdb3       0744 0 0 b   8  19
nod   /dev/sdb4       0744 0 0 b   8  20
nod   /dev/tty0       0700 0 0 c   4   0
nod   /dev/tty1       0700 0 0 c   4   1
nod   /dev/tty2       0700 0 0 c   4   2
nod   /dev/tty3       0700 0 0 c   4   3
nod   /dev/tty4       0700 0 0 c   4   4
nod   /dev/tty5       0700 0 0 c   4   5
nod   /dev/ttyAS0     0700 0 0 c 204  40
nod   /dev/vc/0       0755 0 0 c   4   0
nod   /dev/vc/1       0755 0 0 c   4   1
nod   /dev/vc/2       0755 0 0 c   4   2
nod   /dev/vc/3       0755 0 0 c   4   3
nod   /dev/vc/4       0755 0 0 c   4   4
nod   /dev/vc/5       0755 0 0 c   4   5
nod   /dev/vc/6       0755 0 0 c   4   6
nod   /dev/vc/7       0755 0 0 c   4   7
nod   /dev/vc/8       0755 0 0 c   4   8
nod   /dev/vfd        0755 0 0 c 147   0
nod   /dev/zero       0744 0 0 c   1   5
slink /dev/fb         /dev/fb0  0744 0 0

dir   /bin                                                                                      0777 0 0
file  /bin/busybox                     ../../tufsbox/release/bin/busybox                        0755 0 0
slink /bin/echo                        /bin/busybox                                             0777 0 0
slink /bin/ash                         /bin/busybox                                             0777 0 0
slink /bin/awk                         /bin/busybox                                             0777 0 0
slink /bin/chmod                       /bin/busybox                                             0777 0 0
slink /bin/clear                       /bin/busybox                                             0777 0 0
slink /bin/sh                          /bin/busybox                                             0777 0 0
slink /bin/bash                        /bin/busybox                                             0777 0 0
slink /bin/cp                          /bin/busybox                                             0777 0 0
slink /bin/dd                          /bin/busybox                                             0777 0 0
slink /bin/gzip                        /bin/busybox                                             0777 0 0
slink /bin/gunzip                      /bin/busybox                                             0777 0 0
slink /bin/ln                          /bin/busybox                                             0777 0 0
slink /bin/ls                          /bin/busybox                                             0777 0 0
slink /bin/mv                          /bin/busybox                                             0777 0 0
slink /bin/rm                          /bin/busybox                                             0777 0 0
slink /bin/cat                         /bin/busybox                                             0777 0 0
slink /bin/sleep                       /bin/busybox                                             0777 0 0
slink /bin/sync                        /bin/busybox                                             0777 0 0
slink /bin/expr                        /bin/busybox                                             0777 0 0
slink /bin/wc                          /bin/busybox                                             0777 0 0
slink /bin/grep                        /bin/busybox                                             0777 0 0
slink /bin/stty                        /bin/busybox                                             0777 0 0
slink /bin/tee                         /bin/busybox                                             0777 0 0
slink /bin/mkdir                       /bin/busybox                                             0777 0 0
slink /bin/rmdir                       /bin/busybox                                             0777 0 0
slink /bin/sed                         /bin/busybox                                             0777 0 0
slink /bin/tail                        /bin/busybox                                             0777 0 0
slink /bin/tar                         /bin/busybox                                             0777 0 0
file  /bin/fp_control                  ../../tufsbox/release/bin/fp_control                     0755 0 0

dir   /etc                                                                                      0777 0 0
dir   /etc/inittab.d                                                                            0777 0 0
file  /etc/inittab                     ../../installers/hchs8100/inittab                        0755 0 0
file  /etc/fw_env.config               ../../tufsbox/release/etc/fw_env.config                  0755 0 0
file  /etc/vdstandby.cfg               ../../tufsbox/release/etc/vdstandby.cfg                  0755 0 0

dir   /etc/init.d                                                                               0777 0 0
file  /etc/init.d/rc                   ../../tufsbox/release/etc/init.d/rc                      0755 0 0
file  /etc/init.d/rcS                  ../../installers/hchs8100/hchs8100_rcS                   0755 0 0

dir   /etc/rc.d                                                                                 0777 0 0
dir   /etc/rc.d/rc0.d                                                                           0777 0 0
dir   /etc/rc.d/rc1.d                                                                           0777 0 0
dir   /etc/rc.d/rc2.d                                                                           0777 0 0
dir   /etc/rc.d/rc3.d                                                                           0777 0 0
dir   /etc/rc.d/rc4.d                                                                           0777 0 0
dir   /etc/rc.d/rc5.d                                                                           0777 0 0
dir   /etc/rc.d/rc6.d                                                                           0777 0 0
dir   /etc/rc.d/rcS.d                                                                           0777 0 0

dir   /deploy                                                                                   0777 0 0
file  /deploy/deploy.sh                ../../installers/hchs8100/hchs8100_deploy.sh             0755 0 0
file  /deploy/go_back.sh               ../../installers/hchs8100/go_back.sh                     0755 0 0

dir   /drvko                                                                                    0777 0 0
file  /drvko/e2_proc.ko                ../../tufsbox/release/lib/modules/e2_proc.ko             0755 0 0
file  /drvko/hchs8100_fp.ko            ../../tufsbox/release/lib/modules/hchs8100_fp.ko         0755 0 0

dir   /lib                                                                                      0777 0 0
file  /lib/libc.so.6                   ../../tufsbox/release/lib/libc.so.6                      0755 0 0             
file  /lib/libpthread.so.0             ../../tufsbox/release/lib/libpthread.so.0                0755 0 0
file  /lib/ld-linux.so.2               ../../tufsbox/release/lib/ld-linux.so.2                  0755 0 0
file  /lib/libe2p.so.2                 ../../tufsbox/release/usr/lib/libe2p.so.2                0755 0 0
file  /lib/libext2fs.so.2              ../../tufsbox/release/usr/lib/libext2fs.so.2             0755 0 0
file  /lib/libcom_err.so.0.0           ../../tufsbox/release/usr/lib/libcom_err.so.0.0          0755 0 0
file  /lib/libcom_err.so.0             ../../tufsbox/release/usr/lib/libcom_err.so.0            0755 0 0
file  /lib/libblkid.so.1               ../../tufsbox/release/usr/lib/libblkid.so.1              0755 0 0
file  /lib/libuuid.so.1                ../../tufsbox/release/usr/lib/libuuid.so.1               0755 0 0
file  /lib/libcrypt.so.1               ../../tufsbox/release/lib/libcrypt.so.1                  0755 0 0
file  /lib/libdl-2.14.1.so             ../../tufsbox/release/lib/libdl-2.14.1.so                0755 0 0
slink /lib/libdl.so.2                  /lib/libdl-2.14.1.so                                     0755 0 0
file  /lib/librt-2.14.1.so             ../../tufsbox/release/lib/librt-2.14.1.so                0755 0 0
slink /lib/librt.so.1                  /lib/librt-2.14.1.so                                     0755 0 0

dir   /proc                                                                                     0777 0 0

dir   /root                                                                                     0700 0 0

dir   /sbin                                                                                     0700 0 0
slink /sbin/blockdev                   /bin/busybox                                             0755 0 0
slink /sbin/init                       /bin/busybox                                             0755 0 0
file  /sbin/insmod                     ../../tufsbox/release/sbin/insmod                        0755 0 0
slink /sbin/getty                      /bin/busybox                                             0755 0 0
slink /sbin/mount                      /bin/busybox                                             0755 0 0
slink /sbin/umount                     /bin/busybox                                             0755 0 0
slink /sbin/swapoff                    /bin/busybox                                             0755 0 0
slink /sbin/reboot                     /bin/busybox                                             0755 0 0
slink /sbin/fdisk                      /bin/busybox                                             0755 0 0
file  /sbin/init                       ../../tufsbox/release/sbin/init                          0755 0 0
file  /sbin/mkswap                     ../../tufsbox/release/sbin/mkswap                        0755 0 0
file  /sbin/sfdisk                     ../../tufsbox/release/sbin/sfdisk                        0755 0 0
file  /sbin/shutdown                   ../../tufsbox/release/sbin/shutdown                      0755 0 0
file  /sbin/e2fsck                     ../../tufsbox/release/sbin/e2fsck                        0755 0 0
slink /sbin/fsck.ext2                  /sbin/e2fsck                                             0755 0 0
slink /sbin/fsck.ext3                  /sbin/e2fsck                                             0755 0 0
slink /sbin/fsck.ext4                  /sbin/e2fsck                                             0755 0 0
slink /sbin/fsck.ext4dev               /sbin/e2fsck                                             0755 0 0
file  /sbin/mke2fs                     ../../tufsbox/release/sbin/mke2fs                        0755 0 0
slink /sbin/mkfs.ext2                  /sbin/mke2fs                                             0755 0 0
slink /sbin/mkfs.ext3                  /sbin/mke2fs                                             0755 0 0
slink /sbin/mkfs.ext4                  /sbin/mke2fs                                             0755 0 0
slink /sbin/mkfs.ext4dev               /sbin/mke2fs                                             0755 0 0

slink /init                            /sbin/init                                               0755 0 0

dir   /sys                                                                                      0777 0 0

dir   /usr                                                                                      0777 0 0
dir   /usr/bin                                                                                  0777 0 0
dir   /usr/sbin                                                                                 0777 0 0
file  /usr/sbin/fw_printenv            ../../tufsbox/release/usr/sbin/fw_printenv               0755 0 0
slink /usr/sbin/fw_setenv              /usr/sbin/fw_printenv                                    0755 0 0

