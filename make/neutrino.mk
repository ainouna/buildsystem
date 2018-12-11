#
# Makefile to build NEUTRINO
#
$(TARGET_DIR)/.version:
	$(SILENT)echo "imagename=Neutrino MP" > $@
	$(SILENT)echo "homepage=https://github.com/Audioniek" >> $@
	$(SILENT)echo "creator=$(MAINTAINER)" >> $@
	$(SILENT)echo "docs=https://github.com/Audioniek" >> $@
#	$(SILENT)echo "forum=https://github.com/Duckbox-Developers/neutrino-mp-cst-next" >> $@
	$(SILENT)echo "version=0200`date +%Y%m%d%H%M`" >> $@
	$(SILENT)echo "git=`git log | grep "^commit" | wc -l`" >> $@

NEUTRINO_DEPS  = $(D)/bootstrap $(KERNEL) $(D)/system-tools
NEUTRINO_DEPS += $(D)/ncurses $(LIRC) $(D)/libcurl
NEUTRINO_DEPS += $(D)/libpng $(D)/libjpeg $(D)/giflib $(D)/freetype
NEUTRINO_DEPS += $(D)/alsa_utils $(D)/ffmpeg
NEUTRINO_DEPS += $(D)/libfribidi $(D)/libsigc $(D)/libdvbsi $(D)/libusb
NEUTRINO_DEPS += $(D)/pugixml $(D)/libopenthreads
NEUTRINO_DEPS += $(D)/lua $(D)/luaexpat $(D)/luacurl $(D)/luasocket $(D)/luafeedparser $(D)/luasoap $(D)/luajson
NEUTRINO_DEPS += $(LOCAL_NEUTRINO_DEPS)

ifeq ($(NEUTRINO_VARIANT), mp-tangos + plugins + shairport)
NEUTRINO_DEPS += $(D)/avahi
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), atevio7500 spark spark7162 ufs912 ufs913 ufs910))
NEUTRINO_DEPS += $(D)/ntfs_3g
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910))
NEUTRINO_DEPS += $(D)/parted
NEUTRINO_DEPS += $(D)/mtd_utils
NEUTRINO_DEPS += $(D)/gptfdisk
endif
#NEUTRINO_DEPS +=  $(D)/minidlna
endif

ifeq ($(IMAGE), neutrino-wlandriver)
NEUTRINO_DEPS += $(D)/wpa_supplicant $(D)/wireless_tools
endif

NEUTRINO_DEPS2 = $(D)/libid3tag $(D)/libmad $(D)/flac

N_CFLAGS       = -Wall -W -Wshadow -pipe -Os
N_CFLAGS      += -D__KERNEL_STRICT_NAMES
N_CFLAGS      += -D__STDC_FORMAT_MACROS
N_CFLAGS      += -D__STDC_CONSTANT_MACROS
N_CFLAGS      += -fno-strict-aliasing -funsigned-char -ffunction-sections -fdata-sections
#N_CFLAGS      += -DCPU_FREQ
N_CFLAGS      += $(LOCAL_NEUTRINO_CFLAGS)

N_CPPFLAGS     = -I$(TARGET_DIR)/usr/include
N_CPPFLAGS    += -ffunction-sections -fdata-sections

N_CPPFLAGS    += -I$(DRIVER_DIR)/bpamem
N_CPPFLAGS    += -I$(KERNEL_DIR)/include

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
N_CPPFLAGS += -I$(DRIVER_DIR)/frontcontroller/aotom_spark
endif

LH_CONFIG_OPTS =
ifeq ($(MEDIAFW), gstreamer)
NEUTRINO_DEPS  += $(D)/gst_plugins_dvbmediasink
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
N_CPPFLAGS     += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
LH_CONFIG_OPTS += --enable-gstreamer_10=yes
endif

N_CONFIG_OPTS  = $(LOCAL_NEUTRINO_BUILD_OPTIONS)
ifeq ($(FLAVOUR), neutrino-mp-ni)
N_CONFIG_OPTS += --with-boxtype=armbox
N_CONFIG_OPTS += --with-boxmodel=hd51
else
N_CONFIG_OPTS += --with-boxtype=$(BOXTYPE)
endif
N_CONFIG_OPTS += --enable-freesatepg
#N_CONFIG_OPTS += --enable-pip
#N_CONFIG_OPTS += --disable-webif
#N_CONFIG_OPTS += --disable-upnp
#N_CONFIG_OPTS += --disable-tangos

ifeq ($(FLAVOUR), neutrino-mp-max)
GIT_URL      = https://bitbucket.org/max_10
NEUTRINO_MP  = neutrino-mp-max
LIBSTB_HAL   = libstb-hal-max
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_MP_MAX_PATCHES)
HAL_PATCHES  = $(NEUTRINO_MP_LIBSTB_MAX_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-mp-tangos)
GIT_URL      = https://github.com/TangoCash
NEUTRINO_MP  = neutrino-mp-tangos
LIBSTB_HAL   = libstb-hal-tangos
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_MP_TANGOS_PATCHES)
HAL_PATCHES  = $(NEUTRINO_MP_LIBSTB_TANGOS_PATCHES)
else ifeq  ($(FLAVOUR), neutrino-mp-ddt)
GIT_URL      = https://github.com/Duckbox-Developers
NEUTRINO_MP  = neutrino-mp-ddt
LIBSTB_HAL   = libstb-hal-ddt
NMP_BRANCH  ?= master
HAL_BRANCH  ?= master
NMP_PATCHES  = $(NEUTRINO_MP_DDT_PATCHES)
HAL_PATCHES  = $(NEUTRINO_MP_LIBSTB_DDT_PATCHES)
endif

N_OBJDIR = $(BUILD_TMP)/$(NEUTRINO_MP)
LH_OBJDIR = $(BUILD_TMP)/$(LIBSTB_HAL)

################################################################################
#
# libstb-hal
#

$(D)/libstb-hal.do_prepare:
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL)
	$(SILENT)rm -rf $(SOURCE_DIR)/$(LIBSTB_HAL).org
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)test -d $(SOURCE_DIR) || mkdir -p $(SOURCE_DIR)
	$(SILENT)if [ -d "$(ARCHIVE)/$(LIBSTB_HAL).git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/$(LIBSTB_HAL).git; \
		git pull -q; \
		cd "$(BUILD_TMP)"; \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q $(GIT_URL)/$(LIBSTB_HAL).git $(ARCHIVE)/libstb-hal-ddt.git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/$(LIBSTB_HAL).git $(SOURCE_DIR)/$(LIBSTB_HAL)
	$(SILENT)(cd $(SOURCE_DIR)/$(LIBSTB_HAL); git checkout -q $(HAL_BRANCH);)
	$(SILENT)cp -ra $(SOURCE_DIR)/$(LIBSTB_HAL) $(SOURCE_DIR)/$(LIBSTB_HAL).org
	$(SET) -e; cd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		$(call apply_patches, $(HAL_PATCHES))
	@touch $@

$(D)/libstb-hal.config.status: | $(NEUTRINO_DEPS)
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	$(SILENT)cd $(LH_OBJDIR); \
		test -d $(SOURCE_DIR)/$(LIBSTB_HAL)/m4 || mkdir -p $(SOURCE_DIR)/$(LIBSTB_HAL)/m4; \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(LIBSTB_HAL)/configure  $(SILENT_CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared=no \
			\
			--with-target=cdk \
			--with-targetprefix=/usr \
			--with-boxtype=$(BOXTYPE) \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(D)/libstb-hal.do_compile: $(D)/libstb-hal.config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal: $(D)/libstb-hal.do_prepare $(D)/libstb-hal.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libstb-hal.la
	$(TOUCH)

libstb-hal-clean:
	$(SILENT)rm -f $(D)/libstb-hal
	$(SILENT)rm -f $(D)/libstb-hal.config.status
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-distclean:
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)rm -f $(D)/libstb-hal*

################################################################################
#
# neutrino-mp
#
$(D)/neutrino-mp-plugins.do_prepare \
$(D)/neutrino-mp.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal
	$(START_BUILD)
	$(SILENT)echo "Building variant: $(FLAVOUR), plugins = $(PLUGINS_NEUTRINO)"
	$(SILENT)rm -rf $(SOURCE_DIR)/$(NEUTRINO_MP)
	$(SILENT)rm -rf $(SOURCE_DIR)/$(NEUTRINO_MP).org
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)if [ -d "$(ARCHIVE)/$(NEUTRINO_MP).git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/$(NEUTRINO_MP).git; \
		git pull -q; \
		cd "$(BUILD_TMP)"; \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q $(GIT_URL)/$(NEUTRINO_MP).git $(ARCHIVE)/$(NEUTRINO_MP).git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/$(NEUTRINO_MP).git $(SOURCE_DIR)/$(NEUTRINO_MP)
	$(SILENT)cd $(SOURCE_DIR)/$(NEUTRINO_MP)
	$(SILENT)git checkout -q $(NMP_BRANCH)
	$(SILENT)cp -ra $(SOURCE_DIR)/$(NEUTRINO_MP) $(SOURCE_DIR)/$(NEUTRINO_MP).org
	$(SET) -e; cd $(SOURCE_DIR)/$(NEUTRINO_MP); \
		$(call apply_patches, $(NMP_PATCHES))
	@touch $@

$(D)/neutrino-mp.config.status \
$(D)/neutrino-mp-plugins.config.status:
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/$(NEUTRINO_MP)/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/$(NEUTRINO_MP)/configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix=/usr \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--enable-ffmpegdec \
			--enable-fribidi \
			--enable-giflib \
			--enable-lua \
			--enable-pugixml \
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
		+make $(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h
	@touch $@

$(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h:
	$(SILENT)rm -f $@
	echo '#define BUILT_DATE "'`date`'"' > $@
	$(SILENT)if test -d $(SOURCE_DIR)/$(LIBSTB_HAL); then \
		pushd $(SOURCE_DIR)/$(LIBSTB_HAL); \
		HAL_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(SOURCE_DIR)/$(NEUTRINO_MP); \
		NMP_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(BASE_DIR); \
		BS_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		echo '#define VCS "BS-rev'$$BS_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@; \
	fi

$(D)/neutrino-mp-plugins.do_compile \
$(D)/neutrino-mp.do_compile:
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

mp \
neutrino-mp: $(D)/neutrino-mp.do_prepare $(D)/neutrino-mp.config.status $(D)/neutrino-mp.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)make $(TARGET_DIR)/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "******************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of $(NEUTRINO_MP) for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "******************************************************************************"
	@touch $(D)/build_complete

mp-clean \
neutrino-mp-clean: neutrino-cdkroot-clean
	$(SILENT)rm -f $(D)/neutrino-mp
	$(SILENT)rm -f $(D)/neutrino-mp.config.status
	$(SILENT)rm -f $(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

mp-distclean \
neutrino-mp-distclean: neutrino-cdkroot-clean
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)rm -f $(D)/neutrino-mp*

mpp \
neutrino-mp-plugins: $(D)/neutrino-mp-plugins.do_prepare $(D)/neutrino-mp-plugins.config.status $(D)/neutrino-mp-plugins.do_compile
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(MAKE) $(TARGET_DIR)/.version
	make $(NEUTRINO_PLUGINS)
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "***************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of $(NEUTRINO_MP) for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************************"
	@touch $(D)/build_complete

mpp-clean \
neutrino-mp-plugins-clean: neutrino-cdkroot-clean
	$(SILENT)rm -f $(D)/neutrino-mp-plugins
	$(SILENT)rm -f $(D)/neutrino-mp-plugins.config.status
	$(SILENT)rm -f $(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h
	$(SILENT)make neutrino-mp-plugin-clean
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

mpp-distclean \
neutrino-mp-plugins-distclean: neutrino-cdkroot-clean
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)rm -f $(D)/neutrino-mp-plugins*
	make neutrino-mp-plugin-distclean

################################################################################
#
# neutrino-hd2
#
ifeq ($(BOXTYPE), spark)
NHD2_OPTS = --enable-4digits --enable-scart
else ifeq ($(BOXTYPE), spark7162)
NHD2_OPTS = --enable-scart
#else ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hs7119, hs7810a, hs7819))
#NHD2_OPTS = --enable-ci --enable-4digits
else
NHD2_OPTS = --enable-ci --enable-scart
endif

#
# neutrino-hd2
#
NEUTRINO_HD2_PATCHES =

$(D)/neutrino-hd2.do_prepare: | $(NEUTRINO_DEPS) $(NEUTRINO_DEPS2)
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-hd2
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-hd2.org
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-hd2.git
	$(SILENT)if [ -d "$(ARCHIVE)/neutrino-hd2.git" ]; then \
			echo -n "Update local git..."; \
			cd $(ARCHIVE)/neutrino-hd2.git; \
			git pull -q; \
			echo " done."; \
		else \
			echo -n "Cloning git..."; \
			git clone -q https://github.com/mohousch/neutrinohd2.git $(ARCHIVE)/neutrino-hd2.git; \
			echo " done."; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/neutrino-hd2.git $(SOURCE_DIR)/neutrino-hd2.git
	$(SILENT)ln -s $(SOURCE_DIR)/neutrino-hd2.git/nhd2-exp $(SOURCE_DIR)/neutrino-hd2
	$(SILENT)cp -ra $(SOURCE_DIR)/neutrino-hd2.git/nhd2-exp $(SOURCE_DIR)/neutrino-hd2.org
	$(SET) -e; cd $(SOURCE_DIR)/neutrino-hd2; \
		$(call apply_patches, $(NEUTRINO_HD2_PATCHES))
	@touch $@

$(D)/neutrino-hd2.config.status:
	cd $(SOURCE_DIR)/neutrino-hd2; \
		./autogen.sh; \
		$(BUILDENV) \
		$(CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-silent-rules \
			--with-boxtype=$(BOXTYPE) \
			--with-datadir=/usr/share/tuxbox \
			--with-configdir=/var/tuxbox/config \
			--with-plugindir=/var/tuxbox/plugins \
			$(NHD2_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrino-hd2.do_compile: $(D)/neutrino-hd2.config.status
	$(SILENT)cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) all
	@touch $@

neutrino-hd2: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(START_BUILD)
	$(SILENT)make -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/.version
	$(SILENT)make $(TARGET_DIR)/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "*********************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-hd2 for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "*********************************************************************"
	@touch $(D)/build_complete

nhd2 \
neutrino-hd2-plugins: $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(START_BUILD)
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/.version
	$(MAKE) $(TARGET_DIR)/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-hd2-plugins.build
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "********************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-hd2 with plugins for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "********************************************************************************"
	@touch $(D)/build_complete

nhd2-clean \
neutrino-hd2-clean: neutrino-cdkroot-clean
	$(SILENT)rm -f $(D)/neutrino-hd2
	$(SILENT)rm -f $(D)/neutrino-hd2.config.status
	cd $(SOURCE_DIR)/neutrino-hd2; \
		$(MAKE) clean

nhd2-distclean \
neutrino-hd2-distclean: neutrino-cdkroot-clean
	$(SILENT)rm -f $(D)/neutrino-hd2*
	$(SILENT)rm -f $(D)/neutrino-hd2-plugins*

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

PHONY += $(TARGET_DIR)/.version
PHONY += $(SOURCE_DIR)/$(NEUTRINO_MP)/src/gui/version.h
