#
# titan
#
TITAN_DEPS  = $(D)/bootstrap
TITAN_DEPS += $(KERNEL)
TITAN_DEPS += $(D)/libopenthreads
TITAN_DEPS += $(D)/system-tools
TITAN_DEPS += $(D)/module_init_tools
TITAN_DEPS += $(LIRC)
TITAN_DEPS += $(D)/libpng
TITAN_DEPS += $(D)/freetype
TITAN_DEPS += $(D)/libjpeg
TITAN_DEPS += $(D)/zlib
TITAN_DEPS += $(D)/openssl
TITAN_DEPS += $(D)/timezone
TITAN_DEPS += $(D)/tools-titan-tools

ifeq ($(MEDIAFW), eplayer3)
T_CONFIG_OPTS += --enable-eplayer3
TITAN_DEPS += $(D)/tools-exteplayer3
TITAN_DEPS += $(D)/libcurl
TITAN_DEPS += $(D)/ffmpeg
endif

#ifeq ($(MEDIAFW), gstreamer)
##T_CONFIG_OPTS += --with-gstversion=1.0 --enable-mediafwgstreamer
#TITAN_DEPS += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
#TITAN_DEPS += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
#endif

#ifeq ($(MEDIAFW), gst-eplayer3)
##T_CONFIG_OPTS += --with-gstversion=1.0 --enable-mediafwgstreamer --enable-eplayer3
#TITAN_DEPS += $(D)/libcurl
#TITAN_DEPS += $(D)/ffmpeg
#TITAN_DEPS += $(D)/tools-libeplayer3
#TITAN_DEPS += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
#TITAN_DEPS += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
#endif

TITAN_DEPS += $(LOCAL_TITAN_DEPS)

ifeq ($(IMAGE), titan-wlandriver)
TITAN_DEPS += $(D)/wpa_supplicant $(D)/wireless_tools
endif

ifeq ($(EXTERNAL_LCD), graphlcd)
T_CONFIG_OPTS += --with-graphlcd
TITAN_DEPS_ += $(D)/graphlcd
endif

ifeq ($(EXTERNAL_LCD), lcd4linux)
T_CONFIG_OPTS += --with-lcd4linux
TITAN_DEPS += $(D)/lcd4linux
endif

ifeq ($(EXTERNAL_LCD), both)
T_CONFIG_OPTS += --with-graphlcd
TITAN_DEPS += $(D)/graphlcd
T_CONFIG_OPTS += --with-lcd4linux
TITAN_DEPS += $(D)/lcd4linux
endif

T_CONFIG_OPTS +=$(LOCAL_TITAN_BUILD_OPTIONS)

T_CPPFLAGS   += -DSH4
T_CPPFLAGS   += -DDVDPLAYER 
T_CPPFLAGS   += -Wno-unused-but-set-variable
T_CPPFLAGS   += -I$(DRIVER_DIR)/include
T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include
T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/freetype2
T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/openssl
T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/libpng16
T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/dreamdvd
T_CPPFLAGS   += -I$(KERNEL_DIR)/include
T_CPPFLAGS   += -I$(DRIVER_DIR)/bpamem
T_CPPFLAGS   += -I$(TOOLS_DIR)
T_CPPFLAGS   += -I$(TOOLS_DIR)/libmme_image
T_CPPFLAGS   += -L$(TARGET_DIR)/usr/lib
T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/python
T_CPPFLAGS   += -L$(SOURCE_DIR)/titan/libipkg
#T_LINKFLAGS   += -lm -lpthread -ldl -lpng -lfreetype -ldreamdvd -ljpeg -lmmeimage -lmme_host -lz

ifeq ($(MEDIAFW), eplayer3)
T_CPPFLAGS   += -DEPLAYER3
T_CPPFLAGS   += -DEXTEPLAYER3
T_CPPFLAGS   += -I$(TOOLS_DIR)/exteplayer3/include
#T_CPPFLAGS   += -I$(SOURCE_DIR)/titan/libeplayer3/include
#T_CPPFLAGS   += -I$(SOURCE_DIR)/titan/libeplayer3/include/external
#T_LINKFLAGS   += -lssl -leplayer -lcrypto -lcurl
endif

#ifeq ($(MEDIAFW), gstreamer)
#T_CPPFLAGS   += -DEPLAYER4
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/gstreamer-1.0
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/glib-2.0
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/libxml2
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/lib/gstreamer-1.0/include
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/lib/gstreamer-1.0/include
#T_LINKFLAGS   += -lglib-2.0 -lgobject-2.0 -lgio-2.0 -lgstreamer-1.0
#endif

#ifeq ($(MEDIAFW), gst-explayer3)
#T_CPPFLAGS   += -DEPLAYER3 -DEPLAYER4
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/gstreamer-1.0
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/glib-2.0
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/include/libxml2
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/lib/gstreamer-1.0/include
#T_CPPFLAGS   += -I$(TARGET_DIR)/usr/lib/gstreamer-1.0/include
#T_CPPFLAGS   += -I$(TOOLS_DIR)/exteplayer3/include
#T_CPPFLAGS   += -lssl -leplayer -lcrypto -lcurl -lglib-2.0 -lgobject-2.0 -lgio-2.0 -lgstreamer-1.0
#endif

T_CPPFLAGS   += $(LOCAL_TITAN_CPPFLAGS)
T_CPPFLAGS   += $(PLATFORM_CPPFLAGS)

#
# yaud-titan
#
yaud-titan: yaud-none $(D)/titan $(D)/titan_release
	$(TUXBOX_YAUD_CUSTOMIZE)
	@echo "***************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of Titan for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "***************************************************************"
	@touch $(D)/build_complete

#
# yaud-titan-plugins
#
yaud-titan-plugins: yaud-none $(D)/titan $(D)/titan-plugins $(D)/titan_release
	$(TUXBOX_YAUD_CUSTOMIZE)
	@echo "***************************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of Titan with plugins for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "***************************************************************************"
	@touch $(D)/build_complete

#
# titan
#
REPO_TITAN=http://sbnc.dyndns.tv/svn/titan/
TITAN_PATCH  = build-titan/titan.patch
TITAN_PATCH += build-titan/titan_model.patch
TITAN_PATCH += build-titan/titan_icon.patch
#ifeq ($(MEDIAFW), $(filter $(MEDIAFW), eplayer3 gst-explayer3))
#TITAN_PATCH += build-titan/titan_exteplayer3.patch
#endif

$(D)/titan.do_prepare: $(TITAN_DEPS)
	REPO=$(REPO_TITAN); \
	HEAD="master"; \
	rm -rf $(SOURCE_DIR)/titan; \
	rm -rf $(SOURCE_DIR)/titan.org; \
	clear; \
	echo "Starting Titan build"; \
	echo "===================="; \
	echo; \
	echo "Repository : "$$REPO; \
	[ -d "$(ARCHIVE)/titan.svn" ] || \
	(mkdir $(ARCHIVE)/titan.svn; \
	cd $(ARCHIVE)/titan.svn; \
	echo -n "Retrieving Titan svn..."; svn checkout --username=public --password=public $(REPO_TITAN) -q; echo " done.";); \
	[ -d "$(ARCHIVE)/titan.svn" ] && \
	(cd $(ARCHIVE)/titan.svn/titan; \
	echo -n "Updating archived Titan svn..."; svn update --username=public --password=public -q; echo " done.";); \
	echo -n "Copying local svn content to build environment..."; cp -ra $(ARCHIVE)/titan.svn/titan $(SOURCE_DIR)/titan; echo " done."; \
	cp -ra $(SOURCE_DIR)/titan $(SOURCE_DIR)/titan.org; \
	set -e; cd $(SOURCE_DIR)/titan; \
	echo >> Makefile.am; \
	echo "Applying Titan patches..."; \
	$(call apply_patches, $(TITAN_PATCH)); \
	cd $(SOURCE_DIR)/titan; \
	cp ./libeplayer3/Makefile.am.sh4 ./libeplayer3/Makefile.am; \
	cp ./titan/Makefile.am.sh4 ./titan/Makefile.am; \
	cp ./plugins/network/networkbrowser/netlib/Makefile.sh4 ./plugins/network/networkbrowser/netlib/Makefile; \
	echo; \
	touch $@

$(SOURCE_DIR)/titan/config.status: $(D)/titan.do_prepare
	$(SILENT)cd $(SOURCE_DIR)/titan; \
		echo "Configuring titan..."; \
		./autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(T_CONFIG_OPTS) \
			--datadir=/usr/local/share \
			--libdir=/usr/lib \
			--bindir=/usr/local/bin \
			--prefix=/usr \
			--sysconfdir=/etc \
			--with-boxtype=duckbox \
			--with-boxmodel=$(BOXTYPE) \
			--enable-multicom324 \
			$(TITAN_OPT_OPTION) \
			PKG_CONFIG=$(PKG_CONFIG) \
			CPPFLAGS="$(T_CPPFLAGS)"

$(D)/titan.do_compile: $(SOURCE_DIR)/titan/config.status
	$(SILENT)cd $(SOURCE_DIR)/titan; \
		$(MAKE) all
	@touch $@

$(D)/titan:  $(D)/titan-libipkg $(D)/titan-libdreamdvd $(D)/titan.do_compile
	$(MAKE) -C $(SOURCE_DIR)/titan install DESTDIR=$(TARGET_DIR)
	@echo -n "Stripping..."
	$(SILENT)if [ -e $(TARGET_DIR)/usr/bin/titan ]; then \
		$(TARGET)-strip $(TARGET_DIR)/usr/bin/titan; \
	fi
	$(SILENT)if [ -e $(TARGET_DIR)/usr/local/bin/titan ]; then \
		$(TARGET)-strip $(TARGET_DIR)/usr/local/bin/titan; \
	fi
	$(SILENT)echo " done."
	$(SILENT)echo
	$(TOUCH)

#
# titan-plugins
#
TITAN_PLUGINS_PATCH = build-titan/titan_plugins.patch
$(SOURCE_DIR)/titan/plugins/config.status: $(D)/titan.do_prepare
	$(SILENT)cd $(SOURCE_DIR)/titan/plugins; \
		echo "Configuring titan-plugins..."; \
		ln -s $(SOURCE_DIR)/plugins $(SOURCE_DIR)/titan/plugins; \
		./autogen.sh $(SILENT_OPT); \
		pwd; \
		$(call apply_patches, $(TITAN_PLUGINS_PATCH)); \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--datadir=/usr/local/share \
			--libdir=/usr/lib \
			--bindir=/usr/local/bin \
			--prefix=/usr \
			--sysconfdir=/etc \
			--enable-multicom324 \
			$(TITAN_OPT_OPTION) \
			PKG_CONFIG=$(PKG_CONFIG) \
			CPPFLAGS="$(T_CPPFLAGS)"

$(D)/titan-plugins.do_compile: $(SOURCE_DIR)/titan/plugins/config.status
	$(SILENT)cd $(SOURCE_DIR)/titan/plugins; \
		./makesh4.sh $(KERNEL_STM) $(MEDIAFW) dev $(BOXTYPE) $(SOURCE_DIR) "$(T_CPPFLAGS)"
		$(MAKE) all
#		./makesh4.sh stm24 1 nondev $(BOXTYPE) atemio sh4 $(SOURCE_DIR)/titan
	@touch $@
		ln -s $(SOURCE_DIR)/titan/plugins $(SOURCE_DIR)/titan/titan/plugins; 

$(D)/titan-plugins: $(D)/titan.do_prepare $(D)/python
	$(START_BUILD)
	$(SILENT)cd $(SOURCE_DIR)/titan/plugins; \
		echo "Configuring titan-plugins..."; \
		./autogen.sh $(SILENT_OPT); \
		$(call apply_patches, $(TITAN_PLUGINS_PATCH)); \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--datadir=/usr/local/share \
			--libdir=/usr/lib \
			--bindir=/usr/local/bin \
			--prefix=/usr \
			--sysconfdir=/etc \
			--enable-multicom324 \
			$(TITAN_OPT_OPTION) \
			PKG_CONFIG=$(PKG_CONFIG) \
			CPPFLAGS="$(T_CPPFLAGS)" \
			; \
		./makesh4.sh $(KERNEL_STM) $(MEDIAFW) dev $(BOXTYPE) $(SOURCE_DIR) "$(T_CPPFLAGS)"
#		$(MAKE) -C $(SOURCE_DIR)/titan install DESTDIR=$(TARGET_DIR)
	$(SILENT)echo
	$(TOUCH)

#
# titan-libipkg
#
TITAN_LIBIPKG_PATCH =
$(D)/titan-libipkg: $(D)/titan.do_prepare
	$(START_BUILD)
	$(SILENT)cd $(SOURCE_DIR)/titan/libipkg; \
	aclocal $(ACLOCAL_FLAGS); \
	libtoolize --automake -f -c; \
	autoconf; \
	autoheader; \
	automake --add-missing; \
	$(call apply_patches, $(TITAN_LIBIPKG_PATCH)); \
	./configure $(SILENT_CONFIGURE) \
		--build=$(BUILD) \
		--host=$(TARGET) \
		--datadir=/usr/local/share \
		--libdir=/usr/lib \
		--bindir=/usr/local/bin \
		--prefix=/usr \
		--sysconfdir=/etc \
		$(TITAN_OPT_OPTION) \
		PKG_CONFIG=$(PKG_CONFIG) \
		CPPFLAGS="$(T_CPPFLAGS)" \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		cp $(SOURCE_DIR)/titan/libipkg/libipkg.pc $(TARGET_LIB_DIR)/pkgconfig
		$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libipkg.pc
	$(TOUCH)

#
# titan-libdreamdvd
#
TITAN_LIBDREAMDVD_PATCH =
$(D)/titan-libdreamdvd: $(D)/titan.do_prepare $(D)/libdvdnav
	$(START_BUILD)
	$(SILENT)export PATH=$(hostprefix)/bin:$(PATH); \
	cd $(SOURCE_DIR)/titan/libdreamdvd; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		./autogen.sh; \
		libtoolize --force; \
		aclocal -I $(TARGET_DIR)/usr/share/aclocal; \
		autoconf; \
		automake --foreign --add-missing; \
		$(call apply_patches, $(TITAN_LIBDREAMDVD_PATCH)); \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	cp $(SOURCE_DIR)/titan/libdreamdvd/ddvdlib.h $(TARGET_INCLUDE_DIR)
	cp $(SOURCE_DIR)/titan/libdreamdvd/libdreamdvd.pc $(PKG_CONFIG_PATH)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdreamdvd.pc
	$(TOUCH)

#
# titan-libeplayer3
#
TITAN_LIBEPLAYER3_PATCH =
$(D)/titan-libeplayer3.do_prepare: $(D)/titan.do_prepare
		$(SILENT)cd $(SOURCE_DIR)/titan/libeplayer3; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		./autogen.sh $(SILENT_OPT); \
		$(BUILDENV); \
		$(call apply_patches, $(TITAN_LIBEPLAYER3_PATCH)); \
		./configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			$(T_CONFIG_OPTS) \
			--datadir=/usr/local/share \
			--libdir=/usr/lib \
			--bindir=/usr/local/bin \
			--prefix=/usr \
			--sysconfdir=/etc \
			$(TITAN_OPT_OPTION) \
			PKG_CONFIG=$(PKG_CONFIG) \
			CPPFLAGS="$(T_CPPFLAGS)"
	@touch $@

$(D)/titan-libeplayer3.do_compile: $(D)/titan_libeplayer3.do_prepare
	$(SILENT)cd $(SOURCE_DIR)/titan/libeplayer3; \
		$(MAKE) all
	$(TOUCH)

$(D)/titan-libeplayer3: $(D)/titan.do_prepare
	$(START_BUILD)
	cd $(SOURCE_DIR)/titan/libeplayer3; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

titan-clean:
	rm -f $(D)/titan
	rm -f $(D)/titan.do_compile
	cd $(SOURCE_DIR)/titan; \
		$(MAKE) distclean

titan-distclean:
	rm -f $(D)/titan
	rm -f $(D)/titan.do_compile
	rm -f $(D)/titan.do_prepare
	rm -rf $(SOURCE_DIR)/titan
	rm -rf $(SOURCE_DIR)/titan.org

titan-plugins-clean: titan-clean
	$(SILENT)rm -f $(D)/titan-plugins
	$(SILENT)cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean

titan-plugins-distclean: $(D)/titan-distclean
	$(SILENT)rm -f $(D)/titan-plugins
	$(SILENT)cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean


