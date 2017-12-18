#
# Makefile to build NEUTRINO
#
$(TARGET_DIR)/var/etc/.version:
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

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), atevio7500 spark spark7162 ufs912 ufs913 ufs910))
NEUTRINO_DEPS += $(D)/ntfs_3g
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910))
NEUTRINO_DEPS += $(D)/mtd_utils $(D)/parted
endif
#NEUTRINO_DEPS +=  $(D)/minidlna
endif

ifeq ($(BOXARCH), arm)
NEUTRINO_DEPS += $(D)/ntfs_3g
NEUTRINO_DEPS += $(D)/mc
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
ifeq ($(MEDIAFW), gstreamer)
NEUTRINO_DEPS += $(D)/gst_plugins_dvbmediasink
N_CPPFLAGS    += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
N_CPPFLAGS    += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
N_CPPFLAGS    += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
N_CPPFLAGS    += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
ifeq ($(BOXARCH), arm)
LH_CONFIG_OPTS  = --enable-gstreamer_10=yes
endif

N_CPPFLAGS    += -I$(CROSS_BASE)/$(TARGET)/sys-root/usr/include
endif
ifeq ($(BOXARCH), sh4)
N_CPPFLAGS    += -I$(DRIVER_DIR)/bpamem
N_CPPFLAGS    += -I$(KERNEL_DIR)/include
endif
N_CPPFLAGS    += -ffunction-sections -fdata-sections

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
N_CPPFLAGS += -I$(DRIVER_DIR)/frontcontroller/aotom_spark
endif

N_CONFIG_OPTS  = $(LOCAL_NEUTRINO_BUILD_OPTIONS)
N_CONFIG_OPTS += --enable-freesatepg
N_CONFIG_OPTS += --enable-lua
N_CONFIG_OPTS += --enable-giflib
N_CONFIG_OPTS += --with-tremor
N_CONFIG_OPTS += --enable-ffmpegdec
#N_CONFIG_OPTS += --enable-pip
#N_CONFIG_OPTS += --disable-webif
#N_CONFIG_OPTS += --disable-upnp
#N_CONFIG_OPTS += --disable-tangos
N_CONFIG_OPTS += --enable-pugixml
ifeq ($(BOXARCH), arm)
N_CONFIG_OPTS += --enable-reschange
endif

N_CONFIG_OPTS += \
	--with-boxtype=$(BOXTYPE) \
	--with-libdir=/usr/lib \
	--with-datadir=/usr/share/tuxbox \
	--with-fontdir=/usr/share/fonts \
	--with-configdir=/var/tuxbox/config \
	--with-gamesdir=/var/tuxbox/games \
	--with-iconsdir=/usr/share/tuxbox/neutrino/icons \
	--with-iconsdir_var=/var/tuxbox/icons \
	--with-localedir=/usr/share/tuxbox/neutrino/locale \
	--with-localedir_var=/var/tuxbox/locale \
	--with-plugindir=/var/tuxbox/plugins \
	--with-plugindir_var=/var/tuxbox/plugins \
	--with-luaplugindir=/var/tuxbox/plugins \
	--with-private_httpddir=/usr/share/tuxbox/neutrino/httpd \
	--with-public_httpddir=/var/tuxbox/httpd \
	--with-themesdir=/usr/share/tuxbox/neutrino/themes \
	--with-themesdir_var=/var/tuxbox/themes \
	--with-webtvdir=/share/tuxbox/neutrino/webtv \
	--with-webtvdir_var=/var/tuxbox/plugins/webtv \
	PKG_CONFIG=$(PKG_CONFIG) \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"

OBJDIR = $(BUILD_TMP)
N_OBJDIR = $(OBJDIR)/neutrino-mp
LH_OBJDIR = $(OBJDIR)/libstb-hal

################################################################################
#
# libstb-hal-ddt
#
NEUTRINO_MP_LIBSTB_DDT_PATCHES =

$(D)/libstb-hal-ddt.do_prepare:
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/libstb-hal-ddt
	$(SILENT)rm -rf $(SOURCE_DIR)/libstb-hal-ddt.org
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)if [ -d "$(ARCHIVE)/libstb-hal-ddt.git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/libstb-hal-ddt.git; \
		git pull -q; \
		cd "$(BUILD_TMP)"; \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q https://github.com/Duckbox-Developers/libstb-hal-ddt.git $(ARCHIVE)/libstb-hal-ddt.git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/libstb-hal-ddt.git $(SOURCE_DIR)/libstb-hal-ddt
	$(SILENT)cp -ra $(SOURCE_DIR)/libstb-hal-ddt $(SOURCE_DIR)/libstb-hal-ddt.org
	$(SET) -e; cd $(SOURCE_DIR)/libstb-hal-ddt; \
		$(call post_patch,$(NEUTRINO_MP_LIBSTB_DDT_PATCHES))
	@touch $@

$(D)/libstb-hal-ddt.config.status: | $(NEUTRINO_DEPS)
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	$(SILENT)cd $(LH_OBJDIR); \
		test -d $(SOURCE_DIR)/libstb-hal-ddt/m4 || mkdir -p $(SOURCE_DIR)/libstb-hal-ddt/m4; \
		$(SOURCE_DIR)/libstb-hal-ddt/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/libstb-hal-ddt/configure  $(SILENT_CONFIGURE) \
			--enable-silent-rules \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(D)/libstb-hal-ddt.do_compile: $(D)/libstb-hal-ddt.config.status
	$(SILENT)cd $(SOURCE_DIR)/libstb-hal-ddt; \
		$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal-ddt: $(D)/libstb-hal-ddt.do_prepare $(D)/libstb-hal-ddt.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

libstb-hal-ddt-clean:
	$(SILENT)rm -f $(D)/libstb-hal-ddt
	$(SILENT)rm -f $(D)/libstb-hal-ddt.config.status
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-ddt-distclean:
	$(SILENT)rm -f $(D)/libstb-hal-ddt*

################################################################################
#
# neutrino-mp-ddt
#
NEUTRINO_MP_DDT_PATCHES =

$(D)/neutrino-mp-ddt.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal-ddt
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-mp-ddt
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-mp-ddt.org
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)if [ -d "$(ARCHIVE)/neutrino-mp-ddt.git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/neutrino-mp-ddt.git; \
		git pull -q; \
		cd "$(BUILD_TMP)"; \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q https://github.com/Duckbox-Developers/neutrino-mp-ddt.git $(ARCHIVE)/neutrino-mp-ddt.git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/neutrino-mp-ddt.git $(SOURCE_DIR)/neutrino-mp-ddt
	$(SILENT)cp -ra $(SOURCE_DIR)/neutrino-mp-ddt $(SOURCE_DIR)/neutrino-mp-ddt.org
	$(SET) -e; cd $(SOURCE_DIR)/neutrino-mp-ddt; \
		$(call post_patch,$(NEUTRINO_MP_DDT_PATCHES))
	@touch $@

$(D)/neutrino-mp-ddt.config.status:
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/neutrino-mp-ddt/autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-mp-ddt/configure $(SILENT_CONFIGURE) \
			--enable-silent-rules \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--with-stb-hal-includes=$(SOURCE_DIR)/libstb-hal-ddt/include \
			--with-stb-hal-build=$(LH_OBJDIR)
	@touch $@

$(SOURCE_DIR)/neutrino-mp-ddt/src/gui/version.h:
	$(SILENT)rm -f $@
	$(SILENT)echo '#define BUILT_DATE "'`date`'"' > $@
	$(SILENT)if test -d $(SOURCE_DIR)/libstb-hal-ddt; then \
		pushd $(SOURCE_DIR)/libstb-hal-ddt; \
		HAL_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(SOURCE_DIR)/neutrino-mp-ddt; \
		NMP_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(BASE_DIR); \
		DDT_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@; \
	fi

$(D)/neutrino-mp-ddt.do_compile: $(D)/neutrino-mp-ddt.config.status $(SOURCE_DIR)/neutrino-mp-ddt/src/gui/version.h
	$(SILENT)cd $(SOURCE_DIR)/neutrino-mp-ddt; \
		$(MAKE) -C $(N_OBJDIR) all
	@touch $@

neutrino-mp-ddt: yaud-none $(D)/neutrino-mp-ddt.do_prepare $(D)/neutrino-mp-ddt.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(SILENT)make $(TARGET_DIR)/var/etc/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "***************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-mp-ddt for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************************"
	@touch $(D)/build_complete

mp \
neutrino-mp-ddt-plugins: yaud-none $(D)/neutrino-mp-ddt.do_prepare $(D)/neutrino-mp-ddt.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(SILENT)make $(TARGET_DIR)/var/etc/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-plugins
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "*****************************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-mp-ddt with plugins for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "*****************************************************************************************"
	@touch $(D)/build_complete

mp-clean \
neutrino-mp-ddt-clean: neutrino-cdkroot-clean
	$(SILENT)rm -f $(D)/neutrino-mp-ddt
	$(SILENT)rm -f $(D)/neutrino-mp-ddt.config.status
	$(SILENT)rm -f $(SOURCE_DIR)/neutrino-mp-ddt/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

mp-distclean \
neutrino-mp-ddt-distclean: neutrino-cdkroot-clean
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)rm -f $(D)/neutrino-mp-ddt*

################################################################################
ifeq ($(BOXARCH), arm)
################################################################################
#
# libstb-hal-ni
#
NEUTRINO_MP_LIBSTB_NI_PATCHES =

$(D)/libstb-hal-ni.do_prepare:
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/libstb-hal-ni
	$(SILENT)rm -rf $(SOURCE_DIR)/libstb-hal-ni.org
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)if [ -d "$(ARCHIVE)/libstb-hal-ni.git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/libstb-hal-ni.git; \
		git pull -q; \
		cd "$(BUILD_TMP)"; \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q https://bitbucket.org/neutrino-images/ni-libstb-hal-next.git $(ARCHIVE)/libstb-hal-ni.git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/libstb-hal-ni.git $(SOURCE_DIR)/libstb-hal-ni
	$(SILENT)cp -ra $(SOURCE_DIR)/libstb-hal-ni $(SOURCE_DIR)/libstb-hal-ni.org
	$(SET) -e; cd $(SOURCE_DIR)/libstb-hal-ni; \
		$(call post_patch,$(NEUTRINO_MP_LIBSTB_NI_PATCHES))
	@touch $@

$(D)/libstb-hal-ni.config.status: | $(NEUTRINO_DEPS)
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	$(SILENT)cd $(LH_OBJDIR); \
		test -d $(SOURCE_DIR)/libstb-hal-ni/m4 || mkdir -p $(SOURCE_DIR)/libstb-hal-ni/m4; \
		$(SOURCE_DIR)/libstb-hal-ni/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/libstb-hal-ni/configure $(SILENT_CONFIGURE) \
			--enable-silent-rules \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(D)/libstb-hal-ni.do_compile: $(D)/libstb-hal-ni.config.status
	$(SILENT)cd $(SOURCE_DIR)/libstb-hal-ni; \
		$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal-ni: $(D)/libstb-hal-ni.do_prepare $(D)/libstb-hal-ni.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

libstb-hal-ni-clean:
	$(SILENT)rm -f $(D)/libstb-hal-ni
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-ni-distclean:
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)rm -f $(D)/libstb-hal-ni*

################################################################################
#
# neutrino-mp-ni
#
NEUTRINO_MP_NI_PATCHES =

$(D)/neutrino-mp-ni.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal-ni
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-mp-ni
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-mp-ni.org
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)if [ -d "$(ARCHIVE)/neutrino-mp-ni.git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/neutrino-mp-ni.git; \
		git pull -q; \
		cd "$(BUILD_TMP)"; \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q -b ni/mp/tuxbox https://bitbucket.org/neutrino-images/ni-neutrino-hd.git $(ARCHIVE)/neutrino-mp-ni.git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/neutrino-mp-ni.git $(SOURCE_DIR)/neutrino-mp-ni
	$(SILENT)cp -ra $(SOURCE_DIR)/neutrino-mp-ni $(SOURCE_DIR)/neutrino-mp-ni.org
	$(SET) -e; cd $(SOURCE_DIR)/neutrino-mp-ni; \
		$(call post_patch,$(NEUTRINO_MP_NI_PATCHES))
	@touch $@

$(D)/neutrino-mp-ni.config.status:
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	$(SILENT)cd $(N_OBJDIR); \
		$(SOURCE_DIR)/neutrino-mp-ni/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-mp-ni/configure $(SILENT_CONFIGURE) \
			--enable-silent-rules \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--with-boxtype=armbox \
			--with-stb-hal-includes=$(SOURCE_DIR)/libstb-hal-ni/include \
			--with-stb-hal-build=$(LH_OBJDIR)
	@touch $@

$(SOURCE_DIR)/neutrino-mp-ni/src/gui/version.h:
	$(SILENT)rm -f $@
	$(SILENT)echo '#define BUILT_DATE "'`date`'"' > $@
	$(SILENT)if test -d $(SOURCE_DIR)/libstb-hal-ni; then \
		pushd $(SOURCE_DIR)/libstb-hal-ni; \
		HAL_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(SOURCE_DIR)/neutrino-mp-ni; \
		NMP_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(BASE_DIR); \
		DDT_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@; \
	fi

$(D)/neutrino-mp-ni.do_compile: $(D)/neutrino-mp-ni.config.status $(SOURCE_DIR)/neutrino-mp-ni/src/gui/version.h
	$(SILENT)cd $(SOURCE_DIR)/neutrino-mp-ni; \
		$(MAKE) -C $(N_OBJDIR) all
	@touch $@

neutrino-mp-ni: yaud-none $(D)/neutrino-mp-ni.do_prepare $(D)/neutrino-mp-ni.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)make $(TARGET_DIR)/var/etc/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "******************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-mp-ni for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "******************************************************************************"
	@touch $(D)/build_complete

neutrino-mp-ni-plugins: yaud-none $(D)/neutrino-mp-ni.do_prepare $(D)/neutrino-mp-ni.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)make $(TARGET_DIR)/var/etc/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-plugins
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "*******************************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-mp-ni with plugins for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "*******************************************************************************************"
	@touch $(D)/build_complete

neutrino-mp-ni-clean:
	$(SILENT)rm -f $(D)/neutrino-mp-ni
	$(SILENT)rm -f $(D)/neutrino-mp-ni.config.status
	$(SILENT)rm -f $(SOURCE_DIR)/neutrino-mp-ni/src/gui/version.h
	$(SILENT)cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-ni-distclean:
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)rm -f $(D)/neutrino-mp-ni*

################################################################################

endif

################################################################################
#
# libstb-hal-tangos
#
NEUTRINO_MP_LIBSTB_TANGOS_PATCHES =

$(D)/libstb-hal-tangos.do_prepare:
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/libstb-hal-tangos
	$(SILENT)rm -rf $(SOURCE_DIR)/libstb-hal-tangos.org
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)if [ -d "$(ARCHIVE)/libstb-hal-tangos.git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/libstb-hal-tangos.git; \
		git pull -q; \
		cd "$(BUILD_TMP)"; \
		echo "done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q https://github.com/TangoCash/libstb-hal-tangos.git $(ARCHIVE)/libstb-hal-tangos.git; \
		echo "done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/libstb-hal-tangos.git $(SOURCE_DIR)/libstb-hal-tangos
	$(SILENT)cp -ra $(SOURCE_DIR)/libstb-hal-tangos $(SOURCE_DIR)/libstb-hal-tangos.org
	$(SET) -e; cd $(SOURCE_DIR)/libstb-hal-tangos; \
		$(call post_patch,$(NEUTRINO_MP_LIBSTB_TANGOS_PATCHES))
	@touch $@

$(D)/libstb-hal-tangos.config.status: | $(NEUTRINO_DEPS)
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	$(SILENT)cd $(LH_OBJDIR); \
		test -d $(SOURCE_DIR)/libstb-hal-tangos/m4 || mkdir -p $(SOURCE_DIR)/libstb-hal-tangos/m4; \
		$(SOURCE_DIR)/libstb-hal-tangos/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/libstb-hal-tangos/configure $(SILENT_CONFIGURE) \
			--enable-silent-rules \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(D)/libstb-hal-tangos.do_compile: $(D)/libstb-hal-tangos.config.status
	$(SILENT)cd $(SOURCE_DIR)/libstb-hal-tangos; \
		$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal-tangos: $(D)/libstb-hal-tangos.do_prepare $(D)/libstb-hal-tangos.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

libstb-hal-tangos-clean:
	$(SILENT)rm -f $(D)/libstb-hal-tangos
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-tangos-distclean:
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)rm -f $(D)/libstb-hal-tangos*

################################################################################
#
# neutrino-mp-tangos
#
NEUTRINO_MP_TANGOS_PATCHES =

$(D)/neutrino-mp-tangos.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal-tangos
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-mp-tangos
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-mp-tangos.org
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)if [ -d "$(ARCHIVE)/neutrino-mp-tangos.git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/neutrino-mp-tangos.git; \
		git pull -q; \
		cd "$(BUILD_TMP)"; \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q https://github.com/TangoCash/neutrino-mp-tangos.git $(ARCHIVE)/neutrino-mp-tangos.git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/neutrino-mp-tangos.git $(SOURCE_DIR)/neutrino-mp-tangos
	$(SILENT)cp -ra $(SOURCE_DIR)/neutrino-mp-tangos $(SOURCE_DIR)/neutrino-mp-tangos.org
	$(SET) -e; cd $(SOURCE_DIR)/neutrino-mp-tangos; \
		$(call post_patch,$(NEUTRINO_MP_TANGOS_PATCHES))
	@touch $@

$(D)/neutrino-mp-tangos.config.status:
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	$(SILENT)cd $(N_OBJDIR); \
		$(SOURCE_DIR)/neutrino-mp-tangos/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-mp-tangos/configure  $(SILENT_CONFIGURE) \
			--enable-silent-rules \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--enable-freesatepg \
			--enable-fastscan \
			--with-stb-hal-includes=$(SOURCE_DIR)/libstb-hal-tangos/include \
			--with-stb-hal-build=$(LH_OBJDIR)

$(SOURCE_DIR)/neutrino-mp-tangos/src/gui/version.h:
	$(SILENT)rm -f $@
	$(SILENT)echo '#define BUILT_DATE "'`date`'"' > $@
	$(SILENT)if test -d $(SOURCE_DIR)/libstb-hal-tangos; then \
		pushd $(SOURCE_DIR)/libstb-hal-tangos; \
		HAL_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(SOURCE_DIR)/neutrino-mp-tangos; \
		NMP_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(BASE_DIR); \
		DDT_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'-next_NMP-rev'$$NMP_REV'-tangos"' >> $@; \
	fi

$(D)/neutrino-mp-tangos.do_compile: $(D)/neutrino-mp-tangos.config.status $(SOURCE_DIR)/neutrino-mp-tangos/src/gui/version.h
	$(SILENT)cd $(SOURCE_DIR)/neutrino-mp-tangos; \
		$(MAKE) -C $(N_OBJDIR) all
	@touch $@

#
# neutrino-mp-tangos
#
neutrino-mp-tangos: yaud-none $(D)/neutrino-mp-tangos.do_prepare $(D)/neutrino-mp-tangos.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(SILENT)make $(TARGET_DIR)/var/etc/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "***************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-mp-tangos for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************************"
	@touch $(D)/build_complete

neutrino-mp-tangos-all: yaud-none $(D)/neutrino-mp-tangos.do_prepare $(D)/neutrino-mp-tangos.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(SILENT)make $(TARGET_DIR)/var/etc/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make shairport
	$(SILENT)make neutrino-plugins
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "***************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-mp-tangos-all for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************************"
	@touch $(D)/build_complete

neutrino-mp-tangos-plugins: yaud-none $(D)/neutrino-mp-tangos.do_prepare $(D)/neutrino-mp-tangos.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(MAKE) $(TARGET_DIR)/var/etc/.version
	$(SILENT)touch $(D)/$(notdir $@)
	$(SILENT)make neutrino-plugins
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "***************************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-mp-tangos with plugins for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************************************"
	@touch $(D)/build_complete

neutrino-mp-tangos-clean:
	$(SILENT)rm -f $(D)/neutrino-mp-tangos
	$(SILENT)rm -f $(SOURCE_DIR)/neutrino-mp-tangos/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-tangos-distclean:
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)rm -f $(D)/neutrino-mp-tangos*

################################################################################
#
# libstb-hal-max
#
NEUTRINO_LIBSTB_MAX_PATCHES =

$(D)/libstb-hal-max.do_prepare:
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/libstb-hal-max
	$(SILENT)rm -rf $(SOURCE_DIR)/libstb-hal-max.org
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)if [ -d "$(ARCHIVE)/libstb-hal-max.git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/libstb-hal-max.git; \
		git pull -q; cd "$(BUILD_TMP)"; \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q https://bitbucket.org/max_10/libstb-hal-max.git $(ARCHIVE)/libstb-hal-max.git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/libstb-hal-max.git $(SOURCE_DIR)/libstb-hal-max
	$(SILENT)cp -ra $(SOURCE_DIR)/libstb-hal-max $(SOURCE_DIR)/libstb-hal-max.org
	$(SET) -e; cd $(SOURCE_DIR)/libstb-hal-max; \
		$(call post_patch,$(NEUTRINO_LIBSTB_MAX_PATCHES))
	@touch $@

$(D)/libstb-hal-max.config.status: | $(NEUTRINO_DEPS)
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)test -d $(LH_OBJDIR) || mkdir -p $(LH_OBJDIR)
	$(SILENT)cd $(LH_OBJDIR); \
		test -d $(SOURCE_DIR)/libstb-hal-max/m4 || mkdir -p $(SOURCE_DIR)/libstb-hal-max/m4; \
		$(SOURCE_DIR)/libstb-hal-max/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/libstb-hal-max/configure  $(SILENT_CONFIGURE) \
			--enable-silent-rules \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			$(LH_CONFIG_OPTS) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CFLAGS="$(N_CFLAGS)" CXXFLAGS="$(N_CFLAGS)" CPPFLAGS="$(N_CPPFLAGS)"
	@touch $@

$(D)/libstb-hal-max.do_compile: $(D)/libstb-hal-max.config.status
	$(SILENT)cd $(SOURCE_DIR)/libstb-hal-max; \
		$(MAKE) -C $(LH_OBJDIR) all DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/libstb-hal-max: $(D)/libstb-hal-max.do_prepare $(D)/libstb-hal-max.do_compile
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

libstb-hal-max-clean:
	$(SILENT)rm -f $(D)/libstb-hal-max
	cd $(LH_OBJDIR); \
		$(MAKE) -C $(LH_OBJDIR) distclean

libstb-hal-max-distclean:
	$(SILENT)rm -rf $(LH_OBJDIR)
	$(SILENT)rm -f $(D)/libstb-hal-max*

################################################################################
#
# neutrino-mp-max
#
NEUTRINO_MP_MAX_PATCHES =

$(D)/neutrino-mp-max.do_prepare: | $(NEUTRINO_DEPS) $(D)/libstb-hal-max
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-mp-max
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-mp-max.org
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)if [ -d "$(ARCHIVE)/neutrino-mp-max.git" ]; then \
		echo -n "Update local git..."; \
		cd $(ARCHIVE)/neutrino-mp-max.git; \
		git pull -q; \
		cd "$(BUILD_TMP)"; \
		echo " done."; \
	else \
		echo -n "Cloning git..."; \
		git clone -q https://bitbucket.org/max_10/neutrino-mp-max.git $(ARCHIVE)/neutrino-mp-max.git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/neutrino-mp-max.git $(SOURCE_DIR)/neutrino-mp-max
	$(SILENT)cp -ra $(SOURCE_DIR)/neutrino-mp-max $(SOURCE_DIR)/neutrino-mp-max.org
	$(SET) -e; cd $(SOURCE_DIR)/neutrino-mp-max; \
		$(call post_patch,$(NEUTRINO_MP_MAX_PATCHES))
	@touch $@

$(D)/neutrino-mp-max.config.status:
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR); \
	cd $(N_OBJDIR); \
		$(SOURCE_DIR)/neutrino-mp-max/autogen.sh; \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-mp-max/configure  $(SILENT_CONFIGURE) \
			--enable-silent-rules \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(N_CONFIG_OPTS) \
			--with-stb-hal-includes=$(SOURCE_DIR)/libstb-hal-max/include \
			--with-stb-hal-build=$(LH_OBJDIR)
		@touch $@

$(SOURCE_DIR)/neutrino-mp-max/src/gui/version.h:
	$(SILENT)rm -f $@
	$(SILENT)echo '#define BUILT_DATE "'`date`'"' > $@
	$(SILENT)if test -d $(SOURCE_DIR)/libstb-hal-max; then \
		pushd $(SOURCE_DIR)/libstb-hal-max; \
		HAL_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(SOURCE_DIR)/neutrino-mp-max; \
		NMP_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		pushd $(BASE_DIR); \
		DDT_REV=$$(git log | grep "^commit" | wc -l); \
		popd; \
		echo '#define VCS "DDT-rev'$$DDT_REV'_HAL-rev'$$HAL_REV'_NMP-rev'$$NMP_REV'"' >> $@ ; \
	fi

$(D)/neutrino-mp-max.do_compile: $(D)/neutrino-mp-max.config.status $(SOURCE_DIR)/neutrino-mp-max/src/gui/version.h
	$(SILENT)cd $(SOURCE_DIR)/neutrino-mp-max; \
		$(MAKE) -C $(N_OBJDIR) all
	@touch $@

neutrino-mp-max: yaud-none $(D)/neutrino-mp-max.do_prepare $(D)/neutrino-mp-max.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(MAKE) $(TARGET_DIR)/var/etc/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "***************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-mp-max for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************************"
	@touch $(D)/build_complete

neutrino-mp-max-plugins: yaud-none $(D)/neutrino-mp-max.do_prepare $(D)/neutrino-mp-max.do_compile
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(MAKE) $(TARGET_DIR)/var/etc/.version
	$(SILENT)touch $(D)/$(notdir $@)
#	$(TOUCH)
	$(SILENT)make neutrino-plugins
	$(SILENT)make neutrino-release
	$(TUXBOX_CUSTOMIZE)
	@echo "***************************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of neutrino-mp-max with plugins for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************************"
	@touch $(D)/build_complete

neutrino-mp-max-clean:
	$(SILENT)rm -f $(D)/neutrino-mp-max
	$(SILENT)rm -f $(SOURCE_DIR)/neutrino-mp-max/src/gui/version.h
	cd $(N_OBJDIR); \
		$(MAKE) -C $(N_OBJDIR) distclean

neutrino-mp-max-distclean:
	$(SILENT)rm -rf $(N_OBJDIR)
	$(SILENT)rm -f $(D)/neutrino-mp-max*

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
		$(call post_patch,$(NEUTRINO_HD2_PATCHES))
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

neutrino-hd2: yaud-none $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(START_BUILD)
	$(SILENT)make -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(SILENT)make $(TARGET_DIR)/var/etc/.version
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
neutrino-hd2-plugin: yaud-none  $(D)/neutrino-hd2.do_prepare $(D)/neutrino-hd2.do_compile
	$(START_BUILD)
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2 install DESTDIR=$(TARGET_DIR)
	$(SILENT)rm -f $(TARGET_DIR)/var/etc/.version
	$(MAKE) $(TARGET_DIR)/var/etc/.version
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

