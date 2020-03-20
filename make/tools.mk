#
# tools
#
tools-clean:
	rm -f $(D)/tools-*
	-$(MAKE) -C $(TOOLS_DIR)/aio-grab distclean
	-$(MAKE) -C $(TOOLS_DIR)/satfind distclean
	-$(MAKE) -C $(TOOLS_DIR)/showiframe distclean
	-$(MAKE) -C $(TOOLS_DIR)/minimon distclean
	-$(MAKE) -C $(TOOLS_DIR)/spf_tool distclean
	-$(MAKE) -C $(TOOLS_DIR)/devinit distclean
	-$(MAKE) -C $(TOOLS_DIR)/eplayer3 distclean
	-$(MAKE) -C $(TOOLS_DIR)/exteplayer3 distclean
	-$(MAKE) -C $(TOOLS_DIR)/evremote2 distclean
	-$(MAKE) -C $(TOOLS_DIR)/fp_control distclean
	-$(MAKE) -C $(TOOLS_DIR)/hotplug distclean
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hs7110 hs7420 hs7810a hs7119 hs7429 hs7819))
	-$(MAKE) -C $(TOOLS_DIR)/eeprom_fortis distclean
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
	-$(MAKE) -C $(TOOLS_DIR)/eeprom_ipbox distclean
endif
ifeq ($(MEDIAFW), $(filter $(MEDIAFW), eplayer3 gst-eplayer3))
	-$(MAKE) -C $(TOOLS_DIR)/libeplayer3_org distclean
	-$(MAKE) -C $(TOOLS_DIR)/libeplayer3 distclean
endif
ifeq ($(IMAGE), $(filter $(IMAGE), enigma2 enigma2-wlandriver))
	-$(MAKE) -C $(TOOLS_DIR)/libmme_host distclean
	-$(MAKE) -C $(TOOLS_DIR)/libmme_image distclean
endif
	-$(MAKE) -C $(TOOLS_DIR)/stfbcontrol distclean
	-$(MAKE) -C $(TOOLS_DIR)/streamproxy distclean
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), tf7700))
	-$(MAKE) -C $(TOOLS_DIR)/tfd2mtd distclean
	-$(MAKE) -C $(TOOLS_DIR)/tffpctl distclean
endif
	-$(MAKE) -C $(TOOLS_DIR)/ustslave distclean
	-$(MAKE) -C $(TOOLS_DIR)/vfdctl distclean
	-$(MAKE) -C $(TOOLS_DIR)/wait4button distclean
ifneq ($(wildcard $(TOOLS_DIR)/own-tools),)
	-$(MAKE) -C $(TOOLS_DIR)/own-tools distclean
endif

#
# aio-grab
#
$(D)/tools-aio-grab: $(D)/bootstrap $(D)/libpng $(D)/libjpeg
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/aio-grab; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) CPPFLAGS="$(CPPFLAGS) -I$(DRIVER_DIR)/bpamem" \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# devinit
#
$(D)/tools-devinit: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/devinit; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# evremote2
#
$(D)/tools-evremote2: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/evremote2; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# fortis_eeprom
#
$(D)/tools-fortis_eeprom: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/fortis_eeprom; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# fp_control
#
$(D)/tools-fp_control: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/fp_control; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# hotplug
#
$(D)/tools-hotplug: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/hotplug; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# ipbox_eeprom
#
$(D)/tools-ipbox_eeprom: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/ipbox_eeprom; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# libeplayer3
# CAUTION: name is misleading; builds a library and an executable
$(D)/tools-libeplayer3: $(D)/bootstrap $(D)/ffmpeg $(D)/libass
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/libeplayer3; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix=/usr \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# libeplayer3_new
#
$(D)/tools-libeplayer3_new: $(D)/bootstrap $(D)/ffmpeg
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/libeplayer3_new; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		autoreconf -fi $(SILENT_OPT); \
		$(CONFIGURE) \
			--prefix=/usr \
			--enable-silent-rules \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# libmme_host
#
$(D)/tools-libmme_host: $(D)/bootstrap $(D)/driver
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/libmme_host; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) DRIVER_TOPDIR=$(DRIVER_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) DRIVER_TOPDIR=$(DRIVER_DIR)
	$(TOUCH)

#
# libmme_image
#
$(D)/tools-libmme_image: $(D)/bootstrap $(D)/libjpeg
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/libmme_image; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) DRIVER_TOPDIR=$(DRIVER_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) DRIVER_TOPDIR=$(DRIVER_DIR)
	$(TOUCH)

#
# minimon
#
$(D)/tools-minimon: $(D)/bootstrap $(D)/libjpeg $(D)/libusb
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/minimon; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) KERNEL_DIR=$(KERNEL_DIR) TARGET=$(TARGET) TARGET_DIR=$(TARGET_DIR); \
		$(MAKE) install KERNEL_DIR=$(KERNEL_DIR) TARGET=$(TARGET) TARGET_DIR=$(TARGET_DIR) DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# satfind
#
$(D)/tools-satfind: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/satfind; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# showiframe
#
$(D)/tools-showiframe: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/showiframe; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# spf_tool
#
$(D)/tools-spf_tool: $(D)/bootstrap $(D)/libusb
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/spf_tool; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# stfbcontrol
#
$(D)/tools-stfbcontrol: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/stfbcontrol; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# streamproxy
#
$(D)/tools-streamproxy: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/streamproxy; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# tfd2mtd
#
$(D)/tools-tfd2mtd: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/tfd2mtd; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# tffpctl
#
$(D)/tools-tffpctl: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/tffpctl; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# ustslave
#
$(D)/tools-ustslave: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/ustslave; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# vfdctl
#
ifeq ($(BOXTYPE), spark7162)
EXTRA_CPPFLAGS=-DHAVE_SPARK7162_HARDWARE
endif

$(D)/tools-vfdctl: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/vfdctl; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE) CPPFLAGS="$(EXTRA_CPPFLAGS)"; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# wait4button
#
$(D)/tools-wait4button: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/wait4button; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# eplayer3
# CAUTION: name is misleading; builds a library only
$(D)/tools-eplayer3: $(D)/bootstrap $(D)/ffmpeg
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/eplayer3; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix=/usr\
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# exteplayer3
#
$(D)/tools-exteplayer3: $(D)/bootstrap $(D)/ffmpeg
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/exteplayer3; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# own-tools
#
$(D)/tools-own-tools: $(D)/bootstrap $(D)/libcurl
	$(START_BUILD)
	$(SET) -e; cd $(TOOLS_DIR)/own-tools; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

TOOLS  = $(D)/tools-devinit
TOOLS += $(D)/tools-evremote2
#TOOLS += $(D)/tools-exteplayer3
TOOLS += $(D)/tools-showiframe
TOOLS += $(D)/tools-hotplug
TOOLS += $(D)/tools-stfbcontrol
TOOLS += $(D)/tools-ustslave
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), adb_box atemio520 atemio530 atevio7500 cuberevo cuberevo_250hd cuberevo_2000hd cuberevo_3000hd cuberevo_9500hd cuberevo_mini cuberevo_mini2 cuberevo_mini_fta fortis_hdbox hl101 hs5101 hs7110 hs7420 hs7810a hs7119 hs7429 hs7819 octagon1008 ufc960 ufs910 ufs912 ufs913 ufs922 spark spark7162 tf7700hdpvr vip1-v2 vip2-v1 vitamin_hd5000))
TOOLS += $(D)/tools-fp_control
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hs7110 hs7420 hs7810a hs7119 hs7249 hs7819))
TOOLS += $(D)/tools-eeprom-fortis
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
TOOLS += $(D)/tools-eeprom-ipbox
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), tf7700))
TOOLS += $(D)/tools-tfd2mtd
TOOLS += $(D)/tools-tffpctl
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs912 ufs913 spark7162))
TOOLS += $(D)/tools-vfdctl
endif
ifneq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), small))
TOOLS += $(D)/tools-streamproxy
TOOLS += $(D)/tools-wait4button
endif
ifneq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), small size))
TOOLS += $(D)/tools-aio-grab
TOOLS += $(D)/tools-satfind
ifneq ($(EXTERNAL_LCD), none)
#TOOLS += $(D)/tools-minimon
endif
endif
ifeq ($(IMAGE), $(filter $(IMAGE), enigma2 enigma2-wlandriver))
TOOLS += $(D)/tools-libmme_host
TOOLS += $(D)/tools-libmme_image
endif
ifneq ($(wildcard $(TOOLS_DIR)/own-tools),)
TOOLS += $(D)/tools-own-tools
endif

$(D)/tools: $(TOOLS)
	$(START_BUILD)
	$(TOUCH)

