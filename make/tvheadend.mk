#
# tvheadend
#

TVHEADEND_DEPS  = $(D)/bootstrap $(D)/openssl $(D)/zlib
TVHEADEND_DEPS += $(LOCAL_TVHEADEND_DEPS)

ifeq ($(BOXTYPE),spark)
TVHEADEND_CONFIG_OPTS += --enable-spark
endif

ifeq ($(BOXTYPE),spark7162)
TVHEADEND_CONFIG_OPTS += --enable-spark7162n
TVHEADEND_DEPS += ntp
endif

ifeq ($(BOXTYPE),fortis_hdbox)
TVHEADEND_CONFIG_OPTS += --enable-fortis_hdbox
endif

ifeq ($(BOXTYPE),octagon1008)
TVHEADEND_CONFIG_OPTS += --enable-octagon1008
endif

ifeq ($(BOXTYPE),atevio7500)
TVHEADEND_CONFIG_OPTS += --enable-atevio7500
endif

ifeq ($(BOXTYPE),hs7110)
TVHEADEND_CONFIG_OPTS += --enable-hs7110
endif

ifeq ($(BOXTYPE),hs7420)
TVHEADEND_CONFIG_OPTS += --enable-hs7420
endif

ifeq ($(BOXTYPE),hs7810a)
TVHEADEND_CONFIG_OPTS += --enable-hs7810a
endif

ifeq ($(BOXTYPE),hs7119)
TVHEADEND_CONFIG_OPTS += --enable-hs7119
endif

ifeq ($(BOXTYPE),hs7429)
TVHEADEND_CONFIG_OPTS += --enable-hs7429
endif

ifeq ($(BOXTYPE),hs7819)
TVHEADEND_CONFIG_OPTS += --enable-hs7819
endif

ifeq ($(BOXTYPE), tf7700)
YAUD_ENIGMA2_DEPS = $(D)/uboot_tf7700 $(D)/u-boot.ftfd $(D)/tfinstaller
endif

TVHEADEND_CONFIG_OPTS +=$(LOCAL_TVHEADEND_BUILD_OPTIONS)

#
# yaud-tvheadend
#
yaud-tvheadend: yaud-none $(D)/tvheadend $(D)/tvheadend_release
	$(TUXBOX_YAUD_CUSTOMIZE)
	@echo "***************************************************************"
	@echo -e "$(TERM_GREEN_BOLD)"
	@echo " Build of Tvheadend for $(BOXTYPE) successfully completed."
	@echo -e "$(TERM_NORMAL)"
	@echo "***************************************************************"
	@touch $(D)/build_complete


#
# tvheadend
#
REPO="https://github.com/tvheadend/tvheadend.git"

$(D)/tvheadend.do_prepare: | $(TVHEADEND_DEPS)
	REPO_0=$(REPO); \
	REVISION=$(TVHEADEND_REVISION); \
	HEAD="master"; \
	DIFF=$(TVHEADEND_DIFF); \
	rm -rf $(SOURCE_DIR)/tvheadend; \
	rm -rf $(SOURCE_DIR)/tvheadend.org; \
	clear; \
	echo "Starting Tvheadhead build"; \
	echo "=============================="; \
	echo; \
	echo "Revision : "$$REVISION; \
	echo "Diff     : "$$DIFF; \
	echo ""; \
	[ -d "$(ARCHIVE)/tvheadend.git" ] && \
	(cd $(ARCHIVE)/tvheadend.git; echo -n "Updating archived Tvheadend git..."; git pull -q; echo -e -n " done.\nChecking out HEAD..."; git checkout -q HEAD; echo " done."; cd "$(BUILD_TMP)";); \
	[ -d "$(ARCHIVE)/tvheadend.git" ] || \
	(echo -n "Cloning remote Tvheadend git..."; git clone -q -b $$HEAD $$REPO_0 $(ARCHIVE)/tvheadend.git; echo " done."); \
	echo -n "Copying local git content to build environment..."; cp -ra $(ARCHIVE)//tvheadend.git $(SOURCE_DIR)/tvheadend; echo " done."; \
	if [ "$$REVISION" != "newest" ]; then \
		cd $(SOURCE_DIR)/tvheadend; echo -n "Checking out revision $$REVISION..."; git checkout -q "$$REVISION"; echo " done."; \
	fi; \
	cp -ra $(SOURCE_DIR)/tvheadend $(SOURCE_DIR)/tvheadend.org; \
	echo "Applying diff-$$DIFF patch..."; \
	set -e; cd $(SOURCE_DIR)/tvheadend && patch -p1 $(SILENT_PATCH) < "$(PATCHES)/tvheadend.$$DIFF.diff"; \
	echo "Patching to diff-$$DIFF completed."; \
	cd $(SOURCE_DIR)/tvheadend; \
	echo "Build preparation for Tvheadend complete."; echo; \
	touch $@

$(SOURCE_DIR)/tvheadend/config.status:
	$(SILENT)cd $(SOURCE_DIR)/tvheadend; \
		$(BUILDENV) \
		./configure $(SILENT_OPT) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--disable-hdhomerun_static \
			--disable-avahi \
			--disable-tvhcsa \
			--disable-libav \
			--disable-ffmpeg_static \
			--disable-libx264 \
			--disable-libx264-static \
			--disable-libx265 \
			--disable-libx265-static \
			--disable-libx264 \
			--disable-libx264-static \
			--disable-libvpx \
			--disable-libvpx-static \
			--disable-libtheora \
			--disable-libtheora-static \
			--disable-libvorbis \
			--disable-libvorbis-static \
			--disable-libfdkaac \
			--disable-libfdkaac-static \
			--disable-uriparser \
			--disable-dvben50221 \
			--disable-dbus_1 \
			--with-boxtype=$(BOXTYPE) \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			PY_PATH=$(targetprefix)/usr \
			$(PLATFORM_CPPFLAGS)
	@touch $@

$(D)/tvheadend.do_compile: $(SOURCE_DIR)/tvheadend/config.status
	$(START_BUILD)
	cd $(SOURCE_DIR)/tvheadend; \
		 $(MAKE) all
	@touch $@

$(D)/tvheadend: $(D)/tvheadend.do_prepare $(D)/tvheadend.do_compile
	$(MAKE) -C $(SOURCE_DIR)/tvheadend install DESTDIR=$(TARGET_DIR)
	$(SILENT)echo -n "Stripping..."
	if [ -e $(TARGET_DIR)/usr/bin/tvheadend ]; then \
		$(TARGET)-strip $(TARGET_DIR)/usr/bin/tvheadend; \
	fi
	if [ -e $(TARGET_DIR)/usr/local/bin/tvheadend ]; then \
		$(TARGET)-strip $(TARGET_DIR)/usr/local/bin/tvheadend; \
	fi
	$(SILENT)echo " done."; echo
	$(TOUCH)

tvheadend-clean:
	rm -f $(D)/tvheadend
	rm -f $(D)/tvheadend.do_compile
	cd $(SOURCE_DIR)/tvheadend; \
		 $(MAKE) distclean

tvheadend-distclean:
	rm -f $(D)/tvheadend
	rm -f $(D)/tvheadend.do_compile
	rm -f $(D)/tvheadend.do_prepare
	rm -rf $(SOURCE_DIR)/tvheadend
	rm -rf $(SOURCE_DIR)/tvheadend.org

