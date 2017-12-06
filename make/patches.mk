#
# patch helper
#
enigma%-patch \
neutrino%-patch \
libstb-hal%-patch:
	( cd $(SOURCE_DIR) && diff -Nur --exclude-from=$(SCRIPTS_DIR)/diff-exclude $(subst -patch,,$@).org $(subst -patch,,$@) > $(BASE_DIR)/$(subst -patch,.patch,$@) ; [ $$? -eq 1 ] )

# keeping all patches together in one file
# uncomment if needed
#

# Neutrino MP DDT
NEUTRINO_MP_DDT_PATCHES += $(PATCHES)/neutrino-mp-ddt.patch
NEUTRINO_MP_LIBSTB_DDT_PATCHES += $(PATCHES)/libstb-hal-ddt.patch

# Neutrino MP NI
NEUTRINO_MP_NI_PATCHES += $(PATCHES)/neutrino-mp-ni.patch
NEUTRINO_MP_LIBSTB_NI_PATCHES +=  $(PATCHES)/libstb-hal-ni.patch

# Neutrino MP Tango
NEUTRINO_MP_TANGOS_PATCHES += $(PATCHES)/neutrino-mp-tangos.patch
NEUTRINO_MP_LIBSTB_TANGOS_PATCHES += $(PATCHES)/libstb-hal-tangos.patch

# Neutrino HD2
NEUTRINO_HD2_PATCHES += $(PATCHES)/nhd2-exp.patch
NEUTRINO_HD2_PLUGINS_PATCHES +=

# Neutrino MP Max
NEUTRINO_LIBSTB_MAX_PATCHES += $(PATCHES)/libstb-hal-max.patch
NEUTRINO_MP_MAX_PATCHES += $(PATCHES)/neutrino-mp-max.patch
