TFINSTALLER_DIR=.

all:
	$(SILENT)cp $(KERNEL_DIR)/arch/sh/boot/uImage.gz $(TFINSTALLER_DIR)/uImage.gz.org
	$(SILENT)if [ -e $(KERNEL_DIR)/arch/sh/boot/uImage ]; then \
		rm $(KERNEL_DIR)/arch/sh/boot/uImage; \
	fi
	$(SILENT)if [ -e $(TFINSTALLER_DIR)/uImage ]; then \
		rm $(TFINSTALLER_DIR)/uImage; \
	fi
	$(SILENT)cp $(KERNEL_DIR)/.config $(TFINSTALLER_DIR)/.config.org
ifeq ($(BS_GCC_VER), $(filter $(BS_GCC_VER), 4.6.3 4.8.4))
	$(SILENT)cp $(TFINSTALLER_DIR)/initramfs_list $(KERNEL_DIR)/initramfs_list
else
	$(SILENT)cp $(TFINSTALLER_DIR)/initramfs_list-gcc-4.9.4 $(KERNEL_DIR)/initramfs_list
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
	$(MAKE) -C $(BASE_DIR) tfkernel
	$(SILENT)rm $(KERNEL_DIR)/initramfs_list
	$(SILENT)rm $(KERNEL_DIR)/.config
	$(SILENT)mv $(TFINSTALLER_DIR)/.config.org $(KERNEL_DIR)/.config
	$(SILENT)mv $(KERNEL_DIR)/arch/sh/boot/uImage.gz $(TFINSTALLER_DIR)/uImage
	$(SILENT)mv $(TFINSTALLER_DIR)/uImage.gz.org $(KERNEL_DIR)/arch/sh/boot/uImage.gz

TFP_OBJS = io.o encode.o decode.o maketree.o maketbl.o huf.o tfpacker.o

tfpacker: $(TFP_OBJS)
	gcc -o $@ $(TFP_OBJS)

clean:
	$(SILENT)rm -f $(TFP_OBJS)
#	$(SILENT)rm -f uImage
	$(SILENT)rm -f u-boot.ftfd
	$(SILENT)rm -f tfpacker

.c.o:
	gcc -c $< -Wall

$(TFP_OBJS): ar.h

