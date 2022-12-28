UFSINSTALLER_DIR=.

all:
	$(SILENT)cp $(KERNEL_DIR)/arch/sh/boot/uImage.gz $(UFSINSTALLER_DIR)/uImage.gz.org
	$(SILENT)if [ -e $(KERNEL_DIR)/arch/sh/boot/uImage ]; then \
		rm $(KERNEL_DIR)/arch/sh/boot/uImage; \
	fi
	$(SILENT)if [ -e $(UFSINSTALLER_DIR)/uImage ]; then \
		rm $(UFSINSTALLER_DIR)/uImage; \
	fi
	$(SILENT)cp $(KERNEL_DIR)/.config $(UFSINSTALLER_DIR)/.config.org
ifeq ($(BS_GCC_VER), $(filter $(BS_GCC_VER), 4.6.3 4.8.4))
	$(SILENT)cp $(UFSINSTALLER_DIR)/$(BOXTYPE)_initramfs_list $(KERNEL_DIR)/initramfs_list
else
	$(SILENT)cp $(UFSINSTALLER_DIR)/$(BOXTYPE)_initramfs_list_gcc-4.9.4 $(KERNEL_DIR)/initramfs_list
endif
	$(SILENT)sed -i 's/# CONFIG_INITRAMFS_SOURCE is not set/CONFIG_INITRAMFS_SOURCE="initramfs_list"/g' $(KERNEL_DIR)/.config
	$(SILENT)sed -i 's/CONFIG_INITRAMFS_SOURCE=""/CONFIG_INITRAMFS_SOURCE="initramfs_list"/g' $(KERNEL_DIR)/.config
	$(SILENT)if [ `grep -x -c "CONFIG_INITRAMFS_ROOT_UID=0" $(KERNEL_DIR)/.config` == 0 ]; then \
		echo "CONFIG_INITRAMFS_ROOT_UID=0" >> $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "CONFIG_INITRAMFS_ROOT_GID=0" $(KERNEL_DIR)/.config` == 0 ]; then \
		echo "CONFIG_INITRAMFS_ROOT_GID=0" >> $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "# CONFIG_RD_GZIP is not set" $(KERNEL_DIR)/.config` == 1 ]; then \
		sed -i 's/# CONFIG_RD_GZIP is not set/CONFIG_RD_GZIP=y/g' $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "CONFIG_RD_GZIP=y" $(KERNEL_DIR)/.config` == 0 ]; then \
		echo "CONFIG_RD_GZIP=y" >> $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "CONFIG_RD_BZIP2=y" $(KERNEL_DIR)/.config` == 1 ]; then \
		sed -i 's/CONFIG_RD_BZIP2=y/# CONFIG_RD_BZIP2 is not set=y/g' $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "# CONFIG_RD_BZIP2 is not set" $(KERNEL_DIR)/.config` == 0 ]; then \
		echo "# CONFIG_RD_BZIP2 is not set" >> $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "CONFIG_RD_LZMA=y" $(KERNEL_DIR)/.config` == 1 ]; then \
		sed -i 's/CONFIG_RD_LZMA=y/# CONFIG_RD_LZMA is not set/g' $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "# CONFIG_RD_LZMA is not set" $(KERNEL_DIR)/.config` == 0 ]; then \
		echo "# CONFIG_RD_LZMA is not set" >> $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "CONFIG_INITRAMFS_COMPRESSION_NONE=y" $(KERNEL_DIR)/.config` == 1 ]; then \
		sed -i 's/CONFIG_INITRAMFS_COMPRESSION_NONE=y/# CONFIG_INITRAMFS_COMPRESSION_NONE is not set/g' $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "# CONFIG_INITRAMFS_COMPRESSION_NONE is not set" $(KERNEL_DIR)/.config` == 0 ]; then \
		echo "# CONFIG_INITRAMFS_COMPRESSION_NONE is not set" >> $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "# CONFIG_INITRAMFS_COMPRESSION_GZIP is not set" $(KERNEL_DIR)/.config` == 1 ]; then \
		sed -i 's/# CONFIG_INITRAMFS_COMPRESSION_GZIP is not set/CONFIG_INITRAMFS_COMPRESSION_GZIP=y/g' $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "CONFIG_INITRAMFS_COMPRESSION_GZIP=y" $(KERNEL_DIR)/.config` == 0 ]; then \
		echo "CONFIG_INITRAMFS_COMPRESSION_GZIP=y" >> $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "CONFIG_INITRAMFS_COMPRESSION_BZIP2=y" $(KERNEL_DIR)/.config` == 1 ]; then \
		sed -i 's/CONFIG_INITRAMFS_COMPRESSION_BZIP2=y/# CONFIG_INITRAMFS_COMPRESSION_BZIP2 is not set/g' $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "# CONFIG_INITRAMFS_COMPRESSION_BZIP2 is not set" $(KERNEL_DIR)/.config` == 0 ]; then \
		echo "# CONFIG_INITRAMFS_COMPRESSION_BZIP2 is not set" >> $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "CONFIG_INITRAMFS_COMPRESSION_LZMA=y" $(KERNEL_DIR)/.config` == 1 ]; then \
		sed -i 's/CONFIG_INITRAMFS_COMPRESSION_LZMA=y/# CONFIG_INITRAMFS_COMPRESSION_LZMA is not set/g' $(KERNEL_DIR)/.config; \
	fi
	$(SILENT)if [ `grep -x -c "# CONFIG_INITRAMFS_COMPRESSION_LZMA is not set" $(KERNEL_DIR)/.config` == 0 ]; then \
		echo "# CONFIG_INITRAMFS_COMPRESSION_LZMA is not set" >> $(KERNEL_DIR)/.config; \
	fi
	@export PATH=$(HOST_DIR)/bin:$(PATH) && \
	$(MAKE) -C $(BASE_DIR) ufskernel
	$(SILENT)rm $(KERNEL_DIR)/initramfs_list
	$(SILENT)cp $(KERNEL_DIR)/.config $(UFSINSTALLER_DIR)/.config.inst
	$(SILENT)rm $(KERNEL_DIR)/.config
	$(SILENT)mv $(UFSINSTALLER_DIR)/.config.org $(KERNEL_DIR)/.config
	$(SILENT)mv $(KERNEL_DIR)/arch/sh/boot/uImage.gz $(UFSINSTALLER_DIR)/uImage
	$(SILENT)mv $(UFSINSTALLER_DIR)/uImage.gz.org $(KERNEL_DIR)/arch/sh/boot/uImage.gz

clean:
	$(SILENT)rm -f uImage
	$(SILENT)rm -f config.inst

.c.o:
	gcc -c $< -Wall


