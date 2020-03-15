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

# Neutrino DDT
NEUTRINO_DDT_PATCHES += $(PATCHES)/neutrino-ddt.patch
NEUTRINO_LIBSTB_DDT_PATCHES += $(PATCHES)/libstb-hal-ddt.patch

# Neutrino Tango
NEUTRINO_TANGOS_PATCHES += $(PATCHES)/neutrino-tangos.patch
NEUTRINO_LIBSTB_TANGOS_PATCHES += $(PATCHES)/libstb-hal-tangos.patch

# Neutrino HD2
NEUTRINO_HD2_PATCHES += $(PATCHES)/nhd2-exp.patch
NEUTRINO_HD2_PLUGINS_PATCHES += $(PATCHES)/nhd2-exp-plugins.patch

