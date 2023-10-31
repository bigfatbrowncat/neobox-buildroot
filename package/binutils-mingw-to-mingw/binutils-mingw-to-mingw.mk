################################################################################
#
# binutils-mingw-to-mingw
#
################################################################################

# Version is set when using buildroot toolchain.
# If not, we do like other packages
BINUTILS_MINGW_TO_MINGW_VERSION = $(call qstrip,$(BR2_BINUTILS_VERSION))
ifeq ($(BINUTILS_MINGW_TO_MINGW_VERSION),)
ifeq ($(BR2_arc),y)
BINUTILS_MINGW_TO_MINGW_VERSION = arc-2020.09-release
else
BINUTILS_MINGW_TO_MINGW_VERSION = 2.38
endif
endif # BINUTILS_MINGW_TO_MINGW_VERSION

ifeq ($(BINUTILS_MINGW_TO_MINGW_VERSION),arc-2020.09-release)
BINUTILS_MINGW_TO_MINGW_SITE = $(call github,foss-for-synopsys-dwc-arc-processors,binutils-gdb,$(BINUTILS_MINGW_TO_MINGW_VERSION))
BINUTILS_MINGW_TO_MINGW_SOURCE = binutils-gdb-$(BINUTILS_MINGW_TO_MINGW_VERSION).tar.gz
BINUTILS_MINGW_TO_MINGW_FROM_GIT = y
endif

BINUTILS_MINGW_TO_MINGW_SITE ?= $(BR2_GNU_MIRROR)/binutils
BINUTILS_MINGW_TO_MINGW_SOURCE ?= binutils-$(BINUTILS_MINGW_TO_MINGW_VERSION).tar.xz
BINUTILS_MINGW_TO_MINGW_EXTRA_CONFIG_OPTIONS = $(call qstrip,$(BR2_BINUTILS_EXTRA_CONFIG_OPTIONS))
BINUTILS_MINGW_TO_MINGW_INSTALL_STAGING = YES
BINUTILS_MINGW_TO_MINGW_DEPENDENCIES = zlib $(TARGET_NLS_DEPENDENCIES)
BINUTILS_MINGW_TO_MINGW_MAKE_OPTS = LIBS=$(TARGET_NLS_LIBS)
BINUTILS_MINGW_TO_MINGW_LICENSE = GPL-3.0+, libiberty LGPL-2.1+
BINUTILS_MINGW_TO_MINGW_LICENSE_FILES = COPYING3 COPYING.LIB
BINUTILS_MINGW_TO_MINGW_CPE_ID_VENDOR = gnu

HOST_BINUTILS_MINGW_TO_MINGW_DEPENDENCIES = host-gcc-to-mingw-final

MINGW_TARGET_NAME=x86_64-w64-mingw32

ifeq ($(BINUTILS_MINGW_TO_MINGW_FROM_GIT),y)
BINUTILS_MINGW_TO_MINGW_DEPENDENCIES += host-flex host-bison
HOST_BINUTILS_MINGW_TO_MINGW_DEPENDENCIES += host-flex host-bison
endif

# When binutils sources are fetched from the binutils-gdb repository,
# they also contain the gdb sources, but gdb shouldn't be built, so we
# disable it.
#BINUTILS_MINGW_TO_MINGW_DISABLE_GDB_CONF_OPTS = \
#	--disable-sim \
#	--disable-gdb

# We need to specify host & target to avoid breaking ARM EABI
#BINUTILS_MINGW_TO_MINGW_CONF_OPTS = \
#	--host=x86_64-w64-mingw32 \
#	--target=$(GNU_TARGET_NAME) \
#	--disable-multilib \
#	--disable-werror \
#	--enable-install-libiberty \
#	--enable-build-warnings=no \
#	--disable-gprofng \
#	--with-sysroot=$(STAGING_DIR) \
#	--prefix="$(HOST_DIR)/../mingw-prefix" \
#	$(BINUTILS_MINGW_TO_MINGW_DISABLE_GDB_CO/NF_OPTS) \
#	$(BINUTILS_MINGW_TO_MINGW_EXTRA_CONFIG_OPTIONS)

#ifeq ($(BR2_STATIC_LIBS),y)
#BINUTILS_MINGW_TO_MINGW_CONF_OPTS += --disable-plugins
#endif

# Don't build documentation. It takes up extra space / build time,
# and sometimes needs specific makeinfo versions to work
#BINUTILS_MINGW_TO_MINGW_CONF_ENV += MAKEINFO=true
#BINUTILS_MINGW_TO_MINGW_MAKE_OPTS += MAKEINFO=true
#BINUTILS_MINGW_TO_MINGW_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) MAKEINFO=true install
HOST_BINUTILS_MINGW_TO_MINGW_CONF_ENV += MAKEINFO=true
HOST_BINUTILS_MINGW_TO_MINGW_MAKE_OPTS += MAKEINFO=true
HOST_BINUTILS_MINGW_TO_MINGW_INSTALL_OPTS += MAKEINFO=true install

# Workaround a build issue with -Os for ARM Cortex-M cpus.
# (Binutils 2.25.1 and 2.26.1)
# https://sourceware.org/bugzilla/show_bug.cgi?id=20552
#ifeq ($(BR2_ARM_CPU_ARMV7M)$(BR2_OPTIMIZE_S),yy)
#BINUTILS_MINGW_TO_MINGW_CONF_ENV += CFLAGS="$(TARGET_CFLAGS) -O2"
#endif

#BINUTILS_MINGW_TO_MINGW_CONF_ENV += CC="x86_64-w64-mingw32-gcc"
HOST_BINUTILS_MINGW_TO_MINGW_CONF_ENV += \
	CC="$(MINGW_TARGET_NAME)-gcc" \
	CXX="$(MINGW_TARGET_NAME)-g++" \
	LD="$(MINGW_TARGET_NAME)-ld"
# \
#	CFLAGS="-DATTRIBUTE_RETURNS_NONNULL -D_CRTIMP" \
#	CXXFLAGS="-DATTRIBUTE_RETURNS_NONNULL -D_CRTIMP"

# "host" binutils should actually be "cross"
# We just keep the convention of "host utility" for now
HOST_BINUTILS_MINGW_TO_MINGW_CONF_OPTS = \
	--host=$(MINGW_TARGET_NAME) \
	--target=$(MINGW_TARGET_NAME) \
	--program-prefix=$(MINGW_TARGET_NAME)- \
	--disable-multilib \
	--disable-werror \
	--disable-shared \
	--enable-static \
	--enable-poison-system-directories \
	--without-debuginfod \
	--disable-plugins \
	--disable-lto \
	--without-libiberty \
	--disable-pthreads \
	$(BINUTILS_MINGW_TO_MINGW_DISABLE_GDB_CONF_OPTS) \
	$(BINUTILS_MINGW_TO_MINGW_EXTRA_CONFIG_OPTIONS)

#	--prefix="$(HOST_DIR)/mingw-prefix" \
#	--with-sysroot=$(TARGET_DIR)/../../toolchain/target \
#	--disable-nls \
#	--build=$(GNU_HOST_NAME) \


# Hardlinks between binaries in different directories cause a problem
# with rpath fixup, so we de-hardlink those binaries, and replace them
# with copies instead.
BINUTILS_MINGW_TO_MINGW_TOOLS = ar as ld ld.bfd nm objcopy objdump ranlib readelf strip
define HOST_BINUTILS_TO_MINGW_FIXUP_HARDLINKS
        $(foreach tool,$(BINUTILS_MINGW_TO_MINGW_TOOLS),\
                rm -f $(HOST_DIR)/$(MINGW_TARGET_NAME)/bin/$(tool) && \
                cp -a $(HOST_DIR)/bin/$(MINGW_TARGET_NAME)-$(tool) \
                        $(HOST_DIR)/$(MINGW_TARGET_NAME)/bin/$(tool) && \
                rm -f $(HOST_DIR)/bin/$(tool) \
        )
endef
HOST_BINUTILS_TO_MINGW_POST_INSTALL_HOOKS += HOST_BINUTILS_TO_MINGW_FIXUP_HARDLINKS


ifeq ($(BR2_BINUTILS_GPROFNG),y)
HOST_BINUTILS_MINGW_TO_MINGW_DEPENDENCIES += host-bison
HOST_BINUTILS_MINGW_TO_MINGW_CONF_OPTS += --enable-gprofng
else
HOST_BINUTILS_MINGW_TO_MINGW_CONF_OPTS += --disable-gprofng
endif

define HOST_BINUTILS_MINGW_TO_MINGW_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR)/mingw-prefix install
endef

#$(eval $(autotools-package))
$(eval $(host-autotools-package))
