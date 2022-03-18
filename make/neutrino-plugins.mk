#
# Makefile to build NEUTRINO-PLUGINS
#

#
# links
#
LINKS_VER = 2.7
LINKS_PATCH  = links-$(LINKS_VER).patch
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), spark spark7162))
LINKS_PATCH += links-$(LINKS_VER)-spark-input.patch
endif

$(ARCHIVE)/links-$(LINKS_VER).tar.bz2:
	$(WGET) http://links.twibright.com/download/links-$(LINKS_VER).tar.bz2

$(D)/links: $(D)/bootstrap $(D)/libpng $(D)/openssl $(ARCHIVE)/links-$(LINKS_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/links-$(LINKS_VER)
	$(UNTAR)/links-$(LINKS_VER).tar.bz2
	$(CH_DIR)/links-$(LINKS_VER); \
		$(call apply_patches, $(LINKS_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--without-libtiff \
			--without-svgalib \
			--with-fb \
			--without-directfb \
			--without-pmshell \
			--without-atheos \
			--enable-graphics \
			--enable-javascript \
			--with-ssl=$(TARGET_DIR)/usr \
			--without-x \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(SILENT)mkdir -p $(TARGET_DIR)/var/tuxbox/plugins $(TARGET_DIR)/var/tuxbox/config/links
	$(SILENT)mv $(TARGET_DIR)/bin/links $(TARGET_DIR)/var/tuxbox/plugins/links.so
	echo "name=Links Web Browser"	 > $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "desc=Web Browser"		>> $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "type=2"			>> $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "needoffsets=1"		>> $(TARGET_DIR)/var/tuxbox/plugins/links.cfg
	echo "bookmarkcount=0"		 > $(TARGET_DIR)/var/tuxbox/config/bookmarks
	$(SILENT)touch $(TARGET_DIR)/var/tuxbox/config/links/links.his
	$(SILENT)cp -a $(SKEL_ROOT)/var/tuxbox/config/links/bookmarks.html $(SKEL_ROOT)/var/tuxbox/config/links/tables.tar.gz $(TARGET_DIR)/var/tuxbox/config/links
	$(REMOVE)/links-$(LINKS_VER)
	$(TOUCH)

#
# neutrino-plugin
#
NEUTRINO_PLUGINS  = $(D)/neutrino-plugin-scripts-lua
NEUTRINO_PLUGINS += $(D)/neutrino-plugin-mediathek
NEUTRINO_PLUGINS += $(D)/neutrino-plugin-xupnpd
NEUTRINO_PLUGINS += $(LOCAL_NEUTRINO_PLUGINS)

NP_OBJDIR = $(SOURCE_DIR)/neutrino-plugins

EXTRA_CPPFLAGS_PLUGINS = -DMARTII

$(D)/neutrino-plugin.do_prepare:
	$(START_BUILD)
	$(SILENT)rm -rf $(NP_OBJDIR)
	$(SILENT)rm -rf $(NP_OBJDIR).org
	$(SET) -e; if [ -d $(ARCHIVE)/neutrino-plugins.git ]; \
		then cd $(ARCHIVE)/neutrino-plugins.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/Duckbox-Developers/neutrino-mp-plugins.git neutrino-mp-plugins.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/neutrino-plugins.git $(NP_OBJDIR)
	$(SILENT)cp -ra $(NP_OBJDIR) $(NP_OBJDIR).org
	@touch $@

$(D)/neutrino-plugin.config.status: $(D)/bootstrap
	$(SILENT)cd $(NP_OBJDIR); \
		if [ ! -d m4 ]; then mkdir -p m4; fi;\
		./autogen.sh $(SILENT_OPT) && automake --add-missing $(SILENT_OPT); \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--enable-silent-rules \
			--with-target=cdk \
			--include=/usr/include \
			--enable-maintainer-mode \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS) $(EXTRA_CPPFLAGS_PLUGINS) -DNEW_LIBCURL" \
			LDFLAGS="$(TARGET_LDFLAGS) -L$(NP_OBJDIR)/fx2/lib/.libs"
	@touch $@

$(D)/neutrino-plugin.do_compile: $(D)/neutrino-plugin.config.status
	$(MAKE) -C $(NP_OBJDIR) DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/neutrino-plugin: $(D)/$(NEUTRINO) $(D)/neutrino-plugin.do_prepare $(D)/neutrino-plugin.do_compile
	$(MAKE) -C $(NP_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

neutrino-plugin-clean:
	$(SILENT)rm -f $(D)/neutrino-plugins
	$(SILENT)rm -f $(D)/neutrino-plugin
	$(SILENT)rm -f $(D)/neutrino-plugin.config.status
	$(SILENT)cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean

neutrino-plugin-distclean:
	$(SILENT)rm -rf $(NP_OBJDIR)
	$(SILENT)rm -f $(D)/neutrino-plugin*

#
# xupnpd
#
XUPNPD_PATCH = xupnpd.patch

$(D)/xupnpd \
$(D)/neutrino-plugin-xupnpd: $(D)/bootstrap $(D)/lua $(D)/openssl $(D)/neutrino-plugin-scripts-lua
	$(START_BUILD)
	$(REMOVE)/xupnpd
	$(SET) -e; if [ -d $(ARCHIVE)/xupnpd.git ]; \
		then cd $(ARCHIVE)/xupnpd.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/clark15b/xupnpd.git xupnpd.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/xupnpd.git $(BUILD_TMP)/xupnpd
	$(CH_DIR)/xupnpd; \
		$(call apply_patches, $(XUPNPD_PATCH))
	$(CH_DIR)/xupnpd/src; \
		$(BUILDENV) \
		$(MAKE) -j1 TARGET=$(TARGET) PKG_CONFIG=$(PKG_CONFIG) LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)"; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(SILENT)install -m 755 $(SKEL_ROOT)/etc/init.d/xupnpd $(TARGET_DIR)/etc/init.d/
	$(SILENT)mkdir -p $(TARGET_DIR)/usr/share/xupnpd/config
	$(SILENT)rm $(TARGET_DIR)/usr/share/xupnpd/plugins/staff/xupnpd_18plus.lua
	$(SILENT)install -m 644 $(ARCHIVE)/plugin-scripts-lua.git/xupnpd/xupnpd_18plus.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	$(SILENT)install -m 644 $(ARCHIVE)/plugin-scripts-lua.git/xupnpd/xupnpd_cczwei.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	: install -m 644 $(ARCHIVE)/plugin-scripts-lua.git/xupnpd/xupnpd_coolstream.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	$(SILENT)install -m 644 $(ARCHIVE)/plugin-scripts-lua.git/xupnpd/xupnpd_youtube.lua ${TARGET_DIR}/usr/share/xupnpd/plugins/
	$(REMOVE)/xupnpd
	$(TOUCH)

#
# neutrino-plugin-scripts-lua
#
$(D)/neutrino-plugin-scripts-lua: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/neutrino-plugin-scripts-lua
	$(SET) -e; if [ -d $(ARCHIVE)/plugin-scripts-lua.git ]; \
		then cd $(ARCHIVE)/plugin-scripts-lua.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/tuxbox-neutrino/plugin-scripts-lua.git plugin-scripts-lua.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/plugin-scripts-lua.git/plugins $(BUILD_TMP)/neutrino-plugin-scripts-lua
	$(CH_DIR)/neutrino-plugin-scripts-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/ard_mediathek/* $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/favorites2bin/* $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/mtv/* $(TARGET_DIR)/var/tuxbox/plugins/
		cp -R $(BUILD_TMP)/neutrino-plugin-scripts-lua/netzkino/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/neutrino-plugin-scripts-lua
	$(TOUCH)

#
# neutrino-mediathek
#
NEUTRINO_MEDIATHEK_PATCH = build-neutrino/neutrino-mediathek.patch

$(D)/neutrino-plugin-mediathek:
	$(START_BUILD)
	$(REMOVE)/plugins-mediathek
	$(SET) -e; if [ -d $(ARCHIVE)/plugins-mediathek.git ]; \
		then cd $(ARCHIVE)/plugins-mediathek.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/neutrino-mediathek/mediathek.git plugins-mediathek.git; \
		fi
	$(SILENT)cp -ra $(ARCHIVE)/plugins-mediathek.git $(BUILD_TMP)/plugins-mediathek
	$(SILENT)install -d $(TARGET_DIR)/var/tuxbox/plugins
	$(CH_DIR)/plugins-mediathek; \
		$(call apply_patches, $(NEUTRINO_MEDIATHEK_PATCH))
	$(CH_DIR)/plugins-mediathek; \
		cp -a plugins/* $(TARGET_DIR)/var/tuxbox/plugins/; \
		cp -a share $(TARGET_DIR)/usr
	$(REMOVE)/plugins-mediathek
	$(TOUCH)

#
# neutrino-iptvplayer
#
$(D)/neutrino-plugin-iptvplayer-nightly \
$(D)/neutrino-plugin-iptvplayer: $(D)/librtmp $(D)/python_twisted_small
	$(START_BUILD)
	$(REMOVE)/iptvplayer
	set -e; if [ -d $(ARCHIVE)/iptvplayer.git ]; \
		then cd $(ARCHIVE)/iptvplayer.git; git pull $(MINUS_Q); \
		else cd $(ARCHIVE); git clone $(MINUS_Q) https://github.com/TangoCash/crossplatform_iptvplayer.git iptvplayer.git; \
		fi
	cp -ra $(ARCHIVE)/iptvplayer.git $(BUILD_TMP)/iptvplayer
	@if [ "$@" = "$(D)/neutrino-plugin-iptvplayer-nightly" ]; then \
		$(BUILD_TMP)/iptvplayer/SyncWithGitLab.sh $(BUILD_TMP)/iptvplayer; \
	fi
	install -d $(TARGET_DIR)/var/tuxbox/plugins
	install -d $(TARGET_DIR)/usr/share/E2emulator
	cp -R $(BUILD_TMP)/iptvplayer/E2emulator/* $(TARGET_DIR)/usr/share/E2emulator/
	install -d $(TARGET_DIR)/usr/share/E2emulator/Plugins/Extensions/IPTVPlayer
	cp -R $(BUILD_TMP)/iptvplayer/IPTVplayer/* $(TARGET_DIR)/usr/share/E2emulator//Plugins/Extensions/IPTVPlayer/
	cp -R $(BUILD_TMP)/iptvplayer/IPTVdaemon/* $(TARGET_DIR)/usr/share/E2emulator//Plugins/Extensions/IPTVPlayer/
	chmod 755 $(TARGET_DIR)/usr/share/E2emulator/Plugins/Extensions/IPTVPlayer/cmdlineIPTV.*
	chmod 755 $(TARGET_DIR)/usr/share/E2emulator/Plugins/Extensions/IPTVPlayer/IPTVdaemon.*
	PYTHONPATH=$(TARGET_DIR)/$(PYTHON_DIR) \
	$(HOST_DIR)/bin/python$(PYTHON_VER_MAJOR) -Wi -t -O $(TARGET_DIR)/$(PYTHON_DIR)/compileall.py \
		-d /usr/share/E2emulator -f -x badsyntax $(TARGET_DIR)/usr/share/E2emulator
	cp -R $(BUILD_TMP)/iptvplayer/addon4neutrino/neutrinoIPTV/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/iptvplayer
	$(TOUCH)

#
# neutrino-hd2 plugin
#
NEUTRINO_HD2_PLUGINS_PATCHES =

$(D)/neutrino-hd2-plugin.do_prepare:
	$(START_BUILD)
	$(SILENT)rm -rf $(SOURCE_DIR)/neutrino-hd2-plugins
	$(SILENT)ln -s $(SOURCE_DIR)/neutrino-hd2.git/plugins $(SOURCE_DIR)/neutrino-hd2-plugins
	$(SET) -e; cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
		$(call apply_patches, $(NEUTRINO_HD2_PLUGINS_PATCHES))
	@touch $@

$(D)/neutrino-hd2-plugin.config.status: $(D)/bootstrap neutrino-hd2
	$(SILENT)cd $(SOURCE_DIR)/neutrino-hd2-plugins; \
		./autogen.sh; \
		$(BUILDENV) \
		./configure $(SILENT_CONFIGURE) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-datadir=/usr/share/tuxbox \
			--enable-silent-rules \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(CPPFLAGS) -I$(driverdir) -I$(KERNEL_DIR)/include -I$(TARGET_DIR)/include" \
			LDFLAGS="$(TARGET_LDFLAGS)"
	@touch $@

$(D)/neutrino-hd2-plugin.do_compile: $(D)/neutrino-hd2-plugin.config.status
	$(SILENT)cd $(SOURCE_DIR)/neutrino-hd2-plugins
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2-plugins top_srcdir=$(SOURCE_DIR)/neutrino-hd2
	@touch $@

$(D)/neutrino-hd2-plugins: $(D)/neutrino-hd2 neutrino-hd2-plugin.do_prepare neutrino-hd2-plugin.do_compile
	$(MAKE) -C $(SOURCE_DIR)/neutrino-hd2-plugins install DESTDIR=$(TARGET_DIR) top_srcdir=$(SOURCE_DIR)/neutrino-hd2
	$(TOUCH)

neutrino-hd2-plugin-clean:
	$(SILENT)cd $(SOURCE_DIR)/neutrino-hd2-plugins
	$(MAKE) clean
	$(SILENT)rm -f $(D)/neutrino-hd2-plugin
	$(SILENT)rm -f $(D)/neutrino-hd2-plugin.config.status

neutrino-hd2-plugin-distclean:
	rm -f $(D)/neutrino-hd2-plugin
	rm -f $(D)/neutrino-hd2-plugin.config.status
	rm -f $(D)/neutrino-hd2-plugin.do_prepare
	rm -f $(D)/neutrino-hd2-plugin.do_compile
