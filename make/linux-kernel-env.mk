#
# kernel-env
#
ifeq ($(KERNEL_STM), p0209)
KERNEL_VER             = 2.6.32.46_stm24_0209
KERNEL_REVISION        = 8c676f1a85935a94de1fb103c0de1dd25ff69014
STM_KERNEL_HEADERS_VER = 2.6.32.46-47
P0209                  = p0209
endif

ifeq ($(KERNEL_STM), p0217_61)
KERNEL_VER             = 2.6.32.61_stm24_0217
KERNEL_REVISION        = b43f8252e9f72e5b205c8d622db3ac97736351fc
STM_KERNEL_HEADERS_VER = 2.6.32.46-48
P0217                  = p0217
endif

ifeq ($(KERNEL_STM), p0217)
KERNEL_VER             = 2.6.32.71_stm24_0217
KERNEL_REVISION        = 3ec500f4212f9e4b4d2537c8be5ea32ebf68c43b
STM_KERNEL_HEADERS_VER = 2.6.32.46-48
P0217                  = p0217
endif

split_version=$(subst _, ,$(1))
KERNEL_UPSTREAM    =$(word 1,$(call split_version,$(KERNEL_VER)))
KERNEL_STM        :=$(word 2,$(call split_version,$(KERNEL_VER)))
KERNEL_LABEL      :=$(word 3,$(call split_version,$(KERNEL_VER)))
KERNEL_RELEASE    :=$(subst ^0,,^$(KERNEL_LABEL))
KERNEL_STM_LABEL  :=_$(KERNEL_STM)_$(KERNEL_LABEL)
KERNEL_DIR         =$(BUILD_TMP)/linux-sh4-$(KERNEL_VER)

DEPMOD = $(HOST_DIR)/bin/depmod

