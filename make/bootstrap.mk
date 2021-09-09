TOOLCHECK  = find_git find_svn find_gzip find_bzip2 find_patch find_gawk
TOOLCHECK += find_makeinfo find_automake find_gcc find_libtool
TOOLCHECK += find_yacc find_flex find_tic find_pkg-config find_help2man
TOOLCHECK += find_cmake find_gperf

find_%:
	@TOOL=$(patsubst find_%,%,$@); \
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

#
# host_pkgconfig
#
HOST_PKGCONFIG_VER = 0.29.2
HOST_PKGCONFIG_SOURCE = pkg-config-$(HOST_PKGCONFIG_VER).tar.gz

$(ARCHIVE)/$(HOST_PKGCONFIG_SOURCE):
	$(WGET) https://pkgconfig.freedesktop.org/releases/$(HOST_PKGCONFIG_SOURCE)

$(D)/host_pkgconfig: directories $(ARCHIVE)/$(HOST_PKGCONFIG_SOURCE)
	$(START_BUILD)
	$(REMOVE)/pkg-config-$(HOST_PKGCONFIG_VER)
	$(UNTAR)/$(HOST_PKGCONFIG_SOURCE)
	$(CH_DIR)/pkg-config-$(HOST_PKGCONFIG_VER); \
		./configure $(SILENT_CONFIGURE) $(SILENT_OPT) \
			--prefix=$(HOST_DIR) \
			--program-prefix=$(TARGET)- \
			--disable-host-tool \
			--with-pc_path=$(PKG_CONFIG_PATH) \
		; \
		$(MAKE); \
		$(MAKE) install
	ln -sf $(TARGET)-pkg-config $(HOST_DIR)/bin/pkg-config
	$(REMOVE)/pkg-config-$(HOST_PKGCONFIG_VER)
	$(TOUCH)

#
# host_module_init_tools
#
HOST_MODULE_INIT_TOOLS_VER = $(MODULE_INIT_TOOLS_VER)
HOST_MODULE_INIT_TOOLS_SOURCE = $(MODULE_INIT_TOOLS_SOURCE)
HOST_MODULE_INIT_TOOLS_PATCH = module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER).patch

$(D)/host_module_init_tools: $(ARCHIVE)/$(HOST_MODULE_INIT_TOOLS_SOURCE)
	$(START_BUILD)
	$(SILENT)if [ ! -d $(BUILD_TMP) ]; then mkdir $(BUILD_TMP); fi;
	$(REMOVE)/module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER)
	$(UNTAR)/$(HOST_MODULE_INIT_TOOLS_SOURCE)
	$(CH_DIR)/module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER); \
		$(call apply_patches,$(HOST_MODULE_INIT_TOOLS_PATCH)); \
		autoreconf -fi $(SILENT_OPT); \
		./configure $(SILENT_CONFIGURE) \
			--prefix=$(HOST_DIR) \
			--sbindir=$(HOST_DIR)/bin \
		; \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/module-init-tools-$(HOST_MODULE_INIT_TOOLS_VER)
	$(TOUCH)

#
# host_mtd_utils_old
#
HOST_MTD_UTILS_OLD_VER    = $(MTD_UTILS_OLD_VER)
HOST_MTD_UTILS_OLD_SOURCE = $(MTD_UTILS_OLD_SOURCE)
HOST_MTD_UTILS_OLD_PATCH  = host-mtd-utils-$(HOST_MTD_UTILS_OLD_VER).patch
HOST_MTD_UTILS_OLD_PATCH += host-mtd-utils-$(HOST_MTD_UTILS_OLD_VER)-sysmacros.patch

$(D)/host_mtd_utils_old: directories $(ARCHIVE)/$(HOST_MTD_UTILS_OLD_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mtd-utils-$(HOST_MTD_UTILS_OLD_VER)
	$(UNTAR)/$(HOST_MTD_UTILS_OLD_SOURCE)
	$(CH_DIR)/mtd-utils-$(HOST_MTD_UTILS_OLD_VER); \
		$(call apply_patches,$(HOST_MTD_UTILS_OLD_PATCH)); \
		$(MAKE) `pwd`/mkfs.jffs2 `pwd`/sumtool BUILDDIR=`pwd` WITHOUT_XATTR=1 DESTDIR=$(HOST_DIR); \
		$(MAKE) install DESTDIR=$(HOST_DIR)/bin
	$(REMOVE)/mtd-utils-$(HOST_MTD_UTILS_OLD_VER)
	$(TOUCH)

#
# mtd_utils
#
HOST_MTD_UTILS_VER    = $(MTD_UTILS_VER)
HOST_MTD_UTILS_SOURCE = $(MTD_UTILS_SOURCE)
HOST_MTD_UTILS_PATCH  = host-mtd-utils-$(HOST_MTD_UTILS_VER).patch

$(D)/host_mtd_utils: directories $(ARCHIVE)/$(HOST_MTD_UTILS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/mtd-utils-$(HOST_MTD_UTILS_VER)
	$(UNTAR)/$(HOST_MTD_UTILS_SOURCE)
	$(CH_DIR)/mtd-utils-$(HOST_MTD_UTILS_VER); \
		$(call apply_patches, $(HOST_MTD_UTILS_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--program-suffix="" \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-builddir \
		; \
		$(MAKE); \
		cp -a $(BUILD_TMP)/mtd-utils-$(HOST_MTD_UTILS_VER)/mkfs.jffs2 $(HOST_DIR)/bin
		cp -a $(BUILD_TMP)/mtd-utils-$(HOST_MTD_UTILS_VER)/sumtool $(HOST_DIR)/bin
#		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/mtd-utils-$(HOST_MTD_UTILS_VER)
	$(TOUCH)

#
# host_mkcramfs
#
HOST_MKCRAMFS_VER    = 1.1
HOST_MKCRAMFS_SOURCE = cramfs-$(HOST_MKCRAMFS_VER).tar.gz
HOST_MKCRAMFS_PATCH  = cramfs-$(HOST_MKCRAMFS_VER).patch

$(ARCHIVE)/$(HOST_MKCRAMFS_SOURCE):
	$(WGET) https://sourceforge.net/projects/cramfs/files/cramfs/$(HOST_MKCRAMFS_VER)/$(HOST_MKCRAMFS_SOURCE)

$(D)/host_mkcramfs: directories $(ARCHIVE)/$(HOST_MKCRAMFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/cramfs-$(HOST_MKCRAMFS_VER)
	$(UNTAR)/$(HOST_MKCRAMFS_SOURCE)
	$(CH_DIR)/cramfs-$(HOST_MKCRAMFS_VER); \
		$(call apply_patches, $(HOST_MKCRAMFS_PATCH)); \
		$(MAKE) all
		cp $(BUILD_TMP)/cramfs-$(HOST_MKCRAMFS_VER)/mkcramfs $(HOST_DIR)/bin
		cp $(BUILD_TMP)/cramfs-$(HOST_MKCRAMFS_VER)/cramfsck $(HOST_DIR)/bin
	$(REMOVE)/cramfs-$(HOST_MKCRAMFS_VER)
	$(TOUCH)

#
# host_mksquashfs3
#
HOST_MKSQUASHFS3_VER = 3.3
HOST_MKSQUASHFS3_SOURCE = squashfs$(HOST_MKSQUASHFS3_VER).tar.gz

$(ARCHIVE)/$(HOST_MKSQUASHFS3_SOURCE):
	$(WGET) https://sourceforge.net/projects/squashfs/files/OldFiles/$(HOST_MKSQUASHFS3_SOURCE)

$(D)/host_mksquashfs3: directories $(ARCHIVE)/$(HOST_MKSQUASHFS3_SOURCE)
	$(START_BUILD)
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS3_VER)
	$(UNTAR)/$(HOST_MKSQUASHFS3_SOURCE)
	$(CH_DIR)/squashfs$(HOST_MKSQUASHFS3_VER)/squashfs-tools; \
		$(MAKE) CC=gcc all
		mv $(BUILD_TMP)/squashfs$(HOST_MKSQUASHFS3_VER)/squashfs-tools/mksquashfs $(HOST_DIR)/bin/mksquashfs3.3
		mv $(BUILD_TMP)/squashfs$(HOST_MKSQUASHFS3_VER)/squashfs-tools/unsquashfs $(HOST_DIR)/bin/unsquashfs3.3
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS3_VER)
	$(TOUCH)

#
# host_mksquashfs with LZMA support
#
HOST_MKSQUASHFS_VER = 4.2
HOST_MKSQUASHFS_SOURCE = squashfs$(HOST_MKSQUASHFS_VER).tar.gz

LZMA_VER = 4.65
LZMA_SOURCE = lzma-$(LZMA_VER).tar.bz2

$(ARCHIVE)/$(HOST_MKSQUASHFS_SOURCE):
	$(WGET) https://sourceforge.net/projects/squashfs/files/squashfs/squashfs$(HOST_MKSQUASHFS_VER)/$(HOST_MKSQUASHFS_SOURCE)

$(ARCHIVE)/$(LZMA_SOURCE):
	$(WGET) http://downloads.openwrt.org/sources/$(LZMA_SOURCE)

$(D)/host_mksquashfs: directories $(ARCHIVE)/$(LZMA_SOURCE) $(ARCHIVE)/$(HOST_MKSQUASHFS_SOURCE)
	$(START_BUILD)
	$(REMOVE)/lzma-$(LZMA_VER)
	$(UNTAR)/$(LZMA_SOURCE)
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS_VER)
	$(UNTAR)/$(HOST_MKSQUASHFS_SOURCE)
	$(CH_DIR)/squashfs$(HOST_MKSQUASHFS_VER); \
		$(MAKE) -C squashfs-tools \
			LZMA_SUPPORT=1 \
			LZMA_DIR=$(BUILD_TMP)/lzma-$(LZMA_VER) \
			XATTR_SUPPORT=0 \
			XATTR_DEFAULT=0 \
			install INSTALL_DIR=$(HOST_DIR)/bin
	$(REMOVE)/lzma-$(LZMA_VER)
	$(REMOVE)/squashfs$(HOST_MKSQUASHFS_VER)
	$(TOUCH)

#
#
#
BOOTSTRAP  = directories
BOOTSTRAP += $(D)/ccache
BOOTSTRAP += $(CROSSTOOL)
BOOTSTRAP += $(TARGET_DIR)/lib/libc.so.6
BOOTSTRAP += $(D)/host_pkgconfig
BOOTSTRAP += $(D)/host_module_init_tools
BOOTSTRAP += $(D)/host_mtd_utils_old
BOOTSTRAP += $(D)/host_mkcramfs
#BOOTSTRAP += $(D)/host_mksquashfs

$(D)/bootstrap: $(BOOTSTRAP)
	@touch $@

#
# system-tools
#
SYSTEM_TOOLS  = $(D)/busybox
SYSTEM_TOOLS += $(D)/zlib
SYSTEM_TOOLS += $(D)/sysvinit
SYSTEM_TOOLS += $(D)/diverse-tools
SYSTEM_TOOLS += $(D)/e2fsprogs
SYSTEM_TOOLS += $(D)/hdidle
SYSTEM_TOOLS += $(D)/portmap
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922))
SYSTEM_TOOLS += $(D)/jfsutils
SYSTEM_TOOLS += $(D)/nfs_utils
endif
SYSTEM_TOOLS += $(D)/vsftpd
SYSTEM_TOOLS += $(D)/autofs
SYSTEM_TOOLS += $(D)/udpxy
SYSTEM_TOOLS += $(D)/dvbsnoop
SYSTEM_TOOLS += $(D)/fbshot
SYSTEM_TOOLS += $(D)/driver

$(D)/system-tools: $(SYSTEM_TOOLS) $(TOOLS)
	$(TOUCH)

#
# YAUD NONE
#
YAUD_NONE     = $(D)/bootstrap
YAUD_NONE    += $(KERNEL)
YAUD_NONE    += $(D)/system-tools

yaud-none: $(YAUD_NONE)
	@touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$@$(TERM_NORMAL) completed."; echo

#
# preqs
#
$(DRIVER_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_DRIVER)-driver git repository'
	@echo '===================================================================='
	@if [ ! -e $(DRIVER_DIR)/.git ]; then \
		git clone $(SILENT_CONFIGURE) $(GITHUB)/$(GIT_NAME_DRIVER)/driver.git driver; \
	fi
	@if [ -d ~/pti_np ]; then \
		echo -e "\nREMARK: Installing pti_np.\n"; \
		mkdir $(DRIVER_DIR)/pti_np; \
		cp -rf ~/pti_np/* $(DRIVER_DIR)/pti_np; \
	fi
	
$(TOOLS_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_TOOLS)-tools git repository'
	@echo '===================================================================='
	@if [ ! -e $(TOOLS_DIR)/.git ]; then \
		git clone $(MINUS_Q) $(GITHUB)/$(GIT_NAME_TOOLS)/tools.git tools; \
	fi

$(FLASH_DIR):
	@echo '===================================================================='
	@echo '      Cloning $(GIT_NAME_FLASH)-flash git repository'
	@echo '===================================================================='
	@if [ ! -e $(FLASH_DIR)/.git ]; then \
		git clone $(MINUS_Q) $(GITHUB)/$(GIT_NAME_FLASH)/flash.git flash; \
	fi
	@echo ''

PREQS  = $(DRIVER_DIR)
PREQS += $(TOOLS_DIR)
PREQS += $(FLASH_DIR)

preqs: $(PREQS)

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
	$(SILENT)install -d $(TARGET_DIR)/usr/{bin,lib,sbin,share}
	$(SILENT)install -d $(TARGET_DIR)/usr/lib/pkgconfig
	$(SILENT)install -d $(TARGET_DIR)/usr/include/linux
	$(SILENT)install -d $(TARGET_DIR)/usr/include/linux/dvb
#	$(SILENT)install -d $(TARGET_DIR)/usr/local/{bin,sbin,share}
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

CCACHE_ENV = $(SILENT)install -d $(CCACHE_BINDIR); \
	$(CCACHE_LINKS)

$(D)/ccache:
	$(START_BUILD)
	$(CCACHE_ENV)
	$(TOUCH)

# hack to make sure they are always copied
PHONY += ccache
