################################################################################
#
# Common variables for the gcc-all-mingw packages.
#
################################################################################

#
# Version, site and source
#

GCC_MINGW_VERSION = $(call qstrip,$(BR2_GCC_VERSION))

ifeq ($(BR2_GCC_VERSION_ARC),y)
GCC_MINGW_SITE = $(call github,foss-for-synopsys-dwc-arc-processors,gcc,$(GCC_MINGW_VERSION))
GCC_MINGW_SOURCE = gcc-$(GCC_MINGW_VERSION).tar.gz
else
GCC_MINGW_SITE = $(BR2_GNU_MIRROR:/=)/gcc/gcc-$(GCC_MINGW_VERSION)
GCC_MINGW_SOURCE = gcc-$(GCC_MINGW_VERSION).tar.xz
endif

#
# Xtensa special hook
#
define HOST_GCC_MINGW_XTENSA_OVERLAY_EXTRACT
	$(call arch-xtensa-overlay-extract,$(@D),gcc)
endef

#
# Apply patches
#

# gcc is a special package, not named gcc, but gcc-initial and
# gcc-final, but patches are nonetheless stored in package/gcc in the
# tree, and potentially in BR2_GLOBAL_PATCH_DIR directories as well.
define HOST_GCC_MINGW_APPLY_PATCHES
	for patchdir in \
	    package/gcc-mingw/$(GCC_MINGW_VERSION) \
	    $(addsuffix /gcc-mingw/$(GCC_MINGW_VERSION),$(call qstrip,$(BR2_GLOBAL_PATCH_DIR))) \
	    $(addsuffix /gcc,$(call qstrip,$(BR2_GLOBAL_PATCH_DIR))) ; do \
		if test -d $${patchdir}; then \
			$(APPLY_PATCHES) $(@D) $${patchdir} \*.patch || exit 1; \
		fi; \
	done
	$(HOST_GCC_MINGW_APPLY_POWERPC_PATCH)
endef

HOST_GCC_MINGW_EXCLUDES = \
	libjava/* libgo/*

#
# Create 'build' directory and configure symlink
#

define HOST_GCC_MINGW_CONFIGURE_SYMLINK
	mkdir -p $(@D)/build
	ln -sf ../configure $(@D)/build/configure
endef

#
# Common configuration options
#

HOST_GCC_MINGW_COMMON_DEPENDENCIES = \
	host-gcc-to-mingw-final \
	host-binutils-mingw \
	host-gmp-mingw \
	host-mpc-mingw \
	host-mpfr-mingw \
	$(if $(BR2_BINFMT_FLAT),host-elf2flt)

#	host-gcc-final \

HOST_GCC_MINGW_COMMON_CONF_OPTS = \
        --host=x86_64-w64-mingw32 \
	--enable-static --disable-shared \
        --build=${GNU_HOST_NAME} \
	--target=$(GNU_TARGET_NAME) \
	--with-sysroot=$(STAGING_DIR) \
	--enable-__cxa_atexit \
	--with-gnu-ld \
	--disable-libssp \
	--disable-multilib \
	--disable-decimal-float \
	--enable-plugins \
	--enable-lto \
	--with-gmp=$(HOST_DIR) \
	--with-mpc=$(HOST_DIR) \
	--with-mpfr=$(HOST_DIR) \
	--with-pkgversion="Buildroot $(BR2_VERSION_FULL)" \
	--with-bugurl="http://bugs.buildroot.net/" \
	--without-zstd

#	--with-gmp-lib=/home/user/projects/neobox-base/buildroot/output/gcw0/per-package/host-gcc-initial-mingw/host/lib/libgmp.a \
#	--with-mpc-lib=/home/user/projects/neobox-base/buildroot/output/gcw0/per-package/host-gcc-initial-mingw/host/lib/libmpc.a \
#	--with-mpfr-lib=/home/user/projects/neobox-base/buildroot/output/gcw0/per-package/host-gcc-initial-mingw/host/lib/libmpfr.a \


ifeq ($(BR2_REPRODUCIBLE),y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-debug-prefix-map=$(BASE_DIR)=buildroot
endif

# Don't build documentation. It takes up extra space / build time,
# and sometimes needs specific makeinfo versions to work
HOST_GCC_MINGW_COMMON_CONF_ENV = \
	MAKEINFO=missing \
	GCC_FOR_TARGET="x86_64-w64-mingw32-gcc" \
	CC="x86_64-w64-mingw32-gcc" \
	LD="x86_64-w64-mingw32-ld" \
	CXX="x86_64-w64-mingw32-g++"
#\
#	CROSS_COMPILE="$(GNU_TARGET_NAME)-"

GCC_MINGW_COMMON_TARGET_CFLAGS = $(TARGET_CFLAGS)
GCC_MINGW_COMMON_TARGET_CXXFLAGS = $(TARGET_CXXFLAGS)

# used to fix ../../../../libsanitizer/libbacktrace/../../libbacktrace/elf.c:772:21: error: 'st.st_mode' may be used uninitialized in this function [-Werror=maybe-uninitialized]
ifeq ($(BR2_ENABLE_DEBUG),y)
GCC_MINGW_COMMON_TARGET_CFLAGS += -Wno-error
endif

# Make sure libgcc & libstdc++ always get built with -matomic on ARC700
ifeq ($(GCC_MINGW_TARGET_CPU):$(BR2_ARC_ATOMIC_EXT),arc700:y)
GCC_MINGW_COMMON_TARGET_CFLAGS += -matomic
GCC_MINGW_COMMON_TARGET_CXXFLAGS += -matomic
endif

# Propagate options used for target software building to GCC target libs
HOST_GCC_MINGW_COMMON_CONF_ENV += CFLAGS_FOR_TARGET="$(GCC_MINGW_COMMON_TARGET_CFLAGS)"
HOST_GCC_MINGW_COMMON_CONF_ENV += CXXFLAGS_FOR_TARGET="$(GCC_MINGW_COMMON_TARGET_CXXFLAGS)"
HOST_GCC_MINGW_COMMON_CONF_ENV += AR_FOR_TARGET=gcc-ar NM_FOR_TARGET=gcc-nm RANLIB_FOR_TARGET=gcc-ranlib

# libitm needs sparc V9+
ifeq ($(BR2_sparc_v8)$(BR2_sparc_leon3),y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --disable-libitm
endif

# libmpx uses secure_getenv and struct _libc_fpstate not present in musl
ifeq ($(BR2_TOOLCHAIN_BUILDROOT_MUSL)$(BR2_TOOLCHAIN_GCC_AT_LEAST_6),yy)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --disable-libmpx
endif

# quadmath support requires wchar
ifeq ($(BR2_USE_WCHAR)$(BR2_TOOLCHAIN_HAS_LIBQUADMATH),yy)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --enable-libquadmath --enable-libquadmath-support
else
HOST_GCC_MINGW_COMMON_CONF_OPTS += --disable-libquadmath --disable-libquadmath-support
endif

# libsanitizer requires wordexp, not in default uClibc config. Also
# doesn't build properly with musl.
ifeq ($(BR2_TOOLCHAIN_BUILDROOT_UCLIBC)$(BR2_TOOLCHAIN_BUILDROOT_MUSL),y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --disable-libsanitizer
endif

# libsanitizer is broken for SPARC
# https://bugs.busybox.net/show_bug.cgi?id=7951
ifeq ($(BR2_sparc)$(BR2_sparc64),y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --disable-libsanitizer
endif

# libsanitizer is available for mips64{el} since gcc 12 but fail to build
# with n32 ABI due to struct stat64 definition clash due to mixing
# kernel and user headers.
ifeq ($(BR2_mips64)$(BR2_mips64el):$(BR2_MIPS_NABI32),y:y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --disable-libsanitizer
endif

# libsanitizer bundled in gcc 12 fails to build for mips32 due to
# mixing kernel and user struct stat.
ifeq ($(BR2_mips)$(BR2_mipsel):$(BR2_TOOLCHAIN_GCC_AT_LEAST_12),y:y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --disable-libsanitizer
endif

# The logic in libbacktrace/configure.ac to detect if __sync builtins
# are available assumes they are as soon as target_subdir is not
# empty, i.e when cross-compiling. However, some platforms do not have
# __sync builtins, so help the configure script a bit.
ifeq ($(BR2_TOOLCHAIN_HAS_SYNC_4),)
HOST_GCC_MINGW_COMMON_CONF_ENV += target_configargs="libbacktrace_cv_sys_sync=no"
endif

# TLS support is not needed on uClibc/no-thread and
# uClibc/linux-threads, otherwise, for all other situations (glibc,
# musl and uClibc/NPTL), we need it.
ifeq ($(BR2_TOOLCHAIN_BUILDROOT_UCLIBC)$(BR2_PTHREADS)$(BR2_PTHREADS_NONE),yy)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --disable-tls
else
HOST_GCC_MINGW_COMMON_CONF_OPTS += --enable-tls
endif

ifeq ($(BR2_PTHREADS_NONE),y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += \
	--disable-threads \
	--disable-libitm \
	--disable-libatomic
else
HOST_GCC_MINGW_COMMON_CONF_OPTS += --enable-threads
endif

# gcc 5 doesn't need cloog any more, see
# https://gcc.gnu.org/gcc-5/changes.html and we don't support graphite
# on GCC 4.9.x, so only isl is needed.
ifeq ($(BR2_GCC_ENABLE_GRAPHITE),y)
HOST_GCC_MINGW_COMMON_DEPENDENCIES += host-isl
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-isl=$(HOST_DIR)
else
HOST_GCC_MINGW_COMMON_CONF_OPTS += --without-isl --without-cloog
endif

ifeq ($(BR2_arc),y)
HOST_GCC_MINGW_COMMON_DEPENDENCIES += host-flex host-bison
endif

ifeq ($(BR2_SOFT_FLOAT),y)
# only mips*-*-*, arm*-*-* and sparc*-*-* accept --with-float
# powerpc seems to be needing it as well
ifeq ($(BR2_arm)$(BR2_armeb)$(BR2_mips)$(BR2_mipsel)$(BR2_mips64)$(BR2_mips64el)$(BR2_powerpc)$(BR2_sparc),y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-float=soft
endif
endif

# Determine arch/tune/abi/cpu options
ifneq ($(GCC_TARGET_ARCH),)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-arch="$(GCC_MINGW_TARGET_ARCH)"
endif
ifneq ($(GCC_TARGET_ABI),)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-abi="$(GCC_MINGW_TARGET_ABI)"
endif
ifeq ($(BR2_TOOLCHAIN_HAS_MNAN_OPTION),y)
ifneq ($(GCC_TARGET_NAN),)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-nan="$(GCC_MINGW_TARGET_NAN)"
endif
endif
ifneq ($(GCC_TARGET_FP32_MODE),)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-fp-32="$(GCC_MINGW_TARGET_FP32_MODE)"
endif
ifneq ($(GCC_TARGET_CPU),)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-cpu=$(GCC_MINGW_TARGET_CPU)
endif

ifneq ($(GCC_MINGW_TARGET_FPU),)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-fpu=$(GCC_MINGW_TARGET_FPU)
endif

ifneq ($(GCC_MINGW_TARGET_FLOAT_ABI),)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-float=$(GCC_MINGW_TARGET_FLOAT_ABI)
endif

ifneq ($(GCC_MINGW_TARGET_MODE),)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --with-mode=$(GCC_MINGW_TARGET_MODE)
endif

# Enable proper double/long double for SPE ABI
ifeq ($(BR2_powerpc_SPE),y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += \
	--enable-obsolete \
	--enable-e500_double \
	--with-long-double-128
endif

# Set default to Secure-PLT to prevent run-time
# generation of PLT stubs (supports RELRO and
# SELinux non-exemem capabilities)
ifeq ($(BR2_powerpc)$(BR2_powerpc64),y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += --enable-secureplt
endif

# PowerPC64 big endian by default uses the elfv1 ABI, and PowerPC 64
# little endian by default uses the elfv2 ABI. However, musl has
# decided to use the elfv2 ABI for both, so we force the elfv2 ABI for
# Power64 big endian when the selected C library is musl.
ifeq ($(BR2_TOOLCHAIN_USES_MUSL)$(BR2_powerpc64),yy)
HOST_GCC_MINGW_COMMON_CONF_OPTS += \
	--with-abi=elfv2 \
	--without-long-double-128
endif

# Since glibc >= 2.26, poerpc64le requires double/long double which
# requires at least gcc 6.2.
# See sysdeps/powerpc/powerpc64le/configure.ac
ifeq ($(BR2_TOOLCHAIN_USES_GLIBC)$(BR2_TOOLCHAIN_GCC_AT_LEAST_6)$(BR2_powerpc64le),yyy)
HOST_GCC_MINGW_COMMON_CONF_OPTS += \
	--with-long-double-128
endif

ifeq ($(BR2_s390x),y)
HOST_GCC_MINGW_COMMON_CONF_OPTS += \
	--with-long-double-128
endif

HOST_GCC_MINGW_COMMON_TOOLCHAIN_WRAPPER_ARGS += -DBR_CROSS_PATH_SUFFIX='".br_real"'

# For gcc-initial, we need to tell gcc that the C library will be
# providing the ssp support, as it can't guess it since the C library
# hasn't been built yet.
#
# For gcc-final, the gcc logic to detect whether SSP support is
# available or not in the C library is not working properly for
# uClibc, so let's be explicit as well.
HOST_GCC_MINGW_COMMON_MAKE_OPTS = \
	gcc_cv_libc_provides_ssp=$(if $(BR2_TOOLCHAIN_HAS_SSP),yes,no)

ifeq ($(BR2_CCACHE),y)
HOST_GCC_MINGW_COMMON_CCACHE_HASH_FILES += $($(PKG)_DL_DIR)/$(GCC_MINGW_SOURCE)

# Cfr. PATCH_BASE_DIRS in .stamp_patched, but we catch both versioned
# and unversioned patches unconditionally. Moreover, to facilitate the
# addition of gcc patches in BR2_GLOBAL_PATCH_DIR, we allow them to be
# stored in a sub-directory called 'gcc' even if it's not technically
# the name of the package.
HOST_GCC_MINGW_COMMON_CCACHE_HASH_FILES += \
	$(sort $(wildcard \
		package/gcc-mingw/$(GCC_VERSION)/*.patch \
		$(addsuffix /$($(PKG)_RAWNAME)/$(GCC_VERSION)/*.patch,$(call qstrip,$(BR2_GLOBAL_PATCH_DIR))) \
		$(addsuffix /$($(PKG)_RAWNAME)/*.patch,$(call qstrip,$(BR2_GLOBAL_PATCH_DIR))) \
		$(addsuffix /gcc-mingw/$(GCC_VERSION)/*.patch,$(call qstrip,$(BR2_GLOBAL_PATCH_DIR))) \
		$(addsuffix /gcc-mingw/*.patch,$(call qstrip,$(BR2_GLOBAL_PATCH_DIR)))))
ifeq ($(BR2_xtensa),y)
HOST_GCC_MINGW_COMMON_CCACHE_HASH_FILES += $(ARCH_XTENSA_OVERLAY_FILE)
endif

# _CONF_OPTS contains some references to the absolute path of $(HOST_DIR)
# and a reference to the Buildroot git revision (BR2_VERSION_FULL),
# so substitute those away.
HOST_GCC_MINGW_COMMON_TOOLCHAIN_WRAPPER_ARGS += -DBR_CCACHE_HASH=\"`\
	printf '%s\n' $(subst $(HOST_DIR),@HOST_DIR@,\
		$(subst --with-pkgversion="Buildroot $(BR2_VERSION_FULL)",,$($(PKG)_CONF_OPTS))) \
		| sha256sum - $(HOST_GCC_MINGW_COMMON_CCACHE_HASH_FILES) \
		| cut -c -64 | tr -d '\n'`\"
endif # BR2_CCACHE

# The LTO support in gcc creates wrappers for ar, ranlib and nm which load
# the lto plugin. These wrappers are called *-gcc-ar, *-gcc-ranlib, and
# *-gcc-nm and should be used instead of the real programs when -flto is
# used. However, we should not add the toolchain wrapper for them, and they
# match the *cc-* pattern. Therefore, an additional case is added for *-ar,
# *-ranlib and *-nm.
# According to gfortran manpage, it supports all options supported by gcc, so
# add gfortran to the list of the program called via the Buildroot wrapper.
# Avoid that a .br_real is symlinked a second time.
# Also create <arch>-linux-<tool> symlinks.
#define HOST_GCC_MINGW_INSTALL_WRAPPER_AND_SIMPLE_SYMLINKS
#	$(Q)cd $(HOST_DIR)/bin; \
#	for i in $(GNU_TARGET_NAME)-*; do \
#		case "$$i" in \
#		*.br_real) \
#			;; \
#		*-ar|*-ranlib|*-nm) \
#			ln -snf $$i $(ARCH)-linux$${i##$(GNU_TARGET_NAME)}; \
#			;; \
#		*cc|*cc-*|*++|*++-*|*cpp|*-gfortran|*-gdc) \
#			rm -f $$i.br_real; \
#			mv $$i $$i.br_real; \
#			ln -sf toolchain-wrapper $$i; \
#			ln -sf toolchain-wrapper $(ARCH)-linux$${i##$(GNU_TARGET_NAME)}; \
#			ln -snf $$i.br_real $(ARCH)-linux$${i##$(GNU_TARGET_NAME)}.br_real; \
#			;; \
#		*) \
#			ln -snf $$i $(ARCH)-linux$${i##$(GNU_TARGET_NAME)}; \
#			;; \
#		esac; \
#	done
#
#endef

include $(sort $(wildcard package/gcc-mingw/*/*.mk))
