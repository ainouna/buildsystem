#
# enigma2
#
ENIGMA2_DEPS  = $(D)/bootstrap $(D)/opkg $(D)/ncurses $(LIRC) $(D)/libcurl $(D)/libmad
ENIGMA2_DEPS += $(D)/libpng $(D)/libjpeg $(D)/giflib $(D)/freetype $(D)/libfribidi $(D)/libglib2 $(D)/libdvbsi $(D)/libxml2
ENIGMA2_DEPS += $(D)/openssl $(D)/enigma2_tuxtxt32bpp $(D)/enigma2_hotplug_e2_helper $(D)/parted $(D)/avahi
ENIGMA2_DEPS += python-all $(D)/alsa_utils
ENIGMA2_DEPS += $(D)/libid3tag
ENIGMA2_DEPS += $(D)/expat $(D)/libusb
ENIGMA2_DEPS += $(D)/sdparm $(D)/minidlna $(D)/ethtool
ENIGMA2_DEPS += $(D)/libdreamdvd

ifeq ($(IMAGE), enigma2-wlandriver)
ENIGMA2_DEPS += $(D)/wpa_supplicant $(D)/wireless_tools
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hs7110 hs7119 hs7420 hs7429 hs7810a hs7819))
ifeq ($(DESTINATION), USB)
ENIGMA2_DEPS += $(D)/busybox_usb
E_CONFIG_OPTS += --enable-run_from_usb
endif
endif

# determine libsigc++ version
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 0 2 3 4))
ENIGMA2_DEPS  += $(D)/libsigc
else
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 1))
ENIGMA2_DEPS  += $(D)/libsigc_e2 
else
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 5))
ENIGMA2_DEPS  += $(D)/libsigc_e2 
else
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 6))
ENIGMA2_DEPS  += $(D)/libsigc_e2 
endif
endif
endif
endif

# determine requirements for media framework
# Note: for diffs 0, 2, 3 & 4 there are no extra depencies;
# these are part of enigma2-plugins
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 1)) # diff 1 (local)
ifeq ($(MEDIAFW), eplayer3)
ENIGMA2_DEPS  += $(D)/tools-libeplayer3
E_CONFIG_OPTS += --enable-libeplayer3
endif
ifeq ($(MEDIAFW), gstreamer)
ENIGMA2_DEPS  += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
ENIGMA2_DEPS  += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
E_CONFIG_OPTS += --with-gstversion=1.0 --enable-mediafwgstreamer
endif
ifeq ($(MEDIAFW), gst-eplayer3)
ENIGMA2_DEPS  += $(D)/tools-libeplayer3
ENIGMA2_DEPS  += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
ENIGMA2_DEPS  += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
E_CONFIG_OPTS += --with-gstversion=1.0 --enable-mediafwgstreamer --enable-libeplayer3
endif
else
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 5)) # diff 5
ifeq ($(MEDIAFW), eplayer3)
ENIGMA2_DEPS  += $(D)/tools-eplayer3
E_CONFIG_OPTS += --enable-libeplayer3
endif
ifeq ($(MEDIAFW), gstreamer)
ENIGMA2_DEPS  += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
ENIGMA2_DEPS  += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
E_CONFIG_OPTS += --with-gstversion=1.0 --enable-mediafwgstreamer
endif
ifeq ($(MEDIAFW), gst-eplayer3)
ENIGMA2_DEPS  += $(D)/tools-libeplayer3
ENIGMA2_DEPS  += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
ENIGMA2_DEPS  += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
E_CONFIG_OPTS += --with-gstversion=1.0 --enable-mediafwgstreamer --enable-libeplayer3
endif
else
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 6)) # diff 6 (experimental)
ifeq ($(MEDIAFW), eplayer3)
ENIGMA2_DEPS  += $(D)/tools-libeplayer3_new
E_CONFIG_OPTS += --enable-libeplayer3
endif
ifeq ($(MEDIAFW), gstreamer)
ENIGMA2_DEPS  += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
ENIGMA2_DEPS  += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
E_CONFIG_OPTS += --with-gstversion=1.0 --enable-mediafwgstreamer
endif
ifeq ($(MEDIAFW), gst-eplayer3)
ENIGMA2_DEPS  += $(D)/tools-libeplayer3_new
ENIGMA2_DEPS  += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
ENIGMA2_DEPS  += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
E_CONFIG_OPTS += --with-gstversion=1.0 --enable-mediafwgstreamer --enable-libeplayer3
endif
endif
endif
endif

#E_CONFIG_OPTS += --enable-$(BOXTYPE)

E_CONFIG_OPTS +=$(LOCAL_ENIGMA2_BUILD_OPTIONS)

E_CPPFLAGS    = -I$(DRIVER_DIR)/include
E_CPPFLAGS   += -I$(TARGET_DIR)/usr/include
E_CPPFLAGS   += -I$(KERNEL_DIR)/include
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 1))
E_CPPFLAGS   += -I$(APPS_DIR)/tools/libeplayer3/include
E_CPPFLAGS   += -I$(APPS_DIR)/tools
else
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 5))
E_CPPFLAGS   += -I$(APPS_DIR)/tools/libeplayer3/include
E_CPPFLAGS   += -I$(APPS_DIR)/tools
else
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 6))
E_CPPFLAGS   += -I$(APPS_DIR)/tools/libeplayer3_new/include
E_CPPFLAGS   += -I$(APPS_DIR)/tools
endif
endif
endif
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
#REPO_REPLY_1="https://github.com/MaxWiesel/enigma2-openpli-fulan.git"
REPO_REPLY_1="ssh://gituser@192.168.178.17/volume1//git/audioniek-openpli.git"

$(D)/enigma2.do_prepare: | $(ENIGMA2_DEPS)
	REPO_0=$(REPO_OPENPLI); \
	REPO_1=$(REPO_REPLY_1); \
	REVISION=$(E2_REVISION); \
	HEAD_0="develop"; \
	HEAD_1="master"; \
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
		echo; \
		[ -d "$(ARCHIVE)/enigma2-pli-nightly.git" ] && \
		(cd $(ARCHIVE)/enigma2-pli-nightly.git; echo -n "Updating archived OpenPLi git..."; git pull -q; echo -e -n " done.\nChecking out HEAD..."; git checkout -q HEAD; echo " done."; cd "$(BUILD_TMP)";); \
		[ -d "$(ARCHIVE)/enigma2-pli-nightly.git" ] || \
		(echo -n "Cloning remote OpenPLi git..."; git clone -q -b $$HEAD_0 $$REPO_0 $(ARCHIVE)/enigma2-pli-nightly.git; echo " done."); \
		echo -n "Copying local git content to build environment..."; cp -ra $(ARCHIVE)/enigma2-pli-nightly.git $(SOURCE_DIR)/enigma2; echo " done."; \
		if [ "$$REVISION" != "newest" ]; then \
			cd $(SOURCE_DIR)/enigma2; echo -n "Checking out revision $$REVISION..."; git checkout -q "$$REVISION"; echo " done."; \
		fi; \
		cp -ra $(SOURCE_DIR)/enigma2 $(SOURCE_DIR)/enigma2.org; \
		echo "Applying diff-$$DIFF patch..."; \
		set -e; cd $(SOURCE_DIR)/enigma2 && patch -p1 $(SILENT_PATCH) < "$(PATCHES)/build-enigma2/enigma2-pli-nightly.$$DIFF.diff"; \
		if [ "$(MEDIAFW)" == "eplayer3" ]; then \
			set -e; cd $(SOURCE_DIR)/enigma2 && patch -p1 $(SILENT_PATCH) < "$(PATCHES)/build-enigma2/eplayer3.$$DIFF.patch"; \
		fi; \
		if [ "$(E2_DIFF)" == "0" ] || [ "$(E2_DIFF)" == "2" ]; then \
			if [ "$(BOXTYPE)" == "fortis_hdbox" ] || [ "$(BOXTYPE)" == "octagon1008" ] || [ "$(BOXTYPE)" == "tf7700" ]; then \
				patch -p1 $(SILENT_PATCH) < "$(PATCHES)/build-enigma2/enigma2-no_hdmi_cec.$$DIFF.patch"; \
			fi; \
		fi; \
		echo "Patching to diff-$$DIFF completed."; \
		cd $(SOURCE_DIR)/enigma2; \
		echo -n "Building VFD-drivers..."; \
		patch -p1 -s -i "$(PATCHES)/build-enigma2/vfd-drivers.patch"; echo " done."; \
		rm -rf $(TARGET_DIR)/usr/local/share/enigma2/rc_models; \
		echo; \
		echo -n "Patching remote control files..."; \
		patch -p1 -s -i "$(PATCHES)/build-enigma2/rc-models.patch"; \
		echo -e " done.\nBuild preparation for OpenPLi complete."; echo; \
	else \
		echo "Repository : "$$REPO_1; \
		echo; \
		[ -d "$(SOURCE_DIR)/enigma2" ] ; \
		echo "Cloning local git content to build environment..."; \
		git clone -b $$HEAD_1 $$REPO_1 $(SOURCE_DIR)/enigma2; \
		echo; \
	fi
	@touch $@

$(SOURCE_DIR)/enigma2/config.status:
	$(SILENT)cd $(SOURCE_DIR)/enigma2; \
		./autogen.sh $(SILENT_OPT); \
		sed -e 's|#!/usr/bin/python|#!$(HOST_DIR)/bin/python|' -i po/xml2po.py; \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) $(SILENT_OPT) \
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
			$(ENIGMA_OPT_OPTION) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			PY_PATH=$(TARGET_DIR)/usr \
			CPPFLAGS="$(E_CPPFLAGS)"

$(D)/enigma2.do_compile: $(SOURCE_DIR)/enigma2/config.status
	$(SILENT)cd $(SOURCE_DIR)/enigma2; \
		$(MAKE) all
	@touch $@

PLI_SKIN_PATCH = build-enigma2/PLi-HD_skin.patch
REPO_PLIHD="https://github.com/littlesat/skin-PLiHD.git"
HEAD=master
#REVISION_HD=8c9e43bd5b5fbec2d0e0e86d8e9d69a94f139054
REPO_0=$(REPO_PLIHD)
FW=$(MEDIAFW)
$(D)/enigma2: $(D)/enigma2.do_prepare $(D)/enigma2.do_compile
	$(MAKE) -C $(SOURCE_DIR)/enigma2 install DESTDIR=$(TARGET_DIR)
	@echo -n "Stripping..."
	$(SILENT)if [ -e $(TARGET_DIR)/usr/bin/enigma2 ]; then \
		$(TARGET)-strip $(TARGET_DIR)/usr/bin/enigma2; \
	fi
	$(SILENT)if [ -e $(TARGET_DIR)/usr/local/bin/enigma2 ]; then \
		$(TARGET)-strip $(TARGET_DIR)/usr/local/bin/enigma2; \
	fi
	$(SILENT)echo " done."
	$(SILENT)echo
	$(SILENT)echo "Adding PLi-HD skin"
	$(SILENT)if [ ! -d $(ARCHIVE)/PLi-HD_skin.git ]; then \
		(echo -n "Cloning PLi-HD skin git..."; git clone -q -b $(HEAD) $(REPO_0) $(ARCHIVE)/PLi-HD_skin.git; echo " done."); \
	fi
#	$(SILENT)(cd $(ARCHIVE)/PLi-HD_skin.git; echo -n "Checkout commit $(REVISION_HD)..."; git checkout -q $(REVISION_HD); echo " done.")
	$(SILENT)cp -ra $(ARCHIVE)/PLi-HD_skin.git/usr/share/enigma2/* $(TARGET_DIR)/usr/local/share/enigma2
	@echo -e "$(TERM_RED)Applying Patch:$(TERM_NORMAL) $(PLI_SKIN_PATCH)"; $(PATCH)/$(PLI_SKIN_PATCH)
	@echo -e "Patching $(TERM_GREEN_BOLD)PLi-HD skin$(TERM_NORMAL) completed."
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162 atevio7500 fortis_hdbox hs7110 hs7420 hs7810a hs7119 hs7429 hs7819 tf7700))
	$(SILENT)rm -rf $(TARGET_DIR)/usr/local/share/enigma2/PLi-FullHD
	$(SILENT)rm -rf $(TARGET_DIR)/usr/local/share/enigma2/PLi-FullNightHD
endif
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

