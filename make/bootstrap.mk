TOOLCHECK  = find-git find-svn find-gzip find-bzip2 find-patch find-gawk
TOOLCHECK += find-makeinfo find-automake find-gcc find-libtool
TOOLCHECK += find-yacc find-flex find-tic find-pkg-config find-help2man
TOOLCHECK += find-cmake find-gperf

find-%:
	@TOOL=$(patsubst find-%,%,$@); \
		type -p $$TOOL >/dev/null || \
		{ echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK) preqs
	@echo "All required tools seem to be installed."
	@echo
	@if test "$(subst /bin/,,$(shell readlink /bin/sh))" != bash; then \
		echo "WARNING: /bin/sh is not linked to bash."; \
		echo "         This configuration might work, but is not supported."; \
		echo; \
	fi

BOOTSTRAP  = directories crosstool $(D)/ccache
BOOTSTRAP += $(HOST_DIR)/bin/opkg.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-chksvn.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-gitdescribe.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-find-requires.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-find-provides.sh
BOOTSTRAP += $(HOST_DIR)/bin/opkg-module-deps.sh
BOOTSTRAP += $(HOST_DIR)/bin/get-git-archive.sh
BOOTSTRAP += $(D)/host_pkgconfig
BOOTSTRAP += $(D)/host_module_init_tools
BOOTSTRAP += $(D)/host_mtd_utils
BOOTSTRAP += $(D)/host_mkcramfs
BOOTSTRAP += $(D)/host_mksquashfs

bootstrap: $(D)/bootstrap
$(D)/bootstrap: $(BOOTSTRAP)
	@touch $@

SYSTEM_TOOLS  = $(D)/module_init_tools
SYSTEM_TOOLS += $(D)/busybox
SYSTEM_TOOLS += $(D)/zlib
SYSTEM_TOOLS += $(D)/sysvinit
SYSTEM_TOOLS += $(D)/diverse-tools
SYSTEM_TOOLS += $(D)/e2fsprogs
SYSTEM_TOOLS += $(D)/jfsutils
SYSTEM_TOOLS += $(D)/hdidle
SYSTEM_TOOLS += $(D)/fbshot
SYSTEM_TOOLS += $(D)/portmap
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs922))
SYSTEM_TOOLS += $(D)/nfs_utils
endif
SYSTEM_TOOLS += $(D)/vsftpd
SYSTEM_TOOLS += $(D)/autofs
SYSTEM_TOOLS += $(D)/udpxy
SYSTEM_TOOLS += $(D)/dvbsnoop
SYSTEM_TOOLS += $(D)/driver

$(D)/system-tools: $(SYSTEM_TOOLS) $(TOOLS)
	$(TOUCH)

$(HOST_DIR)/bin/unpack%.sh \
$(HOST_DIR)/bin/get%.sh \
$(HOST_DIR)/bin/opkg%sh: | directories
	ln -sf $(SCRIPTS_DIR)/$(shell basename $@) $(HOST_DIR)/bin

#
STM_RELOCATE     = /opt/STM/STLinux-2.4

# updates / downloads
STL_FTP          = http://archive.stlinux.com/stlinux/2.4
STL_FTP_UPD_SRC  = $(STL_FTP)/updates/SRPMS
STL_FTP_UPD_SH4  = $(STL_FTP)/updates/RPMS/sh4
STL_FTP_UPD_HOST = $(STL_FTP)/updates/RPMS/host
STL_ARCHIVE      = $(ARCHIVE)/stlinux
STL_GET          = $(WGET)/stlinux

## ordering is important here. The /host/ rule must stay before the less
## specific %.sh4/%.i386/%.noarch rule. No idea if this is portable or
## even reliable :-(
$(STL_ARCHIVE)/stlinux24-host-%.i386.rpm \
$(STL_ARCHIVE)/stlinux24-host-%noarch.rpm:
	$(STL_GET) $(STL_FTP_UPD_HOST)/$(subst $(STL_ARCHIVE)/,"",$@)

$(STL_ARCHIVE)/stlinux24-host-%.src.rpm:
	$(STL_GET) $(STL_FTP_UPD_SRC)/$(subst $(STL_ARCHIVE)/,"",$@)

$(STL_ARCHIVE)/stlinux24-sh4-%.sh4.rpm \
$(STL_ARCHIVE)/stlinux24-cross-%.i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-%.noarch.rpm:
	$(STL_GET) $(STL_FTP_UPD_SH4)/$(subst $(STL_ARCHIVE)/,"",$@)

#
# install the RPMs
#

# 4.6.3
#BINUTILS_VERSION = 2.22-64
#GCC_VERSION      = 4.6.3-111
#LIBGCC_VERSION   = 4.6.3-111
#GLIBC_VERSION    = 2.10.2-42

# 4.8.4
BINUTILS_VERSION = 2.24.51.0.3-76
GCC_VERSION      = 4.8.4-139
LIBGCC_VERSION   = 4.8.4-148
GLIBC_VERSION    = 2.14.1-59

crosstool-rpminstall: \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-$(BINUTILS_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-cpp-$(GCC_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-gcc-$(GCC_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-g++-$(GCC_VERSION).i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-linux-kernel-headers-$(STM_KERNEL_HEADERS_VERSION).noarch.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-$(GLIBC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-dev-$(GLIBC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libgcc-$(LIBGCC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-$(LIBGCC_VERSION).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VERSION).sh4.rpm
	$(START_BUILD)
	$(SILENT)unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4 $(CROSS_DIR) \
		$^
	@touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(TERM_NORMAL) completed."; echo

crosstool: directories driver-symlink \
$(HOST_DIR)/bin/unpack-rpm.sh \
crosstool-rpminstall
	$(START_BUILD)
	$(SET) -e; cd $(CROSS_BASE); rm -f sh4-linux/sys-root; ln -s ../target sh4-linux/sys-root; \
	if [ -e $(CROSS_DIR)/target/usr/lib/libstdc++.la ]; then \
		sed -i "s,^libdir=.*,libdir='$(CROSS_DIR)/target/usr/lib'," $(CROSS_DIR)/target/usr/lib/lib{std,sup}c++.la; \
	fi
	$(SILENT)if test -e $(CROSS_DIR)/target/usr/lib/libstdc++.so; then \
		cp -a $(CROSS_DIR)/target/usr/lib/libstdc++.s*[!y] $(TARGET_DIR)/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libdl.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libm.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/librt.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libutil.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libpthread.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libresolv.so $(TARGET_DIR)/usr/lib; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc.so $(TARGET_DIR)/usr/lib/libc.so; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc_nonshared.a $(TARGET_DIR)/usr/lib/libc_nonshared.a; \
	fi
	$(SILENT)if test -e $(CROSS_DIR)/target/lib; then \
		cp -a $(CROSS_DIR)/target/lib/*so* $(TARGET_DIR)/lib; \
	fi
	$(SILENT)if test -e $(CROSS_DIR)/target/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/target/sbin/ldconfig $(TARGET_DIR)/sbin; \
		cp -a $(CROSS_DIR)/target/etc/ld.so.conf $(TARGET_DIR)/etc; \
		cp -a $(CROSS_DIR)/target/etc/host.conf $(TARGET_DIR)/etc; \
	fi
	@touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(TERM_NORMAL) completed."; echo

#
# host_u_boot_tools
#
host_u_boot_tools: \
$(STL_ARCHIVE)/stlinux24-host-u-boot-tools-1.3.1_stm24-9.i386.rpm
	$(START_BUILD)
	$(SILENT)unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/host/bin $(HOST_DIR)/bin \
		$^
	@touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(TERM_NORMAL) completed."; echo

#
# crosstool-ng
#
CROSSTOOL_NG_VERSION = 1.22.0
CROSSTOOL_NG_SOURCE = crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.xz

$(ARCHIVE)/crosstool-ng-$(CROSSTOOL_NG_VERSION).tar.xz:
	$(WGET) http://crosstool-ng.org/download/crosstool-ng/$(CROSSTOOL_NG_SOURCE)

crosstool-ng: directories $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(REMOVE)/crosstool-ng
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	$(SILENT)set -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VERSION)-$(BOXARCH).config .config; \
		NUM_CPUS=$$(expr `getconf _NPROCESSORS_ONLN` \* 2); \
		MEM_512M=$$(awk '/MemTotal/ {M=int($$2/1024/512); print M==0?1:M}' /proc/meminfo); \
		test $$NUM_CPUS -gt $$MEM_512M && NUM_CPUS=$$MEM_512M; \
		test $$NUM_CPUS = 0 && NUM_CPUS=1; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$NUM_CPUS@" .config; \
		export BS_BASE_DIR=$(TUFSBOX_DIR); \
		./configure --enable-local; \
		MAKELEVEL=0 make; \
		./ct-ng oldconfig; \
		./ct-ng build
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(TERM_NORMAL) completed."; echo

crossmenuconfig: $(ARCHIVE)/$(CROSSTOOL_NG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/crosstool-ng
	$(UNTAR)/$(CROSSTOOL_NG_SOURCE)
	$(SET) -e; unset CONFIG_SITE; cd $(BUILD_TMP)/crosstool-ng; \
		cp -a $(PATCHES)/crosstool-ng-$(CROSSTOOL_NG_VERSION)-$(BOXARCH).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng; \
		./ct-ng menuconfig
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(TERM_NORMAL) completed."; echo

PREQS  = $(DRIVER_DIR)
PREQS += $(APPS_DIR)
PREQS += $(FLASH_DIR)

preqs: $(PREQS)

$(DRIVER_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_DRIVER)-driver git repository'
	@echo '===================================================================='
	if [ ! -e $(DRIVER_DIR)/.git ]; then \
		git clone $(CONFIGURE_SILENT) $(GITHUB)/$(GIT_NAME_DRIVER)/driver.git driver; \
	fi

$(APPS_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_APPS)-apps git repository'
	@echo '===================================================================='
	if [ ! -e $(APPS_DIR)/.git ]; then \
		git clone $(CONFIGURE_SILENT) $(GITHUB)/$(GIT_NAME_APPS)/apps.git apps; \
	fi

$(FLASH_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_FLASH)-flash git repository'
	@echo '===================================================================='
	if [ ! -e $(FLASH_DIR)/.git ]; then \
		git clone $(CONFIGURE_SILENT) $(GITHUB)/$(GIT_NAME_FLASH)/flash.git flash; \
	fi
	@echo ''

#
# directories
#
directories:
	$(START_BUILD)
	$(SILENT)test -d $(D) || mkdir $(D)
	$(SILENT)test -d $(ARCHIVE) || mkdir $(ARCHIVE)
	$(SILENT)test -d $(STL_ARCHIVE) || mkdir $(STL_ARCHIVE)
	$(SILENT)test -d $(BUILD_TMP) || mkdir $(BUILD_TMP)
	$(SILENT)test -d $(SOURCE_DIR) || mkdir $(SOURCE_DIR)
	$(SILENT)install -d $(TARGET_DIR)
	$(SILENT)install -d $(CROSS_DIR)
	$(SILENT)install -d $(BOOT_DIR)
	$(SILENT)install -d $(HOST_DIR)
	$(SILENT)install -d $(HOST_DIR)/{bin,lib,share}
	$(SILENT)install -d $(TARGET_DIR)/{bin,boot,etc,lib,sbin,usr,var}
	$(SILENT)install -d $(TARGET_DIR)/etc/{init.d,mdev,network,rc.d}
	$(SILENT)install -d $(TARGET_DIR)/etc/rc.d/{rc0.d,rc6.d}
	$(SILENT)ln -sf ../init.d $(TARGET_DIR)/etc/rc.d/init.d
	$(SILENT)install -d $(TARGET_DIR)/lib/{lsb,firmware}
	$(SILENT)install -d $(TARGET_DIR)/usr/{bin,lib,local,sbin,share}
	$(SILENT)install -d $(TARGET_DIR)/usr/lib/pkgconfig
	$(SILENT)install -d $(TARGET_DIR)/usr/include/linux
	$(SILENT)install -d $(TARGET_DIR)/usr/include/linux/dvb
	$(SILENT)install -d $(TARGET_DIR)/usr/local/{bin,sbin,share}
	$(SILENT)install -d $(TARGET_DIR)/var/{etc,lib,run}
	$(SILENT)install -d $(TARGET_DIR)/var/lib/{misc,nfs}
	$(SILENT)install -d $(TARGET_DIR)/var/bin
	@touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(TERM_NORMAL) completed."; echo

#
# ccache
#
CCACHE_BINDIR = $(HOST_DIR)/bin
CCACHE_BIN = $(CCACHE)

CCACHE_LINKS = \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/cc; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/gcc; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/g++; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/$(TARGET)-gcc; \
	ln -sf $(CCACHE_BIN) $(CCACHE_BINDIR)/$(TARGET)-g++

CCACHE_ENV = install -d $(CCACHE_BINDIR); \
	$(CCACHE_LINKS)

$(D)/ccache:
	$(START_BUILD)
	$(CCACHE_ENV)
	$(TOUCH)

# hack to make sure they are always copied
PHONY += ccache bootstrap

#
# YAUD NONE
#
yaud-none: \
	$(D)/bootstrap \
	$(D)/linux-kernel \
	$(D)/system-tools
	@touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(TERM_NORMAL) completed."; echo

