#
# Makefile to build NEUTRINO
#
$(TARGET_DIR)/.version:
	$(SILENT)echo "imagename=Neutrino" > $@
	$(SILENT)echo "homepage=https://github.com/Audioniek" >> $@
	$(SILENT)echo "creator=$(MAINTAINER)" >> $@
	$(SILENT)echo "docs=https://github.com/Audioniek" >> $@
#	$(SILENT)echo "forum=https://github.com/Duckbox-Developers/neutrino-cst-next" >> $@
	$(SILENT)echo "version=0200`date +%Y%m%d%H%M`" >> $@
	$(SILENT)echo "git=`git log | grep "^commit" | wc -l`" >> $@

NEUTRINO_DEPS  = $(D)/bootstrap
NEUTRINO_DEPS += $(KERNEL)
NEUTRINO_DEPS += $(D)/system-tools
NEUTRINO_DEPS += $(D)/module_init_tools
NEUTRINO_DEPS += $(D)/alsa_utils
NEUTRINO_DEPS += $(D)/ffmpeg
NEUTRINO_DEPS += $(D)/libopenthreads
NEUTRINO_DEPS += $(LIRC)
NEUTRINO_DEPS += $(D)/libcurl
ifneq ($(FLAVOUR), neutrino-hd2)
NEUTRINO_DEPS += $(D)/libsigc241
else
NEUTRINO_DEPS += $(D)/libsigc
endif
NEUTRINO_DEPS += $(D)/pugixml
NEUTRINO_DEPS += $(D)/libdvbsi
NEUTRINO_DEPS += $(D)/libfribidi
NEUTRINO_DEPS += $(D)/giflib
NEUTRINO_DEPS += $(D)/lua
#NEUTRINO_DEPS += $(D)/luaexpat
#NEUTRINO_DEPS += $(D)/luacurl
#NEUTRINO_DEPS += $(D)/luasocket
#NEUTRINO_DEPS += $(D)/luafeedparser
#NEUTRINO_DEPS += $(D)/luasoap
#NEUTRINO_DEPS += $(D)/luajson
NEUTRINO_DEPS += $(D)/libpng
NEUTRINO_DEPS += $(D)/libjpeg
NEUTRINO_DEPS += $(D)/freetype
#NEUTRINO_DEPS += $(D)/libusb
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_DEPS)

ifeq ($(FLAVOUR), neutrino-tangos)
ifeq ($(PLUGINS_NEUTRINO), Yes)
NEUTRINO_DEPS += $(D)/avahi
endif
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hs8200 spark spark7162 ufs912 ufs913 ufs910))
NEUTRINO_DEPS += $(D)/ntfs_3g
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910))
NEUTRINO_DEPS += $(D)/parted
NEUTRINO_DEPS += $(D)/mtd_utils_old
NEUTRINO_DEPS += $(D)/gptfdisk
endif
NEUTRINO_DEPS += $(D)/minidlna
endif

ifeq ($(IMAGE), neutrino-wlandriver)
NEUTRINO_DEPS += $(D)/wpa_supplicant $(D)/wireless_tools
endif

NEUTRINO_DEPS2 = $(D)/libid3tag $(D)/libmad $(D)/flac

N_CFLAGS       = -Wall -W -Wshadow -pipe -Os
N_CFLAGS      += -D__KERNEL_STRICT_NAMES
N_CFLAGS      += -D__STDC_FORMAT_MACROS
N_CFLAGS      += -D__STDC_CONSTANT_MACROS
N_CFLAGS      += -fno-strict-aliasing
N_CFLAGS      += -funsigned-char
N_CFLAGS      += -ffunction-sections
N_CFLAGS      += -fdata-sections
#N_CFLAGS      += -DCPU_FREQ
N_CFLAGS      += $(LOCAL_NEUTRINO_CFLAGS)

N_CPPFLAGS     = -I$(TARGET_DIR)/usr/include
#N_CPPFLAGS    += -std=c++11
N_CPPFLAGS    += -ffunction-sections -fdata-sections

N_CPPFLAGS    += -I$(DRIVER_DIR)/bpamem
N_CPPFLAGS    += -I$(KERNEL_DIR)/include
N_CPPFLAGS    += -ffunction-sections
N_CPPFLAGS    += -fdata-sections

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
N_CPPFLAGS += -I$(DRIVER_DIR)/frontcontroller/aotom_spark
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), vip2))
N_CPPFLAGS += -I$(DRIVER_DIR)/frontcontroller/aotom_vip
endif

#ifeq ($(FLAVOUR), neutrino-tangos)
#N_CPPFLAGS += -std=c++11
#endif

LH_CONFIG_OPTS =
ifeq ($(MEDIAFW), gstreamer)
#NEUTRINO_DEPS  += $(D)/gst_plugins_multibox_dvbmediasink
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
LH_CONFIG_OPTS += --enable-gstreamer_10=yes
endif

N_CONFIG_OPTS   = $(LOCAL_NEUTRINO_BUILD_OPTIONS)
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
LH_CONFIG_OPTS += --with-boxtype=spark
N_CONFIG_OPTS  += --with-boxtype=spark
else
LH_CONFIG_OPTS += --with-boxtype=duckbox
N_CONFIG_OPTS  += --with-boxtype=duckbox
endif
N_CONFIG_OPTS  += --with-boxmodel=$(BOXTYPE)
N_CONFIG_OPTS  += --enable-freesatepg
#N_CONFIG_OPTS  += --enable-pip

ifeq ($(EXTERNAL_LCD), graphlcd)
N_CONFIG_OPTS += --enable-graphlcd
NEUTRINO_DEPS += $(D)/graphlcd
endif

ifeq ($(EXTERNAL_LCD), lcd4linux)
N_CONFIG_OPTS += --enable-lcd4linux
NEUTRINO_DEPS += $(D)/lcd4linux
#NEUTRINO_DEPS += $(D)/neutrino-plugin-l4l-skins
endif

ifeq ($(EXTERNAL_LCD), both)
N_CONFIG_OPTS += --enable-graphlcd
NEUTRINO_DEPS += $(D)/graphlcd
N_CONFIG_OPTS += --enable-lcd4linux
NEUTRINO_DEPS += $(D)/lcd4linux
endif

ifeq ($(FLAVOUR), neutrino-tangos)
GIT_URL       = https://github.com/TangoCash
NEUTRINO      = neutrino-tangos
LIBSTB_HAL    = libstb-hal-tangos
N_BRANCH     ?= master
N_CHECKOUT   ?= 066a0703b51588c500977763b8145df82f4270ce
HAL_BRANCH   ?= master
HAL_CHECKOUT ?= 2a909d72ae12e5c030cd3f21854f247c72823daf
N_PATCHES     = $(NEUTRINO_TANGOS_PATCHES)
HAL_PATCHES   = $(NEUTRINO_LIBSTB_TANGOS_PATCHES)
else ifeq ($(FLAVOUR), neutrino-ddt)
GIT_URL       = https://github.com/Duckbox-Developers
NEUTRINO      = neutrino-ddt
LIBSTB_HAL    = libstb-hal-ddt
N_BRANCH     ?= master
#N_CHECKOUT   ?= 4a627ad954c71fbca4f049202a585928276bb56d
N_CHECKOUT   ?= b60746ccc7ea9535ac0f7ba542fdf611770b9fa8
HAL_BRANCH   ?= master
#HAL_CHECKOUT ?= 5ab119ed51ac15a520e86c54b228288667de960c
HAL_CHECKOUT ?= da719b18518fbf12559930cb63a26ebd1028f125
N_PATCHES     = $(NEUTRINO_DDT_PATCHES)
HAL_PATCHES   = $(NEUTRINO_LIBSTB_DDT_PATCHES)
else ifeq ($(FLAVOUR), neutrino-hd2)
GIT_URL       = https://github.com/mohousch/neutrinohd2
NEUTRINO      = neutrino-hd2
N_BRANCH     ?= master
N_CHECKOUT   ?= d2ec257482e841563ad8c29e1aa5253145e4bd21
N_PATCHES     = $(NEUTRINO_HD2_PATCHES)
else
NEUTRINO      = dummy
LIBSTB_HAL    = dummy2
endif

N_OBJDIR = $(SOURCE_DIR)/$(NEUTRINO)
LH_OBJDIR = $(SOURCE_DIR)/$(LIBSTB_HAL)

#
# yaud-neutrino
#
yaud-neutrino: yaud-none $(D)/$(NEUTRINO) $(D)/neutrino_release
	@echo "***************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of $(NEUTRINO) for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************"
	@touch $(D)/build_complete

#
# yaud-neutrino-plugins
#
yaud-neutrino-plugins: yaud-none $(D)/$(NEUTRINO)-plugins $(D)/neutrino_release
	@echo "***************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of $(NEUTRINO) for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************"
	@touch $(D)/build_complete

ifeq ($(FLAVOUR), $(filter $(FLAVOUR), neutrino-ddt neutrino-tangos))
################################################################################
#
# libstb-hal
#

$(D)/$(LIBSTB_HAL).do_prepare: | $(NEUTRINO_DEPS)
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL)
	$(SILENT)rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL).org
	$(SILENT)test -d $(SOURCE_DIR) || mkdir -p $(SOURCE_DIR)
	$(SILENT)if [ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/$(LIBSTB_HAL).git; \
		git pull $(MINUS_Q); \
		cd $(SOURCE_DIR); \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone $(MINUS_Q) -b $(HAL_BRANCH) $(GIT_URL)/$(LIBSTB_HAL).git $(ARCHIVE)/$(LIBSTB_HAL).git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/$(LIBSTB_HAL).git $(SOURCE_DIR)/$(LIBSTB_HAL)
	$(SILENT)echo -n "Checking out commit $(HAL_CHECKOUT)..."
	$(SILENT)(cd $(SOURCE_DIR)/$(LIBSTB_HAL); git checkout $(MINUS_Q) $(HAL_CHECKOUT))
	$(SILENT)echo " done."
	$(SILENT)cp -ra $(SOURCE_DIR)/$(LIBSTB_HAL) $(SOURCE_DIR)/$(LIBSTB_HAL).org
	$(SET) -e; cd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		$(call apply_patches, $(HAL_PATCHES))
	@touch $@

$(SOURCE_DIR)/$(LIBSTB_HAL)/config.status:
	$(SILENT)cd $(LH_OBJDIR); \
		test -d $(SOURCE_DIR)/$(LIBSTB_HAL)/m4 || mkdir -p $(SOURCE_DIR)/$(LIBSTB_HAL)/m4; \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/configure $(SILENT_CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared=no \
			\
			--with-target=cdk \
			--with-targetprefix=/usr \
			--with-boxmodel=$(BOXTYPE) \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

$(D)/$(LIBSTB_HAL).do_compile: $(SOURCE_DIR)/$(LIBSTB_HAL)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/$(LIBSTB_HAL): $(D)/$(LIBSTB_HAL).do_prepare $(D)/$(LIBSTB_HAL).do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libstb-hal.la
	$(TOUCH)

$(LIBSTB_HAL)-clean:
	$(SILENT)rm -f $(D)/$(LIBSTB_HAL)
	$(SILENT)rm -f $(SOURCE_DIR)/$(LIBSTB_HAL)/config.status
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

$(LIBSTB_HAL)-distclean:
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)rm -f $(D)/$(LIBSTB_HAL)l*

################################################################################
#
# neutrino-ddt & neutrino-tangos
#
$(D)/$(NEUTRINO)-plugins.do_prepare \
$(D)/$(NEUTRINO).do_prepare: | $(NEUTRINO_DEPS) $(D)/$(LIBSTB_HAL)
	$(START_BUILD)
	$(SILENT)echo "Building variant: $(FLAVOUR), plugins = $(PLUGINS_NEUTRINO)"
	$(SILENT)rm -rf $(SOURCE_DIR)/$(NEUTRINO)
	$(SILENT)rm -rf $(SOURCE_DIR)/$(NEUTRINO).org
	$(SILENT)if [ -d "$(ARCHIVE)/$(NEUTRINO).git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/$(NEUTRINO).git; \
		git pull $(MINUS_Q); \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone $(MINUS_Q) -b $(N_BRANCH) $(GIT_URL)/$(NEUTRINO).git $(ARCHIVE)/$(NEUTRINO).git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/$(NEUTRINO).git $(SOURCE_DIR)/$(NEUTRINO)
	$(SILENT)echo -n "Checking out commit $(N_CHECKOUT)..."
	$(SILENT)(cd $(SOURCE_DIR)/$(NEUTRINO); git checkout $(MINUS_Q) $(N_CHECKOUT))
	$(SILENT)echo " done."
	$(SILENT)cp -ra $(SOURCE_DIR)/$(NEUTRINO) $(SOURCE_DIR)/$(NEUTRINO).org
	$(SET) -e; cd $(SOURCE_DIR)/$(NEUTRINO); \
		$(call apply_patches, $(N_PATCHES))
	@touch $@

$(SOURCE_DIR)/$(NEUTRINO)/config.status:
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/$(NEUTRINO)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(NEUTRINO)/configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--enable-ffmpegdec \
			--enable-fribidi \
			--enable-giflib \
			--enable-lua \
			--enable-pugixml \
			--enable-fastscan \
			$(N_CONFIG_OPTS) \
			\
			--with-tremor \
			--with-target=cdk \
			--with-targetprefix=/usr \
			--with-stb-hal-includes=$(SOURCE_DIR)/$(LIBSTB_HAL)/include \
			--with-stb-hal-build=$(LH_OBJDIR) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
		make $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
#	@touch $@

$(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h:
	$(SILENT)rm -f $@
	$(SILENT)echo '#define BUILT_DATE "'`date`'"' > $@
	$(SILENT)if test -d $(SOURCE_DIR)/$(LIBSTB_HAL); then \
		pushd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		HAL_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(SOURCE_DIR)/$(NEUTRINO); \
		N_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(BASE_DIR); \
		BS_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		echo '#define VCS "BS-rev'$$BS_REV'_HAL-rev'$$HAL_REV'_N-rev'$$N_REV'"' >> $@; \
	fi

$(D)/$(NEUTRINO)-plugins.do_compile \
$(D)/$(NEUTRINO).do_compile: $(SOURCE_DIR)/$(NEUTRINO)/config.status $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $(D)/$(NEUTRINO).do_compile

$(D)/$(NEUTRINO): $(D)/$(NEUTRINO).do_prepare $(D)/$(NEUTRINO).do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)make $(TARGET_DIR)/.version
	$(SILENT)touch $(D)/$(notdir $@)
	$(TOUCH)

$(NEUTRINO)-clean: neutrino-cdkroot-clean
	$(SILENT)rm -f $(D)/$(NEUTRINO)
	$(SILENT)rm -f $(SOURCE_DIR)/$(NEUTRINO)/config.status:
	$(SILENT)rm -f $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

$(NEUTRINO)-distclean: neutrino-cdkroot-clean
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)rm -f $(D)/$(NEUTRINO)*

$(D)/$(NEUTRINO)-plugins: $(D)/$(NEUTRINO)-plugins.do_prepare $(D)/$(NEUTRINO)-plugins.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(MAKE) $(TARGET_DIR)/.version
	make $(NEUTRINO_PLUGINS)
#	$(SILENT)touch $(D)/$(notdir $@)
	$(TOUCH)

$(NEUTRINO)-plugins-clean: neutrino-cdkroot-clean
	$(SILENT)rm -f $(D)/$(NEUTRINO)-plugins
	$(SILENT)rm -f $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
	$(SILENT)make $(NEUTRINO)-plugin-clean
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

$(NEUTRINO)-plugins-distclean: neutrino-cdkroot-clean
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)rm -f $(D)/$(NEUTRINO)-plugins*
	make $(NEUTRINO)-plugin-distclean
endif

ifeq ($(FLAVOUR), neutrino-hd2)
################################################################################
#
# neutrino-hd2
#
ifeq ($(BOXTYPE), spark)
NHD2_OPTS        = --enable-4digits --enable-scart
else ifeq ($(BOXTYPE), spark7162)
NHD2_OPTS        = --enable-scart
else ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hs7110, hs7119, hs7420, hs7429, hs7810a, hs7819))
#NHD2_OPTS       = --enable-ci --enable-4digits
NHD2_OPTS        = --enable-ci
else ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hs7420, hs7429, hs7810a, hs7819, adb_box, vitamin_hd5000))
NHD2_OPTS       += --enable-scart
else ifeq ($(BOXTYPE), $(filter $(BOXTYPE), adb_box))
NHD2_OPTS        = --enable-scart
else
NHD2_OPTS        = --enable-ci --enable-scart
endif

#NHD2_OPTS      += --enable-lua

ifeq ($(MEDIAFW), gstreamer)
#ifeq ($(MEDIAFW), $(filter $(MEDIAFW), gstreamer, gst-eplayer3))
NHD2_OPTS      += --enable-gstreamer
NHD2_OPTS      += --with-gstversion=1.0
NEUTRINO_DEPS2 += $(D)/gstreamer
NEUTRINO_DEPS2 += $(D)/gst_plugins_multibox_dvbmediasink
NEUTRINO_DEPS2 += $(D)/gst_plugins_good
NEUTRINO_DEPS2 += $(D)/gst_plugins_bad
NEUTRINO_DEPS2 += $(D)/gst_plugins_ugly
endif

ifeq ($(EXTERNAL_LCD), $(filter $(EXTERNAL_LCD), graphlcd, lcd4linux, both))
NHD2_OPTS     += --enable-lcd
endif

#NHD2_BRANCH   ?= master
#NHD2_CHECKOUT  = d2ec257482e841563ad8c29e1aa5253145e4bd21

#
# yaud-neutrino-hd2
#
yaud-neutrino-hd2: yaud-none $(D)/neutrino-hd2 $(D)/neutrino_release
	@echo "***************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-hd2 for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************"
	@touch $(D)/build_complete

#
# yaud-neutrino-hd2-plugins
#
yaud-neutrino-hd2-plugins: yaud-none $(D)/neutrino-hd2 $(D)/neutrino-hd2-plugin $(D)/neutrino_release
	@echo "*****************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-hd2-plugins for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "*****************************************************************************"
	@touch $(D)/build_complete

#
# neutrino-hd2
#
NEUTRINO_HD2_PATCHES =

$(D)/neutrino-hd2.do_prepare: | $(NEUTRINO_DEPS) $(NEUTRINO_DEPS2)
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/$(NEUTRINO)
	$(SILENT)rm -rf $(SOURCE_DIR)/$(NEUTRINO).org
	$(SILENT)rm -rf $(SOURCE_DIR)/$(NEUTRINO).git
	$(SILENT)if [ -d "$(ARCHIVE)/neutrino-hd2.git" ]; then \
			echo -n "Update local git..."; \
			cd $(ARCHIVE)/$(NEUTRINO).git; \
			git pull $(MINUS_Q); \
			echo " done."; \
		else \
			echo -n "Cloning git..."; \
			git clone $(MINUS_Q) -b $(N_BRANCH) $(GIT_URL).git $(ARCHIVE)/$(NEUTRINO).git; \
			echo " done."; \
		fi
	$(SILENT)if [ ! -d $(SOURCE_DIR) ]; then \
		mkdir -p $(SOURCE_DIR); \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/$(NEUTRINO).git $(SOURCE_DIR)/$(NEUTRINO).git
	$(SILENT)ln -sf $(SOURCE_DIR)/$(NEUTRINO).git/nhd2-exp $(SOURCE_DIR)/$(NEUTRINO)
	$(SILENT)echo -n "Checking out commit $(N_CHECKOUT)..."
	$(SILENT)(cd $(SOURCE_DIR)/$(NEUTRINO); git checkout $(MINUS_Q) $(N_CHECKOUT))
	$(SILENT)echo " done."
	$(SILENT)cp -ra $(SOURCE_DIR)/$(NEUTRINO).git/nhd2-exp $(SOURCE_DIR)/$(NEUTRINO).org
	$(SET) -e; cd $(SOURCE_DIR)/$(NEUTRINO); \
		$(call apply_patches, $(N_PATCHES))
	@touch $@

$(SOURCE_DIR)/neutrino-hd2/config.status:
	cd $(SOURCE_DIR)/$(NEUTRINO); \
		./autogen.sh; \
		$(BUILDENV) \
		$(CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-silent-rules \
			--with-boxmodel=$(BOXTYPE) \
			--with-boxtype=$(BOXTYPE) \
			--with-datadir=/usr/share/tuxbox \
			--with-configdir=/var/tuxbox/config \
			--with-plugindir=/var/tuxbox/plugins \
			$(NHD2_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"

$(D)/neutrino-hd2.do_compile: $(SOURCE_DIR)/neutrino-hd2/config.status
	$(SILENT)cd $(SOURCE_DIR)/$(NEUTRINO); \
		$(MAKE) all
	@touch $@

$(D)/neutrino-hd2: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(START_BUILD)
	$(SILENT)make -C $(SOURCE_DIR)/$(NEUTRINO) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/.version
	$(SILENT)make $(TARGET_DIR)/.version
#	$(SILENT)touch $(D)/$(notdir $@)
	$(TOUCH)
	$(TUXBOX_CUSTOMIZE)

nhd2-clean \
neutrino-hd2-clean: neutrino-cdkroot-clean
	$(SILENT)rm -f $(D)/$(NEUTRINO)
	$(SILENT)rm -f $(D)/$(NEUTRINO).config.status
	cd $(SOURCE_DIR)/$(NEUTRINO); \
		$(MAKE) clean

nhd2-distclean \
neutrino-hd2-distclean: neutrino-cdkroot-clean
	$(SILENT)rm -f $(D)/$(NEUTRINO)*
#	$(SILENT)rm -f $(D)/neutrino-hd2-plugins*

################################################################################
neutrino-cdkroot-clean:
	[ -e $(TARGET_DIR)/usr/local/bin ] && cd $(TARGET_DIR)/usr/local/bin && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/local/share/iso-codes ] && cd $(TARGET_DIR)/usr/local/share/iso-codes && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/share/tuxbox/neutrino ] && cd $(TARGET_DIR)/usr/share/tuxbox/neutrino && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/usr/share/fonts ] && cd $(TARGET_DIR)/usr/share/fonts && find -name '*' -delete || true
	[ -e $(TARGET_DIR)/var/tuxbox ] && cd $(TARGET_DIR)/var/tuxbox && find -name '*' -delete || true

dual:
	$(SILENT)make nhd2
	$(SILENT)make neutrino-cdkroot-clean
	$(SILENT)make mp

dual-clean:
	$(SILENT)make nhd2-clean
	$(SILENT)make mp-clean

dual-distclean:
	$(SILENT)make nhd2-distclean
	$(SILENT)make mp-distclean
endif

PHONY += $(TARGET_DIR)/.version
PHONY += $(SOURCE_DIR)/$(NEUTRINO)/src/gui/version.h
