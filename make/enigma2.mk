#
# enigma2
#
ENIGMA2_DEPS  = $(D)/bootstrap $(D)/opkg $(D)/ncurses $(LIRC) $(D)/libcurl $(D)/libid3tag $(D)/libmad
ENIGMA2_DEPS += $(D)/libpng $(D)/libjpeg $(D)/giflib $(D)/freetype
ENIGMA2_DEPS += $(D)/alsa_utils $(D)/ffmpeg
ENIGMA2_DEPS += $(D)/libfribidi $(D)/libsigc_e2 $(D)/expat $(D)/libdvbsi $(D)/libusb
ENIGMA2_DEPS += $(D)/sdparm $(D)/minidlna $(D)/ethtool
ENIGMA2_DEPS += python-all
ENIGMA2_DEPS += $(D)/libdreamdvd $(D)/enigma2_tuxtxt32bpp $(D)/enigma2_hotplug_e2_helper $(D)/parted
ENIGMA2_DEPS += $(LOCAL_ENIGMA2_DEPS)

ifeq ($(IMAGE), enigma2-wlandriver)
ENIGMA2_DEPS += $(D)/wpa_supplicant $(D)/wireless_tools
endif

ifeq ($(DESTINATION), USB)
ENIGMA2_DEPS += $(D)/busybox_usb
E_CONFIG_OPTS += --enable-run_from_usb
endif

ifeq ($(EXTERNAL_LCD), externallcd)
ENIGMA2_DEPS  += $(D)/graphlcd
E_CONFIG_OPTS += --with-graphlcd
endif

ifeq ($(EXTERNAL_LCD), lcd4linux)
ENIGMA2_DEPS += $(D)/lcd4linux
endif

ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 0 2))
ENIGMA2_DEPS  += $(D)/avahi
endif

ifeq ($(MEDIAFW), eplayer3)
ENIGMA2_DEPS  += $(D)/tools-eplayer3
E_CONFIG_OPTS += --enable-libeplayer3
endif

ifeq ($(MEDIAFW), gstreamer)
ENIGMA2_DEPS  += $(D)/gst_plugins_dvbmediasink
E_CONFIG_OPTS += --with-gstversion=1.0 --enable-mediafwgstreamer
endif

ifeq ($(MEDIAFW), gst-eplayer3)
ENIGMA2_DEPS  += $(D)/tools-libeplayer3
ENIGMA2_DEPS  += $(D)/gst_plugins_dvbmediasink
E_CONFIG_OPTS += --with-gstversion=1.0 --enable-libeplayer3 --enable-mediafwgstreamer
endif

ifeq ($(BOXTYPE),spark)
E_CONFIG_OPTS += --enable-spark
endif

ifeq ($(BOXTYPE),spark7162)
E_CONFIG_OPTS += --enable-spark7162
ENIGMA2_DEPS += ntp
endif

ifeq ($(BOXTYPE),fortis_hdbox)
E_CONFIG_OPTS += --enable-fortis_hdbox
endif

ifeq ($(BOXTYPE),octagon1008)
E_CONFIG_OPTS += --enable-octagon1008
endif

ifeq ($(BOXTYPE),atevio7500)
E_CONFIG_OPTS += --enable-atevio7500
endif

ifeq ($(BOXTYPE),hs7110)
E_CONFIG_OPTS += --enable-hs7110
endif

ifeq ($(BOXTYPE),hs7420)
E_CONFIG_OPTS += --enable-hs7420
endif

ifeq ($(BOXTYPE),hs7810a)
E_CONFIG_OPTS += --enable-hs7810a
endif

ifeq ($(BOXTYPE),hs7119)
E_CONFIG_OPTS += --enable-hs7119
endif

ifeq ($(BOXTYPE),hs7429)
E_CONFIG_OPTS += --enable-hs7429
endif

ifeq ($(BOXTYPE),hs7819)
E_CONFIG_OPTS += --enable-hs7819
endif

E_CONFIG_OPTS +=$(LOCAL_ENIGMA2_BUILD_OPTIONS)

E_CPPFLAGS    = -I$(DRIVER_DIR)/include
E_CPPFLAGS   += -I$(TARGET_DIR)/usr/include
E_CPPFLAGS   += -I$(KERNEL_DIR)/include
E_CPPFLAGS   += -I$(APPS_DIR)/tools/libeplayer3/include
E_CPPFLAGS   += -I$(APPS_DIR)/tools
E_CPPFLAGS   += $(LOCAL_ENIGMA2_CPPFLAGS)
E_CPPFLAGS   += $(PLATFORM_CPPFLAGS)

ifeq ($(BOXTYPE), tf7700)
YAUD_ENIGMA2_DEPS = $(D)/uboot_tf7700 $(D)/u-boot.ftfd $(D)/tfinstaller
endif

#
# yaud-enigma2
#
yaud-enigma2: yaud-none $(D)/enigma2 $(D)/enigma2-plugins $(D)/enigma2_release
	$(TUXBOX_YAUD_CUSTOMIZE)
	@echo "***************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of Enigma2 for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "***************************************************************"
	@touch $(D)/build_complete

#
# enigma2
#
REPO_OPENPLI="https://github.com/OpenPLi/enigma2.git"
REPO_REPLY_1="https://github.com/MaxWiesel/enigma2-openpli-fulan.git"

$(D)/enigma2.do_prepare: | $(ENIGMA2_DEPS)
	REPO_0=$(REPO_OPENPLI); \
	REPO_1=$(REPO_REPLY_1); \
	REVISION=$(E2_REVISION); \
	HEAD="master"; \
	DIFF=$(E2_DIFF); \
	rm -rf $(SOURCE_DIR)/enigma2; \
	rm -rf $(SOURCE_DIR)/enigma2.org; \
	clear; \
	echo "Starting OpenPLi Enigma2 build"; \
	echo "=============================="; \
	echo; \
	if [ "$$DIFF" != "1" ]; then \
		echo "Repository : "$$REPO_0; \
		echo "Revision   : "$$REVISION; \
		echo "Diff       : "$$DIFF; \
	else \
		echo "Repository : "$$REPO_1; \
	fi; \
	echo ""; \
	if [ "$$DIFF" != "1" ]; then \
		[ -d "$(ARCHIVE)/enigma2-pli-nightly.git" ] && \
		(cd $(ARCHIVE)/enigma2-pli-nightly.git; echo -n "Updating archived OpenPLi git..."; git pull -q; echo -e -n " done.\nChecking out HEAD..."; git checkout -q HEAD; echo " done."; cd "$(BUILD_TMP)";); \
		[ -d "$(ARCHIVE)/enigma2-pli-nightly.git" ] || \
		(echo -n "Cloning remote OpenPLi git..."; git clone -q -b $$HEAD $$REPO_0 $(ARCHIVE)/enigma2-pli-nightly.git; echo " done."); \
		echo -n "Copying local git content to build environment..."; cp -ra $(ARCHIVE)/enigma2-pli-nightly.git $(SOURCE_DIR)/enigma2; echo " done."; \
		if [ "$$REVISION" != "newest" ]; then \
			cd $(SOURCE_DIR)/enigma2; pwd; echo -n "Checking out revision $$REVISION..."; git checkout -q "$$REVISION"; echo " done."; \
		fi; \
		cp -ra $(SOURCE_DIR)/enigma2 $(SOURCE_DIR)/enigma2.org; \
		echo "Applying diff-$$DIFF patch..."; \
		set -e; cd $(SOURCE_DIR)/enigma2 && patch -p1 $(SILENT_PATCH) < "$(PATCHES)/enigma2-pli-nightly.$$DIFF.diff"; \
		if [ "$(MEDIAFW)" == "eplayer3" ]; then \
			set -e; cd $(SOURCE_DIR)/enigma2 && patch -p1 $(SILENT_PATCH) < "$(PATCHES)/eplayer3.$$DIFF.patch"; \
		fi; \
		echo "Patching to diff-$$DIFF completed."; \
		cd $(SOURCE_DIR)/enigma2; \
		echo -n "Building VFD-drivers..."; \
		patch -p1 -s -i "$(PATCHES)/vfd-drivers.patch"; echo " done."; \
		rm -rf $(TARGET_DIR)/usr/local/share/enigma2/rc_models; \
		echo; \
		echo -n "Patching remote control files..."; \
		patch -p1 -s -i "$(PATCHES)/rc-models.patch"; \
		echo -e " done.\nBuild preparation for OpenPLi complete."; echo; \
	else \
		[ -d "$(SOURCE_DIR)/enigma2" ] ; \
		echo "Cloning local git content to build environment..."; \
		git clone -b $$HEAD $$REPO_1 $(SOURCE_DIR)/enigma2; \
	fi
	@touch $@

$(SOURCE_DIR)/enigma2/config.status:
	cd $(SOURCE_DIR)/enigma2; \
		./autogen.sh $(SILENT_OPT); \
		sed -e 's|#!/usr/bin/python|#!$(HOST_DIR)/bin/python|' -i po/xml2po.py; \
		$(BUILDENV) \
		./configure $(SILENT_OPT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(E_CONFIG_OPTS) \
			--with-libsdl=no \
			--datadir=/usr/local/share \
			--libdir=/usr/lib \
			--bindir=/usr/local/bin \
			--prefix=/usr \
			--sysconfdir=/etc \
			--with-boxtype=none \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			PY_PATH=$(TARGET_DIR)/usr \
			CPPFLAGS="$(E_CPPFLAGS)"

$(D)/enigma2.do_compile: $(SOURCE_DIR)/enigma2/config.status
	cd $(SOURCE_DIR)/enigma2; \
		$(MAKE) all
	@touch $@

PLI_SKIN_PATCH = PLi-HD_skin.patch
REPO_PLIHD="https://github.com/littlesat/skin-PLiHD.git"

$(D)/enigma2: $(D)/enigma2.do_prepare $(D)/enigma2.do_compile
	$(MAKE) -C $(SOURCE_DIR)/enigma2 install DESTDIR=$(TARGET_DIR)
	$(SILENT)echo -n "Stripping..."; \
	if [ -e $(TARGET_DIR)/usr/bin/enigma2 ]; then \
		$(TARGET)-strip $(TARGET_DIR)/usr/bin/enigma2; \
	fi
	if [ -e $(TARGET_DIR)/usr/local/bin/enigma2 ]; then \
		$(TARGET)-strip $(TARGET_DIR)/usr/local/bin/enigma2; \
	fi
	echo " done."; \
	echo ; \
	echo "Adding PLi-HD skin"; \
	HEAD="master"; \
	REPO_0=$(REPO_PLIHD); \
	if [ -d $(ARCHIVE)/PLi-HD_skin.git ]; then \
		cd $(ARCHIVE)/PLi-HD_skin.git; \
		echo -n "Updating archived PLi-HD skin git..."; \
		git pull -q; git checkout -q $$HEAD; \
		echo " done."; \
	else \
		echo -n "Cloning PLi-HD skin git..."; \
		git clone -q -b $$HEAD $$REPO_0 $(ARCHIVE)/PLi-HD_skin.git; \
		echo " done."; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/PLi-HD_skin.git/usr/share/enigma2/* $(TARGET_DIR)/usr/local/share/enigma2
#	$(call post_patch,$(PLI_SKIN_PATCH))
	echo -e "$(TERM_RED)Applying Patch:$(TERM_NORMAL) $(PLI_SKIN_PATCH)"; $(PATCH)/$(PLI_SKIN_PATCH)
	echo -e "Patching $(TERM_GREEN_BOLD)PLi-HD skin$(TERM_NORMAL) completed.";
	$(SILENT)rm -rf $(TARGET_DIR)/usr/local/share/enigma2/PLi-FullHD
	$(SILENT)rm -rf $(TARGET_DIR)/usr/local/share/enigma2/PLi-FullNightHD
	$(TOUCH)

enigma2-clean:
	rm -f $(D)/enigma2
	rm -f $(D)/enigma2.do_compile
	cd $(SOURCE_DIR)/enigma2; \
		$(MAKE) distclean

enigma2-distclean:
	rm -f $(D)/enigma2
	rm -f $(D)/enigma2.do_compile
	rm -f $(D)/enigma2.do_prepare
	rm -rf $(SOURCE_DIR)/enigma2
	rm -rf $(SOURCE_DIR)/enigma2.org
