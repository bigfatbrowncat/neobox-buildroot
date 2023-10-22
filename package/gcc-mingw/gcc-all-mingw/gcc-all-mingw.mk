################################################################################
#
# gcc-all-mingw
#
################################################################################

GCC_ALL_MINGW_VERSION = $(GCC_MINGW_VERSION)
GCC_ALL_MINGW_SITE = $(GCC_MINGW_SITE)
GCC_ALL_MINGW_SOURCE = $(GCC_MINGW_SOURCE)

# We do not have a 'gcc' package per-se; we only have two incarnations,
# gcc-initial and gcc-final. gcc-initial is just an internal step that
# users should not care about, while gcc-final is the one they shall see.
HOST_GCC_ALL_MINGW_DL_SUBDIR = gcc

HOST_GCC_ALL_MINGW_DEPENDENCIES = $(HOST_GCC_MINGW_COMMON_DEPENDENCIES)

HOST_GCC_ALL_MINGW_EXCLUDES = $(HOST_GCC_MINGW_EXCLUDES)

ifneq ($(ARCH_XTENSA_OVERLAY_FILE),)
HOST_GCC_ALL_MINGW_POST_EXTRACT_HOOKS += HOST_GCC_MINGW_XTENSA_OVERLAY_EXTRACT
HOST_GCC_ALL_MINGW_EXTRA_DOWNLOADS += $(ARCH_XTENSA_OVERLAY_URL)
endif

HOST_GCC_ALL_MINGW_POST_PATCH_HOOKS += HOST_GCC_MINGW_APPLY_PATCHES

# gcc doesn't support in-tree build, so we create a 'build'
# subdirectory in the gcc sources, and build from there.
HOST_GCC_ALL_MINGW_SUBDIR = build

HOST_GCC_ALL_MINGW_PRE_CONFIGURE_HOOKS += HOST_GCC_MINGW_CONFIGURE_SYMLINK

HOST_GCC_ALL_MINGW_CONF_OPTS = \
	$(HOST_GCC_MINGW_COMMON_CONF_OPTS) \
	--enable-languages=c,c++ \
	--disable-shared \
	$(call qstrip,$(BR2_EXTRA_GCC_CONFIG_OPTIONS))

#	--without-headers \
#	--disable-threads \
#	--with-newlib \
#	--disable-largefile \

HOST_GCC_ALL_MINGW_CONF_ENV = \
	$(HOST_GCC_MINGW_COMMON_CONF_ENV)

# Enable GCC target libs optimizations to optimize out __register_frame
# when needed for some architectures when building with glibc.
ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_107728),y)
HOST_GCC_ALL_MINGW_CONF_ENV += CFLAGS_FOR_TARGET="$(GCC_MINGW_COMMON_TARGET_CFLAGS) -O1"
HOST_GCC_ALL_MINGW_CONF_ENV += CXXFLAGS_FOR_TARGET="$(GCC_MINGW_COMMON_TARGET_CXXFLAGS) -O1"
endif

HOST_GCC_ALL_MINGW_MAKE_OPTS = $(HOST_GCC_MINGW_COMMON_MAKE_OPTS) all-gcc all-target-libgcc
HOST_GCC_ALL_MINGW_INSTALL_OPTS = install-gcc install-target-libgcc

HOST_GCC_ALL_MINGW_TOOLCHAIN_WRAPPER_ARGS += $(HOST_GCC_MINGW_COMMON_TOOLCHAIN_WRAPPER_ARGS)
HOST_GCC_ALL_MINGW_POST_BUILD_HOOKS += TOOLCHAIN_WRAPPER_BUILD
HOST_GCC_ALL_MINGW_POST_INSTALL_HOOKS += TOOLCHAIN_WRAPPER_INSTALL
HOST_GCC_ALL_MINGW_POST_INSTALL_HOOKS += HOST_GCC_MINGW_INSTALL_WRAPPER_AND_SIMPLE_SYMLINKS

$(eval $(host-autotools-package))
