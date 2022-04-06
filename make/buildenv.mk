#
# set up build environment for other makefiles
#
# -----------------------------------------------------------------------------

#SHELL := $(SHELL) -x

CONFIG_SITE =
export CONFIG_SITE

LD_LIBRARY_PATH =
export LD_LIBRARY_PATH

export BOXTYPE

# -----------------------------------------------------------------------------

# set up default parallelism
PARALLEL_JOBS := $(shell echo $$((1 + `getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`)))
override MAKE = make $(if $(findstring j,$(filter-out --%,$(MAKEFLAGS))),,-j$(PARALLEL_JOBS)) $(SILENT_OPT)
export PARALLEL_JOBS

MAKEFLAGS            += --no-print-directory

# -----------------------------------------------------------------------------

# default platform...
BASE_DIR             := $(shell pwd)
ARCHIVE              ?= $(HOME)/Archive
TOOLS_DIR             = $(BASE_DIR)/tools
BUILD_TMP             = $(BASE_DIR)/build_tmp
SOURCE_DIR            = $(BASE_DIR)/build_source
DRIVER_DIR            = $(BASE_DIR)/driver
FLASH_DIR             = $(BASE_DIR)/flash

-include $(BASE_DIR)/config

# for local extensions
-include $(BASE_DIR)/config.local

ifneq ($(GIT_USER), "")
ifneq ($(GIT_TOKEN), "")
GIT_ACCESS            = $(GIT_USER):$(GIT_TOKEN)@
endif
endif
GIT_PROTOCOL         ?= http
ifneq ($(GIT_PROTOCOL), http)
GITHUB               ?= git://$(GIT_ACCESS)github.com
else
GITHUB               ?= https://$(GIT_ACCESS)github.com
endif
GIT_NAME             ?= Audioniek
GIT_NAME_DRIVER      ?= Audioniek
GIT_NAME_TOOLS       ?= Audioniek
GIT_NAME_FLASH       ?= Audioniek

# default config...
KBUILD_VERBOSE       ?= normal
BOXARCH              ?= sh4
BOXTYPE              ?= hs8200
BOXARCH              ?= sh4
KERNEL_STM           ?= p0217
IMAGE                ?= neutrino-wlandriver
FLAVOUR              ?= neutrino-ddt
OPTIMIZATIONS        ?= size
MEDIAFW              ?= buildinplayer
EXTERNAL_LCD         ?= none
DESTINATION          ?= flash

TUFSBOX_DIR           = $(BASE_DIR)/tufsbox
#CROSS_BASE            = $(BASE_DIR)/cross/$(BOXTYPE)
CROSS_BASE            = $(TUFSBOX_DIR)/cross
TARGET_DIR            = $(TUFSBOX_DIR)/cdkroot
BOOT_DIR              = $(TUFSBOX_DIR)/cdkroot-tftpboot
CROSS_DIR             = $(TUFSBOX_DIR)/cross
HOST_DIR              = $(TUFSBOX_DIR)/host
RELEASE_DIR           = $(TUFSBOX_DIR)/release

CUSTOM_DIR            = $(BASE_DIR)/custom
OWN_BUILD             = $(BASE_DIR)/own_build
PATCHES               = $(BASE_DIR)/patches
SCRIPTS_DIR           = $(BASE_DIR)/scripts
SKEL_ROOT             = $(BASE_DIR)/root
D                     = $(BASE_DIR)/.deps
# backwards compatibility
DEPDIR                = $(D)

MAINTAINER           ?= $(shell whoami)
MAIN_ID               = $(shell echo -en "\x41\x75\x64\x69\x6f\x6e\x69\x65\x6b")
CCACHE                = /usr/bin/ccache

BUILD                ?= $(shell /usr/share/libtool/config.guess 2>/dev/null || /usr/share/libtool/config/config.guess 2>/dev/null || /usr/share/libtool/build-aux/config.guess 2>/dev/null || /usr/share/misc/config.guess 2>/dev/null)

CCACHE_DIR            = $(HOME)/.ccache-bs-sh4
export CCACHE_DIR

BS_GCC_VER           ?= 4.8.4
ifeq ($(BS_GCC_VER), $(filter $(BS_GCC_VER), 4.6.3 4.8.4))
TARGET               ?= sh4-linux
else
TARGET               ?= sh4-stm-linux-gnu
endif
KERNELNAME            = uImage
TARGET_MARCH_CFLAGS   =

OPTIMIZATIONS        ?= size
ifeq ($(OPTIMIZATIONS), small)
TARGET_O_CFLAGS       = -Os
TARGET_EXTRA_CFLAGS   = -ffunction-sections -fdata-sections
TARGET_EXTRA_LDFLAGS  = -Wl,--gc-sections
ENIGMA_OPT_OPTION     = --without-debug
endif
ifeq ($(OPTIMIZATIONS), size)
TARGET_O_CFLAGS       = -Os
TARGET_EXTRA_CFLAGS   = -ffunction-sections -fdata-sections
TARGET_EXTRA_LDFLAGS  = -Wl,--gc-sections
ENIGMA_OPT_OPTION     =
# Uncomment next line to support Power VU DES (requires public pti!)
#POWER_VU_DES          = 1
endif
ifeq ($(OPTIMIZATIONS), normal)
TARGET_O_CFLAGS       = -O2
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
ENIGMA_OPT_OPTION     =
endif
ifeq ($(OPTIMIZATIONS), kerneldebug)
TARGET_O_CFLAGS       = -O2
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
ENIGMA_OPT_OPTION     =
endif
ifeq ($(OPTIMIZATIONS), debug)
TARGET_O_CFLAGS       = -O0 -g
TARGET_EXTRA_CFLAGS   =
TARGET_EXTRA_LDFLAGS  =
ENIGMA_OPT_OPTION     =
endif

TARGET_LIB_DIR        = $(TARGET_DIR)/usr/lib
TARGET_INCLUDE_DIR    = $(TARGET_DIR)/usr/include

TARGET_CFLAGS         = -pipe $(TARGET_O_CFLAGS) $(TARGET_MARCH_CFLAGS) $(TARGET_EXTRA_CFLAGS) -I$(TARGET_INCLUDE_DIR)
TARGET_CPPFLAGS       = $(TARGET_CFLAGS)
TARGET_CXXFLAGS       = $(TARGET_CFLAGS)
TARGET_LDFLAGS        = -Wl,-rpath -Wl,/usr/lib -Wl,-rpath-link -Wl,$(TARGET_LIB_DIR) -L$(TARGET_LIB_DIR) -L$(TARGET_DIR)/lib $(TARGET_EXTRA_LDFLAGS)
LD_FLAGS              = $(TARGET_LDFLAGS)
PKG_CONFIG            = $(HOST_DIR)/bin/$(TARGET)-pkg-config
PKG_CONFIG_PATH       = $(TARGET_LIB_DIR)/pkgconfig

VPATH                 = $(D)

PATH                 := $(HOST_DIR)/bin:$(CROSS_DIR)/bin:$(CROSS_BASE)/bin:$(PATH):/sbin:/usr/sbin:/usr/local/sbin

TERM_RED             := \033[00;31m
TERM_RED_BOLD        := \033[01;31m
TERM_GREEN           := \033[00;32m
TERM_GREEN_BOLD      := \033[01;32m
TERM_YELLOW          := \033[00;33m
TERM_YELLOW_BOLD     := \033[01;33m
TERM_NORMAL          := \033[0m

# set the default verbosity
#ifndef KBUILD_VERBOSE
#KBUILD_VERBOSE        = normal
#endif

MAKEFLAGS            += --no-print-directory
MINUS_Q               = -q
ifeq ($(KBUILD_VERBOSE), verbose)
MINUS_Q               =
SILENT_CONFIGURE      =
SILENT_PATCH          =
SILENT_OPT            =
SILENT                =
WGET_SILENT_OPT       =
endif
ifeq ($(KBUILD_VERBOSE), normal)
SILENT_CONFIGURE      = $(MINUS_Q)
SILENT_PATCH          =
SILENT_OPT            =
SILENT                = @
WGET_SILENT_OPT       =
endif
ifeq ($(KBUILD_VERBOSE), quiet)
SILENT_CONFIGURE      = >/dev/null 2>&1
SILENT_PATCH          = -s
SILENT_OPT            = >/dev/null 2>&1
SILENT                = @
WGET_SILENT_OPT       = -o /dev/null
MAKEFLAGS            += --silent
endif
export SILENT

# certificates
CA_BUNDLE             = ca-certificates.crt
CA_BUNDLE_DIR         = /etc/ssl/certs

# helper-"functions"
REWRITE_LIBTOOL       = $(SILENT)sed -i "s,^libdir=.*,libdir='$(TARGET_DIR)/usr/lib'," $(TARGET_DIR)/usr/lib
REWRITE_LIBTOOL_NQ    = sed -i "s,^libdir=.*,libdir='$(TARGET_DIR)/usr/lib'," $(TARGET_DIR)/usr/lib
REWRITE_LIBTOOLDEP    = $(SILENT)sed -i -e "s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/usr/lib,\ $(TARGET_DIR)/usr/lib,g" $(TARGET_DIR)/usr/lib
REWRITE_PKGCONF       = $(SILENT)sed -i "s,^prefix=.*,prefix='$(TARGET_DIR)/usr',"
REWRITE_PKGCONF_NQ    = sed -i "s,^prefix=.*,prefix='$(TARGET_DIR)/usr',"

# unpack tarballs, clean up
UNTAR                 = $(SILENT)tar -C $(BUILD_TMP) -xf $(ARCHIVE)
SET                   = $(SILENT)set
REMOVE                = $(SILENT)rm -rf $(BUILD_TMP)

CH_DIR                = $(SILENT)set -e; cd $(BUILD_TMP)
MK_DIR                = mkdir -p $(BUILD_TMP)
STRIP                 = $(TARGET)-strip
#
split_deps_dir=$(subst ., ,$(1))
DEPS_DIR              = $(subst $(D)/,,$@)
PKG_NAME              = $(word 1,$(call split_deps_dir,$(DEPS_DIR)))
PKG_NAME_HELPER       = $(shell echo $(PKG_NAME) | sed 's/.*/\U&/')
PKG_VER_HELPER        = A$($(PKG_NAME_HELPER)_VER)A
PKG_VER               = $($(PKG_NAME_HELPER)_VER)

START_BUILD           = @echo "=============================================================="; \
                        echo; \
                        if [ $(PKG_VER_HELPER) == "AA" ]; then \
                            echo -e "Start build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL)."; \
                        else \
                            echo -e "Start build of $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL)."; \
                        fi

TOUCH                 = @touch $@; \
                        echo "--------------------------------------------------------------"; \
                        if [ $(PKG_VER_HELPER) == "AA" ]; then \
                            echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed."; \
                        else \
                            echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed."; \
                        fi; \
                        echo

#
PATCH                 = patch -p1 $(SILENT_PATCH) -i $(PATCHES)
APATCH                = patch -p1 $(SILENT_PATCH) -i
define apply_patches
    for i in $(1); do \
        if [ -d $$i ]; then \
            for p in $$i/*; do \
                if [ $${p:0:1} == "/" ]; then \
                    echo -e "$(TERM_RED)Applying Patch:$(TERM_NORMAL) $$p"; $(APATCH) $$p; \
                else \
                    echo -e "$(TERM_RED)Applying Patch:$(TERM_NORMAL) $$p"; $(PATCH)/$$p; \
                fi; \
            done; \
        else \
            if [ $${i:0:1} == "/" ]; then \
                echo -e "$(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; $(APATCH) $$i; \
            else \
                echo -e "$(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; $(PATCH)/$$i; \
            fi; \
        fi; \
    done; \
    if [ '$(1)' -a '$(1)' != ' ' ]; then \
        if [ $(PKG_VER_HELPER) == "AA" ]; then \
            echo -e "Patching $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed."; \
        else \
            echo -e "Patching $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed."; \
        fi; \
    fi; \
    echo
endef

# wget tarballs into archive directory
WGET = $(SILENT)wget --progress=bar:force --no-check-certificate $(WGET_SILENT_OPT) -t6 -T20 -c -P $(ARCHIVE)

TUXBOX_YAUD_CUSTOMIZE = $(SILENT)[ -x $(CUSTOM_DIR)/$(notdir $@)-local.sh ] && \
	KERNEL_VER=$(KERNEL_VER) && \
	BOXTYPE=$(BOXTYPE) && \
	$(CUSTOM_DIR)/$(notdir $@)-local.sh \
	$(RELEASE_DIR) \
	$(TARGET_DIR) \
	$(BASE_DIR) \
	$(SOURCE_DIR) \
	$(FLASH_DIR) \
	$(BOXTYPE) \
	|| true
TUXBOX_CUSTOMIZE = $(SILENT)[ -x $(CUSTOM_DIR)/$(notdir $@)-local.sh ] && \
	KERNEL_VER=$(KERNEL_VER) && \
	BOXTYPE=$(BOXTYPE) && \
	$(CUSTOM_DIR)/$(notdir $@)-local.sh \
	$(RELEASE_DIR) \
	$(TARGET_DIR) \
	$(BASE_DIR) \
	$(BOXTYPE) \
	$(FLAVOUR) \
	|| true

#
#
#
CONFIGURE_OPTS = \
	--build=$(BUILD) --host=$(TARGET) $(SILENT_CONFIGURE)

BUILDENV = \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	LN_S="ln -s" \
	CFLAGS="$(TARGET_CFLAGS)" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CXXFLAGS="$(TARGET_CXXFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

ifneq ($(KBUILD_VERBOSE), verbose)
CONFIGURE = \
	test -f ./configure || ./autogen.sh $(SILENT_OPT) && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)
else
CONFIGURE = \
	test -f ./configure || ./autogen.sh && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)
endif

CONFIGURE_TOOLS = \
	./autogen.sh $(SILENT_OPT) && \
	$(BUILDENV) \
	./configure $(CONFIGURE_OPTS)

MAKE_OPTS := \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	LN_S="ln -s" \
	ARCH=sh \
	CROSS_COMPILE=$(TARGET)-

#
# image
#
ifeq ($(IMAGE), enigma2)
BUILD_CONFIG       = build-enigma2
else ifeq ($(IMAGE), enigma2-wlandriver)
BUILD_CONFIG       = build-enigma2
WLANDRIVER         = WLANDRIVER=wlandriver
else ifeq ($(IMAGE), neutrino)
BUILD_CONFIG       = build-neutrino
else ifeq ($(IMAGE), neutrino-wlandriver)
BUILD_CONFIG       = build-neutrino
WLANDRIVER         = WLANDRIVER=wlandriver
else ifeq ($(IMAGE), titan)
BUILD_CONFIG       = build-titan
else ifeq ($(IMAGE), titan-wlandriver)
BUILD_CONFIG       = build-titan
WLANDRIVER         = WLANDRIVER=wlandriver
else
BUILD_CONFIG       = build-neutrino
endif

#
#
#
ifeq ($(MEDIAFW), eplayer3)
EPLAYER3           = 1
else ifeq ($(MEDIAFW), gstreamer)
gstreamer          = 1
else ifeq ($(MEDIAFW), gst-eplayer3)
EPLAYER3           = 1
gst-eplayer3       = 1
else
buildinplayer      = 1
endif

#
DRIVER_PLATFORM   := $(WLANDRIVER)

#
ifeq ($(BOXTYPE), ufs910)
KERNEL_PATCHES_24  = $(UFS910_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_UFS910
DRIVER_PLATFORM   += UFS910=ufs910
E_CONFIG_OPTS     += --enable-ufs910
endif
ifeq ($(BOXTYPE), ufs912)
KERNEL_PATCHES_24  = $(UFS912_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_UFS912
DRIVER_PLATFORM   += UFS912=ufs912
E_CONFIG_OPTS     += --enable-ufs912
endif
ifeq ($(BOXTYPE), ufs913)
KERNEL_PATCHES_24  = $(UFS913_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_UFS913
DRIVER_PLATFORM   += UFS913=ufs913
E_CONFIG_OPTS     += --enable-ufs913
endif
ifeq ($(BOXTYPE), ufs922)
KERNEL_PATCHES_24  = $(UFS922_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_UFS922
DRIVER_PLATFORM   += UFS922=ufs922
E_CONFIG_OPTS     += --enable-ufs922
endif
ifeq ($(BOXTYPE), ufc960)
KERNEL_PATCHES_24  = $(UFC960_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_UFC960
DRIVER_PLATFORM   += UFC960=ufc960
E_CONFIG_OPTS     += --enable-ufc960
endif
ifeq ($(BOXTYPE), tf7700)
KERNEL_PATCHES_24  = $(TF7700_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_TF7700
DRIVER_PLATFORM   += TF7700=tf7700
E_CONFIG_OPTS     += --enable-tf7700
endif
ifeq ($(BOXTYPE), hl101)
KERNEL_PATCHES_24  = $(HL101_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_HL101
DRIVER_PLATFORM   += HL101=hl101
E_CONFIG_OPTS     += --enable-hl101
endif
ifeq ($(BOXTYPE), spark)
KERNEL_PATCHES_24  = $(SPARK_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_SPARK
DRIVER_PLATFORM   += SPARK=spark
E_CONFIG_OPTS     += --enable-spark
endif
ifeq ($(BOXTYPE), spark7162)
KERNEL_PATCHES_24  = $(SPARK7162_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_SPARK7162
DRIVER_PLATFORM   += SPARK7162=spark7162
E_CONFIG_OPTS     += --enable-spark7162
endif
ifeq ($(BOXTYPE), fs9000)
KERNEL_PATCHES_24  = $(FS9000_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_FS9000
DRIVER_PLATFORM   += FS9000=fs9000
E_CONFIG_OPTS     += --enable-fs9000
endif
ifeq ($(BOXTYPE), hs7110)
KERNEL_PATCHES_24  = $(HS7110_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_HS7110
DRIVER_PLATFORM   += HS7110=hs7110
E_CONFIG_OPTS     += --enable-hs7110
endif
ifeq ($(BOXTYPE), hs7119)
KERNEL_PATCHES_24  = $(HS7119_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_HS7119
DRIVER_PLATFORM   += HS7119=hs7119
E_CONFIG_OPTS     += --enable-hs7119
endif
ifeq ($(BOXTYPE), hs7420)
KERNEL_PATCHES_24  = $(HS7420_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_HS7420
DRIVER_PLATFORM   += HS7420=hs7420
E_CONFIG_OPTS     += --enable-hs7420
endif
ifeq ($(BOXTYPE), hs7429)
KERNEL_PATCHES_24  = $(HS7429_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_HS7429
DRIVER_PLATFORM   += HS7429=hs7429
E_CONFIG_OPTS     += --enable-hs7429
endif
ifeq ($(BOXTYPE), hs7810a)
KERNEL_PATCHES_24  = $(HS7810A_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_HS7810A
DRIVER_PLATFORM   += HS7810A=hs7810a
E_CONFIG_OPTS     += --enable-hs7810a
endif
ifeq ($(BOXTYPE), hs7819)
KERNEL_PATCHES_24  = $(HS7819_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_HS7819
DRIVER_PLATFORM   += HS7819=hs7819
E_CONFIG_OPTS     += -enable-hs7819
endif
ifeq ($(BOXTYPE), atemio520)
KERNEL_PATCHES_24  = $(ATEMIO520_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_ATEMIO520
DRIVER_PLATFORM   += ATEMIO520=atemio520
E_CONFIG_OPTS     += --enable-atemio520
endif
ifeq ($(BOXTYPE), atemio530)
KERNEL_PATCHES_24  = $(ATEMIO530_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_ATEMIO530
DRIVER_PLATFORM   += ATEMIO530=atemio530
E_CONFIG_OPTS     += --enable-atemio530
endif
ifeq ($(BOXTYPE), hs8200)
KERNEL_PATCHES_24  = $(HS8200_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_HS8200
DRIVER_PLATFORM   += HS8200=hs8200
E_CONFIG_OPTS     += --enable-hs8200
endif
ifeq ($(BOXTYPE), hs9510)
KERNEL_PATCHES_24  = $(HS9510_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_HS9510
DRIVER_PLATFORM   += HS9510=hs9510
E_CONFIG_OPTS     += --enable-hs9510
endif
ifeq ($(BOXTYPE), adb_box)
KERNEL_PATCHES_24  = $(ADB_BOX_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_ADB_BOX
DRIVER_PLATFORM   += ADB_BOX=adb_box
E_CONFIG_OPTS     += --enable-adb_box
endif
ifeq ($(BOXTYPE), ipbox55)
KERNEL_PATCHES_24  = $(IPBOX55_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_IPBOX55
DRIVER_PLATFORM   += IPBOX55=ipbox55
E_CONFIG_OPTS     += --enable-ipbox55
endif
ifeq ($(BOXTYPE), ipbox99)
KERNEL_PATCHES_24  = $(IPBOX99_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_IPBOX99
DRIVER_PLATFORM   += IPBOX99=ipbox99
E_CONFIG_OPTS     += --enable-ipbox99
endif
ifeq ($(BOXTYPE), ipbox9900)
KERNEL_PATCHES_24  = $(IPBOX9900_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_IPBOX9900
DRIVER_PLATFORM   += IPBOX9900=ipbox9900
E_CONFIG_OPTS     += --enable-ipbox9900
endif
ifeq ($(BOXTYPE), cuberevo)
KERNEL_PATCHES_24  = $(CUBEREVO_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_CUBEREVO
DRIVER_PLATFORM   += CUBEREVO=cuberevo
E_CONFIG_OPTS     += --enable-cuberevo
endif
ifeq ($(BOXTYPE), cuberevo_mini)
KERNEL_PATCHES_24  = $(CUBEREVO_MINI_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_CUBEREVO_MINI
DRIVER_PLATFORM   += CUBEREVO_MINI=cuberevo_mini
E_CONFIG_OPTS     += --enable-cuberevo_mini
endif
ifeq ($(BOXTYPE), cuberevo_mini2)
KERNEL_PATCHES_24  = $(CUBEREVO_MINI2_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_CUBEREVO_MINI2
DRIVER_PLATFORM   += CUBEREVO_MINI2=cuberevo_mini2
E_CONFIG_OPTS     += --enable-cuberevo_mini2
endif
ifeq ($(BOXTYPE), cuberevo_mini_fta)
KERNEL_PATCHES_24  = $(CUBEREVO_MINI_FTA_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_CUBEREVO_MINI_FTA
DRIVER_PLATFORM   += CUBEREVO_MINI_FTA=cuberevo_mini_fta
E_CONFIG_OPTS     += --enable-cuberevo_mini_fta
endif
ifeq ($(BOXTYPE), cuberevo_250hd)
KERNEL_PATCHES_24  = $(CUBEREVO_250HD_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_CUBEREVO_250HD
DRIVER_PLATFORM   += CUBEREVO_250HD=cuberevo_250hd
E_CONFIG_OPTS     += --enable-cuberevo_250hd
endif
ifeq ($(BOXTYPE), cuberevo_2000hd)
KERNEL_PATCHES_24  = $(CUBEREVO_2000HD_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_CUBEREVO_2000HD
DRIVER_PLATFORM   += CUBEREVO_2000HD=cuberevo_2000hd
E_CONFIG_OPTS     += --enable-cuberevo_2000hd
endif
ifeq ($(BOXTYPE), cuberevo_3000hd)
KERNEL_PATCHES_24  = $(CUBEREVO_3000HD_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_CUBEREVO_3000HD
DRIVER_PLATFORM   += CUBEREVO_3000HD=cuberevo_3000hd
E_CONFIG_OPTS     += --enable-cuberevo_3000hd
endif
ifeq ($(BOXTYPE), cuberevo_9500hd)
KERNEL_PATCHES_24  = $(CUBEREVO_9500HD_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_CUBEREVO_9500HD
DRIVER_PLATFORM   += CUBEREVO_9500HD=cuberevo_9500hd
E_CONFIG_OPTS     += --enable-cuberevo_9500hd
endif
ifeq ($(BOXTYPE), vitamin_hd5000)
KERNEL_PATCHES_24  = $(VITAMIN_HD5000_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_VITAMIN_HD5000
DRIVER_PLATFORM   += VITAMIN_HD5000=vitamin_hd5000
E_CONFIG_OPTS     += --enable-vitamin_hd5000
endif
ifeq ($(BOXTYPE), sagemcom88)
KERNEL_PATCHES_24  = $(SAGEMCOM88_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_SAGEMCOM88
DRIVER_PLATFORM   += SAGEMCOM88=sagemcom88
E_CONFIG_OPTS     += --enable-sagemcom88
endif
ifeq ($(BOXTYPE), arivalink200)
KERNEL_PATCHES_24  = $(ARIVALINK200_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_ARIVALINK200
DRIVER_PLATFORM   += ARIVALINK200=arivalink200
E_CONFIG_OPTS     += --enable-arivalink200
endif
ifeq ($(BOXTYPE), pace7241)
KERNEL_PATCHES_24  = $(PACE7241_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_PACE7241
DRIVER_PLATFORM   += PACE7241=pace7241
E_CONFIG_OPTS     += --enable-pace7241
endif
ifeq ($(BOXTYPE), vip1_v1)
KERNEL_PATCHES_24  = $(VIP1_V1_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_VIP1_V1
DRIVER_PLATFORM   += VIP1_V1=vip1_v1
E_CONFIG_OPTS     += --enable-vip1_v1
endif
ifeq ($(BOXTYPE), vip1_v2)
KERNEL_PATCHES_24  = $(VIP1_V2_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_VIP1_V2
DRIVER_PLATFORM   += VIP1_V2=vip1_v2
E_CONFIG_OPTS     += --enable-vip1_v2
endif
ifeq ($(BOXTYPE), vip2)
KERNEL_PATCHES_24  = $(VIP2_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_VIP2
DRIVER_PLATFORM   += VIP2=vip2
E_CONFIG_OPTS     += --enable-vip2
endif
ifeq ($(BOXTYPE), adb_2850)
KERNEL_PATCHES_24  = $(ADB_2850_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_ADB_2850
DRIVER_PLATFORM   += ADB_2850=adb_2850
E_CONFIG_OPTS     += --enable-adb_2850
endif
ifeq ($(BOXTYPE), opt9600)
KERNEL_PATCHES_24  = $(OPT9600_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_OPT9600
DRIVER_PLATFORM   += OPT9600=opt9600
E_CONFIG_OPTS     += --enable-opt9600
endif
ifeq ($(BOXTYPE), opt9600mini)
KERNEL_PATCHES_24  = $(OPT9600MINI_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_OPT9600MINI
DRIVER_PLATFORM   += OPT9600MINI=opt9600mini
E_CONFIG_OPTS     += --enable-opt9600mini
endif
ifeq ($(BOXTYPE), opt9600prima)
KERNEL_PATCHES_24  = $(OPT9600PRIMA_PATCHES_24)
PLATFORM_CPPFLAGS += -DPLATFORM_OPT9600PRIMA
DRIVER_PLATFORM   += OPT9600PRIMA=opt9600prima
E_CONFIG_OPTS     += --enable-opt9600prima
endif

