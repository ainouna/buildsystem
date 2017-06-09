#
# diff helper
#
enigma2-patch \
neutrino-hd2-patch \
neutrino-mp-next-patch \
neutrino-mp-tangos-patch \
neutrino-mp-cst-next-patch \
neutrino-mp-cst-next-ni-patch \
neutrino-mp-cst-next-max-patch \
libstb-hal-next-patch \
libstb-hal-cst-next-patch :
	cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,.patch,$@) ; [ $$? -eq 1 ]

# keeping all patches together in one file
# uncomment if needed
#
# Neutrino MP Max from github
NEUTRINO_MP_LIBSTB_CST_NEXT_MAX_PATCHES +=
NEUTRINO_MP_CST_NEXT_MAX_PATCHES +=

# LIB-STB-Hal for MP CST Next / NI from github
NEUTRINO_MP_LIBSTB_CST_NEXT_PATCHES += $(PATCHES)/libstb-hal-cst-next.patch

# Neutrino MP CST Next from github
NEUTRINO_MP_CST_NEXT_PATCHES += $(PATCHES)/neutrino-mp-cst-next.patch

# Neutrino MP CST Next NI from github
NEUTRINO_MP_CST_NEXT_NI_PATCHES += $(PATCHES)/neutrino-mp-cst-next_ni.patch

# LIB-STB-Hal for MP Tango
NEUTRINO_MP_LIBSTB_CST_NEXT_TANGOS_PATCHES += $(PATCHES)/libstb-hal-cst-next.patch

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES += $(PATCHES)/neutrino-mp-tangos.patch

# Neutrino HD2
NEUTRINO_HD2_PATCHES += $(PATCHES)/nhd2-exp.patch
NEUTRINO_HD2_PLUGINS_PATCHES +=

