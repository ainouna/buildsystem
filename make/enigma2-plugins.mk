#
# enigma2_hotplug_e2_helper
#
HOTPLUG_E2_PATCH = build-enigma2/hotplug-e2-helper.patch

$(D)/enigma2_hotplug_e2_helper: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/hotplug-e2-helper
	$(SET) -e; if [ -d $(ARCHIVE)/hotplug-e2-helper.git ]; \
		then cd $(ARCHIVE)/hotplug-e2-helper.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/OpenPLi/hotplug-e2-helper.git hotplug-e2-helper.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/hotplug-e2-helper.git $(BUILD_TMP)/hotplug-e2-helper
	$(SET) -e; cd $(BUILD_TMP)/hotplug-e2-helper; \
		$(call apply_patches,$(HOTPLUG_E2_PATCH)); \
		$(CONFIGURE) \
			--prefix=/usr \
		; \
		$(MAKE) all; \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR)
	$(REMOVE)/hotplug-e2-helper
	$(TOUCH)

#
# enigma2_tuxtxtlib
#
TUXTXTLIB_PATCH = build-enigma2/tuxtxtlib-1.0-fix-dbox-headers.patch

$(D)/enigma2_tuxtxtlib: $(D)/bootstrap $(D)/freetype
	$(START_BUILD)
	$(REMOVE)/tuxtxtlib
	$(SILENT)if [ -d $(ARCHIVE)/tuxtxt.git ]; \
		then cd $(ARCHIVE)/tuxtxt.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/OpenPLi/tuxtxt.git tuxtxt.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/tuxtxt.git/libtuxtxt $(BUILD_TMP)/tuxtxtlib
	$(SILENT)cd $(BUILD_TMP)/tuxtxtlib; \
		$(call apply_patches,$(TUXTXTLIB_PATCH)); \
		aclocal; \
		autoheader; \
		autoconf; \
		libtoolize --force $(SILENT_OPT); \
		automake --foreign --add-missing; \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--with-boxtype=generic \
			--with-configdir=/etc \
			--with-datadir=/usr/share/tuxtxt \
			--with-fontdir=/usr/share/fonts \
		; \
		$(MAKE) all; \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/tuxbox-tuxtxt.pc
	$(REWRITE_LIBTOOL)/libtuxtxt.la
	$(REMOVE)/tuxtxtlib
	$(TOUCH)

#
# enigma2_tuxtxt32bpp
#
TUXTXT32BPP_PATCH = tuxtxt32bpp-1.0-fix-dbox-headers.patch

$(D)/enigma2_tuxtxt32bpp: $(D)/bootstrap $(D)/enigma2_tuxtxtlib
	$(START_BUILD)
	$(REMOVE)/tuxtxt
	$(SILENT)cp -ra $(ARCHIVE)/tuxtxt.git/tuxtxt $(BUILD_TMP)/tuxtxt
	$(SET) -e; cd $(BUILD_TMP)/tuxtxt; \
		$(call apply_patches,$(TUXTXT32BPP_PATCH)); \
		aclocal; \
		autoheader; \
		autoconf; \
		libtoolize --force $(SILENT_OPT); \
		automake --foreign --add-missing; \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--with-fbdev=/dev/fb0 \
			--with-boxtype=generic \
			--with-configdir=/etc \
			--with-datadir=/usr/share/tuxtxt \
			--with-fontdir=/usr/share/fonts \
		; \
		$(MAKE) all; \
		$(MAKE) install prefix=/usr DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libtuxtxt32bpp.la
	$(REMOVE)/tuxtxt
	$(TOUCH)

#
# Plugins
#
E2_PLUGIN_DEPS  = $(D)/enigma2_openwebif
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 0 2 3 4))
ifeq ($(MEDIAFW), $(filter $(MEDIAFW), eplayer3 gstreamer gst-eplayer3))
#E2_PLUGIN_DEPS = enigma2_servicemp3
E2_PLUGIN_DEPS += enigma2_servicemp3epl
endif
ifeq ($(MEDIAFW), gst-eplayer3-dual)
E2_PLUGIN_DEPS += enigma2_serviceapp
endif
endif
ifneq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), small))
E2_PLUGIN_DEPS += $(D)/enigma2_networkbrowser
endif
ifneq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), small size))
E2_PLUGIN_DEPS += $(D)/enigma2_blurayplayer
endif

$(D)/enigma2-plugins: $(E2_PLUGIN_DEPS)

#
# enigma2-openwebif
#
$(D)/enigma2_openwebif: $(D)/bootstrap $(D)/enigma2 $(D)/python_cheetah $(D)/python_ipaddress $(D)/python_pyopenssl
	$(START_BUILD)
	$(REMOVE)/e2openplugin-OpenWebif
	$(SILENT)if [ -d $(ARCHIVE)/e2openplugin-OpenWebif.git ]; \
		then cd $(ARCHIVE)/e2openplugin-OpenWebif.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/E2OpenPlugins/e2openplugin-OpenWebif.git e2openplugin-OpenWebif.git; \
	fi
	$(SILENT)cp -ra $(ARCHIVE)/e2openplugin-OpenWebif.git $(BUILD_TMP)/e2openplugin-OpenWebif
	$(SET) -e; cd $(BUILD_TMP)/e2openplugin-OpenWebif; \
		$(BUILDENV) \
		cp -a plugin $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif; \
		python -O -m compileall $(SILENT_OPT) $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/cs/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/de/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/el/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/nl/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/pl/LC_MESSAGES; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/uk/LC_MESSAGES; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/cs/LC_MESSAGES/OpenWebif.mo locale/cs.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/de/LC_MESSAGES/OpenWebif.mo locale/de.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/el/LC_MESSAGES/OpenWebif.mo locale/el.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/nl/LC_MESSAGES/OpenWebif.mo locale/nl.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/pl/LC_MESSAGES/OpenWebif.mo locale/pl.po; \
		msgfmt -o $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/locale/uk/LC_MESSAGES/OpenWebif.mo locale/uk.po; \
		rm -f $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/Extensions/OpenWebif/public/images/boxes/{alphatriplehd.png,dm500hd.png,dm520.png,dm7020hd.png,dm7080.png,dm8000.png,dm800.jpg,dm800se.png,dm820.png,dm900.png,dm920.png,dsi87.jpg,duo2.png,duo4k.png,duo.png,e3hd.jpg,e4hd.png,elite.jpg,esi88.jpg,et10000.png,et11000.png,et4x00.png,et5x00.png,et6500.png,et6x00.png,et7000.png,et7500.png,et7x00mini.png,et7x00.png,et8000.png,et8500.png,et8500s.jpg,et9x00.png,formuler1.png,formuler3.png,formuler4.png,formuler4turbo.png,fusionhd.png,fusionhdse.png,galaxy4k.png,gb800ueplus.jpg,gbquad4k.png,gbquad.jpg,gbue4k.png,h3.png,h4.png,h5.png,h6.png,h7.png,h9combo.png,h9.png,hd1100.png,hd11.png,hd1200.png,hd1265.png,hd1500.png,hd2400.png,hd500c.png,hd51.png,hd530c.png,hd60.png,i55plus.png,i55.png,ini-1000.jpg,ini-3000.jpg,ini-5000.jpg,ini-7000.jpg,ixussone.jpg,ixusszero.jpg,lc.png,lunix3-4k.png,lunix4k.png,lunix.png,mbmicro.png,mbmicrov2.png,mbtwinplus.png,me.jpg,minime.jpg,miraclebox.jpg,multibox.png,optimussos1.jpg,optimussos1plus.jpg,optimussos2.jpg,optimussos2plus.jpg,osmega.png,osminiplus.png,osmini.png,osmio4kplus.png,osmio4k.png,osninoplus.png,osnino.png,osninopro.png,premium.jpg,premium+.jpg,purehd.png,purehdse.png,revo4k.png,sf4008.png,sf8008.png,sh1.png,solo2.png,solo4k.png,solo.png,solose.png,spycat4kmini.png,spycatminiplus.png,spycatmini.png,spycat.png,uhd88.jpg,ultimo4k.png,ultimo.png,ultra.jpg,uno4k.png,uno4kse.png,uno.png,vipercombohdd.png,vipercombo.png,viperslim.png,vipert2c.png,vs1000.png,vs1500.png,wetekplay.png,xcombo.jpg,xp1000.png,xpeedlx3.jpg,xpeedlx.png,zero4k.png,zero.png}
	$(REMOVE)/e2openplugin-OpenWebif
	$(TOUCH)

#
# enigma2-networkbrowser
#
ENIGMA2_NETWORBROWSER_PATCH = build-enigma2/enigma2-networkbrowser-support-autofs.patch

$(D)/enigma2_networkbrowser: $(D)/bootstrap $(D)/enigma2
	$(START_BUILD)
	$(REMOVE)/enigma2-networkbrowser
	$(SILENT)if [ -d $(ARCHIVE)/enigma2-plugins.git ]; \
		then cd $(ARCHIVE)/enigma2-plugins.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/OpenPLi/enigma2-plugins.git enigma2-plugins.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/enigma2-plugins.git/networkbrowser/ $(BUILD_TMP)/enigma2-networkbrowser
	$(SET) -e; cd $(BUILD_TMP)/enigma2-networkbrowser; \
		$(call apply_patches,$(ENIGMA2_NETWORBROWSER_PATCH))
	$(SET) -e; cd $(BUILD_TMP)/enigma2-networkbrowser/src/lib; \
		$(BUILDENV) \
		sh4-linux-gcc -shared -o netscan.so \
			-I $(TARGET_DIR)/usr/include/python$(PYTHON_VER_MAJOR) \
			-include Python.h \
			errors.h \
			list.c \
			list.h \
			main.c \
			nbtscan.c \
			nbtscan.h \
			range.c \
			range.h \
			showmount.c \
			showmount.h \
			smb.h \
			smbinfo.c \
			smbinfo.h \
			statusq.c \
			statusq.h \
			time_compat.h
	$(SET) -e; cd $(BUILD_TMP)/enigma2-networkbrowser; \
		mkdir -p $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser; \
		cp -a po $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/; \
		cp -a meta $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/; \
		cp -a src/* $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/; \
		cp -a src/lib/netscan.so $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/; \
		python -O -m compileall $(SILENT_OPT) $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/lib; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/Makefile.am; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/icons/Makefile.am; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/meta/Makefile.am; \
		rm -rf $(TARGET_DIR)/usr/lib/enigma2/python/Plugins/SystemPlugins/NetworkBrowser/po/Makefile.am
	$(REMOVE)/enigma2-networkbrowser
	$(TOUCH)

#
# enigma2-servicemp3
#
SERVICEMP3_VER       = 0.1
SERVICEMP3_DEPS      = $(D)/bootstrap $(D)/enigma2
SERVICEMP3_CPPFLAGS  = -std=c++11
SERVICEMP3_CPPFLAGS += -I$(TARGET_DIR)/usr/include/python$(PYTHON_VER_MAJOR)
SERVICEMP3_CPPFLAGS += -I$(SOURCE_DIR)/enigma2
SERVICEMP3_CPPFLAGS += -I$(SOURCE_DIR)/enigma2/include
SERVICEMP3_CPPFLAGS += -I$(KERNEL_DIR)/include
SERVICEMP3_PATCH     = build-enigma2/enigma2-servicemp3-$(SERVICEMP3_VER).patch

ifeq ($(MEDIAFW), eplayer3)
SERVICEMP3_DEPS     += $(D)/tools-eplayer3
SERVICEMP3_CONF     += --enable-libeplayer3
endif

ifeq ($(MEDIAFW), gstreamer)
SERVICEMP3_DEPS    += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
SERVICEMP3_DEPS    += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
SERVICEMP3_CONF    += --enable-mediafwgstreamer
SERVICEMP3_CONF    += --with-gstversion=1.0
endif

ifeq ($(MEDIAFW), gst-eplayer3)
SERVICEMP3_DEPS    += $(D)/tools-libeplayer3
SERVICEMP3_DEPS    += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
SERVICEMP3_DEPS    += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
SERVICEMP3_CONF    += --enable-libeplayer3
SERVICEMP3_CONF    += --enable-mediafwgstreamer
SERVICEMP3_CONF    += --with-gstversion=1.0
endif

$(D)/enigma2_servicemp3: | $(SERVICEMP3_DEPS)
	$(START_BUILD)
	$(REMOVE)/enigma2-servicemp3-$(SERVICEMP3_VER)
	$(SILENT)if [ -d $(ARCHIVE)/enigma2-servicemp3-$(SERVICEMP3_VER).git ]; \
		then cd $(ARCHIVE)/enigma2-servicemp3-$(SERVICEMP3_VER).git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/OpenPLi/servicemp3.git enigma2-servicemp3-$(SERVICEMP3_VER).git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/enigma2-servicemp3-$(SERVICEMP3_VER).git/ $(BUILD_TMP)/enigma2-servicemp3-$(SERVICEMP3_VER)
	$(SET) -e; cd $(BUILD_TMP)/enigma2-servicemp3-$(SERVICEMP3_VER); \
		$(call apply_patches,$(SERVICEMP3_PATCH)); \
		./autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--enable-silent-rules \
			$(SERVICEMP3_CONF) \
			CPPFLAGS="$(SERVICEMP3_CPPFLAGS)" \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/enigma2-servicemp3-$(SERVICEMP3_VER)
	$(TOUCH)

#
# enigma2-servicemp3epl
#
SERVICEMP3EPL_VER       = 0.1
SERVICEMP3EPL_DEPS      = $(D)/bootstrap $(D)/enigma2
SERVICEMP3EPL_CPPFLAGS  = -std=c++11
SERVICEMP3EPL_CPPFLAGS += -I$(TARGET_DIR)/usr/include/python$(PYTHON_VER_MAJOR)
SERVICEMP3EPL_CPPFLAGS += -I$(SOURCE_DIR)/enigma2
SERVICEMP3EPL_CPPFLAGS += -I$(SOURCE_DIR)/enigma2/include
SERVICEMP3EPL_CPPFLAGS += -I$(KERNEL_DIR)/include
SERVICEMP3EPL_PATCH     = build-enigma2/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).patch
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 3 4 5))
SERVICEMP3EPL_PATCH    += build-enigma2/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER)-e2diff.patch
endif

ifeq ($(MEDIAFW), eplayer3)
SERVICEMP3EPL_DEPS     += $(D)/tools-libeplayer3
SERVICEMP3EPL_CONF     += --enable-libeplayer3
endif

ifeq ($(MEDIAFW), gstreamer)
SERVICEMP3EPL_DEPS     += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
SERVICEMP3EPL_DEPS     += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
SERVICEMP3EPL_CONF     += --enable-gstreamer
endif

ifeq ($(MEDIAFW), gst-eplayer3)
SERVICEMP3EPL_DEPS     += $(D)/tools-libeplayer3
SERVICEMP3EPL_DEPS     += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
SERVICEMP3EPL_DEPS     += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
SERVICEMP3EPL_CONF     += --enable-libeplayer3
SERVICEMP3EPL_CONF     += --enable-gstreamer
endif

ifeq ($(MEDIAFW), gst-eplayer3-dual)
SERVICEMP3EPL_DEPS     += $(D)/tools-libeplayer3
SERVICEMP3EPL_DEPS     += $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_multibox_dvbmediasink
SERVICEMP3EPL_DEPS     += $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
SERVICEMP3EPL_CONF     += --enable-dual_mediafw
endif

$(D)/enigma2_servicemp3epl: | $(SERVICEMP3EPL_DEPS)
	$(START_BUILD)
	$(REMOVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER)
	$(SILENT)if [ -d $(ARCHIVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).git ]; \
		then cd $(ARCHIVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/OpenVisionE2/servicemp3epl.git enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER).git/ $(BUILD_TMP)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER)
	$(SET) -e; cd $(BUILD_TMP)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER); \
		$(call apply_patches,$(SERVICEMP3EPL_PATCH)); \
		./autogen.sh $(SILENT_OPT); \
		$(BUILDENV) \
		$(CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--enable-silent-rules \
			$(SERVICEMP3EPL_CONF) \
			CPPFLAGS="$(SERVICEMP3EPL_CPPFLAGS)" \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/enigma2-servicemp3epl-$(SERVICEMP3EPL_VER)
	$(TOUCH)

#
# enigma2-serviceapp
#
SERVICEAPP_VER       = 0.1
SERVICEAPP_CPPFLAGS  = -std=c++11
SERVICEAPP_CPPFLAGS += -I$(TARGET_DIR)/usr/include/python$(PYTHON_VER_MAJOR)
SERVICEAPP_CPPFLAGS += -I$(SOURCE_DIR)/enigma2
SERVICEAPP_CPPFLAGS += -I$(SOURCE_DIR)/enigma2/include
SERVICEAPP_CPPFLAGS += -I$(KERNEL_DIR)/include
SERVICEAPP_PATCH     = build-enigma2/enigma2-serviceapp-$(SERVICEAPP_VER).patch

$(D)/enigma2_serviceapp: $(D)/bootstrap $(D)/enigma2 $(D)/enigma2_servicemp3epl $(D)/uchardet
	$(START_BUILD)
	$(REMOVE)/enigma2-serviceapp-$(SERVICEAPP_VER)
	$(SILENT)if [ -d $(ARCHIVE)/enigma2-serviceapp-$(SERVICEAPP_VER).git ]; \
		then cd $(ARCHIVE)/enigma2-serviceapp-$(SERVICEAPP_VER).git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) -b develop git://github.com/mx3L/serviceapp.git enigma2-serviceapp-$(SERVICEAPP_VER).git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/enigma2-serviceapp-$(SERVICEAPP_VER).git/ $(BUILD_TMP)/enigma2-serviceapp-$(SERVICEAPP_VER)
	$(SET) -e; cd $(BUILD_TMP)/enigma2-serviceapp-$(SERVICEAPP_VER); \
		$(call apply_patches,$(SERVICEAPP_PATCH)); \
		$(BUILDENV) \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix=/usr \
			--enable-silent-rules \
			$(SERVICEAPP_CONF) \
			CPPFLAGS="$(SERVICEAPP_CPPFLAGS)" \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/enigma2-serviceapp-$(SERVICEAPP_VER)
	$(TOUCH)

#
# enigma2-blurayplayer
#
BLURAYPLAYER_VER   = 1.0
BLURAYPLAYER_PATCH =

$(D)/enigma2_blurayplayer: $(D)/bootstrap $(D)/enigma2 $(D)/libudfread $(D)/libbluray $(D)/python $(D)/python_setuptools
	$(START_BUILD)
	$(REMOVE)/enigma2-blurayplayer-$(BLURAYPLAYER_VER)
	$(SILENT)if [ -d $(ARCHIVE)/enigma2-plugin-blurayplayer.git ]; \
		then cd $(ARCHIVE)/enigma2-plugin-blurayplayer.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) -b openpli https://github.com/Taapat/enigma2-plugin-blurayplayer enigma2-plugin-blurayplayer.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/enigma2-plugin-blurayplayer.git/ $(BUILD_TMP)/enigma2-blurayplayer-$(BLURAYPLAYER_VER)
	$(SET) -e; cd $(BUILD_TMP)/enigma2-blurayplayer-$(BLURAYPLAYER_VER); \
		$(call apply_patches,$(BLURAYPLAYER_PATCH)); \
		$(PYTHON_BUILD); \
		$(PYTHON_INSTALL)
	$(REMOVE)/enigma2-blurayplayer-$(BLURAYPLAYER_VER)
	$(TOUCH)

