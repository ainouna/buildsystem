#
# tools
#
tools-clean:
	rm -f $(D)/tools-*
	-$(MAKE) -C $(APPS_DIR)/tools/aio-grab distclean
	-$(MAKE) -C $(APPS_DIR)/tools/satfind distclean
	-$(MAKE) -C $(APPS_DIR)/tools/showiframe distclean
	-$(MAKE) -C $(APPS_DIR)/tools/minimon distclean
	-$(MAKE) -C $(APPS_DIR)/tools/spf_tool distclean
	-$(MAKE) -C $(APPS_DIR)/tools/devinit distclean
	-$(MAKE) -C $(APPS_DIR)/tools/eplayer3 distclean
	-$(MAKE) -C $(APPS_DIR)/tools/evremote2 distclean
	-$(MAKE) -C $(APPS_DIR)/tools/fp_control distclean
	-$(MAKE) -C $(APPS_DIR)/tools/hotplug distclean
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
	-$(MAKE) -C $(APPS_DIR)/tools/ipbox_eeprom distclean
endif
ifeq ($(MEDIAFW), $(filter $(MEDIAFW), eplayer3 gst-eplayer3))
	-$(MAKE) -C $(APPS_DIR)/tools/libeplayer3 distclean
endif
ifeq ($(IMAGE), $(filter $(IMAGE), enigma2 enigma2-wlandriver))
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_host distclean
	-$(MAKE) -C $(APPS_DIR)/tools/libmme_image distclean
endif
	-$(MAKE) -C $(APPS_DIR)/tools/stfbcontrol distclean
	-$(MAKE) -C $(APPS_DIR)/tools/streamproxy distclean
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), tf7700))
	-$(MAKE) -C $(APPS_DIR)/tools/tfd2mtd distclean
	-$(MAKE) -C $(APPS_DIR)/tools/tffpctl distclean
endif
	-$(MAKE) -C $(APPS_DIR)/tools/ustslave distclean
	-$(MAKE) -C $(APPS_DIR)/tools/vfdctl distclean
	-$(MAKE) -C $(APPS_DIR)/tools/wait4button distclean
ifneq ($(wildcard $(APPS_DIR)/tools/own-tools),)
	-$(MAKE) -C $(APPS_DIR)/tools/own-tools distclean
endif

#
# aio-grab
#
$(D)/tools-aio-grab: $(D)/bootstrap $(D)/libpng $(D)/libjpeg
	$(START_BUILD)
	$(SET) -e; cd $(APPS_DIR)/tools/aio-grab; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/devinit; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/evremote2; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/fp_control; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/hotplug; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/ipbox_eeprom; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# libeplayer3
#
$(D)/tools-libeplayer3: $(D)/bootstrap $(D)/ffmpeg
	$(START_BUILD)
	$(SET) -e; cd $(APPS_DIR)/tools/libeplayer3; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# libmme_host
#
$(D)/tools-libmme_host: $(D)/bootstrap $(D)/driver
	$(START_BUILD)
	$(SET) -e; cd $(APPS_DIR)/tools/libmme_host; \
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
$(D)/tools-libmme_image: $(D)/bootstrap
	$(START_BUILD)
	$(SET) -e; cd $(APPS_DIR)/tools/libmme_image; \
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
$(D)/tools-minimon: $(D)/bootstrap $(D)/jpeg_turbo
	$(START_BUILD)
	$(SET) -e; cd $(APPS_DIR)/tools/minimon; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/satfind; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/showiframe; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/spf_tool; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/stfbcontrol; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/streamproxy; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/tfd2mtd; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/tffpctl; \
		$(CONFIGURE_TOOLS) \
		if [ ! -d m4 ]; then mkdir m4; fi; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/ustslave; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/vfdctl; \
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
	$(SET) -e; cd $(APPS_DIR)/tools/wait4button; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

#
# eplayer3
#
$(D)/tools-eplayer3: $(D)/bootstrap $(D)/ffmpeg
	$(START_BUILD)
	$(SET) -e; cd $(APPS_DIR)/tools/eplayer3; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
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
	$(SET) -e; cd $(APPS_DIR)/tools/own-tools; \
		if [ ! -d m4 ]; then mkdir m4; fi; \
		$(CONFIGURE_TOOLS) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

TOOLS  = $(D)/tools-aio-grab
TOOLS += $(D)/tools-satfind
TOOLS += $(D)/tools-showiframe
#TOOLS += $(D)/tools-minimon
TOOLS += $(D)/tools-devinit
TOOLS += $(D)/tools-evremote2
TOOLS += $(D)/tools-fp_control
TOOLS += $(D)/tools-hotplug
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd))
TOOLS += $(D)/tools-ipbox_eeprom
endif
TOOLS += $(D)/tools-stfbcontrol
TOOLS += $(D)/tools-streamproxy
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), tf7700))
TOOLS += $(D)/tools-tfd2mtd
TOOLS += $(D)/tools-tffpctl
endif
TOOLS += $(D)/tools-ustslave
TOOLS += $(D)/tools-vfdctl
TOOLS += $(D)/tools-wait4button
ifeq ($(IMAGE), $(filter $(IMAGE), enigma2 enigma2-wlandriver))
TOOLS += $(D)/tools-libmme_host
TOOLS += $(D)/tools-libmme_image
endif
ifeq ($(E2_DIFF), $(filter $(E2_DIFF), 4 5))
ifeq ($(MEDIAFW), $(filter $(MEDIAFW), gst-eplayer3))
TOOLS += $(D)/tools-libeplayer3
endif
ifeq ($(MEDIAFW), $(filter $(MEDIAFW), eplayer3))
TOOLS += $(D)/tools-eplayer3
endif
endif
ifneq ($(wildcard $(APPS_DIR)/tools/own-tools),)
TOOLS += $(D)/tools-own-tools
endif

$(D)/tools: $(TOOLS)
	$(START_BUILD)
	$(TOUCH)

