#
# auxiliary targets for model-specific builds
#

#
# release_cube_common
#
neutrino-release-cube_common:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_cuberevo $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)install -m 0777 $(SKEL_ROOT)/release/reboot_cuberevo $(RELEASE_DIR)/etc/init.d/reboot
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-cx24116.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/

#
# release_cube_common_tuner
#
neutrino-release-cube_common_tuner:
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/multituner/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/media/dvb/frontends/dvb-pll.ko $(RELEASE_DIR)/lib/modules/

#
# cuberevo_9500hd
#
neutrino-release-cuberevo_9500hd: neutrino-release-cube_common neutrino-release-cube_common_tuner
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/ipbox/micom.ko $(RELEASE_DIR)/lib/modules/

#
# cuberevo_2000hd
#
neutrino-release-cuberevo_2000hd: neutrino-release-cube_common neutrino-release-cube_common_tuner
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cuberevo_micom/cuberevo_micom.ko $(RELEASE_DIR)/lib/modules/

#
# cuberevo_250hd
#
neutrino-release-cuberevo_250hd: neutrino-release-cube_common neutrino-release-cube_common_tuner
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cuberevo_micom/cuberevo_micom.ko $(RELEASE_DIR)/lib/modules/

#
# cuberevo_mini_fta
#
neutrino-release-cuberevo_mini_fta: neutrino-release-cube_common neutrino-release-cube_common_tuner
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cuberevo_micom/cuberevo_micom.ko $(RELEASE_DIR)/lib/modules/

#
# cuberevo_mini2
#
neutrino-release-cuberevo_mini2: neutrino-release-cube_common neutrino-release-cube_common_tuner
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cuberevo_micom/cuberevo_micom.ko $(RELEASE_DIR)/lib/modules/

#
# cuberevo_mini
#
neutrino-release-cuberevo_mini: neutrino-release-cube_common neutrino-release-cube_common_tuner
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cuberevo_micom/cuberevo_micom.ko $(RELEASE_DIR)/lib/modules/

#
# cuberevo
#
neutrino-release-cuberevo: neutrino-release-cube_common neutrino-release-cube_common_tuner
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cuberevo_micom/cuberevo_micom.ko $(RELEASE_DIR)/lib/modules/

#
# cuberevo_3000hd
#
neutrino-release-cuberevo_3000hd: neutrino-release-cube_common neutrino-release-cube_common_tuner
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cuberevo_micom/cuberevo_micom.ko $(RELEASE_DIR)/lib/modules/

#
# common_ipbox
#
neutrino-release-common_ipbox:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_ipbox $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/siinfo/siinfo.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp -f $(SKEL_ROOT)/release/fstab_ipbox $(RELEASE_DIR)/etc/fstab
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/as102_data1_st.hex $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/as102_data2_st.hex $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_ipbox.conf $(RELEASE_DIR)/etc/lircd.conf
	$(SILENT)rm -f $(RELEASE_DIR)/lib/firmware/*
	$(SILENT)rm -f $(RELEASE_DIR)/lib/modules/boxtype.ko
	$(SILENT)rm -f $(RELEASE_DIR)/etc/network/interfaces

#
# ipbox9900
#
neutrino-release-ipbox9900: neutrino-release-common_ipbox
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/ipbox99xx/micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/rmu/rmu.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/ipbox99xx_fan/ipbox_fan.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp -p $(SKEL_ROOT)/release/tvmode_ipbox $(RELEASE_DIR)/usr/bin/tvmode

#
# ipbox99
#
neutrino-release-ipbox99: neutrino-release-common_ipbox
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/ipbox99xx/micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/ipbox99xx_fan/ipbox_fan.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp -p $(SKEL_ROOT)/release/tvmode_ipbox $(RELEASE_DIR)/usr/bin/tvmode

#
# ipbox55
#
neutrino-release-ipbox55: neutrino-release-common_ipbox
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/ipbox55/front.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp -p $(SKEL_ROOT)/release/tvmode_ipbox55 $(RELEASE_DIR)/usr/bin/tvmode

#
# ufs910
#
neutrino-release-ufs910: $(D)/uboot-utils
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_ufs $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/ufs910_fp/ufs910_fp.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7100.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7100.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-cx21143.fw $(RELEASE_DIR)/lib/firmware/dvb-fe-cx24116.fw
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_ufs910.conf $(RELEASE_DIR)/etc/lircd.conf
	$(SILENT)rm -f $(RELEASE_DIR)/bin/vdstandby
	$(SILENT)cp $(TARGET_DIR)/usr/bin/fw_setenv $(RELEASE_DIR)/usr/bin/
	$(SILENT)ln -sf $(RELEASE_DIR)/usr/bin/fw_setenv $(RELEASE_DIR)/usr/bin/fw_printenv

#
# ufs912
#
neutrino-release-ufs912:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_ufs912 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/kathrein_micom/kathrein_micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# ufs913
#
neutrino-release-ufs913:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_ufs912 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/kathrein_micom/kathrein_micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/multituner/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/

#
# ufs922
#
neutrino-release-ufs922:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_ufs $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/kathrein_micom/kathrein_micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-cx21143.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)touch $(RELEASE_DIR)/var/etc/.rccode
	$(SILENT)echo "1" > $(RELEASE_DIR)/var/etc/.rccode
ifeq ($(DESTINATION), flash)
	$(MAKE) $(D)/ufsinstaller
endif

#
# ufc960
#
neutrino-release-ufc960:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_ufs $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/micom/micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-cx21143.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/

#
# spark
#
neutrino-release-spark:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_spark $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/aotom_spark/aotom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw
	$(SILENT)rm -f $(RELEASE_DIR)/bin/vdstandby
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_spark.conf $(RELEASE_DIR)/etc/lircd.conf

#
# spark7162
#
neutrino-release-spark7162:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_spark7162 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/aotom_spark/aotom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	$(SILENT)rm -f $(RELEASE_DIR)/bin/vdstandby
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_spark7162.conf $(RELEASE_DIR)/etc/lircd.conf
	$(SILENT)cp $(SKEL_ROOT)/release/fw_env.config_$(BOXTYPE)_neutrino $(RELEASE_DIR)/etc/fw_env.config

#
# fs9000
#
neutrino-release-fs9000:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_fs9000 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf

#
# hs8200
#
neutrino-release-hs8200:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_fs9000 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/multituner/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)rm -f $(RELEASE_DIR)/lib/modules/boxtype.ko
	$(SILENT)rm  -f $(RELEASE_DIR)/lib/modules/mpeg2hw.ko

#
# hs9510
#
neutrino-release-hs9510:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_hs9510 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/

#
# hs7110
#
neutrino-release-hs7110:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_hs7110 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# hs7119
#
neutrino-release-hs7119:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_hs7119 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# hs7420
#
neutrino-release-hs7420:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_hs742x $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)chmod 755 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# hs7429
#
neutrino-release-hs7429:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_hs742x $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)chmod 755 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# hs7810a
#
neutrino-release-hs7810a:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_hs7810a $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# hs7819
#
neutrino-release-hs7819:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_hs7819 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/nuvoton/nuvoton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# atemio520
#
neutrino-release-atemio520:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_atemio520 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cn_micom/cn_micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# adb_box
#
neutrino-release-adb_box:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_adb_box $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/adb_5800_fp/adb_5800_fp.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7100.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cec_adb_box/cec_ctrl.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/dvbt/as102/dvb-as102.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7100.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/as102_data1_st.hex $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/as102_data2_st.hex $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp -f $(SKEL_ROOT)/release/fstab_adb_box $(RELEASE_DIR)/etc/fstab
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_adb_box.conf $(RELEASE_DIR)/etc/lircd.conf

#
# tf7700
#
neutrino-release-tf7700:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_tf7700 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/tffp/tffp.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-cx24116.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp -f $(SKEL_ROOT)/release/fstab_tf7700 $(RELEASE_DIR)/etc/fstab
ifeq ($(DESTINATION), flash)
	$(MAKE) $(D)/tfinstaller
endif

#
# vitamin_hd5000
#
neutrino-release-vitamin_hd5000:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_ufs912 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/vitamin_hd5000/micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/smartcard/smartcard.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# sagemcom88
#
neutrino-release-sagemcom88:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_ufs912 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/front_led/front_led.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/front_vfd/front_vfd.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/sagemcomtype/boxtype.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)[ -e $(SKEL_ROOT)/release/fe_core_sagemcom88$(KERNEL_STM_LABEL).ko ] && cp $(SKEL_ROOT)/release/fe_core_sagemcom88$(KERNEL_STM_LABEL).ko $(RELEASE_DIR)/lib/modules/fe_core.ko || true
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_sagemcom88.conf $(RELEASE_DIR)/etc/lircd.conf

#
# arivalink200
#
neutrino-release-arivalink200:
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/front_ArivaLink200/vfd.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/front_ArivaLink200/vfd.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-cx24116.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_arivalink200.conf $(RELEASE_DIR)/etc/lircd.conf

#
# hl101
#
neutrino-release-hl101:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_hl101 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/proton/proton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/as102_data1_st.hex $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/as102_data2_st.hex $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_hl101.conf $(RELEASE_DIR)/etc/lircd.conf

#
# vip1_v1
#
neutrino-release-vip1_v1:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_hl101 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/proton/proton.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/as102_data1_st.hex $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/as102_data2_st.hex $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_vip_rc12.conf $(RELEASE_DIR)/etc/lircd.conf
	$(SILENT)touch $(RELEASE_DIR)/var/etc/.rccode
	$(SILENT)echo "1" > $(RELEASE_DIR)/var/etc/.rccode

#
# vip1_v2
#
neutrino-release-vip1_v2:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_vip2 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/aotom_vip/aotom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
#	$(SILENT)rm -f $(RELEASE_DIR)/lib/firmware/dvb-fe-{avl2108,avl6222,cx24116,cx21143,stv6306}.fw
#	$(SILENT)cp -f $(SKEL_ROOT)/release/fstab_vip2 $(RELEASE_DIR)/etc/fstab
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_vip_rc12.conf $(RELEASE_DIR)/etc/lircd.conf
	$(SILENT)cp -f $(TARGET_DIR)/sbin/shutdown $(RELEASE_DIR)/sbin/
	$(SILENT)mkdir -p $(RELEASE_DIR)/var/run/lirc
	$(SILENT)rm -f $(RELEASE_DIR)/bin/vdstandby
	$(SILENT)touch $(RELEASE_DIR)/var/etc/.rccode
	$(SILENT)echo "1" > $(RELEASE_DIR)/var/etc/.rccode

#
# vip2
#
neutrino-release-vip2: neutrino-release-vip1_v2
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_vip_rc12.conf $(RELEASE_DIR)/etc/lircd.conf
	$(SILENT)touch $(RELEASE_DIR)/var/etc/.rccode
	$(SILENT)echo "1" > $(RELEASE_DIR)/var/etc/.rccode

#
# pace7241
#
neutrino-release-pace7241:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_ufs912 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/pace_7241_fp/pace_7241_fp.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)[ -e $(SKEL_ROOT)/release/fe_core_pace7241$(KERNEL_STM_LABEL).ko ] && cp $(SKEL_ROOT)/release/fe_core_space7241$(KERNEL_STM_LABEL).ko $(RELEASE_DIR)/lib/modules/fe_core.ko || true
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	$(SILENT)cp -dp $(SKEL_ROOT)/release/lircd_pace7241.conf $(RELEASE_DIR)/etc/lircd.conf

#
# opt9600
#
neutrino-release-opt9600:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_opt9600 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/opt9600_fp/opt9600_fp.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7109.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/

#
# opt9600mini
#
neutrino-release-opt9600mini:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_atemio520 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cn_micom/cn_micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# opt9600prima
#
neutrino-release-opt9600prima:
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/halt_atemio520 $(RELEASE_DIR)/etc/init.d/halt
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/cn_micom/cn_micom.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/lnb/lnb.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	$(SILENT)cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	$(SILENT)cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	$(SILENT)cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	$(SILENT)cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/

#
# neutrino-release-base
#
# the following target creates the common file base
neutrino-release-base:
	$(SILENT)echo "=============================================================="
	$(SILENT)echo
	$(SILENT)echo -e "Start build of $(TERM_GREEN_BOLD)neutrino_release$(TERM_NORMAL)."
	$(SILENT)rm -rf $(RELEASE_DIR) || true
	$(SILENT)echo -n "Copying image to release directory..."
	$(SILENT)install -d $(RELEASE_DIR)
	$(SILENT)install -d $(RELEASE_DIR)/{autofs,bin,boot,dev,dev.static,etc,hdd,home,lib,media,mnt,proc,ram,root,sbin,swap,sys,tmp,usr,var}
	$(SILENT)install -d $(RELEASE_DIR)/etc/{init.d,network,mdev,ssl}
	$(SILENT)install -d $(RELEASE_DIR)/etc/network/if-{post-{up,down},pre-{up,down},up,down}.d
	$(SILENT)install -d $(RELEASE_DIR)/lib/{modules,udev,firmware,tuxbox}
	$(SILENT)install -d $(RELEASE_DIR)/lib/tuxbox/plugins
	$(SILENT)install -d $(RELEASE_DIR)/media/{dvd,nfs,usb,sda1,sdb1}
	$(SILENT)ln -sf /hdd $(RELEASE_DIR)/media/hdd
	$(SILENT)install -d $(RELEASE_DIR)/mnt/{hdd,nfs,usb}
	$(SILENT)install -d $(RELEASE_DIR)/mnt/mnt{0..7}
	$(SILENT)install -d $(RELEASE_DIR)/usr/{bin,lib,sbin,share}
	$(SILENT)install -d $(RELEASE_DIR)/usr/lib/tuxbox/{luaplugins,plugins}
ifneq ($(FLAVOUR), $(filter $(FLAVOUR), neutrino-hd2, neutrino-hd2 + plugins))
	$(SILENT)install -d $(RELEASE_DIR)/usr/share/{fonts,tuxbox,udhcpc,zoneinfo,lua}
else
	$(SILENT)install -d $(RELEASE_DIR)/usr/share/{tuxbox,udhcpc,zoneinfo,lua}
endif
	$(SILENT)install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino
ifeq ($(FLAVOUR), $(filter $(FLAVOUR), neutrino-hd2, neutrino-hd2 + plugins))
	$(SILENT)install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino/fonts
endif
	$(SILENT)install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/logo
	$(SILENT)install -d $(RELEASE_DIR)/usr/share/lua/5.2
	$(SILENT)install -d $(RELEASE_DIR)/var/{bin,boot,emu,etc,epg,httpd,keys,lib,logos,net,tuxbox,update}
	$(SILENT)install -d $(RELEASE_DIR)/var/lib/{nfs,modules}
	$(SILENT)install -d $(RELEASE_DIR)/var/net/epg
	$(SILENT)install -d $(RELEASE_DIR)/var/tuxbox/{config,fonts,locale,plugins,themes}
	$(SILENT)install -d $(RELEASE_DIR)/var/tuxbox/webtv
	$(SILENT)install -d $(RELEASE_DIR)/var/tuxbox/config/{webtv,zapit}
	$(SILENT)mkdir -p $(RELEASE_DIR)/etc/rc.d/rc0.d
	$(SILENT)ln -s ../init.d/sendsigs $(RELEASE_DIR)/etc/rc.d/rc0.d/S20sendsigs
	$(SILENT)ln -s ../init.d/umountfs $(RELEASE_DIR)/etc/rc.d/rc0.d/S40umountfs
	$(SILENT)ln -s ../init.d/halt $(RELEASE_DIR)/etc/rc.d/rc0.d/S90halt
	$(SILENT)mkdir -p $(RELEASE_DIR)/etc/rc.d/rc6.d
	$(SILENT)ln -s ../init.d/sendsigs $(RELEASE_DIR)/etc/rc.d/rc6.d/S20sendsigs
	$(SILENT)ln -s ../init.d/umountfs $(RELEASE_DIR)/etc/rc.d/rc6.d/S40umountfs
	$(SILENT)ln -s ../init.d/reboot $(RELEASE_DIR)/etc/rc.d/rc6.d/S90reboot
	$(SILENT)ln -sf /usr/share/tuxbox/neutrino/icons/logo $(RELEASE_DIR)/logos
	$(SILENT)ln -sf /usr/share/tuxbox/neutrino/icons/logo $(RELEASE_DIR)/var/httpd/logos
	$(SILENT)touch $(RELEASE_DIR)/var/etc/.firstboot
	$(SILENT)cp -a $(TARGET_DIR)/bin/* $(RELEASE_DIR)/bin/
	$(SILENT)cp -a $(TARGET_DIR)/usr/bin/* $(RELEASE_DIR)/usr/bin/
	$(SILENT)cp -a $(TARGET_DIR)/sbin/* $(RELEASE_DIR)/sbin/
	$(SILENT)cp -a $(TARGET_DIR)/usr/sbin/* $(RELEASE_DIR)/usr/sbin/
	$(SILENT)cp -dp $(TARGET_DIR)/.version $(RELEASE_DIR)/
	$(SILENT)ln -sf /.version $(RELEASE_DIR)/var/etc/.version
	$(SILENT)cp $(TARGET_DIR)/boot/$(KERNELNAME) $(RELEASE_DIR)/boot/
	$(SILENT)ln -sf /proc/mounts $(RELEASE_DIR)/etc/mtab
	$(SILENT)cp -dp $(SKEL_ROOT)/sbin/MAKEDEV $(RELEASE_DIR)/sbin/
	$(SILENT)ln -sf ../sbin/MAKEDEV $(RELEASE_DIR)/dev/MAKEDEV
	$(SILENT)ln -sf ../../sbin/MAKEDEV $(RELEASE_DIR)/lib/udev/MAKEDEV
	$(SILENT)cp -aR $(SKEL_ROOT)/etc/mdev/* $(RELEASE_DIR)/etc/mdev/
	$(SILENT)cp -aR $(SKEL_ROOT)/etc/mdev.conf $(RELEASE_DIR)/etc/mdev.conf
	$(SILENT)cp -aR $(SKEL_ROOT)/usr/share/udhcpc/* $(RELEASE_DIR)/usr/share/udhcpc/
	$(SILENT)cp -aR $(SKEL_ROOT)/usr/share/zoneinfo/* $(RELEASE_DIR)/usr/share/zoneinfo/
	$(SILENT)cp $(SKEL_ROOT)/bin/autologin $(RELEASE_DIR)/bin/
	$(SILENT)cp $(SKEL_ROOT)/bin/vdstandby $(RELEASE_DIR)/bin/
	$(SILENT)cp $(SKEL_ROOT)/usr/sbin/fw_printenv $(RELEASE_DIR)/usr/sbin/
	$(SILENT)cp -aR $(TARGET_DIR)/etc/init.d/* $(RELEASE_DIR)/etc/init.d/
	$(SILENT)cp -aR $(TARGET_DIR)/etc/* $(RELEASE_DIR)/etc/
	$(SILENT)echo "$(BOXTYPE)" > $(RELEASE_DIR)/etc/hostname
	$(SILENT)ln -sf ../../bin/busybox $(RELEASE_DIR)/usr/bin/ether-wake
	$(SILENT)ln -sf ../../bin/showiframe $(RELEASE_DIR)/usr/bin/showiframe
	$(SILENT)ln -sf ../../usr/sbin/fw_printenv $(RELEASE_DIR)/usr/sbin/fw_setenv
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hs8200 fs9000 hs9510 ufs910 ufs912 ufs913 ufs922 ufc960 spark ipbox55 ipbox99 ipbox9900 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_250hd cuberevo_2000hd cuberevo_3000hd adb_box tf7700 vitamin_hd5000))
	$(SILENT)cp $(SKEL_ROOT)/release/fw_env.config_$(BOXTYPE) $(RELEASE_DIR)/etc/fw_env.config
endif
	$(SILENT)install -m 0755 $(SKEL_ROOT)/release/rcS_neutrino_$(BOXTYPE) $(RELEASE_DIR)/etc/init.d/rcS
#
# player
#
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stm_v4l2.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stm_v4l2.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmfb.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmfb.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmvbi.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmvbi.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmvout.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmvout.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)cd $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra && \
	for mod in \
		sound/pseudocard/pseudocard.ko \
		sound/silencegen/silencegen.ko \
		stm/mmelog/mmelog.ko \
		stm/monitor/stm_monitor.ko \
		media/dvb/stm/dvb/stmdvb.ko \
		sound/ksound/ksound.ko \
		media/dvb/stm/mpeg2_hard_host_transformer/mpeg2hw.ko \
		media/dvb/stm/backend/player2.ko \
		media/dvb/stm/h264_preprocessor/sth264pp.ko \
		media/dvb/stm/allocator/stmalloc.ko \
		stm/platform/platform.ko \
		stm/platform/p2div64.ko \
		media/sysfs/stm/stmsysfs.ko \
	;do \
		if [ -e player2/linux/drivers/$$mod ]; then \
			cp player2/linux/drivers/$$mod $(RELEASE_DIR)/lib/modules/; \
			$(TARGET)-strip --strip-unneeded $(RELEASE_DIR)/lib/modules/`basename $$mod`; \
		else \
			touch $(RELEASE_DIR)/lib/modules/`basename $$mod`; \
		fi; \
	done
#
# modules
#
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/avs/avs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/avs/avs.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/bpamem/bpamem.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/bpamem/bpamem.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/boxtype/boxtype.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/boxtype/boxtype.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/compcache/ramzswap.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/compcache/ramzswap.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/e2_proc/e2_proc.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/e2_proc/e2_proc.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/ipv6/ipv6.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/ipv6/ipv6.ko $(RELEASE_DIR)/lib/modules/ || true
#
# multicom
#
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshell/embxshell.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshell/embxshell.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxmailbox/embxmailbox.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxmailbox/embxmailbox.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshm/embxshm.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshm/embxshm.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/mme/mme_host.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/mme/mme_host.ko $(RELEASE_DIR)/lib/modules/ || true
#
#
#
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/simu_button/simu_button.ko $(RELEASE_DIR)/lib/modules/
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), cuberevo_mini_fta cuberevo_250hd vip2 spark spark7162 adb_box adb_2850 sagemcom88 pace7241))
	$(SILENT)cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cic/*.ko $(RELEASE_DIR)/lib/modules/
endif
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/button/button.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/button/button.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cec/cec.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cec/cec.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cpu_frequ/cpu_frequ.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cpu_frequ/cpu_frequ.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/led/led.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/led/led.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti/pti.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti/pti.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti_np/pti.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti_np/pti.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/smartcard/smartcard.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/smartcard/smartcard.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/sata_switch/sata.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/sata_switch/sata.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/mini_fo/mini_fo.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/mini_fo/mini_fo.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/autofs4/autofs4.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/autofs4/autofs4.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/tun.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/tun.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/fuse/fuse.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/fuse/fuse.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/ntfs/ntfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/ntfs/ntfs.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/cifs/cifs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/cifs/cifs.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/jfs/jfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/jfs/jfs.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfsd/nfsd.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfsd/nfsd.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/exportfs/exportfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/exportfs/exportfs.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs_common/nfs_acl.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs_common/nfs_acl.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs/nfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs/nfs.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko $(RELEASE_DIR)/lib/modules/ftdi.ko || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko $(RELEASE_DIR)/lib/modules/ || true
#
# wlan
#
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/mt7601u/mt7601Usta.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/mt7601u/mt7601Usta.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt2870sta/rt2870sta.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt2870sta/rt2870sta.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt3070sta/rt3070sta.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt3070sta/rt3070sta.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt5370sta/rt5370sta.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rt5370sta/rt5370sta.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl871x/8712u.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl871x/8712u.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8188eu/8188eu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8188eu/8188eu.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192cu/8192cu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192cu/8192cu.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192du/8192du.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192du/8192du.ko $(RELEASE_DIR)/lib/modules/ || true
	$(SILENT)[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192eu/8192eu.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/wireless/rtl8192eu/8192eu.ko $(RELEASE_DIR)/lib/modules/ || true
#
# wlan firmware
#
ifeq ($(IMAGE), neutrino-wlandriver)
	$(SILENT)install -d $(RELEASE_DIR)/etc/Wireless
	$(SILENT)cp -aR $(SKEL_ROOT)/firmware/Wireless/* $(RELEASE_DIR)/etc/Wireless/
	$(SILENT)cp -aR $(SKEL_ROOT)/firmware/rtlwifi $(RELEASE_DIR)/lib/firmware/
	$(SILENT)cp -aR $(SKEL_ROOT)/firmware/*.bin $(RELEASE_DIR)/lib/firmware/
endif
#
# modules.available
#
	$(SILENT)cp -aR $(SKEL_ROOT)/release/modules.available $(RELEASE_DIR)/etc/modules.available
#
# lib usr/lib
#
	$(SILENT)cp -R $(TARGET_DIR)/lib/* $(RELEASE_DIR)/lib/
	$(SILENT)rm -f $(RELEASE_DIR)/lib/*.{a,o,la}
	$(SILENT)chmod 755 $(RELEASE_DIR)/lib/*
	$(SILENT)ln -s /var/tuxbox/plugins/libfx2.so $(RELEASE_DIR)/lib/libfx2.so
	$(SILENT)cp -R $(TARGET_DIR)/usr/lib/* $(RELEASE_DIR)/usr/lib/
	$(SILENT)rm -rf $(RELEASE_DIR)/usr/lib/{engines,gconv,libxslt-plugins,pkgconfig,python$(PYTHON_VER),sigc++-2.0}
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/*.{a,o,la}
	$(SILENT)chmod 755 $(RELEASE_DIR)/usr/lib/*
#
# fonts
#
ifneq ($(FLAVOUR), $(filter $(FLAVOUR), neutrino-hd2, neutrino-hd2 + plugins))
	$(SILENT)if [ -e $(TARGET_DIR)/usr/share/fonts/ubuntu-l-webfont.ttf ]; then \
		cp -aR $(TARGET_DIR)/usr/share/fonts $(RELEASE_DIR)/usr/share/; \
	else \
		if [ -e $(TARGET_DIR)/usr/share/fonts/neutrino.ttf ]; then \
			cp -aR $(TARGET_DIR)/usr/share/fonts/neutrino.ttf $(RELEASE_DIR)/usr/share/fonts; \
		fi; \
		if [ -e $(TARGET_DIR)/usr/share/fonts/micron.ttf ]; then \
			cp -aR $(TARGET_DIR)/usr/share/fonts/micron.ttf $(RELEASE_DIR)/usr/share/fonts; \
		fi; \
		if [ -e $(TARGET_DIR)/usr/share/fonts/DejaVuLGCSansMono-Bold.ttf ]; then \
			cp -aR $(TARGET_DIR)/usr/share/fonts/DejaVuLGCSansMono-Bold.ttf $(RELEASE_DIR)/usr/share/fonts; \
			ln -s /usr/share/fonts/DejaVuLGCSansMono-Bold.ttf $(RELEASE_DIR)/usr/share/fonts/tuxtxt.ttf; \
		else \
			cp -aR $(TARGET_DIR)/usr/share/fonts/tuxtxt.ttf $(RELEASE_DIR)/usr/share/fonts; \
		fi; \
	fi
else
	$(SILENT)if [ -d $(TARGET_DIR)/usr/share/tuxbox/neutrino/fonts ]; then \
		cp -aR $(TARGET_DIR)/usr/share/tuxbox/neutrino/fonts $(RELEASE_DIR)/usr/share/tuxbox/neutrino/; \
	fi
endif
#
# neutrino
#
ifeq ($(FLAVOUR), $(filter $(FLAVOUR), neutrino-hd2, neutrino-hd2 + plugins))
#	$(SILENT)ln -sf /usr/share $(RELEASE_DIR)/usr/local/share
	$(SILENT)if [ -e $(TARGET_DIR)/usr/local/bin/neutrino ]; then \
		cp $(TARGET_DIR)/usr/local/bin/neutrino $(RELEASE_DIR)/usr/bin/; \
	fi
	$(SILENT)if [ -e $(TARGET_DIR)/usr/local/bin/pzapit ]; then \
		cp $(TARGET_DIR)/usr/local/bin/pzapit $(RELEASE_DIR)/usr/bin/; \
	fi
	$(SILENT)if [ -e $(TARGET_DIR)/usr/local/bin/sectionsdcontrol ]; then \
		cp $(TARGET_DIR)/usr/local/bin/sectionsdcontrol $(RELEASE_DIR)/usr/bin/; \
	fi
	$(SILENT)if [ -e $(TARGET_DIR)/usr/local/bin/install.sh ]; then \
		cp $(TARGET_DIR)/usr/local/bin/install.sh $(RELEASE_DIR)/bin/; \
	fi
endif
#
# channellist / tuxtxt
#
	$(SILENT)cp -aR $(TARGET_DIR)/var/tuxbox/config/* $(RELEASE_DIR)/var/tuxbox/config
#
# copy root_neutrino
#
	$(SILENT)cp -aR $(SKEL_ROOT)/root_neutrino/boot/* $(RELEASE_DIR)/boot
	$(SILENT)cp -aR $(SKEL_ROOT)/root_neutrino/etc/* $(RELEASE_DIR)/etc
ifeq ($(FLAVOUR), $(filter $(FLAVOUR), neutrino-ddt, neutrino-ddt + plugins))
	$(SILENT)cp -aR $(SKEL_ROOT)/root_neutrino/var_ddt/* $(RELEASE_DIR)/var/
endif
ifeq ($(FLAVOUR), $(filter $(FLAVOUR), neutrino-hd2, neutrino-hd2 + plugins))
	$(SILENT)cp -aR $(SKEL_ROOT)/root_neutrino/var_hd2/* $(RELEASE_DIR)/var/
endif
ifeq ($(FLAVOUR), $(filter $(FLAVOUR), neutrino-tangos, neutrino-tangos + plugins))
	$(SILENT)cp -aR $(SKEL_ROOT)/root_neutrino/var_tangos/* $(RELEASE_DIR)/var/
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), hs8200 spark7162 cuberevo cuberevo_mini cuberevo_mini2 cuberevo_3000hd))
	$(SILENT)rm -f $(RELEASE_DIR)/var/tuxbox/config/cables.xml
	$(SILENT)rm -f $(RELEASE_DIR)/var/tuxbox/config/terrestrial.xml
endif
#
# iso-codes
#
	$(SILENT)[ -e $(TARGET_DIR)/usr/share/iso-codes ] && cp -aR $(TARGET_DIR)/usr/share/iso-codes $(RELEASE_DIR)/usr/share/ || true
	$(SILENT)[ -e $(TARGET_DIR)/usr/share/tuxbox/iso-codes ] && cp -aR $(TARGET_DIR)/usr/share/tuxbox/iso-codes $(RELEASE_DIR)/usr/share/tuxbox/ || true
#
# httpd/icons/locale/themes
#
	$(SILENT)cp -aR $(TARGET_DIR)/usr/share/tuxbox/neutrino/* $(RELEASE_DIR)/usr/share/tuxbox/neutrino
#
# alsa
#
	$(SILENT)if [ -e $(TARGET_DIR)/usr/share/alsa ]; then \
		mkdir -p $(RELEASE_DIR)/usr/share/alsa/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/cards/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp -dp $(TARGET_DIR)/usr/share/alsa/alsa.conf $(RELEASE_DIR)/usr/share/alsa/alsa.conf; \
		cp $(TARGET_DIR)/usr/share/alsa/cards/aliases.conf $(RELEASE_DIR)/usr/share/alsa/cards/; \
		cp $(TARGET_DIR)/usr/share/alsa/pcm/default.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp $(TARGET_DIR)/usr/share/alsa/pcm/dmix.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
	fi
#
# xupnpd
#
	$(SILENT)if [ -e $(TARGET_DIR)/usr/bin/xupnpd ]; then \
		cp -aR $(TARGET_DIR)/usr/share/xupnpd $(RELEASE_DIR)/usr/share; \
		mkdir -p $(RELEASE_DIR)/usr/share/xupnpd/playlists; \
	fi
#
# mc
#
	$(SILENT)if [ -e $(TARGET_DIR)/usr/bin/mc ]; then \
		cp -aR $(TARGET_DIR)/usr/share/mc $(RELEASE_DIR)/usr/share/; \
		cp -af $(TARGET_DIR)/usr/libexec $(RELEASE_DIR)/usr/; \
	fi
#
# lua
#
	$(SILENT)if [ -d $(TARGET_DIR)/usr/share/lua ]; then \
		cp -aR $(TARGET_DIR)/usr/share/lua $(RELEASE_DIR)/usr/share; \
	fi
#
# plugins
#
	$(SILENT)if [ -d $(TARGET_DIR)/var/tuxbox/plugins ]; then \
		cp -af $(TARGET_DIR)/var/tuxbox/plugins $(RELEASE_DIR)/var/tuxbox/; \
	fi
	$(SILENT)if [ -d $(TARGET_DIR)/lib/tuxbox/plugins ]; then \
		cp -af $(TARGET_DIR)/lib/tuxbox/plugins $(RELEASE_DIR)/lib/tuxbox/; \
	fi
	$(SILENT)if [ -e $(RELEASE_DIR)/var/tuxbox/plugins/tuxwetter.so ]; then \
		cp -rf $(TARGET_DIR)/var/tuxbox/config/tuxwetter $(RELEASE_DIR)/var/tuxbox/config; \
	fi
	$(SILENT)if [ -e $(RELEASE_DIR)/var/tuxbox/plugins/sokoban.so ]; then \
		cp -rf $(TARGET_DIR)/usr/share/tuxbox/sokoban $(RELEASE_DIR)/var/tuxbox/plugins; \
		ln -s /var/tuxbox/plugins/sokoban $(RELEASE_DIR)/usr/share/tuxbox/sokoban; \
	fi
#
# shairport
#
	$(SILENT)if [ -e $(TARGET_DIR)/usr/bin/shairport ]; then \
		cp -f $(TARGET_DIR)/usr/bin/shairport $(RELEASE_DIR)/usr/bin; \
		cp -f $(TARGET_DIR)/usr/bin/mDNSPublish $(RELEASE_DIR)/usr/bin; \
		cp -f $(TARGET_DIR)/usr/bin/mDNSResponder $(RELEASE_DIR)/usr/bin; \
		cp -f $(SKEL_ROOT)/etc/init.d/shairport $(RELEASE_DIR)/etc/init.d/shairport; \
		chmod 755 $(RELEASE_DIR)/etc/init.d/shairport; \
		cp -f $(TARGET_DIR)/usr/lib/libhowl.so* $(RELEASE_DIR)/usr/lib; \
		cp -f $(TARGET_DIR)/usr/lib/libmDNSResponder.so* $(RELEASE_DIR)/usr/lib; \
	fi
#
# Neutrino HD2 Workaround Built-in Player
#
	$(SILENT)if [ -e $(TARGET_DIR)/usr/local/bin/eplayer3 ]; then \
		cp -f $(TARGET_DIR)/usr/local/bin/eplayer3 $(RELEASE_DIR)/bin/; \
		cp -f $(TARGET_DIR)/usr/local/bin/meta $(RELEASE_DIR)/bin/; \
	fi
	$(SILENT)echo " done."
#
# delete unnecessary files
#
	$(SILENT)echo -n "Cleaning up..."
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922))
	$(SILENT)rm -f $(RELEASE_DIR)/sbin/jfs_fsck
	$(SILENT)rm -f $(RELEASE_DIR)/sbin/fsck.jfs
	$(SILENT)rm -f $(RELEASE_DIR)/sbin/jfs_mkfs
	$(SILENT)rm -f $(RELEASE_DIR)/sbin/mkfs.jfs
	$(SILENT)rm -f $(RELEASE_DIR)/sbin/jfs_tune
	$(SILENT)rm -f $(RELEASE_DIR)/etc/ssl/certs/ca-certificates.crt
endif
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/lua/5.2/*.la
	$(SILENT)rm -rf $(RELEASE_DIR)/lib/autofs
	$(SILENT)rm -f $(RELEASE_DIR)/lib/libSegFault*
	$(SILENT)rm -f $(RELEASE_DIR)/lib/libstdc++.*-gdb.py
	$(SILENT)rm -f $(RELEASE_DIR)/lib/libthread_db*
	$(SILENT)rm -f $(RELEASE_DIR)/lib/libanl*
	$(SILENT)rm -rf $(RELEASE_DIR)/lib/modules/$(KERNEL_VER)
	$(SILENT)rm -rf $(RELEASE_DIR)/usr/lib/alsa
	$(SILENT)rm -rf $(RELEASE_DIR)/usr/lib/glib-2.0
	$(SILENT)rm -rf $(RELEASE_DIR)/usr/lib/cmake
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/*.py
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/libc.so
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/xml2Conf.sh
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/libfontconfig*
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/libdvdcss*
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/libdvdnav*
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/libdvdread*
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/libcurses.so
	$(SILENT)[ ! -e $(RELEASE_DIR)/usr/bin/mc ] && rm -f $(RELEASE_DIR)/usr/lib/libncurses* || true
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/libthread_db*
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/libanl*
	$(SILENT)rm -f $(RELEASE_DIR)/usr/lib/libopkg*
	$(SILENT)rm -f $(RELEASE_DIR)/bin/gitVCInfo
	$(SILENT)rm -f $(RELEASE_DIR)/bin/evtest
	$(SILENT)rm -f $(RELEASE_DIR)/bin/meta
	$(SILENT)rm -f $(RELEASE_DIR)/bin/streamproxy
	$(SILENT)rm -f $(RELEASE_DIR)/bin/libstb-hal-test
	$(SILENT)rm -f $(RELEASE_DIR)/sbin/ldconfig
	$(SILENT)rm -f $(RELEASE_DIR)/usr/bin/pic2m2v
	$(SILENT)rm -f $(RELEASE_DIR)/usr/bin/{gdbus-codegen,glib-*,gtester-report}
	$(SILENT)echo " done."
#
# The main target depends on the model.
# IMPORTANT: it is assumed that only one variable is set. Otherwise the target name won't be resolved.
#
$(D)/neutrino_release: neutrino-release-base neutrino-release-$(BOXTYPE)
	$(TUXBOX_CUSTOMIZE)
	@touch $@
#
# FOR YOUR OWN CHANGES use these folder in own_build/neutrino-hd
#
#	default for all receivers
	@echo -n "Processing own_build..."
	$(SILENT)find $(OWN_BUILD)/neutrino-hd/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} +
	@echo " done."
#	receiver specific (only if directory exists)
	@echo -n "Processing receiver specific own build for $(BOXTYPE)..."
	$(SILENT)[ -d "$(OWN_BUILD)/neutrino-hd.$(BOXTYPE)" ] && find $(OWN_BUILD)/neutrino-hd.$(BOXTYPE)/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} + || true
	$(SILENT)echo $(BOXTYPE) > $(RELEASE_DIR)/etc/model
	@echo " done."
	$(SILENT)rm  -f $(RELEASE_DIR)/for_your_own_changes
#
# nicht die feine Art, aber funktioniert ;)
#
	$(SILENT)cp -dpfr $(RELEASE_DIR)/etc $(RELEASE_DIR)/var
	$(SILENT)rm -fr $(RELEASE_DIR)/etc
	$(SILENT)ln -sf /var/etc $(RELEASE_DIR)
#
	$(SILENT)ln -s /tmp $(RELEASE_DIR)/lib/init
	$(SILENT)ln -s /tmp $(RELEASE_DIR)/var/lib/urandom
	$(SILENT)ln -s /tmp $(RELEASE_DIR)/var/lock
	$(SILENT)ln -s /tmp $(RELEASE_DIR)/var/log
	$(SILENT)ln -s /tmp $(RELEASE_DIR)/var/run
	$(SILENT)ln -s /tmp $(RELEASE_DIR)/var/tmp
#
	$(SILENT)mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/scan.jpg $(RELEASE_DIR)/var/boot/
	$(SILENT)ln -s /var/boot/scan.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
	$(SILENT)mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/mp3.jpg $(RELEASE_DIR)/var/boot/
	$(SILENT)ln -s /var/boot/mp3.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
	$(SILENT)rm -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/mp3-?.jpg
	$(SILENT)mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/shutdown.jpg $(RELEASE_DIR)/var/boot/
	$(SILENT)ln -s /var/boot/shutdown.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
	$(SILENT)mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/radiomode.jpg $(RELEASE_DIR)/var/boot/
	$(SILENT)ln -s /var/boot/radiomode.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
	$(SILENT)mv -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/start.jpg $(RELEASE_DIR)/var/boot/
	$(SILENT)ln -s /var/boot/start.jpg $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/
#
# linux-strip all
#
ifneq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug))
	@echo -n "Stripping...";
	$(SILENT)find $(RELEASE_DIR)/ -name '*' -exec $(TARGET)-strip --strip-unneeded {} &>/dev/null \;
	@echo -e " done.\n";
endif
#ifeq ($(BOXTYPE), tf7700)
#	$(MAKE) $(D)/tfinstaller
#endif

#
#
# neutrino-release-clean
#
neutrino-release-clean:
	rm -f $(D)/neutrino-release
