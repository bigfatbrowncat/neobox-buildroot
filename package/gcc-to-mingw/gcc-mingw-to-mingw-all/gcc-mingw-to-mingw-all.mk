################################################################################
#
# gcc-mingw-to-mingw-all
#
################################################################################

GCC_MINGW_TO_MINGW_ALL_VERSION = $(GCC_TO_MINGW_VERSION)
GCC_MINGW_TO_MINGW_ALL_SITE = $(GCC_TO_MINGW_SITE)
GCC_MINGW_TO_MINGW_ALL_SOURCE = $(GCC_TO_MINGW_SOURCE)

HOST_GCC_MINGW_TO_MINGW_ALL_DL_SUBDIR = gcc

HOST_GCC_MINGW_TO_MINGW_ALL_DEPENDENCIES = \
        host-gcc-to-mingw-final \
        host-binutils-mingw-to-mingw \
        host-gmp-mingw \
        host-mpc-mingw \
        host-mpfr-mingw \
	$(BR_LIBC)

HOST_GCC_MINGW_TO_MINGW_ALL_EXCLUDES = $(HOST_GCC_TO_MINGW_EXCLUDES)

MINGW_TARGET_NAME=x86_64-w64-mingw32

ifneq ($(ARCH_XTENSA_OVERLAY_FILE),)
HOST_GCC_MINGW_TO_MINGW_ALL_POST_EXTRACT_HOOKS += HOST_GCC_TO_MINGW_XTENSA_OVERLAY_EXTRACT
HOST_GCC_MINGW_TO_MINGW_ALL_EXTRA_DOWNLOADS += $(ARCH_XTENSA_OVERLAY_URL)
endif

HOST_GCC_MINGW_TO_MINGW_ALL_POST_PATCH_HOOKS += HOST_GCC_TO_MINGW_APPLY_PATCHES

# gcc doesn't support in-tree build, so we create a 'build'
# subdirectory in the gcc sources, and build from there.
HOST_GCC_MINGW_TO_MINGW_ALL_SUBDIR = build

HOST_GCC_MINGW_TO_MINGW_ALL_PRE_CONFIGURE_HOOKS += HOST_GCC_TO_MINGW_CONFIGURE_SYMLINK

# We want to always build the static variants of all the gcc libraries,
# of which libstdc++, libgomp, libmudflap...
# To do so, we can not just pass --enable-static to override the generic
# --disable-static flag, otherwise gcc fails to build some of those
# libraries, see;
#   http://lists.busybox.net/pipermail/buildroot/2013-October/080412.html
#
# So we must completely override the generic commands and provide our own.
#
define HOST_GCC_MINGW_TO_MINGW_ALL_CONFIGURE_CMDS
	(cd $(HOST_GCC_MINGW_TO_MINGW_ALL_SRCDIR) && rm -rf config.cache; \
		$(HOST_CONFIGURE_OPTS) \
		CFLAGS="$(HOST_CFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS)" \
		$(HOST_GCC_MINGW_TO_MINGW_ALL_CONF_ENV) \
		./configure \
		--prefix="$(HOST_DIR)" \
		--sysconfdir="$(HOST_DIR)/etc" \
		--enable-static --disable-shared \
		$(QUIET) $(HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS) \
	)
endef

# Languages supported by the cross-compiler
GCC_MINGW_TO_MINGW_ALL_CROSS_LANGUAGES-y = c
GCC_MINGW_TO_MINGW_ALL_CROSS_LANGUAGES-$(BR2_INSTALL_LIBSTDCPP) += c++
GCC_MINGW_TO_MINGW_ALL_CROSS_LANGUAGES-$(BR2_TOOLCHAIN_BUILDROOT_DLANG) += d
GCC_MINGW_TO_MINGW_ALL_CROSS_LANGUAGES-$(BR2_TOOLCHAIN_BUILDROOT_FORTRAN) += fortran
GCC_MINGW_TO_MINGW_ALL_CROSS_LANGUAGES = $(subst $(space),$(comma),$(GCC_MINGW_TO_MINGW_ALL_CROSS_LANGUAGES-y))


# The kernel wants to use the -m4-nofpu option to make sure that it
# doesn't use floating point operations.
ifeq ($(BR2_sh4)$(BR2_sh4eb),y)
HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += "--with-multilib-list=m4,m4-nofpu"
HOST_GCC_MINGW_TO_MINGW_ALL_GCC_TO_MINGW_LIB_DIR = $(HOST_DIR)/$(MINGW_TARGET_NAME)/lib/!m4*
else ifeq ($(BR2_sh4a)$(BR2_sh4aeb),y)
HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += "--with-multilib-list=m4a,m4a-nofpu"
HOST_GCC_MINGW_TO_MINGW_ALL_GCC_TO_MINGW_LIB_DIR = $(HOST_DIR)/$(MINGW_TARGET_NAME)/lib/!m4*
else
HOST_GCC_MINGW_TO_MINGW_ALL_GCC_TO_MINGW_LIB_DIR = $(HOST_DIR)/$(MINGW_TARGET_NAME)/lib*
endif

ifeq ($(BR2_GCC_SUPPORTS_LIBCILKRTS),y)

# libcilkrts does not support v8
#ifeq ($(BR2_sparc),y)
#HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += --disable-libcilkrts
#endif

# Pthreads are required to build libcilkrts
ifeq ($(BR2_PTHREADS_NONE),y)
HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += --disable-libcilkrts
endif

ifeq ($(BR2_STATIC_LIBS),y)
# disable libcilkrts as there is no static version
HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += --disable-libcilkrts
endif

endif # BR2_GCC_SUPPORTS_LIBCILKRTS

# Disable shared libs like libstdc++ if we do static since it confuses linking
ifeq ($(BR2_STATIC_LIBS),y)
HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += --disable-shared
else
HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += --enable-shared
endif

ifeq ($(BR2_GCC_ENABLE_OPENMP),y)
HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += --enable-libgomp
else
HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += --disable-libgomp
endif

# End with user-provided options, so that they can override previously
# defined options.
#HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS += \
#	$(call qstrip,$(BR2_EXTRA_GCC_TO_MINGW_CONFIG_OPTIONS))

HOST_GCC_MINGW_TO_MINGW_ALL_CONF_ENV = \
	$(HOST_GCC_TO_MINGW_COMMON_CONF_ENV)


HOST_GCC_MINGW_TO_MINGW_ALL_CONF_OPTS = \
	$(HOST_GCC_TO_MINGW_COMMON_CONF_OPTS) \
	--host=$(MINGW_TARGET_NAME) \
	--program-prefix=$(MINGW_TARGET_NAME)- \
	--enable-languages=$(GCC_MINGW_TO_MINGW_ALL_CROSS_LANGUAGES) \
	--with-build-time-tools=$(HOST_DIR)/$(MINGW_TARGET_NAME)/bin

HOST_GCC_MINGW_TO_MINGW_ALL_CONF_ENV += \
        MAKEINFO=missing \
        GCC_FOR_TARGET="x86_64-w64-mingw32-gcc" \
        CC="x86_64-w64-mingw32-gcc" \
        LD="x86_64-w64-mingw32-ld" \
        CXX="x86_64-w64-mingw32-g++"


HOST_GCC_MINGW_TO_MINGW_ALL_MAKE_OPTS += $(HOST_GCC_TO_MINGW_COMMON_MAKE_OPTS)

# Make sure we have 'cc'
#define HOST_GCC_MINGW_TO_MINGW_ALL_CREATE_CC_SYMLINKS
#	if [ ! -e $(HOST_DIR)/bin/$(MINGW_TARGET_NAME)-cc ]; then \
#		ln -f $(HOST_DIR)/bin/$(MINGW_TARGET_NAME)-gcc \
#			$(HOST_DIR)/bin/$(MINGW_TARGET_NAME)-cc; \
#	fi
#endef
#HOST_GCC_MINGW_TO_MINGW_ALL_POST_INSTALL_HOOKS += HOST_GCC_MINGW_TO_MINGW_ALL_CREATE_CC_SYMLINKS

#HOST_GCC_MINGW_TO_MINGW_ALL_TOOLCHAIN_WRAPPER_ARGS += $(HOST_GCC_TO_MINGW_COMMON_TOOLCHAIN_WRAPPER_ARGS)
#HOST_GCC_MINGW_TO_MINGW_ALL_POST_BUILD_HOOKS += TOOLCHAIN_WRAPPER_BUILD
#HOST_GCC_MINGW_TO_MINGW_ALL_POST_INSTALL_HOOKS += TOOLCHAIN_WRAPPER_INSTALL
# Note: this must be done after CREATE_CC_SYMLINKS, otherwise the
# -cc symlink to the wrapper is not created.
#HOST_GCC_MINGW_TO_MINGW_ALL_POST_INSTALL_HOOKS += HOST_GCC_TO_MINGW_INSTALL_WRAPPER_AND_SIMPLE_SYMLINKS

# coldfire is not working without removing these object files from libgcc.a
#ifeq ($(BR2_m68k_cf),y)
#define HOST_GCC_MINGW_TO_MINGW_ALL_M68K_LIBGCC_FIXUP
#	find $(STAGING_DIR) -name libgcc.a -print | \
#		while read t; do $(MINGW_TARGET_NAME)-ar dv "$t" _ctors.o; done
#endef
#HOST_GCC_MINGW_TO_MINGW_ALL_POST_INSTALL_HOOKS += HOST_GCC_MINGW_TO_MINGW_ALL_M68K_LIBGCC_FIXUP
#endif

# Cannot use the HOST_GCC_FINAL_USR_LIBS mechanism below, because we want
# libgcc_s to be installed in /lib and not /usr/lib.
#define HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_LIBGCC
#	-cp -dpf $(HOST_GCC_MINGW_TO_MINGW_ALL_GCC_LIB_DIR)/libgcc_s* \
#		$(STAGING_DIR)/lib/
#	-cp -dpf $(HOST_GCC_MINGW_TO_MINGW_ALL_GCC_LIB_DIR)/libgcc_s* \
#		$(TARGET_DIR)/lib/
#endef

#HOST_GCC_MINGW_TO_MINGW_ALL_POST_INSTALL_HOOKS += HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_LIBGCC

#define HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_LIBATOMIC
#	-cp -dpf $(HOST_GCC_MINGW_TO_MINGW_ALL_GCC_LIB_DIR)/libatomic* \
#		$(STAGING_DIR)/lib/
#	-cp -dpf $(HOST_GCC_MINGW_TO_MINGW_ALL_GCC_LIB_DIR)/libatomic* \
#		$(TARGET_DIR)/lib/
#endef

#HOST_GCC_MINGW_TO_MINGW_ALL_POST_INSTALL_HOOKS += HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_LIBATOMIC

# Handle the installation of libraries in /usr/lib
#HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS =

#ifeq ($(BR2_INSTALL_LIBSTDCPP),y)
#HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS += libstdc++
#endif

#ifeq ($(BR2_TOOLCHAIN_BUILDROOT_DLANG),y)
#HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS += libgdruntime libgphobos
#endif

#ifeq ($(BR2_TOOLCHAIN_BUILDROOT_FORTRAN),y)
#HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS += libgfortran
# fortran needs quadmath on x86 and x86_64
#ifeq ($(BR2_TOOLCHAIN_HAS_LIBQUADMATH),y)
#HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS += libquadmath
#endif
#endif

#ifeq ($(BR2_GCC_ENABLE_OPENMP),y)
#HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS += libgomp
#endif

#HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS += $(call qstrip,$(BR2_TOOLCHAIN_EXTRA_LIBS))

#ifneq ($(HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS),)
#define HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_STATIC_LIBS
#	for i in $(HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS) ; do \
#		cp -dpf $(HOST_GCC_MINGW_TO_MINGW_ALL_GCC_LIB_DIR)/$${i}.a \
#			$(STAGING_DIR)/usr/lib/ ; \
#	done
#endef

#ifeq ($(BR2_STATIC_LIBS),)
#define HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_SHARED_LIBS
#	for i in $(HOST_GCC_MINGW_TO_MINGW_ALL_USR_LIBS) ; do \
#		cp -dpf $(HOST_GCC_MINGW_TO_MINGW_ALL_GCC_LIB_DIR)/$${i}.dll* \
#			$(STAGING_DIR)/usr/lib/ ; \
#		cp -dpf $(HOST_GCC_MINGW_TO_MINGW_ALL_GCC_LIB_DIR)/$${i}.dll* \
#			$(TARGET_DIR)/usr/lib/ ; \
#	done
#endef
#endif

#define HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_USR_LIBS
#	mkdir -p $(TARGET_DIR)/usr/lib
#	$(HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_STATIC_LIBS)
#	$(HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_SHARED_LIBS)
#endef
#HOST_GCC_MINGW_TO_MINGW_ALL_POST_INSTALL_HOOKS += HOST_GCC_MINGW_TO_MINGW_ALL_INSTALL_USR_LIBS
#endif

# Removing strange double-prefixed artifacts
define HOST_GCC_MINGW_TO_MINGW_REMOVE_DOUBLE_PREFIXED
        rm -f $(HOST_DIR)/bin/$(MINGW_TARGET_NAME)-$(MINGW_TARGET_NAME)-*.exe
endef
HOST_GCC_MINGW_TO_MINGW_ALL_POST_INSTALL_HOOKS += HOST_GCC_MINGW_TO_MINGW_REMOVE_DOUBLE_PREFIXED



$(eval $(host-autotools-package))
