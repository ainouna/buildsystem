#
# python helpers
#
PYTHON3_DIR         = usr/lib/python$(PYTHON3_VER_MAJOR)
PYTHON3_INCLUDE_DIR = usr/include/python$(PYTHON3_VER_MAJOR)

PYTHON3_BUILD = \
	CC="$(TARGET)-gcc" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LDSHARED="$(TARGET)-gcc -shared" \
	PYTHONPATH=$(TARGET_DIR)/$(PYTHON3_DIR)/site-packages \
	CPPFLAGS="$(TARGET_CPPFLAGS) -I$(TARGET_DIR)/$(PYTHON3_INCLUDE_DIR)" \
	$(HOST_DIR)/bin/python3 ./setup.py $(MINUS_Q) build --executable=/usr/bin/python3

PYTHON3_INSTALL = \
	CC="$(TARGET)-gcc" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LDSHARED="$(TARGET)-gcc -shared" \
	PYTHONPATH=$(TARGET_DIR)/$(PYTHON3_DIR)/site-packages \
	CPPFLAGS="$(TARGET_CPPFLAGS) -I$(TARGET_DIR)/$(PYTHON3_INCLUDE_DIR)" \
	$(HOST_DIR)/bin/python3 ./setup.py $(MINUS_Q) install --root=$(TARGET_DIR) --prefix=/usr

#
# host_python3
#
PYTHON3_VER_MAJOR = 3.10
PYTHON3_VER_MINOR = 6
PYTHON3_VER = $(PYTHON3_VER_MAJOR).$(PYTHON3_VER_MINOR)
PYTHON3_SOURCE = Python-$(PYTHON3_VER).tar.xz
HOST_PYTHON3_PATCH  = python-$(PYTHON3_VER).patch
#HOST_PYTHON3_PATCH += python-$(PYTHON3_VER)-support_64bit.patch

$(ARCHIVE)/$(PYTHON3_SOURCE):
	$(WGET) https://www.python.org/ftp/python/$(PYTHON3_VER)/$(PYTHON3_SOURCE)

$(D)/host_python3: $(ARCHIVE)/$(PYTHON3_SOURCE)
	$(START_BUILD)
	$(SILENT)if [ ! -d $(BUILD_TMP) ]; then mkdir $(BUILD_TMP); fi;
	$(REMOVE)/Python-$(PYTHON3_VER)
	$(UNTAR)/$(PYTHON3_SOURCE)
	$(CH_DIR)/Python-$(PYTHON3_VER); \
		$(call apply_patches, $(HOST_PYTHON3_PATCH)); \
		autoconf; \
		CONFIG_SITE= \
		OPT="$(HOST_CFLAGS)" \
		./configure $(SILENT_CONFIGURE) \
			--enable-optimizations \
			--without-cxx-main \
		; \
		$(MAKE) python; \
		mv python ./hostpython; \
		\
		$(MAKE) distclean; \
		./configure $(SILENT_CONFIGURE) \
			--prefix=$(HOST_DIR) \
			--sysconfdir=$(HOST_DIR)/etc \
			--without-cxx-main \
		; \
		$(MAKE) all install
#	$(REMOVE)/Python-$(PYTHON3_VER)
	$(TOUCH)

#
# python3
#
PYTHON3_PATCH  = python-$(PYTHON3_VER).patch
#PYTHON3_PATCH += python-$(PYTHON3_VER)-xcompile.patch
#PYTHON3_PATCH += python-$(PYTHON3_VER)-revert_use_of_sysconfigdata.patch
#PYTHON3_PATCH += python-$(PYTHON3_VER)-pgettext.patch

$(D)/python3: $(D)/bootstrap $(D)/host_python3 $(D)/ncurses $(D)/zlib $(D)/openssl $(D)/libffi $(D)/bzip2 $(D)/readline $(D)/sqlite $(ARCHIVE)/$(PYTHON3_SOURCE)
	$(START_BUILD)
	$(REMOVE)/Python-$(PYTHON3_VER)
	$(UNTAR)/$(PYTHON3_SOURCE)
	$(CH_DIR)/Python-$(PYTHON3_VER); \
		$(call apply_patches, $(PYTHON3_PATCH)); \
		CONFIG_SITE= \
		SETUPTOOLS_USE_DISTUTILS=stdlib \
		$(BUILDENV) \
		autoconf $(SILENT_OPT); \
		./configure $(SILENT_CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--prefix=/usr \
			--mandir=/.remove \
			--sysconfdir=/etc \
			--enable-shared \
			--with-lto \
			--enable-ipv6 \
			--with-pymalloc \
			--enable-optimizations \
			ac_sys_system=Linux \
			ac_sys_release=2 \
			ac_cv_file__dev_ptmx=no \
			ac_cv_file__dev_ptc=no \
			ac_cv_have_long_long_format=yes \
			ac_cv_no_strict_aliasing_ok=yes \
			ac_cv_pthread=yes \
			ac_cv_cxx_thread=yes \
			ac_cv_sizeof_off_t=8 \
			ac_cv_have_chflags=no \
			ac_cv_have_lchflags=no \
			ac_cv_py_format_size_t=yes \
			ac_cv_broken_sem_getvalue=no \
			HOSTPYTHON=$(HOST_DIR)/bin/python$(PYTHON3_VER_MAJOR) \
		; \
		$(MAKE) $(MAKE_OPTS) \
			PYTHON3_MODULES_INCLUDE="$(TARGET_DIR)/usr/include" \
			PYTHON3_MODULES_LIB="$(TARGET_DIR)/usr/lib" \
			PYTHON3_XCOMPILE_DEPENDENCIES_PREFIX="$(TARGET_DIR)" \
			CROSS_COMPILE_TARGET=yes \
			CROSS_COMPILE=$(TARGET) \
			MACHDEP=linux2 \
			HOSTARCH=$(TARGET) \
			CFLAGS="$(TARGET_CFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LD="$(TARGET)-gcc" \
			HOSTPYTHON=$(HOST_DIR)/bin/python$(PYTHON3_VER_MAJOR) \
			HOSTPGEN=$(HOST_DIR)/bin/pgen \
			all DESTDIR=$(TARGET_DIR) \
		; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	pwd
	ln -sf ../../libpython$(PYTHON3_VER_MAJOR).so.1.0 $(TARGET_DIR)/$(PYTHON3_DIR)/config/libpython$(PYTHON3_VER_MAJOR).so; \
	ln -sf $(TARGET_DIR)/$(PYTHON3_INCLUDE_DIR) $(TARGET_DIR)/usr/include/python
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/python-$(PYTHON3_VER_MAJOR).pc
	$(REMOVE)/Python-$(PYTHON3_VER)
	$(TOUCH)

PYTHON3_DEPS  = $(D)/host_python3
PYTHON3_DEPS += $(D)/python3
PYTHON3_DEPS += $(D)/python_twisted
PYTHON3_DEPS += $(D)/python_lxml
PYTHON3_DEPS += $(D)/python_service_identity
PYTHON3_DEPS += $(D)/python_netifaces
PYTHON3_DEPS += $(D)/python_six
ifeq ($(IMAGE), $(filter $(IMAGE), enigma2-wlandriver))
PYTHON3_DEPS += $(D)/python_wifi
endif
ifneq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), small))
# TODO: are these necessary?
PYTHON3_DEPS += $(D)/python_elementtree
PYTHON3_DEPS += $(D)/python_imaging
PYTHON3_DEPS += $(D)/python_pyusb
PYTHON3_DEPS += $(D)/python_pycrypto
PYTHON3_DEPS += $(D)/python_mechanize
PYTHON3_DEPS += $(D)/python_requests
PYTHON3_DEPS += $(D)/python_futures
PYTHON3_DEPS += $(D)/python_singledispatch
#----
PYTHON3_DEPS += $(D)/python_livestreamer
PYTHON3_DEPS += $(D)/python_livestreamersrv
endif

python3-all: $(PYTHON3_DEPS)

PHONY += python3-all
